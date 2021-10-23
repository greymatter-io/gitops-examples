package mesh

domain_key: "apple"
zone_key:   "default-zone"
route_key:  "apple-local"
route_match: {path: "/", match_type: "prefix"}
rules: [{
	constraints: light: [ {cluster_key: "apple-local", weight: 1}]
}]
