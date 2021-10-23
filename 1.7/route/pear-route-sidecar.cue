package mesh

domain_key: "edge"
zone_key:   "default-zone"
route_key:  "pear"
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
	constraints: light: [ {cluster_key: "pear", weight: 1}]
}]
