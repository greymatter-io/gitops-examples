package mesh

// Catalog

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name=catalog to the clusters template
clusters: catalog: {
	instances: [ {host: #localhost, port: #catalogUpstream}]
}

// Provide Name=catalog to the routes template.
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
