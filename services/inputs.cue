package services

// YOU SHOULD EDIT ME...

// All default values for this project's mesh configs go in this file.
// Things like upstream port values, names, hosts, etc...
// Globally accessed values should live here and be reused accordingly
// in the respective service definitions.
// Note the package: It must match the package of your service configurations.

defaults: {
	mesh_name: "greymatter-mesh" // the name of your mesh, does not change the name
	spire:     false            
	zone:      "default-zone"
	redis_cluster_name: "redis"

	// default port values that get unified in the service definitions
	ports: {
		default_ingress: 10808
		redis_ingress:   10910
	}
}

mesh: {
  metadata: {
    name: string | *"greymatter-mesh"

  }
  spec: {
		install_namespace: string | *"greymatter"
		watch_namespaces:  [...string] | *["default", "plus"]
		release_version:   string | *"1.7" // no longer does anything, for the moment
		zone:              string | *"default-zone"
		images: {// TODO start with defaults from below
			proxy:     string | *"docker.greymatter.io/release/gm-proxy:1.7.0"
			catalog:   string | *"docker.greymatter.io/release/gm-catalog:3.0.0"
			dashboard: string | *"docker.greymatter.io/release/gm-dashboard:6.0.0"

			control:     string | *"docker.greymatter.io/internal/gm-control:1.7.1"
			control_api: string | *"docker.greymatter.io/internal/gm-control-api:1.7.1"

			redis: string | *"redis:latest"
		}
	}

}

config: {
  spire: false
}
