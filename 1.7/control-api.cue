package mesh

clusters: "control-api": {
	instances: [{host: #localhost, port: #controlAPIUpstream}]
}

routes: "control-api": {
	domain_key: "edge"
	route_match: {
		path:       "/services/control-api/latest/"
		match_type: "prefix"
	}
	prefix_rewrite: "/"
	redirects: [{
		from:          "^/services/control-api/latest$"
		to:            "/services/control-api/latest/"
		redirect_type: "permanent"
	}]
	rules: [{
		constraints: light: [ {cluster_key: "control-api", weight: 1}]
	}]
}
