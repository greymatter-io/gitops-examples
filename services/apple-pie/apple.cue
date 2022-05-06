package services

// Grey Matter configuration for the Apple service

let Name = "apple"
let AppleIngressName = "\(Name)-ingress-to-apple"

Apple: {
	name:   Name
	config: apple_config
}

apple_config: [
	// Apple -> HTTP ingress
	#domain & {domain_key: AppleIngressName},
	#listener & {
		listener_key: AppleIngressName
		_spire_self:  Name
	},
	// upstream_port -> port your service is listening on,
	#cluster & {cluster_key: AppleIngressName, _upstream_port: 8080},
	#route & {route_key:     AppleIngressName},



	// Shared apple proxy object
	#proxy & {
		proxy_key: Name
		domain_keys: [Name]
		listener_keys: [Name]
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



	#catalogservice & {
		name:                      Name
		mesh_id:                   defaults.mesh_name
		service_id:                Name
		// version:                   "v1.0.0"
		description:               "Apple service that serves up apples!"
		api_endpoint:              "/services/\(Name)/"
		api_spec_endpoint:         "/services/\(Name)/"
		// business_impact:           "low"
		enable_instance_metrics:   true
		enable_historical_metrics: false
	},
]
