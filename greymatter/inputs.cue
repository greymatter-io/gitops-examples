package examples

config: {
	spire: bool | *false @tag(spire,type=bool) // enable Spire-based mTLS
}

mesh: {
	metadata: {
		name: string | *"greymatter-mesh"
	}
	spec: {
		zone: string | *"default-zone"
		images: {
			proxy: string | *"quay.io/greymatterio/gm-proxy:1.7.0"
		}
	}
}

defaults: {
	redis_cluster_name: "redis"

	ports: {
		default_ingress: 10808
		edge_ingress:    10809
		redis_ingress:   10910
		metrics:         8081
	}

	edge: {
		key:        "edge-example"
		enable_tls: false
		oidc: {
			endpoint_host: ""
			endpoint_port: 0
			endpoint:      "https://\(endpoint_host):\(endpoint_port)"
			domain:        ""
			client_id:     "\(defaults.edge.key)"
			client_secret: ""
			realm:         ""
			jwt_authn_provider: {
				keycloak: {
					issuer: "\(endpoint)/auth/realms/\(realm)"
					audiences: ["\(defaults.edge.key)"]
					local_jwks: {
						inline_string: #"""
					  {}
					  """#
					}
					// If you want to use a remote JWKS provider, comment out local_jwks above, and 
					// uncomment the below remote_jwks configuration. There are coinciding configurations
					// in ./gm/outputs/edge.cue that you will also need to uncomment.
					// remote_jwks: {
					//  http_uri: {
					//   uri:     "\(endpoint)/auth/realms/\(realm)/protocol/openid-connect/certs"
					//   cluster: "edge_plus_to_keycloak" // this key should be unique across the mesh
					//  }
					// }
				}
			}
		}
	}
}
