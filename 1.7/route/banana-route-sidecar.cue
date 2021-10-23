package mesh

domain_key: "edge"
zone_key:   "default-zone"
route_key:  "banana"
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
