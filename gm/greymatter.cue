// Core proto files
package gm

// import "google/protobuf/duration.proto";
#Duration: {
	seconds?: int64
	nanos?:   int32
}

// `Any` contains an arbitrary serialized protocol buffer message along with a
// URL that describes the type of the serialized message.
// this is a google type
#Any: {
	typeUrl?: string
	value?:   bytes
}

#Checksum: {
	checksum?: string
}

#Metadata: {
	metadata?: [...#Metadatum]
}

#Metadatum: {
	key?:   string
	value?: string
}

#Listener: {
	listener_key: string
	zone_key:     string
	name:         string
	// Docs say deprecated: https://docs.greymatter.io/reference/api/fabric-api/listener#protocol
	protocol?: string
	active_network_filters?: [...string]
	// TODO: are we handling these correctly?
	// is _ the arbitrary type?
	network_filters?: _
	active_http_filters?: [...string]
	http_filters?: _
	ip:            string
	port:          int64
	domain_keys: [string]
	tracing_config:          #TracingConfig | *null
	secret?:                 #Secret
	org_key?:                string
	access_loggers?:         #AccessLoggers
	use_remote_address?:     bool
	http_protocol_options?:  #HTTPProtocolOptions
	http2_protocol_options?: #HTTP2ProtocolOptions
	stream_idle_timeout?:    string
	request_timeout?:        string
	drain_timeout?:          string
	delayed_close_timeout?:  string
	checksum?:               #Checksum
}

#HTTP2ProtocolOptions: {
	hpackTableSize?:                               uint32
	maxConcurrentStreams?:                         uint32
	initialStreamWindowSize?:                      uint32
	initialConnectionWindowSize?:                  uint32
	allowConnect?:                                 bool
	maxOutboundFrames?:                            uint32
	maxOutboundControlFrames?:                     uint32
	maxConsecutiveInboundFramesWithEmptyPayload?:  uint32
	maxInboundPriorityFramesPerStream?:            uint32
	maxInboundWindowUpdateFramesPerDataFrameSent?: uint32
	streamErrorOnInvalidHTTPMessaging?:            bool
}

#HTTPConnectionLoggers: {
	disabled?: bool
	fileLoggers?: [...#FileAccessLog]
	hTTPGRPCAccessLoggers?: [...#HTTPGRPCAccessLog]
}

#HTTPProtocolOptions: {
	allowAbsoluteURL?:     bool
	acceptHTTP10?:         bool
	defaultHostForHTTP10?: string
	headerKeyFormat?:      #HeaderKeyFormat
	enableTrailers?:       bool
}

#HTTPUpstreamLoggers: {
	disabled?: bool
	fileLoggers?: [...#FileAccessLog]
	hTTPGRPCAccessLoggers?: [...#HTTPGRPCAccessLog]
}

#TracingConfig: {
	ingress?: bool
	requestHeadersForTags?: [...string]
}

#HeaderKeyFormat: {
	properCaseWords?: bool
}

#Loggers: {
	disabled?: bool
	fileLoggers?: [...#FileAccessLog]
	hTTPGRPCAccessLoggers?: [...#HTTPGRPCAccessLog]
}

#AccessLoggers: {
	hTTPConnectionLoggers?: #Loggers
	hTTPUpstreamLoggers?:   #Loggers
}

#FileAccessLog: {
	path?:   string
	format?: string
	JSONFormat?: {
		[string]: string
	}
	typedJSONFormat?: {
		[string]: string
	}
}

#HTTPGRPCAccessLog: {
	commonConfig?: #GRPCCommonConfig
	additionalRequestHeaders?: [...string]
	additionalResponseHeaders?: [...string]
	additionalResponseTrailers?: [...string]
}

#ErrorCase: {
	attribute?: string
	msg?:       string
}

#From: {
	key?:   string
	value?: string
}

#To: {
	key?:   string
	value?: string
}

