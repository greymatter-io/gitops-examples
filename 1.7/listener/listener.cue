package mesh

listener_key: "edge"
zone_key:     "default-zone"
name:         "edge"
domain_keys: ["edge"]
active_http_filters: ["gm.metrics"]
ip:       "0.0.0.0"
port:     10808
protocol: "http_auto"
http_filters: gm_metrics: {
	metrics_port:                               310808
	metrics_host:                               "0.0.0.0"
	metrics_dashboard_uri_path:                 "/metrics"
	metrics_prometheus_uri_path:                "/prometheus"
	metrics_ring_buffer_size:                   4096
	prometheus_system_metrics_interval_seconds: 15
	metrics_key_function:                       "depth"
	metrics_key_depth:                          "3"
	metrics_receiver: redis_connection_string: "redis://127.0.0.1:6379"
}
