package examples

let Name = "apple"
let AppleIngressName = "\(Name)-ingress-to-apple"

// Top level service objects enable programmatic access to service 
// metadata when exported. Tagging can be used throughout the CUE
// to do things like namespace object keys, provide contextual information
// about your service such as the name, which mesh it belongs too, etc...
// Each service object is REQUIRED to have a `config` array that contains
// all associated mesh configurations as displayed below.
Apple: {
	name:   Name
	config: [
		// Apple -> HTTP ingress
		#domain & {domain_key: AppleIngressName},
		#listener & {
			listener_key:          AppleIngressName
			_spire_self:           Name
			_gm_observables_topic: Name
			_is_ingress:           true
			_enable_rbac:          true
		},
		// upstream_port -> port your service is listening on,
		#cluster & {cluster_key: AppleIngressName, _upstream_port: 8080},
		#route & {route_key:     AppleIngressName},

		// Shared apple proxy object
		#proxy & {
			proxy_key: Name
			domain_keys: [AppleIngressName]
			listener_keys: [AppleIngressName]
		},

		// Edge config for the Apple service
		#cluster & {
			cluster_key:  Name
			_spire_other: Name
		},
		#route & {
			domain_key: "edge"
			route_key:  Name
			route_match: {
				path: "/services/apple/"
			}
			redirects: [
				{
					from:          "^/services/apple$"
					to:            route_match.path
					redirect_type: "permanent"
				},
			]
			prefix_rewrite: "/"
		},

		#catalogentry & {
			name:                      Name
			mesh_id:                   mesh.metadata.name
			service_id:                Name
			version:                   "v1.0.0"
			description:               "Apple service that serves up apples!"
			api_endpoint:              "/services/\(Name)/"
			api_spec_endpoint:         "/services/\(Name)/"
			business_impact:           "low"
			enable_instance_metrics:   true
			enable_historical_metrics: false
		},
	]
}