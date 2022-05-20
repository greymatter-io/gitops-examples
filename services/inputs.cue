package services

// EDIT ME

// All default values for mesh configs go in this struct.
// Things like upstream port values, names, hosts, etc...
// Globally accessed values should live here and be reused accordingly
// in the respective service definitions.

defaults: {
	mesh_name: "mesh-sample"
	spire:     false
	zone:      "default-zone"
	redis_cluster_name: "redis"

	// default port values that get unified in the service definitions
	ports: {
		default_ingress: 10808
		redis_ingress:   10910
	}
}
