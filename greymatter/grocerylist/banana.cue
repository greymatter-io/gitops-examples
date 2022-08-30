package greymatter

let Name = "examples-banana"
let BananaIngressName = "\(Name)-ingress-to-banana"
let EgressToRedisName = "\(Name)-egress-to-redis"

// Top level service objects enable programmatic access to service 
// metadata when exported. Tagging can be used throughout the CUE
// to do things like namespace object keys, provide contextual information
// about your service such as the name, which mesh it belongs too, etc...
// Each service object is REQUIRED to have a `config` array that contains
// all associated mesh configurations as displayed below.
Banana: {
	name: Name
	config: [
		// Banana -> HTTP ingress
		#domain & {domain_key: BananaIngressName},
		#listener & {
			listener_key:          BananaIngressName
			_spire_self:           Name
			_gm_observables_topic: Name
			_is_ingress:           true
		},
		#cluster & {cluster_key: BananaIngressName, _upstream_port: 8080},
		#route & {route_key:     BananaIngressName},

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

		// Shared Banana proxy object
		#proxy & {
			proxy_key: Name
			domain_keys: [BananaIngressName, EgressToRedisName]
			listener_keys: [BananaIngressName, EgressToRedisName]
		},

		// Edge config for the Banana service
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
			version:                   "v0.0.1"
			description:               "Banana service that serves up bananas"
			api_endpoint:              "/services/\(Name)/"
			api_spec_endpoint:         "/services/\(Name)/"
			business_impact:           "low"
			enable_instance_metrics:   true
			enable_historical_metrics: false
		},
	]
}
