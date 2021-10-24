package mesh

// Edge

// Templates are defined in defaults.cue, and defaults.cue imports schemas from gm/greymatter.cue

// Provide Name=edge to the proxies template
proxies: edge: {}

// Provide Name=edge to the domains template, and also set the
// nest field "port" to the value of #edgePort
domains: edge: port: #edgePort
