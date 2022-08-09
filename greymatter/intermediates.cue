package examples

import (
	greymatter "greymatter.io/api"
	rbac "envoyproxy.io/extensions/filters/http/rbac/v3"
	ratelimit "envoyproxy.io/extensions/filters/network/ratelimit/v3"
	jwt_authn "envoyproxy.io/extensions/filters/http/jwt_authn/v3"
	fault "envoyproxy.io/extensions/filters/http/fault/v3"
	ext_authz "envoyproxy.io/extensions/filters/http/ext_authz/v3"
	ext_authz_tcp "envoyproxy.io/extensions/filters/network/ext_authz/v3"
)

/////////////////////////////////////////////////////////////
// "Functions" for Grey Matter config objects with defaults
// representing an ingress to a local service. Override-able.
/////////////////////////////////////////////////////////////

#domain: greymatter.#Domain & {
	_force_https: bool | *false
	domain_key:   string
	name:         string | *"*"
	port:         int | *defaults.ports.default_ingress
	zone_key:     mesh.spec.zone
	force_https:  _force_https
	if _force_https == true {
		ssl_config: greymatter.#SSLConfig & {
			protocols: [ "TLSv1_2"]
			trust_file: "/etc/proxy/tls/sidecar/ca.crt"
			cert_key_pairs: [
				greymatter.#CertKeyPathPair & {
					certificate_path: "/etc/proxy/tls/sidecar/server.crt"
					key_path:         "/etc/proxy/tls/sidecar/server.key"
				},
			]
		}
	}
}

