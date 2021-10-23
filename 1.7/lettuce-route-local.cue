package mesh

domain_key: "lettuce"
zone_key:   "default-zone"
route_key:  "lettuce-local"
route_match: {path: "/", match_type: "prefix"}
rules: [{
	constraints: light: [ {cluster_key: "lettuce-local", weight: 1}]
}]
