package mesh

// Apple

proxies: apple: {}

clusters: "apple-local": {
	instances: [{host: #localhost, port: #appleUpstream}]
}

clusters: apple: {
	instances: [{host: #localhost, port: #appleSidecar}]
}

domains: apple: port: #appleSidecar

listeners: apple: {
	port: #appleSidecar
	ip:   #all_interfaces
}

routes: "apple-local": {
	domain_key: "apple"
	rules: [{
		constraints: light: [{cluster_key: "apple-local", weight: 1}]
	}]
}

routes: apple: {
	domain_key: "edge"
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
		constraints: light: [{cluster_key: "apple", weight: 1}]
	}]
}