#listener: greymatter.#Listener & {
	_tcp_upstream?:              string        // for TCP listeners, you can just specify the upstream cluster
	_is_ingress:                 bool | *false // specifiy if this listener is for ingress which will active default HTTP filters
	_gm_observables_topic:       string        // unique topic name for observable audit collection
	_spire_self:                 string        // can specify current identity - defaults to "edge"
	_spire_other:                string        // can specify an allowable downstream identity - defaults to "edge"
	_enable_rbac:                bool | *false
	_enable_fault_injection:     bool | *false
	_enable_oidc_authentication: bool | *false
	_enable_inheaders:           bool | *false
	_enable_impersonation:       bool | *false
	_oidc_endpoint:              string
	_oidc_service_url:           string
	_oidc_provider:              string
	_oidc_client_id:             string
	_oidc_client_secret:         string
	_oidc_cookie_domain:         string
	_oidc_realm:                 string
	_enable_tcp_rate_limit:      bool | *false // You must include a service->rate limiter service cluster. HTTP/2
	_enable_ext_authz:           bool | *false // you must create a service->ext authz service cluster. HTTP/2 only if auth server is grpc

	listener_key: string
	name:         listener_key
	ip:           string | *"0.0.0.0"
	port:         int | *defaults.ports.default_ingress
	domain_keys:  [...string] | *[listener_key]

	if _tcp_upstream != _|_ {
		active_network_filters: [
			if _enable_ext_authz {
				"envoy.ext_authz"
			},
			if _enable_tcp_rate_limit {
				"envoy.rate_limit"
			},
			"envoy.tcp_proxy",
		]
		network_filters: {
			if _enable_tcp_rate_limit {
				envoy_rate_limit: #envoy_tcp_rate_limit
			}

			if _enable_ext_authz {
				envoy_ext_authz: #envoy_tcp_ext_authz
			}

			// Needs to be last in filter chain
			envoy_tcp_proxy: {
				cluster:     _tcp_upstream // NB: contrary to the docs, this points at a cluster *name*, not a cluster_key
				stat_prefix: _tcp_upstream
			}
		}
	}

	// if there isn't a tcp cluster, then assume http filters, and provide the usual defaults
	if _tcp_upstream == _|_ && _is_ingress == true {
		active_http_filters: [
			if _enable_fault_injection {
				"envoy.fault"
			},
			if _enable_inheaders {
				"gm.inheaders"
			},
			if _enable_impersonation {
				"gm.acl"
			},
			if _enable_oidc_authentication {
				"gm.oidc-authentication"
			},
			if _enable_oidc_authentication {
				"gm.ensure-variables"
			},
			if _enable_oidc_authentication {
				"gm.oidc-validation"
			},
			"gm.observables",
			if _enable_oidc_authentication {
				"envoy.jwt_authn"
			},
			if _enable_ext_authz {
				"envoy.ext_authz"
			},
			if _enable_rbac {
				"envoy.rbac"
			},
			"gm.metrics",
			...string,
		]
		http_filters: {
			gm_metrics: {
				metrics_host:                               "0.0.0.0"
				metrics_port:                               defaults.ports.metrics
				metrics_dashboard_uri_path:                 "/metrics"
				metrics_prometheus_uri_path:                "/prometheus"
				metrics_ring_buffer_size:                   4096
				prometheus_system_metrics_interval_seconds: 15
				metrics_key_function:                       "depth"
				metrics_key_depth:                          string | *"1"
				metrics_receiver: {
					redis_connection_string: string | *"redis://127.0.0.1:\(defaults.ports.redis_ingress)"
					push_interval_seconds:   10
				}
			}
			gm_observables: {
				topic: _gm_observables_topic
			}
			if _enable_oidc_authentication {
				"gm_oidc-authentication": #oidc_authentication & {
					serviceUrl:   _oidc_service_url
					provider:     _oidc_provider
					clientId:     _oidc_client_id
					clientSecret: _oidc_client_secret
					accessToken: {
						cookieOptions: {
							domain: _oidc_cookie_domain
						}
					}
					idToken: {
						cookieOptions: {
							domain: _oidc_cookie_domain
						}
					}
					tokenRefresh: {
						endpoint: _oidc_endpoint
						realm:    _oidc_realm
					}
				}
				"gm_ensure-variables": #ensure_variables_filter
				"gm_oidc-validation": {
					provider: _oidc_provider
					enforce:  bool | *false
					if enforce {
						enforceResponseCode: int32 | *403
					}
					accessToken: {
						key:      "access_token"
						location: *"cookie" | _
						if location == "metadata" {
							metadataFilter: string
						}
					}
					userInfo: {
						location: *"header" | _
						// USER_DN header is currently required for observables
						// application to show user audit data
						key: "USER_DN"
						claims: ["name"]
					}
					TLSConfig?: {
						useTLS:             bool | *false
						certPath:           string | *""
						keyPath:            string | *""
						caPath:             string | *""
						insecureSkipVerify: bool | *false
					}
				}
				"envoy_jwt_authn": #envoy_jwt_authn & {
					providers: defaults.edge.oidc.jwt_authn_provider
				}
			}
			if _enable_rbac {
				envoy_rbac: #envoy_rbac_filter
			}
			if _enable_fault_injection {
				envoy_fault: #envoy_fault_injection
			}
			if _enable_inheaders {
				gm_inheaders: debug: bool | *false
			}
			if _enable_impersonation {
				gm_impersonation: {
					servers:       string | *""
					caseSensitive: bool | *false
				}
			}
			if _enable_ext_authz {
				envoy_ext_authz: #envoy_ext_authz
			}
		}
	}

	if config.spire && _spire_self != _|_ {
		secret: #spire_secret & {
			// Expects _name and _subject to be passed in like so from above:
			// _spire_self: "dashboard"
			// _spire_other: "edge"  // but this defaults to "edge" and may be omitted
			_name:    _spire_self
			_subject: _spire_other
			// TODO I just copied the following two from the previous operator without knowing why -DC
			set_current_client_cert_details: uri: true
			forward_client_cert_details: "APPEND_FORWARD"
		}
	}

	zone_key: mesh.spec.zone
	protocol: "http_auto" // vestigial
}

#cluster: greymatter.#Cluster & {
	// You can either specify the upstream with these, or leave it to service discovery
	_upstream_host:           string | *"127.0.0.1"
	_upstream_port:           int
	_spire_self:              string // can specify current identity - defaults to "edge"
	_spire_other:             string // can specify an allowable upstream identity - defaults to "edge"
	_enable_circuit_breakers: bool | *false
	// We can expand options here for load balancers that superseed the lb_policy field
	_load_balancer: "round_robin" | "least_request" | "maglev" | "ring_hash" | "random"

	cluster_key: string
	name:        string | *cluster_key
	instances:   [...greymatter.#Instance] | *[]

	if _upstream_port != _|_ {
		instances: [{host: _upstream_host, port: _upstream_port}]
	}
	if config.spire && _spire_other != _|_ {
		require_tls: true
		secret:      #spire_secret & {
			// Expects _name and _subject to be passed in like so from above:
			// _spire_self: "redis"  // but this defaults to "edge" and may be omitted
			// _spire_other: "dashboard"
			_name:    _spire_self
			_subject: _spire_other
		}
	}
	zone_key: mesh.spec.zone

	if _enable_circuit_breakers {
		circuit_breakers: #circuit_breaker // can specify circuit breaker levels for normal
		// and high priority traffic with configured defaults
	}
	if _load_balancer != _|_ {
		lb_policy: _load_balancer
		if lb_policy == "least_request" {
			least_request_lb_conf: {
				choice_count: uint32 | *2
			}
		}

		if lb_policy == "ring_hash" || lb_policy == "maglev" {
			ring_hash_lb_conf: {
				minimum_ring_size?: uint64 & <8388608 | *1024
				hash_func?:         uint32 | *0                  //corresponds to the xxHash; 1 for MURMUR_HASH_2 
				maximum_ring_size?: uint64 & <8388608 | *4194304 // 4M
			}
		}
	}
}

