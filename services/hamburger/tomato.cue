package services

// Tomato

let Name = "tomato"
let TomatoIngressName = "\(Name)-ingress-to-tomato"

Tomato: {
	name:   Name
	config: tomato_config
}

tomato_config: [
	// tomato -> HTTP ingress
	#domain & {domain_key: TomatoIngressName},
	#listener & {
		listener_key: TomatoIngressName
		_spire_self:  Name
	},
	// upstream_port -> port your service is listening on
	#cluster & {cluster_key: TomatoIngressName, _upstream_port: 8080},
	#route & {route_key:     TomatoIngressName},



	// Shared tomato proxy object
	#proxy & {
		proxy_key: Name
		domain_keys: [Name]
		listener_keys: [Name]
	},



	// Edge config for the tomato service
	#cluster & {
		cluster_key:  Name
		_spire_other: Name
	},
	#route & {
		domain_key: "edge"
		route_key:  Name
		route_match: {
			path: "/services/tomato/"
		}
		redirects: [
			{
				from:          "^/services/tomato$"
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
		description:               "Tomato service that serves up tomato!"
		api_endpoint:              "/services/\(Name)/"
		api_spec_endpoint:         "/services/\(Name)/"
		// business_impact:           "low"
		enable_instance_metrics:   true
		enable_historical_metrics: false
	},
]
