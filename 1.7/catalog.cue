package mesh

clusters: catalog: {
	instances: [ {host: #localhost, port: #catalogUpstream}]
}

routes: catalog: {
	domain_key: "edge"
	route_match: {
		path:       "/services/catalog/latest/"
		match_type: "prefix"
	}
	prefix_rewrite: "/"
	redirects: [{
		from:          "^/services/catalog/latest$"
		to:            "/services/catalog/latest/"
		redirect_type: "permanent"
	}]
	rules: [{
		constraints: light: [ {cluster_key: "catalog", weight: 1}]
	}]

}
