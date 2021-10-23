package mesh

domain_key: "edge"
zone_key:   "default-zone"
route_key:  "root"
route_match: {path: "/", match_type: "prefix"}
rules: [{
	constraints: light: [ {cluster_key: "dashboard", weight: 1}]
}]
filter_metadata: "gm.metrics": [{
		key:                        "metrics_key_function"
		value:                      "depth"
}, {key: "metrics_key_depth", value: "1"}]