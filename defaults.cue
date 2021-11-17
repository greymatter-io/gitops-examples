package mesh

import "produce.local/gm"

// Reusable IP address definitions
#all_interfaces: "0.0.0.0"
#localhost:      "127.0.0.1"

// Ports for the caddy service
#caddySidecar:  9003
#caddyUpstream: 4420

// Ports for Grey Matter core services
#catalogUpstream:    8080
#controlAPIUpstream: 5555
#dashboardUpstream:  1337
#edgePort:           10808

// Zone definition that everything shares
#DefaultZone: "zone-default-zone"

// Domain template 
domains: [Name=_]: gm.#Domain & {
	// provide a host string, or accept any "*" by default
	name:       string | *"*"
	domain_key: Name
	zone_key:   #DefaultZone
}

// Listeners template
listeners: [Name=_]: gm.#Listener & {
	name:         Name
	listener_key: Name
	domain_keys:  [string] | *["\(Name)"]
	#PlaintextListenerDefaults
}

// Clusters template
clusters: [Name=_]: gm.#Cluster & {
	name:        Name
	cluster_key: Name
	zone_key:    #DefaultZone
}

// Proxy template
proxies: [Name=_]: gm.#Proxy & {
	proxy_key:   Name
	name:        Name
	domain_keys: [string] | *["\(Name)"]
	zone_key:    #DefaultZone
}

// Route template
routes: [Name=_]: gm.#Route & {
	zone_key:    #DefaultZone
	route_key:   Name
	route_match: gm.#RouteMatch | *{path: "/", match_type: "prefix"}
}

// Note: we don't have any sharedrules in this mesh.

// (End templates)

// Our entire mesh is plaintext, no TLS. We can build a default Listener object
// to embed in our templates. This eliminates a lot of duplications.
#PlaintextListenerDefaults: gm.#Listener & {
	secret:       #EmptySecret
	zone_key:     #DefaultZone
	http_filters: #default_filters
	protocol:     "http_auto"
	ip:           #all_interfaces
	// Default active filters
	active_http_filters: ["gm.metrics"]
}

// Note that we provide a default metrics port of 39001, but let our users
// override it. This is required for gm-e2e meshes, since everything's running
// on the same local interface.
#default_filters: {
	"gm_metrics": {
		"metrics_dashboard_uri_path": "/metrics"
		"metrics_host":               "0.0.0.0"
		"metrics_key_depth":          "3"
		"metrics_key_function":       "depth"
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

// Default secret object, validated against the imported "gm" package's definition
#EmptySecret: gm.#Secret & {
	"ecdh_curves":            null
	"secret_key":             ""
	"secret_name":            ""
	"secret_validation_name": ""
}
