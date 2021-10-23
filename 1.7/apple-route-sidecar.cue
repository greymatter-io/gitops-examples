package mesh

domain_key: "edge"
zone_key:   "default-zone"
route_key:  "apple"
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
	constraints: light: [ {cluster_key: "apple", weight: 1}]
}]
