package mesh

domain_key: "banana"
zone_key:   "default-zone"
route_key:  "banana-local"
route_match: {path: "/", match_type: "prefix"}
rules: [{
	constraints: light: [ {cluster_key: "banana-local", weight: 1}]
}]
