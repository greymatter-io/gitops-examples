package mesh

proxies: lettuce: {}

clusters: "lettuce-local": {
	instances: [{host: #localhost, port: #lettuceUpstream}]
}

clusters: lettuce: {
	instances: [{host: #localhost, port: #lettuceSidecar}]
}

domains: lettuce: port: #lettuceSidecar

listeners: lettuce: {
	ip:   #all_interfaces
	port: #lettuceSidecar
	http_filters: gm_metrics: metrics_port: 39004
}

routes: "lettuce-local": {
	domain_key: "lettuce"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [ {cluster_key: "lettuce-local", weight: 1}]
	}]
}

routes: lettuce: {
	domain_key: "edge"
	route_match: {
		path:       "/services/lettuce/latest/"
		match_type: "prefix"
	}
	prefix_rewrite: "/"
	redirects: [{
		from:          "^/services/lettuce/latest$"
		to:            "/services/lettuce/latest/"
		redirect_type: "permanent"
	}]
	rules: [{
		constraints: light: [ {cluster_key: "lettuce", weight: 1}]
	}]
}
