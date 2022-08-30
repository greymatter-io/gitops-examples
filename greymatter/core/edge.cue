// Edge configuration for enterprise mesh-segmentation. This is a dedicated
// edge proxy that provides north/south network traffic to services in this
// repository in the mesh. This edge would be separate from the default
// greymatter.io edge that is deployed via enterprise-level configuration in
// the gitops-core git repository.

package greymatter

let EgressToRedisName = "\(edge.key)_egress_to_redis"

// Uncomment the below line for use with a remote JWKS provider (in this case, Keycloak)
// let EdgeToKeycloakName = edge.oidc.jwt_authn_provider.keycloak.remote_jwks.http_uri.cluster

Edge: {
	name: edge.key
	config: [
		#domain & {
			domain_key:   edge.key
			port:         edge.ingress_port
			_force_https: edge.enable_tls
		},
		#listener & {
			listener_key:                edge.key
			port:                        edge.ingress_port
			_gm_observables_topic:       edge.key
			_is_ingress:                 true
			_enable_oidc_authentication: edge.enable_oidc
			_enable_rbac:                false
			_oidc_endpoint:              edge.oidc.endpoint
			_oidc_service_url:           "https://\(edge.oidc.domain):\(edge.ingress_port)"
			_oidc_provider:              "\(edge.oidc.endpoint)/auth/realms/\(edge.oidc.realm)"
			_oidc_client_id:             edge.oidc.client_id
			_oidc_client_secret:         edge.oidc.client_secret
			_oidc_cookie_domain:         edge.oidc.domain
			_oidc_realm:                 edge.oidc.realm
		},
		// This cluster must exist (though it never receives traffic)
		// so that Catalog will be able to look-up edge instances
		#cluster & {cluster_key: edge.key},

		// edge TCP egress -> redis for greymatter.io health checking
		#domain & {domain_key: EgressToRedisName, port: mesh.redis.ingress_port},
		#cluster & {
			cluster_key:  EgressToRedisName
			name:         mesh.redis.key
			_spire_self:  edge.key
			_spire_other: mesh.redis.key
		},
		#route & {route_key: EgressToRedisName},
		#listener & {
			listener_key:  EgressToRedisName
			ip:            "127.0.0.1" // egress listeners are local-only
			port:          mesh.redis.ingress_port
			_tcp_upstream: mesh.redis.key
		},

		// Grey Matter catalog service definition for grocerylist
		#catalog_entry & {
			name:                      "Grocerylist Edge"
			mesh_id:                   mesh.name
			service_id:                edge.key
			version:                   "v1.7.1"
			description:               "EDIT ME: Edge ingress for grocerylist"
			business_impact:           "low"
			enable_instance_metrics:   true
			enable_historical_metrics: false
		},

		#proxy & {
			proxy_key: edge.key
			domain_keys: [edge.key, EgressToRedisName]
			listener_keys: [edge.key, EgressToRedisName]
		}

		// egress->Keycloak for OIDC/JWT Authentication (only necessary with remote JWKS provider)
		// NB: You need to add the EdgeToKeycloakName key to the domain_keys and listener_keys 
		// in the #proxy above for the cluster to be discoverable by the sidecar
		// #cluster & {
		//  cluster_key:    EdgeToKeycloakName
		//  _upstream_host: edge.oidc.endpoint_host
		//  _upstream_port: edge.oidc.endpoint_port
		//  ssl_config: {
		//   protocols: ["TLSv1.2"]
		//   sni: edge.oidc.endpoint_host
		//  }
		//  require_tls: true
		// },
		// #route & {route_key:   EdgeToKeycloakName},
		// #domain & {domain_key: EdgeToKeycloakName, port: edge.oidc.endpoint_port},
		// #listener & {
		//  listener_key: EdgeToKeycloakName
		//  port:         edge.oidc.endpoint_port
		// },,,,,,,,
	]
}