#GRPCCommonConfig: {
	logName?:     string
	gRPCService?: #GRPCService
}

#GRPCService: {
	clusterName?: string
}

#GoogleRE2: {
	maxProgramSize?: int64
}

#GoogleRe2: {
	maxProgramSize?: int64
}

#DataSource: {
	filename?:     string
	inlineString?: string
}

#CommonConfig: {
	logName?:     string
	gRPCService?: #GRPCService
}

#ValidationError: {
	errors?: [...#ErrorCase]
}

#ValidationErrorsByAttribute: {
}

#Percent: {
	value?: float64
}

#ResponseData: {
	// both fields are optional; so our default is empty object {}
	headers?: [...#HeaderDatum]
	cookies?: [...#CookieDatum]
}

#ResponseDatum: {
	name?:           string
	value?:          string
	valueIsLiteral?: bool
}

#HeaderDatum: {
	responseDatum?: #ResponseDatum
}

#CookieDatum: {
	responseDatum?: #ResponseDatum
	expiresInSec?:  uint32
	domain?:        string
	path?:          string
	secure?:        bool
	httpOnly?:      bool
	sameSite?:      string
}

#Secret: {
	secret_key?:  string
	secret_name?: string
	// renamed validation_name -> secret_validation_name
	secret_validation_name?:          string
	subject_names:                    [...string] | *null
	ecdh_curves:                      [...string] | *null
	forward_client_cert_details?:     string
	set_current_client_cert_details?: #SetCurrentClientCertDetails
	checksum:                         #Checksum | *""
}

#SSLConfig: {
	cipherFilter?: string
	protocols?: [...string]
	certKeyPairs?: [...#CertKeyPathPair]
	requireClientCerts?: bool
	trustFile?:          string
	SNI?: [...string]
	CRL?: #DataSource
}

#CertKeyPathPair: {
	certificatePath?: string
	keyPath?:         string
}

#SetCurrentClientCertDetails: {
	uri?: bool | *false
}

#CircuitBreakers: {
	maxConnections?:     int64
	maxPendingRequests?: int64
	maxRequests?:        int64
	maxRetries?:         int64
	maxConnectionPools?: int64
	trackRemaining?:     bool
}

#CircuitBreakersThresholds: {
	maxConnections?:     int64
	maxPendingRequests?: int64
	maxRequests?:        int64
	maxRetries?:         int64
	maxConnectionPools?: int64
	trackRemaining?:     bool
	high?:               #CircuitBreakers
}

#HealthCheck: {
	timeoutMsec?:               int64
	intervalMsec?:              int64
	intervalJitterMsec?:        int64
	unhealthyThreshold?:        int64
	healthyThreshold?:          int64
	reuseConnection?:           bool
	noTrafficIntervalMsec?:     int64
	unhealthyIntervalMsec?:     int64
	unhealthyEdgeIntervalMsec?: int64
	healthyEdgeIntervalMsec?:   int64
	healthChecker?:             #HealthChecker
}

#HealthChecker: {
	HTTPHealthCheck?: #HTTPHealthCheck
	TCPHealthCheck?:  #TCPHealthCheck
}

#TCPHealthCheck: {
	send?: string
	receive?: [...string]
}

#HTTPHealthCheck: {
	host?:        string
	path?:        string
	serviceName?: string
	request_headers_to_add?: [...#Metadata]
}

#OutlierDetection: {
	intervalMsec?:                       int64
	baseEjectionTimeMsec?:               int64
	maxEjectionPercent?:                 int64
	consecutive5xx?:                     int64
	enforcingConsecutive5xx?:            int64
	enforcingSuccessRate?:               int64
	successRateMinimumHosts?:            int64
	successRateRequestVolume?:           int64
	successRateStdevFactor?:             int64
	consecutiveGatewayFailure?:          int64
	enforcingConsecutiveGatewayFailure?: int64
}

