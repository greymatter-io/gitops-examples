package mesh

domain_key: "edge"
zone_key:   "default-zone"
route_key:  "catalog"
route_match: {
	path:       "/services/catalog/latest/"
	match_type: "prefix"
}
prefix_rewrite: "/"
redirects: [{
	from:          "^/services/catalog/latest$"
	to:            "/services/catalog/latest/"
	redirect_type: "permanent"
}]
rules: [{
	constraints: light: [ {cluster_key: "catalog", weight: 1}]
}]