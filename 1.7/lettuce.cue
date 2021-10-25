package mesh

// Lettuce

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name=lettuce to the proxies template
proxies: lettuce: {}

// Provide Name="lettuce-local" to the clusters template. The key contains
// a hyphen, so it must be quoted.
clusters: "lettuce-local": {
	instances: [{host: #localhost, port: #lettuceUpstream}]
}

// Provide Name=lettuce to the clusters template
clusters: lettuce: {
	instances: [{host: #localhost, port: #lettuceSidecar}]
}

// Provide Name=lettuce to the domains template, and also set the
// nested field "port" to the value of #lettuceSidecar
domains: lettuce: port: #lettuceSidecar

// Provide Name=lettuce to the listeners template. Set the deeply-nested
// field metrics_port, which has a default, but is overridable.
listeners: lettuce: {
	ip:   #all_interfaces
	port: #lettuceSidecar
	http_filters: gm_metrics: metrics_port: 39004
}

// Provide Name="lettuce-local" to the routes template. Again, the key
// contains a hyphen, so it must be quoted.
routes: "lettuce-local": {
	domain_key: "lettuce"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [ {cluster_key: "lettuce-local", weight: 1}]
	}]
}

// Provide Name=lettuce to the routes template. We set a few additional
// fields here, like redirects.
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