#CommonLbConfig: {
	healthyPanicThreshold?:           #Percent
	zoneAwareLbConf?:                 #ZoneAwareLbConfig
	localityWeightedLbConf?:          #LocalityWeightedLbConfig
	updateMergeWindow?:               #Duration
	ignoreNewHostsUntilFirstHc?:      bool
	closeConnectionsOnHostSetChange?: bool
	consistentHashingLbConf?:         #ConsistentHashingLbConfig
}

#ConsistentHashingLbConfig: {
	useHostnameForHashing?: bool
}

#LeastRequestLbConfig: {
	choiceCount?: uint32
}

#LocalityWeightedLbConfig: {
}

#OriginalDstLbConfig: {
	useHTTPHeader?: bool
}

#RingHashLbConfig: {
	minimumRingSize?: uint64
	hashFunc?:        uint32
	maximumRingSize?: uint64
}

#ZoneAwareLbConfig: {
	routingEnabled?:     #Percent
	minClusterSize?:     uint64
	failTrafficOnPanic?: bool
}

#Cluster: {
	cluster_key:  string
	zone_key:     string
	name:         string
	require_tls?: bool
	secret?:      #Secret
	ssl_config?:  #SSLConfig
	instances?: [...#Instance]
	org_key?: string
	// modified from protobuf
	circuit_breakers?:  #CircuitBreakers | #CircuitBreakersThresholds | *null
	outlier_detection?: #OutlierDetection | *null
	health_checks?: [...#HealthCheck]
	lb_policy?:              string | *""
	http_protocol_options?:  #HTTPProtocolOptions
	http2_protocol_options?: #HTTP2ProtocolOptions
	protocol_selection?:     string
	ring_hash_lb_conf?:      #RingHashLbConfig
	original_dst_lb_conf?:   #OriginalDstLbConfig
	least_request_lb_conf?:  #LeastRequestLbConfig
	common_lb_conf?:         #CommonLbConfig
	checksum?:               #Checksum
}

#Instance: {
	host: string
	port: int64
	metadata?: [...#Metadata]
}

#Clusters: {
	clusters?: [...#Cluster]
}

#Domain: {
	domain_key: string
	zone_key:   string
	// Name is a virtual host pattern
	name: string | *"*"
	// Port should probably match Listener
	port:         int64
	ssl_config?:  #SSLConfig
	redirects?:   [...#Redirect] | *null
	cors_config?: #CorsConfig | *null
	aliases?:     [...string] | *null
	org_key?:     string
	force_https?: bool | *false
	custom_headers?: [...#Header]
	checksum?: #Checksum
	// not in protobuf?
	gzip_enabled?: bool | *false
}

#CorsConfig: {
	allowedOrigins?: [...#AllowOriginStringMatchItem]
	allowCredentials?: bool
	exposedHeaders?: [...string]
	maxAge?: int64
	allowedMethods?: [...string]
	allowedHeaders?: [...string]
}

#AllowOriginStringMatchItem: {
	matchType?: string
	value?:     string
}

#Route: {
	route_key:  string
	domain_key: string
	zone_key:   string
	// path is deprecated
	path?:          string
	route_match?:   #RouteMatch
	prefix_rewrite: string | *null
	redirects?: [...#Redirect]
	shared_rules_key?: string
	rules:             [...#Rule] | *null
	response_data?:    #ResponseData
	cohort_seed?:      string | *null
	retry_policy?:     #RetryPolicy | *null
	high_priority?:    bool
	filter_metadata?: {
		[string]: #Metadata
	}
	filter_configs?: {
		[string]: #Any
	}
	timeout?:      string
	idle_timeout?: string
	org_key?:      string
	request_headers_to_add?: [...#Header]
	request_headers_to_remove?: [...string]
	response_headers_to_add?: [...#Header]
	response_headers_to_remove?: [...string]
	checksum?: #Checksum
}

#RouteMatch: {
	path:       string
	match_type: string
}

#Redirect: {
	name?:          string
	from?:          string
	to?:            string
	redirect_type?: string
	header_constraints?: [...#HeaderConstraint]
}

#Header: {
	key?:   string
	value?: string
}

#RetryPolicy: {
	numRetries?:                    int64
	perTryTimeoutMsec?:             int64
	timeoutMsec?:                   int64
	retryOn?:                       string
	retryPriority?:                 string
	retryHostPredicate?:            string
	hostSelectionRetryMaxAttempts?: int64
	retriableStatusCodes?:          int64
	retryBackOff?:                  #BackOff
	retriableHeaders?:              #HeaderMatcher
	retriableRequestHeaders?:       #HeaderMatcher
}

#RetriableHeaders: {
	name?:           string
	exactMatch?:     string
	regexMatch?:     string
	safeRegexMatch?: #RegexMatcher
	rangeMatch?:     #RangeMatch
	presentMatch?:   bool
	prefixMatch?:    string
	suffixMatch?:    string
	invertMatch?:    bool
}

