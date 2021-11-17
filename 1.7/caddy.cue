package mesh

domains: caddy: port: #caddySidecar

listeners: caddy: {
	port: #caddySidecar
	ip:   #all_interfaces
	http_filters: gm_metrics: metrics_port: 8081
}

// in k8s, name must match proxy name which must match greymatter.io/control: name
proxies: caddy: {
	listener_keys: ["caddy"]
}

// Provide Name="caddy-local" to the clusters template. The key contains
// a hyphen, so it must be quoted.
clusters: "caddy-local": {
	instances: [{host: #localhost, port: #caddyUpstream}]
}

// routes match on path, headers, cookies, metadata, then map to rules->clusters
routes: "caddy-local": {
	domain_key: "caddy"
	route_match: {path: "/", match_type: "prefix"}
	rules: [{
		constraints: light: [{cluster_key: "caddy-local", weight: 1}]
	}]
}
