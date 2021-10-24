package mesh

proxies: pear: {}

clusters: "pear-local": {
	instances: [{host: #localhost, port: #pearUpstream}]
}

clusters: pear: {
	instances: [{host: #localhost, port: #pearSidecar}]
}

domains: pear: port: #pearSidecar

listeners: pear: {
	ip:   #all_interfaces
	port: #pearSidecar
}

routes: "pear-local": {
	domain_key: "pear"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [{cluster_key: "pear-local", weight: 1}]
	}]
}

routes: pear: {
	domain_key: "edge"
	route_match: {
		path:       "/services/pear/latest/"
		match_type: "prefix"
	}
	prefix_rewrite: "/"
	redirects: [{
		from:          "^/services/pear/latest$"
		to:            "/services/pear/latest/"
		redirect_type: "permanent"
	}]
	rules: [{
		constraints: light: [{cluster_key: "pear", weight: 1}]
	}]
}
