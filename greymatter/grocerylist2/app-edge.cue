package greymatter

let Name = "plus-grocerylist-edge"
let AppEdgeIngressName = "\(Name)-ingress"
let EgressToRedisName = "\(Name)-egress-to-redis"

// listener, proxy, domain, cluster (local), lots of routes

AppEdge: {
    name: Name
    config: [
		// AppEdge -> HTTP ingress
		#domain & {domain_key: AppEdgeIngressName},
		#listener & {
			listener_key:          AppEdgeIngressName
			_spire_self:           Name
			_gm_observables_topic: Name
			_is_ingress:           true
			_enable_rbac:          true
		},
		// <REMOVE THIS DEFAULT ROUTE and the local cluster>
        // upstream_port -> port your service is listening on,
        // #cluster & {cluster_key: AppEdgeIngressName, _upstream_port: 8080},
        // #route & {route_key:     AppEdgeIngressName},

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

		// Shared AppEdge proxy object
		#proxy & {
			proxy_key: Name
			domain_keys: [AppEdgeIngressName, EgressToRedisName]
			listener_keys: [AppEdgeIngressName, EgressToRedisName]
		},

		// Edge config for the AppEdge service
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

        // routes apple
        #route & {
			domain_key: AppEdgeIngressName
			route_key:  "\(Name)-to-apple"
			route_match: {
				path: "/apple/"
			}
			redirects: [
				{
					from:          "^/apple$"
					to:            route_match.path
					redirect_type: "permanent"
				},
			]
			prefix_rewrite: "/"
            rules: [{
                constraints: light: [{
                    cluster_key: "plus-apple"
                    weight: 1
                }]
            }]
		},
        // route to banana
        #route & {
			domain_key: AppEdgeIngressName
			route_key:  "\(Name)-to-banana"
			route_match: {
				path: "/banana/"
			}
			redirects: [
				{
					from:          "^/banana$"
					to:            route_match.path
					redirect_type: "permanent"
				},
			]
			prefix_rewrite: "/"
            rules: [{
                constraints: light: [{
                    cluster_key: "plus-banana"
                    weight: 1
                }]
            }]
		},
        // route to lettuce
        #route & {
			domain_key: AppEdgeIngressName
			route_key:  "\(Name)-to-lettuce"
			route_match: {
				path: "/lettuce/"
			}
			redirects: [
				{
					from:          "^/lettuce$"
					to:            route_match.path
					redirect_type: "permanent"
				},
			]
			prefix_rewrite: "/"
            rules: [{
                constraints: light: [{
                    cluster_key: "plus-lettuce"
                    weight: 1
                }]
            }]
		},
        // route to tomato
        #route & {
			domain_key: AppEdgeIngressName
			route_key:  "\(Name)-to-tomato"
			route_match: {
				path: "/tomato/"
			}
			redirects: [
				{
					from:          "^/tomato$"
					to:            route_match.path
					redirect_type: "permanent"
				},
			]
			prefix_rewrite: "/"
            rules: [{
                constraints: light: [{
                    cluster_key: "plus-tomato"
                    weight: 1
                }]
            }]
		},
        // default route (in this case we chose apple)
        #route & {
			domain_key: AppEdgeIngressName
			route_key:  "\(Name)-to-default"
			route_match: {
				path: "/"
			}
			prefix_rewrite: "/"
            rules: [{
                constraints: light: [{
                    cluster_key: "plus-apple"
                    weight: 1
                }]
            }]
		},


		#catalog_entry & {
			name:                      Name
			mesh_id:                   mesh.metadata.name
			service_id:                Name
			version:                   "v1.0.0"
			description:               "Application Edge node for grocerylist2"
			api_endpoint:              "<APP EDGE FQDN GOES HERE>"
			api_spec_endpoint:         "<APP EDGE FQDN GOES HERE>"
			business_impact:           "low"
			enable_instance_metrics:   true
			enable_historical_metrics: false
		},
	]
}