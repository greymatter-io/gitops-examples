package grocerylist

config: {
	// enable Spire-based mTLS
	spire: bool | *false @tag(spire,type=bool)

	mesh: {
		metadata: {
			name: string | *"greymatter-mesh"
		}
		spec: {
			zone: string | *"default-zone"
			images: {
				proxy: string | *"quay.io/greymatterio/gm-proxy:1.7.1"
			}
		}
	}

	global_ports: {
		default_ingress: 10808
		metrics:         8081
	}

	redis: {
		key:          "redis"
		ingress_port: 10910
	}

	// greymatter.io core edge input configurations
	edge: {
		key:          "edge-grocerylist"
		ingress_port: 10809
		enable_tls:   false
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