#circuit_breaker: {
	#circuit_breaker_default
	high?: #circuit_breaker_default
}

#circuit_breaker_default: {
	max_connections:      int64 | *512
	max_pending_requests: int64 | *512
	max_requests:         int64 | *512
	max_retries:          int64 | *2
	max_connection_pools: int64 | *512
	track_remaining:      bool | *false
}

#route: greymatter.#Route & {
	route_key:               string
	domain_key:              string | *route_key
	_upstream_cluster_key:   string | *route_key
	_enable_route_ext_authz: bool | *false
	route_match: {
		path:       string | *"/"
		match_type: string | *"prefix"
	}
	rules: [{
		constraints: light: [{
			cluster_key: _upstream_cluster_key
			weight:      1
		}]
	}]
	zone_key:       mesh.spec.zone
	prefix_rewrite: string | *"/"
	filter_configs: {
		if _enable_route_ext_authz {
			envoy_ext_authz: ext_authz.#ExtAuthzPerRoute | *{disabled: true} // example: disable auth for landing page
		}
	}
}

#proxy: greymatter.#Proxy & {
	proxy_key:     string
	name:          proxy_key
	domain_keys:   [...string] | *[proxy_key] // TODO how to get more in here for, e.g., the extra egresses?
	listener_keys: [...string] | *[proxy_key]
	zone_key:      mesh.spec.zone
}

#spire_secret: {
	_name:    string | *defaults.edge.key // at least one of these will be overridden
	_subject: string | *defaults.edge.key
	_subjects?: [...string] // If provided, this list of strings will be used instead of _subject

	set_current_client_cert_details?: {...}
	forward_client_cert_details?: string

	secret_validation_name: "spiffe://greymatter.io"
	secret_name:            "spiffe://greymatter.io/\(mesh.metadata.name).\(_name)"
	if _subjects == _|_ {
		subject_names: ["spiffe://greymatter.io/\(mesh.metadata.name).\(_subject)"]
	}
	if _subjects != _|_ {
		subject_names: [ for s in _subjects {"spiffe://greymatter.io/\(mesh.metadata.name).\(s)"}]
	}
	ecdh_curves: ["X25519:P-256:P-521:P-384"]
}

// Allows for RBAC permissions to be applied to a service and its configuration
#envoy_rbac_filter: rbac.#RBAC | *#default_rbac
#default_rbac: {
	rules: {
		action: "ALLOW"
		policies: {
			all: {
				permissions: [
					{
						any: true
					},
				]
				principals: [
					{
						any: true
					},
				]
			}
		}
	}
}

// This filter is used by OIDC/JWT authentication and ensures that the access_token JWT
// that is present as a cookie is copied into the header of the request
// so that it can be accessed by the envoy_jwt_authn filter.
#ensure_variables_filter: {
	rules: [...#ensure_variables_rules] | *[
		{
			copyTo: [
				{
					key:      "access_token"
					location: "header"
				},
			]
			key:      "access_token"
			location: "cookie"
		},
	]
}

// If other variables need to be copied/used in other filters, this filter provides
// a template for those rules.
#ensure_variables_rules: {
	key:      string
	location: string
	copyTo: [...{
		key:      string
		location: string
	}]
}

// This filter allows for the JWT supplied by an OIDC provider to be validated and 
// used in other contexts, such as RBAC configurations.
#envoy_jwt_authn: jwt_authn.#JwtAuthentication & {
	providers: {
		keycloak?: {
			issuer:    string | *""
			audiences: [...string] | *[""]
			remote_jwks?: {
				http_uri: {
					uri:     string | *""
					cluster: string | *""
					timeout: string | *"1s"
				}
				cache_duration: string | *"300s"
			}
			local_jwks?: {
				inline_string: string | *""
			}
			forward:             bool | *true
			from_headers:        [...] | *[{name: "access_token"}]
			payload_in_metadata: string | *"claims"
		}
	}
	rules: [...] | *[
		{
			match: {prefix: "/"}
			requires: {provider_name: "keycloak"}
		},
	]
}

