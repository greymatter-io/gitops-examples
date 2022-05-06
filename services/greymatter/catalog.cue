package services

// Catalog configuration

let Name = "catalog"
let CatalogIngressName = "\(Name)-ingress-to-catalog"
let EgressToRedisName = "\(Name)-egress-to-redis"

Catalog: {
	name:   Name
	config: catalog_config
}

catalog_config: [
	// Catalog -> HTTP Ingress
	#domain & {domain_key: CatalogIngressName},
	#listener & {
		listener_key: CatalogIngressName
		_spire_self:  Name
	},
	#cluster & {cluster_key: CatalogIngressName, _upstream_port: 8080},
	#route & {route_key:     CatalogIngressName},



	// Egress -> redis
	#domain & {domain_key: EgressToRedisName, port: defaults.ports.redis_ingress},
	#cluster & {
		cluster_key:  EgressToRedisName
		name:         defaults.redis_cluster_name
		_spire_self:  Name
		_spire_other: defaults.redis_cluster_name
	},
	#route & {route_key: EgressToRedisName}, // unused route must exist for the cluster to be registered with sidecar (this is a TCP quirk)
	#listener & {
		listener_key:  EgressToRedisName
		ip:            "127.0.0.1" // egress listeners are local-only
		port:          defaults.ports.redis_ingress
		_tcp_upstream: defaults.redis_cluster_name
	},



	// Shared catalog proxy object
	#proxy & {
		proxy_key: Name
		domain_keys: [Name]
		listener_keys: [Name]
	},



	// Edge config for catalog ingress
	#cluster & {
		cluster_key:  Name
		_spire_other: Name
	},
	#route & {
		domain_key: "edge"
		route_key:  Name
		route_match: {
			path: "/services/catalog/"
		}
		redirects: [
			{
				from:          "^/services/catalog$"
				to:            route_match.path
				redirect_type: "permanent"
			},
		]
		prefix_rewrite: "/"
	},
]
