package mesh

// Control API

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name="control-api" to the clusters template. The key contains
// a hyphen, so we have to quote it.
clusters: "control-api": {
	instances: [{host: #localhost, port: #controlAPIUpstream}]
}

// Provide Name="control-api" to the routes template
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
