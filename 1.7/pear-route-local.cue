package mesh

domain_key: "pear"
zone_key:   "default-zone"
route_key:  "pear-local"
route_match: {path: "/", match_type: "prefix"}
rules: [{
	constraints: light: [ {cluster_key: "pear-local", weight: 1}]
}]
