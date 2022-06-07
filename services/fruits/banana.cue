package services

import greymatter "greymatter.io/api"

// Grey Matter configuration for the Banana service

let Name = "banana"
let BananaIngressName = "\(Name)-ingress-to-banana"

Banana: {
	name:   Name
	config: banana_config
}

banana_config: [
	// Banana -> HTTP ingress
	#domain & {domain_key: BananaIngressName},
	#listener & {
		listener_key: BananaIngressName
		_spire_self:  Name
		_gm_observables_topic: Name
		_is_ingress: true
	},
	#cluster & {cluster_key: BananaIngressName, _upstream_port: 8080}, // upstream_port -> port your service is listening on
	#route & {route_key:     BananaIngressName},



	// Shared Banana proxy object
	#proxy & {
		proxy_key: Name
		domain_keys: [BananaIngressName]
		listener_keys: [BananaIngressName]
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
			path: "/services/banana/"
		}
		redirects: [
			{
				from:          "^/services/banana$"
				to:            route_match.path
				redirect_type: "permanent"
			},
		]
		prefix_rewrite: "/"
	},

	

	// Grey Matter catalog service entry
	greymatter.#CatalogService & {
		name:                      Name
		mesh_id:                   defaults.mesh_name
		service_id:                Name
		version:                   "v0.0.1"
		description:               "Banana service that serves up bananas!"
		api_endpoint:              "/services/\(Name)/"
		api_spec_endpoint:         "/services/\(Name)/"
		business_impact:           "low"
		enable_instance_metrics:   true
		enable_historical_metrics: false
	},
]
