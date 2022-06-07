package services

import greymatter "greymatter.io/api"

// Lettuce

let Name = "lettuce"
let LettuceIngressName = "\(Name)-ingress-to-lettuce"

Lettuce: {
	name:   Name
	config: lettuce_config
}

lettuce_config: [
	// Lettuce -> HTTP ingress
	#domain & {domain_key: LettuceIngressName},
	#listener & {
		listener_key: LettuceIngressName
		_spire_self:  Name
		_gm_observables_topic: Name
		_is_ingress: true
	},
	// upstream_port -> port your service is listening on
	#cluster & {cluster_key: LettuceIngressName, _upstream_port: 8080},
	#route & {route_key:     LettuceIngressName},



	// Shared lettuce proxy object
	#proxy & {
		proxy_key: Name
		domain_keys: [LettuceIngressName]
		listener_keys: [LettuceIngressName]
	},



	// Edge config for the lettuce service
	#cluster & {
		cluster_key:  Name
		_spire_other: Name
	},
	#route & {
		domain_key: "edge"
		route_key:  Name
		route_match: {
			path: "/services/lettuce/"
		}
		redirects: [
			{
				from:          "^/services/lettuce$"
				to:            route_match.path
				redirect_type: "permanent"
			},
		]
		prefix_rewrite: "/"
	},

	

	greymatter.#CatalogService & {
		name:                      Name
		mesh_id:                   defaults.mesh_name
		service_id:                Name
		version:                   "v1.0.0"
		description:               "Lettuce service that serves up lettuce!"
		api_endpoint:              "/services/\(Name)/"
		api_spec_endpoint:         "/services/\(Name)/"
		business_impact:           "low"
		enable_instance_metrics:   true
		enable_historical_metrics: false
	},
]