// Allows for authentication via an OIDC provider such as Keycloak.
#oidc_authentication: {
	provider:     string | *""
	serviceUrl:   string | *""
	callbackPath: string | *"/oauth"
	clientId:     string | *""
	clientSecret: string | *""

	accessToken: {
		// options are "header" | "cookie" | "queryString" | "metadata"
		location: *"cookie" | _
		key:      string | *"access_token"
		if location == "metadata" {
			metadataFilter: string
		}
		if location == "cookie" {
			cookieOptions: {
				httpOnly: bool | *true
				secure:   bool | *false
				maxAge:   string | *"6h"
				domain:   string | *""
				path:     string | *"/"
			}
		}
	}

	idToken: {
		location: *"cookie" | _
		key:      string | *"authz_token"
		if location == "cookie" {
			cookieOptions: {
				httpOnly: bool | *true
				secure:   bool | *false
				maxAge:   string | *"6h"
				domain:   string | *""
				path:     string | *"/"
			}
		}
	}

	tokenRefresh: {
		enabled:   bool | *true
		endpoint:  string | *""
		realm:     string | *""
		timeoutMs: int | *5000
		useTLS:    bool | *false
		if useTLS {
			certPath:           string | *""
			keyPath:            string | *""
			caPath:             string | *""
			insecureSkipVerify: bool | *false
		}
	}

	// Optional requested permissions
	additionalScopes: [...string] | *["openid"]
}

#envoy_tcp_rate_limit: ratelimit.#RateLimit | *#default_rate_limit

// Assumes the http/2 cluster between proxy and the rate limit service is called ratelimit.
// see https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/other_features/global_rate_limiting#arch-overview-global-rate-limit for a discussion of ratelimiting and 
// special descriptors to use
#default_rate_limit: {
	stat_prefix:       defaults.edge.key
	domain:            defaults.edge.key
	failure_mode_deny: true
	descriptors: [
		{
			entries: [
				{
					key:   "path"
					value: "/"
				},
			]
		},
	]
	rate_limit_service: {
		grpc_service: {
			envoy_grpc: {
				timeout:      "0.25s"
				cluster_name: "ratelimit"
			}
		}
	}
}

// Allows for the configuration of fault injection into a proxy
// See https://www.envoyproxy.io/docs/envoy/v1.16.5/configuration/http/http_filters/fault_filter.html for header/runtime configuration
// specifics, along with further configuration for specific upstream clusters
#envoy_fault_injection: fault.#HTTPFault | *{
	delay: {
		fixed_delay: "5s"
		percentage: {
			numerator:   50
			denominator: "HUNDRED"
		}
	}
	abort: {
		// Allows request to specify the status code with which to fail using the x-envoy-fault-abort-request header
		header_abort: {} // Headers can also specify the percentage of requests to fail, capped by the below value with the x-envoy-fault-abort-request-percentage header
		percentage: {
			numerator:   50
			denominator: "HUNDRED"
		}
	}
}

// See https://www.envoyproxy.io/docs/envoy/v1.16.5/configuration/http/http_filters/ext_authz_filter for additional configuration including
// interfacing with a traditional HTTP/1 authorization service.
#envoy_ext_authz: ext_authz.#ExtAuthz | *{
	grpc_service: {
		envoy_grpc: {
			cluster_name: "ext_authz" // Needs to match the name of your cluster. Since its a grpc connection, you must create an http/2 cluster
		}
	}
	failure_mode_allow: false // set to true to allow requests to pass in the case of a authz network failure
	with_request_body: {
		max_request_bytes:     1024
		allow_partial_message: true
		pack_as_bytes:         true
	}
}

#envoy_tcp_ext_authz: ext_authz_tcp.#ExtAuthz | *{
	grpc_service: {
		envoy_grpc: {
			cluster_name: "ext_authz_tcp" // Needs to match the name of your cluster
		}
	}
	failure_mode_allow: false // set to true to allow requests to pass in the case of a authz network failure
}

#OPAEgress: {
	input: {
		name:       string
		domain_key: string
		configs: [...]
	}
	_opa_key: "\(input.name)-egress-to-opa"
	out: {
		key:    _opa_key
		config: [
			#cluster & {
				cluster_key: _opa_key
				name:        "opa"
				http2_protocol_options: {
					allow_connect: true
				}
			},
			#route & {route_key: _opa_key, domain_key: input.domain_key},
		] + input.configs
	}
}

#catalogentry: greymatter.#CatalogService
