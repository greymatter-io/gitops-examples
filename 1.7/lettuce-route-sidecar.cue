package mesh

domain_key: "edge"
zone_key:   "default-zone"
route_key:  "lettuce"
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
