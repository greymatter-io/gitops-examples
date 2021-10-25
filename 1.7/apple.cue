package mesh

// Apple

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name=apple to the proxies template
proxies: apple: {}

// Provide Name="apple-local" to the clusters template. The key contains
// a hyphen, so it must be quoted.
clusters: "apple-local": {
	instances: [{host: #localhost, port: #appleUpstream}]
}

// Provide Name=apple to the clusters template
clusters: apple: {
	instances: [{host: #localhost, port: #appleSidecar}]
}

// Provide Name=apple to the domains template, and also set the
// nested field "port" to the value of #appleSidecar
domains: apple: port: #appleSidecar

// Provide Name=apple to the listeners template. Set the deeply-nested
// field metrics_port, which has a default, but is overridable.
listeners: apple: {
	port: #appleSidecar
	ip:   #all_interfaces
	http_filters: gm_metrics: metrics_port: 39003
}

// Provide Name="apple-local" to the routes template. Again, the key
// contains a hyphen, so it must be quoted.
routes: "apple-local": {
	domain_key: "apple"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [{cluster_key: "apple-local", weight: 1}]
	}]
}

// Provide Name=apple to the routes template. We set a few additional
// fields here, like redirects.
routes: apple: {
	domain_key: "edge"
	route_match: {
		path:       "/services/apple/latest/"
		match_type: "prefix"
	}
	prefix_rewrite: "/"
	redirects: [{
		from:          "^/services/apple/latest$"
		to:            "/services/apple/latest/"
		redirect_type: "permanent"
	}]
	rules: [{
		constraints: light: [{cluster_key: "apple", weight: 1}]
	}]
}