#RetriableRequestHeaders: {
	name?:           string
	exactMatch?:     string
	regexMatch?:     string
	safeRegexMatch?: #RegexMatcher
	rangeMatch?:     #RangeMatch
	presentMatch?:   bool
	prefixMatch?:    string
	suffixMatch?:    string
	invertMatch?:    bool
}

#SafeRegexMatch: {
	googleRE2?: #GoogleRe2
	regex?:     string
}

#HeaderMatcher: {
	name?:           string
	exactMatch?:     string
	regexMatch?:     string
	safeRegexMatch?: #RegexMatcher
	rangeMatch?:     #RangeMatch
	presentMatch?:   bool
	prefixMatch?:    string
	suffixMatch?:    string
	invertMatch?:    bool
}

#RangeMatch: {
	start?: int64
	end?:   int64
}

#RegexMatcher: {
	googleRE2?: #GoogleRe2
	regex?:     string
}

#BackOff: {
	baseInterval?: string
	maxInterval?:  string
}

#HeaderConstraint: {
	name?:          string
	value?:         string
	caseSensitive?: bool
	invert?:        bool
}

#AllConstraints: {
	light?: [...#ClusterConstraint] | *null
	dark?:  [...#ClusterConstraint] | *null
	tap?:   [...#ClusterConstraint] | *null
}

#Constraints: {
	light?: [...#ClusterConstraint]
	dark?: [...#ClusterConstraint]
	tap?: [...#ClusterConstraint]
}

#ClusterConstraint: {
	constraint_key: string | *""
	cluster_key:    string
	metadata?:      [...#Metadata] | *null
	properties?:    [...#Metadata] | *null
	response_data?: #ResponseData
	// We probably do not want to default the weight value
	weight: uint32
}

#SharedRules: {
	shared_rules_key: string
	name?:            string
	zone_key:         string
	default:          #AllConstraints
	rules:            [...#Rule] | *null
	response_data:    #ResponseData
	cohort_seed?:     string | *null
	properties?:      [...#Metadata] | *null
	retry_policy?:    #RetryPolicy | *null
	org_key?:         string
	checksum?:        #Checksum
}

#Rule: {
	ruleKey?: string
	methods?: [...string]
	matches?: [...#Match]
	constraints?: #AllConstraints
	cohort_seed?: string
}

#Match: {
	kind?:     string
	behavior?: string
	from?:     #Metadatum
	to?:       #Metadatum
}

#Mesh: {
	name?:     string
	zone_key?: string
	roots?: [...#Service]
	orphans?: #Orphans
}

#Orphans: {
	listeners?: [...#Listener]
	domains?: [...#Domain]
	routes?: [...#RouteTree]
	shared_rules?: [...#SharedRules]
	clusters?: [...#Cluster]
}

#Org: {
	org_key?:      string
	name?:         string
	contactEmail?: string
	checksum?:     #Checksum
}

// A PolicyRequest requests a versioned list of all API objects
#PolicyRequest: {
	// The policy_version field should be utilized as a tracker for the current state of the mesh.
	// This means that if properly implemented, API could rollback as well as allow requesting of specific API versions
	// handling the case of incorrect or broken config. This should act as a counter when new objects are created or changed
	// and should be atomic in nature.
	policyVersion?: string

	// The stream_nonce field acts as a counter for actions taken across the stream. This should be all logged as all
	// requests and responses.
	streamNonce?: string

	// The policy_type identifies what the API should send back in the response. If left blank the API should respond as a wildcard with all resources
	policyType?: string
}

// A PolicyResponse
#PolicyResponse: {
	// The policy_version field should be utilized as a tracker for the current state of the mesh.
	// This means that if properly implemented, API could rollback as well as allow requesting of specific API versions
	// handling the case of incorrect or broken config. This should act as a counter when new objects are created or changed
	// and should be atomic in nature. When responding to a request, the policy_version should contain the applied version as an ACK.
	// If the version is not agreed upon between the API and Control, then an error has ocurred and the user should be notified.
	policyVersion?: string

	// The stream_nonce field acts as a counter for actions taken across the stream. This should be all logged as all
	// requests and responses.
	streamNonce?: string

	// The resources field will contain the serialized bytes that are to be sent to the Control server. Contained will be
	// objects that have been modified, added, or deleted. It is a state holder that Control can read and apply.
	resources?: [...#Resource]

	// The status represents status codes according to the action taken.
	// If an application of config was successful, a 200 should be sent back, etc...
	status?: #Status

	// Error contains error information. If empty then the API server can assume that no error has occurred.
	error?: string
}

// Resource contains mesh policies that must flow down to Control
#Resource: {
	// Type will define the type of resource this wrapper object holds
	type?: string

	// Serialized bytes that will be sent through containing the resourece itself
	resource?: bytes
}

#Proxy: {
	proxy_key: string
	zone_key:  string
	name:      string
	domain_keys: [...string]
	listener_keys: [...string]
	listeners: [...#Listener] | *null
	upgrades?: string
	active_filters?: [...string]
	filters?:  _
	org_key?:  string
	checksum?: #Checksum
}

#Service: {
	name?:     string
	proxy?:    #Proxy
	zone_key?: string
	listeners?: [...#Listener]
	domains?: [...#DomainTree]
}

#DomainTree: {
	domain?: #Domain
	routes?: [...#RouteTree]
}

#RouteTree: {
	route?: #Route
	shared_rules?: [...#SharedRulesTree]
	rule_tree?: #RuleTree
}

#RuleTree: {
	rule?: #Rule
	clusters?: [...#DeepCluster]
}

#SharedRulesTree: {
	shared_rules?: #SharedRules
	clusters?: [...#DeepCluster]
}

#DeepCluster: {
	cluster?: #Cluster
	service?: #Service
}

#Zone: {
	zone_key?: string
	name?:     string
	org_key?:  string
	checksum?: #Checksum
}

// The `Status` type defines a logical error model that is suitable for
// different programming environments, including REST APIs and RPC APIs. It is
// used by [gRPC](https://github.com/grpc). Each `Status` message contains
// three pieces of data: error code, error message, and error details.
//
// You can find out more about this error model and how to work with it in the
// [API Design Guide](https://cloud.google.com/apis/design/errors).
#Status: {
	// The status code, which should be an enum value of [google.rpc.Code][google.rpc.Code].
	code?: int32

	// A developer-facing error message, which should be in English. Any
	// user-facing error message should be localized and sent in the
	// [google.rpc.Status.details][google.rpc.Status.details] field, or localized by the client.
	message?: string

	// A list of messages that carry the error details.  There is a common set of
	// message types for APIs to use.
	details?: [...#Any]
}
