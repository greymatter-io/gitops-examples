package greymatter

let Name = "examples-tomato"
let TomatoIngressName = "\(Name)-ingress-to-tomato"
let EgressToRedisName = "\(Name)-egress-to-redis"

// Top level service objects enable programmatic access to service 
// metadata when exported. Tagging can be used throughout the CUE
// to do things like namespace object keys, provide contextual information
// about your service such as the name, which mesh it belongs too, etc...
// Each service object is REQUIRED to have a `config` array that contains
// all associated mesh configurations as displayed below.
Tomato: {
	name: Name
	config: [
		// Tomato -> HTTP ingress
		#domain & {domain_key: TomatoIngressName},
		#listener & {
			listener_key:          TomatoIngressName
			_spire_self:           Name
			_gm_observables_topic: Name
			_is_ingress:           true
		},
		// upstream_port -> port your service is listening on
		#cluster & {cluster_key: TomatoIngressName, _upstream_port: 8080},
		#route & {route_key:     TomatoIngressName},

		// egress -> redis
		#domain & {domain_key: EgressToRedisName, port: defaults.ports.redis_ingress},
		#cluster & {
			cluster_key:  EgressToRedisName
			name:         defaults.redis_cluster_name
			_spire_self:  Name
			_spire_other: defaults.redis_cluster_name
		},
		#route & {route_key: EgressToRedisName},
		#listener & {
			listener_key: EgressToRedisName
			// egress listeners are local-only
			ip:   "127.0.0.1"
			port: defaults.ports.redis_ingress
			// NB this points at a cluster name, not key
			_tcp_upstream: defaults.redis_cluster_name
		},

		// Shared Tomato proxy object
		#proxy & {
			proxy_key: Name
			domain_keys: [TomatoIngressName, EgressToRedisName]
			listener_keys: [TomatoIngressName, EgressToRedisName]
		},

		// Edge config for the Tomato service
		#cluster & {
			cluster_key:  Name
			_spire_other: Name
		},
		#route & {
			domain_key: "edge"
			route_key:  Name
			route_match: {
				path: "/services/\(Name)/"
			}
			redirects: [
				{
					from:          "^/services/\(Name)$"
					to:            route_match.path
					redirect_type: "permanent"
				},
			]
			prefix_rewrite: "/"
		},

		#catalog_entry & {
			name:                      Name
			mesh_id:                   mesh.metadata.name
			service_id:                Name
			version:                   "v1.0.0"
			description:               "Tomato service that serves up tomato"
			api_endpoint:              "/services/\(Name)/"
			api_spec_endpoint:         "/services/\(Name)/"
			business_impact:           "low"
			enable_instance_metrics:   true
			enable_historical_metrics: false
		},
	]
}
