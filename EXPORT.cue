// All Grey Matter config objects for core componenents drawn together
// for simultaneous deployment.

// EXPORT.cue is the finalized configuration file that gets read by a GitOPS tool
// to import and sync configuration with a remote deployed Grey Matter instance.

// You may specify which array of configs you'd like to sync or bundle them all in one.
// We recommend splitting out your configs through namespaces such as core services,
// business applications, etc...

// example evaluation commands:
// cue eval -c EXPORT.cue --out json -e greymatter_configs
// cue eval -c EXPORT.cue --out yaml -e service_configs
// cue eval -c EXPORT.cue --out json -e all_configs

// This package name refers to your target mesh. We are attempting to write configs for the "produce"
// Grey Matter mesh so we all our top level package "produce". This does not need to match the cue module name.
package produce

import (
	// Point to the services folder in the mesh package since that's where we actually 
	// define our mesh configs for individual applications.
	greymatter "produce.local/services/greymatter:services"

	applications "produce.local/services/applications:services"
	apple "produce.local/services/apple:services"

	// NOTE: import paths must be aliased to their respective folders under the services package
	// otherwise CUE will not evaluate properly. An example import path:
	// 
	// alias_name "<cue_module>/{path}:<name_of_directory_package>"
)

greymatter_configs: greymatter.Redis.config +
	greymatter.Edge.config +
	greymatter.Catalog.config +
	greymatter.Control.config +
	greymatter.Dashboard.config +
	greymatter.Catalog.config

application_configs: applications.Banana.config +
	applications.Lettuce.config +
	apple.Apple.config

all_configs: greymatter_configs + application_configs
