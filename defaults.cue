package mesh

import "produce.local/gm"

// Reusable IP address definitions
#all_interfaces: "0.0.0.0"
#localhost:      "127.0.0.1"

// Ports for the apple service
#appleSidecar:  9003
#appleUpstream: 42071

// Ports for the banana service
#bananaSidecar:  9001
#bananaUpstream: 42069

// Ports for the lettuce service
#lettuceSidecar:  9004
#lettuceUpstream: 42072

// Ports for the pear service
#pearUpstream: 42070
#pearSidecar:  9002

// Ports for Grey Matter core services
#catalogUpstream:    8080
#controlAPIUpstream: 5555
#dashboardUpstream:  1337
#edgePort:           10808

// Zone definition that everything shares
#DefaultZone: "default-zone"

//
// Templates are an advanced concept with powerful code-reuse capability
// docs: https://cuelang.org/docs/tutorials/tour/types/templates/
//

// NOTE: the domains, listeners, clusters, etc. keys defined here literally ARE
// the top-level keys that we render in our final JSON export. But we supply
// the concrete values to these templates with the files in the 1.7 directory.

// Each of these templates takes a single parameter, Name. Using a template
// looks like this in CUE:
//
//                         ,--- port must be provided a concrete value
//    domains: myDomain: port: 1001
//                ^-- Name param
//
// The output of the above usage of the "domains" template is is
//    "domains: {
//       "myDomain": {
//         "zone_key": "default-zone",   <-- Taken from #DefaultZone def.
//         "port": 1001,                 <-- Provided a value explicitly
//         "domain_key": "pear",         <-- Populated by Name parameter
//         "name": "*"                   <-- The default value
//       }
//    }
//

// Domain template 
domains: [Name=_]: gm.#Domain & {
	name:       string | *"*"
	domain_key: Name
	zone_key:   #DefaultZone
}

// Listeners template
listeners: [Name=_]: gm.#Listener & {
	name:         Name
	listener_key: Name
	// We interpolate the Name paramter in a default array-of-string! Wow!
	domain_keys: [string] | *["\(Name)"]
	// Embedded struct
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
