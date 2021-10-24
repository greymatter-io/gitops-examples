package mesh

// Dashboard

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name="dashboard" to the clusters template
clusters: dashboard: {
	instances: [{host: #localhost, port: #dashboardUpstream}]
}

// Provide Name=root to the routes template
routes: root: {
	domain_key: "edge"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [ {cluster_key: "dashboard", weight: 1}]
	}]
	filter_metadata: "gm.metrics": [
		{
			key:   "metrics_key_function"
			value: "depth"
		},
		{
			key:   "metrics_key_depth"
			value: "1"
		},
	]
}
