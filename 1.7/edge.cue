package mesh

// Edge

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name=edge to the proxies template
proxies: edge: {}

// Provide Name=edge to the domains template, and also set the
// nest field "port" to the value of #edgePort
//domains: edge: port: #edgePort
domains: edge: port: 4464

//
// Edge ingress for caddy
//

clusters: caddy: {
	// Instances is populated by service disc.
	instances: []
}

// Provide Name=caddy to the routes template. We set a few additional
// fields here, like redirects.
routes: caddy: {
	domain_key: "edge"
	route_match: {
		path:       "/services/caddy/latest/"
		match_type: "prefix"
	}
	prefix_rewrite: "/"
	redirects: [{
		from:          "^/services/caddy/latest$"
		to:            "/services/caddy/latest/"
		redirect_type: "permanent"
	}]
	rules: [{
		constraints: light: [{cluster_key: "caddy", weight: 1}]
	}]
}
