package greymatter

// INFORMATION - Values in the mesh section must not be changed arbitrarily
// because a tenant's project hooks into an existing enterprise's mesh.
// Change these values in accordance with enterprise-level direction. This
// may require coordination with an operations team.
mesh: {
	// Mesh zone must match the enterprise zone so services are discovered
	// by the greymatter control plane. Consult with the enterprise operations
	// team if you are not sure about this value. It's important that the zone
	// matches the enterprise zone before deploying tenant services.
	zone: "default-zone"
	// Mesh name must match the enterprise mesh name so services appear
	// in the greymatter dashboard.
	name: "greymatter-mesh"
	// Enabling Spire creates the necessary configurations to support sidecar
	// to sidecar mutual TLS (mTLS) connections. The pre-requisite for this
	// feature is that the enterprise team has deployed Spire or is using an
	// external one. Therefore, enabling Spire on tenant sidecars should be
	// done in accordance with enterprise-level Spire settings. The above mesh
	// and zone names are used in Spire configuration and must match enterprise
	// configurations.
	enable_spire: false
	// Sidecars publish metrics to Redis in support of sidecar/service
	// health checks in the dashboard. A tenant does not need to change
	// these configurations. Doing so may prevent operators from using
	// health checks to troubleshoot sidecars/services.
	redis: {
		// The Redis key identifies the target for sidecar to Redis
		// egress communication.
		key: "redis"
		// The Redis port indicates the localhost port from which egress
		// requests flow out from the sidecar to Redis.
		ingress_port: 10910
	}
}

// A subset of a tenant's sidecar configurations can be modified in
// isolation from the enterprise. These do not impact global sidecar
// configurations.
sidecars: {
	// The ingress port that all tenant sidecars will listen on.
	ingress_port: 10808
}

// Tenant edge gateway for north/south traffic control. This is a separate
// edge from the core greymatter edge. It is intended to provide tenants
// with an edge gateway that has capabilities unique to the tenant.
edge: {
	// The edge key must be unique from other edges in the mesh.
	key: "edge-grocerylist"
	// The default ingress port to the edge proxy.
	ingress_port: 10809
	// Enables TLS on the edge proxy. Certificates will need to be generated
	// and mounted into the edge proxy.
	// See https://docs.greymatter.io/guides/edge-tls for details.
	enable_tls: false
	// Enables OIDC filters on a tenant edge proxy.
	enable_oidc: false
	// Configure an OIDC provider for oAuth single-sign-on at the edge.
	// Currently only supports Keycloak.
	oidc: {
		endpoint_host: ""
		endpoint_port: 0
		endpoint:      "https://\(endpoint_host):\(endpoint_port)"
		domain:        ""
		client_id:     "\(edge.key)"
		client_secret: ""
		realm:         ""
		jwt_authn_provider: {
			keycloak: {
				issuer: "\(endpoint)/auth/realms/\(realm)"
				audiences: ["\(edge.key)"]
				local_jwks: {
					inline_string: #"""
						{}
						"""#
				}
				// If you want to use a remote JWKS provider, comment out
				// local_jwks above, and uncomment the below remote_jwks
				// configuration. There are coinciding configurations
				// in ./greymatter/core/edge.cue that you will also need to
				// uncomment.
				// remote_jwks: {
				//  http_uri: {
				//   uri:     "\(endpoint)/auth/realms/\(realm)/protocol/openid-connect/certs"
				//   // this key should be unique across the mesh
				//   cluster: "edge_plus_to_keycloak"
				//  }
				// }
			}
		}
	}
}
