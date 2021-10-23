package mesh

// import "produce.local/gm"

// Original
// cluster_key: "apple-local"
// zone_key:    "default-zone"
// name:        "apple-local"
// instances: [ {host: "127.0.0.1", port: 42071}]


clusters: "apple-local": {
    instances: [ {host: #localhost, port: #applePort}]
}