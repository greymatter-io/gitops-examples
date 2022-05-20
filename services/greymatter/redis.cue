package services

let Name = "redis"
let RedisIngressName = "\(Name)_local"

Redis: {
	name:   Name
	config: redis_config
}

redis_config: [
	// Redis TCP ingress
	#domain & {domain_key:   RedisIngressName, port:           defaults.ports.redis_ingress},
	#cluster & {cluster_key: RedisIngressName, _upstream_port: 6379},
	// unused route must exist for the cluster to be registered
	#route & {route_key:   RedisIngressName},
	redis_listener_object, // see below
	#proxy & {
		proxy_key: Name
		domain_keys: [RedisIngressName]
		listener_keys: [RedisIngressName]
	},
]

// The Redis listener is special among Grey Matter config because we have to update it with new Spire
// configuration every time we add a sidecar to the mesh (for metrics beacons). That's why it's separated
// out here: We need to be able to unify a new mesh.status.sidecar_list and re-apply this listener.
redis_listener_object: #listener & {
	listener_key:  RedisIngressName
	port:          defaults.ports.redis_ingress
	_tcp_upstream: RedisIngressName // this _actually_ connects the cluster to the listener
	// custom secret instead of listener helpers because we need to accept multiple subjects in this listener
	if defaults.spire {
		secret: #spire_secret & {
			_name: Name
			_subjects: []
		}
	}
}
