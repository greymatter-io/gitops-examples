package mesh

import "produce.local/gm"

#all_interfaces: "0.0.0.0"

#default_filters: {
	"gm_metrics": {
		"metrics_dashboard_uri_path":  "/metrics"
		"metrics_host":                "0.0.0.0"
		"metrics_key_depth":           "3"
		"metrics_key_function":        "depth"
		// int OR a default allows us to override it
		"metrics_port":                int | *39001
		"metrics_prometheus_uri_path": "/prometheus"
		"metrics_receiver": {
			"redis_connection_string": "redis://127.0.0.1:6379"
		}
		"metrics_ring_buffer_size":                   4096
		"prometheus_system_metrics_interval_seconds": 15
	}
}

#EmptySecret: gm.#Secret & {
	"ecdh_curves":            null
	"secret_key":             ""
	"secret_name":            ""
	"secret_validation_name": ""
}

#DefaultZone: "default-zone"

// Domain template with defaults
domains: [Name=_]: gm.#Domain & {
	name:       "*"
	domain_key: Name
	zone_key:   #DefaultZone
}

// Listeners template w/ defaults
listeners: [Name=_]: gm.#Listener & {
	name:         Name
	listener_key: Name
	domain_keys:  [string] | *["\(Name)"]
	#PlaintextListenerDefaults
}

// Clusters template w/ defaults
clusters: [Name=_]: gm.#Cluster & {
	name:        Name
	cluster_key: Name
	zone_key:    #DefaultZone
}

proxies: [Name=_]: gm.#Proxy & {
	proxy_key:   Name
	name:        Name
	domain_keys: [string] | *["\(Name)"]
	zone_key:    #DefaultZone
}

routes: [Name=_]: gm.#Route & {
	zone_key:    #DefaultZone
	route_key:   Name
	route_match: gm.#RouteMatch | {path: "/", match_type: "prefix"}
}

// Constants and shared data

#appleSidecar:       9003
#appleUpstream:      42071
#bananaSidecar:      9001
#bananaUpstream:     42069
#catalogUpstream:    8080
#controlAPIUpstream: 5555
#dashboardUpstream:  1337
#lettuceSidecar:     9004
#lettuceUpstream:    42072
#pearUpstream:       42070
#pearSidecar:        9002
#edgePort:           10808
#localhost:          "127.0.0.1"

// Set defaults
#PlaintextListenerDefaults: gm.#Listener & {
	secret:       #EmptySecret
	zone_key:     #DefaultZone
	http_filters: #default_filters
	protocol:     "http_auto"
	ip:           #all_interfaces
	// Default active filters
	active_http_filters: ["gm.metrics"]
}
