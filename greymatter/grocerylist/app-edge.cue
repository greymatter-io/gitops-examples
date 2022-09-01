package greymatter

let Name = "grocerylist-edge"
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
        
        // For application edge's we create a default route (in this case we chose apple).
        //This will typically be to the ui component of an app stack
        #route & {
			domain_key: AppEdgeIngressName
			route_key:  "\(Name)-to-default"
			route_match: {
				path: "/"
			}
			prefix_rewrite: "/"
            // demo of traffic splitting
            // you will see a round robin with prefrence to apple
            rules: [{
                constraints: light: [
                    { cluster_key: "apple", weight: 3 },
                    { cluster_key: "banana", weight: 1 },
                    { cluster_key: "lettuce", weight: 1 },
                    { cluster_key: "tomato", weight: 1 }
                ]
            }]
		},
        // routes to apple <app edge fqdn>/apple
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
                    cluster_key: "apple"
                    weight: 1
                }]
            }]
		},
        // route to banana  <app edge fqdn>/banana
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
                    cluster_key: "banana"
                    weight: 1
                }]
            }]
		},
        // route to lettuce  <app edge fqdn>/lettuce
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
                    cluster_key: "lettuce"
                    weight: 1
                }]
            }]
		},
        // route to tomato  <app edge fqdn>/tomato
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
                    cluster_key: "tomato"
                    weight: 1
                }]
            }]
		},

        // If you want see the application's edge node in the dashboard
        // then you need to specify a cluster object and route object on the gm core edge domain and a catalog entry
        // Edge config for the AppEdge service
		#cluster & {
			cluster_key:  Name
			_spire_other: Name
		},

        // This route needs to remain inplace if you want to access the routes via the dashboard through this application edge node
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
			description:               "Application Edge node for grocerylist"
			api_endpoint:              "<APP EDGE FQDN GOES HERE>"
			api_spec_endpoint:         "<APP EDGE FQDN GOES HERE>"
			business_impact:           "low"
			enable_instance_metrics:   true
			enable_historical_metrics: true
		},
	]
}