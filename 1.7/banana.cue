package mesh

// Banana

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name=banana to the proxies template
proxies: banana: {}

// Provide Name="banana-local" to the clusters template. The key contains
// a hyphen, so it must be quoted.
clusters: "banana-local": {
	instances: [{host: #localhost, port: #bananaUpstream}]
}

// Provide Name=banana to the clusters template
clusters: banana: {
	instances: [{host: #localhost, port: #bananaSidecar}]
}

// Provide Name=banana to the domains template, and also set the
// nested field "port" to the value of #bananaSidecar
domains: banana: port: #bananaSidecar

// Provide Name=banana to the listeners template. Set the deeply-nested
// field metrics_port, which has a default, but is overridable.
listeners: banana: {
	port: #bananaSidecar
	ip:   #all_interfaces
	http_filters: gm_metrics: metrics_port: 39001
}

// Provide Name="banana-local" to the routes template. Again, the key
// contains a hyphen, so it must be quoted.
routes: "banana-local": {
	domain_key: "banana"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [ {cluster_key: "banana-local", weight: 1}]
	}]
}

// Provide Name=banana to the routes template. We set a few additional
// fields here, like redirects.
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
