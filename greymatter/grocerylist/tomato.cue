package greymatter

let Name = "tomato"
let IngressName = "\(Name)-ingress-to-\(Name)"
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
		// Tomato -> HTTP ingress to your container
		#domain & {domain_key: IngressName},
		#listener & {
			listener_key:          IngressName
			_spire_self:           Name
			_gm_observables_topic: Name
			_is_ingress:           true
			_enable_rbac:          true
		},
		// upstream_port -> port your service is listening on,
		#cluster & {cluster_key: IngressName, _upstream_port: 8080},
		#route & {route_key:     IngressName},

		// Tomato TCP egress -> redis for greymatter.io health checking
		#domain & {domain_key: EgressToRedisName, port: mesh.redis.ingress_port},
		#cluster & {
			cluster_key:  EgressToRedisName
			name:         mesh.redis.key
			_spire_self:  Name
			_spire_other: mesh.redis.key
		},
		#route & {route_key: EgressToRedisName},
		#listener & {
			listener_key:  EgressToRedisName
			ip:            "127.0.0.1" // egress listeners are local-only
			port:          mesh.redis.ingress_port
			_tcp_upstream: mesh.redis.key // NB this points at a cluster name, not key
		},

		// Edge config for the Tomato service.
		// These configs are REQUIRED for your service to be accessible
		// outside your cluster/mesh.
		#cluster & {
			cluster_key:  Name
			_spire_other: Name
		},
		#route & {
			domain_key: "edge"
			route_key:  Name
			route_match: {
				path: "/services/grocerylist/tomato/"
			}
			redirects: [
				{
					from:          "^/services/grocerylist/tomato$"
					to:            route_match.path
					redirect_type: "permanent"
				},
			]
			prefix_rewrite: "/"
		},

		// Grey Matter catalog service definition for tomato
		#catalog_entry & {
			name:                      Name
			mesh_id:                   mesh.name
			service_id:                Name
			version:                   "v1.0.0"
			description:               "EDIT ME: service description goes here"
			api_endpoint:              "/services/grocerylist/\(Name)/"
			api_spec_endpoint:         "/services/grocerylist/\(Name)/"
			business_impact:           "low"
			enable_instance_metrics:   true
			enable_historical_metrics: false
		},

		// Shared tomato proxy object. All configs
		// become associated with this object with the exception
		// of the catalog definition. Proxy objects are REQUIRED
		// to register your service in a Grey Matter mesh and MUST
		// be created after all other objects.
		#proxy & {
			proxy_key: Name
			domain_keys: [IngressName, EgressToRedisName]
			listener_keys: [IngressName, EgressToRedisName]
		},
	]
}
