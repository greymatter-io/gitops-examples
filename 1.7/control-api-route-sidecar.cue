package mesh

domain_key: "edge"
zone_key:   "default-zone"
route_key:  "control-api"
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
