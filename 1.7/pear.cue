package mesh

// Pear

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name=pear to the proxies template
proxies: pear: {}

// Provide Name="pear-local" to the clusters template. The key contains
// a hyphen, so it must be quoted.
clusters: "pear-local": {
	instances: [{host: #localhost, port: #pearUpstream}]
}

// Provide Name=pear to the clusters template
clusters: pear: {
	instances: [{host: #localhost, port: #pearSidecar}]
}

// Provide Name=pear to the domains template, and also set the
// nested field "port" to the value of #pearSidecar
domains: pear: port: #pearSidecar

// Provide Name=pear to the listeners template. Set the deeply-nested
// field metrics_port, which has a default, but is overridable.
listeners: pear: {
	ip:   #all_interfaces
	port: #pearSidecar
	http_filters: gm_metrics: metrics_port: 39002
}

// Provide Name="pear-local" to the routes template. Again, the key
// contains a hyphen, so it must be quoted.
routes: "pear-local": {
	domain_key: "pear"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [{cluster_key: "pear-local", weight: 1}]
	}]
}

// Provide Name=pear to the routes template. We set a few additional
// fields here, like redirects.
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
