package mesh

proxies: banana: {}

clusters: "banana-local": {
	instances: [{host: #localhost, port: #bananaUpstream}]
}

clusters: banana: {
	instances: [{host: #localhost, port: #bananaSidecar}]
}

domains: banana: port: #bananaSidecar

clusters: banana: {
	instances: [ {host: #localhost, port: #bananaSidecar}]
}

listeners: banana: {
	port: #bananaSidecar
	ip:   #all_interfaces
	http_filters: gm_metrics: metrics_port: 39001
}

routes: "banana-local": {
	domain_key: "banana"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [ {cluster_key: "banana-local", weight: 1}]
	}]
}

routes: banana: {
	domain_key: "edge"
	route_match: {
		path:       "/services/banana/latest/"
		match_type: "prefix"
	}
	prefix_rewrite: "/"
	redirects: [{
		from:          "^/services/banana/latest$"
		to:            "/services/banana/latest/"
		redirect_type: "permanent"
	}]
	rules: [{
		constraints: light: [ {cluster_key: "banana", weight: 1}]
	}]

}
