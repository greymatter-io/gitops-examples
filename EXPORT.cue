// All Grey Matter config objects for core componenents drawn together
// for simultaneous deployment.

// EXPORT.cue is the finalized configuration file that gets read by a GitOPS tool
// to import and sync configuration with a remote deployed Grey Matter instance.

// You may specify which array of configs you'd like to sync or bundle them all in one.
// We recommend splitting out your configs through namespaces such as core services,
// business applications, etc...

// example evaluation commands:
// cue eval -c EXPORT.cue --out json -e configs

// This package name refers to your target mesh. We are attempting to write configs for the "produce"
// Grey Matter mesh so we all our top level package "produce". This does not need to match the cue module name.
package produce

import (
	// Point to the services folder in the mesh package since that's where we actually 
	// define our mesh configs for individual applications.
	vegetables "produce.local/services/vegetables:services"
	fruits "produce.local/services/fruits:services"

	// NOTE: import paths must be aliased to their respective folders under the services package
	// otherwise CUE will not evaluate properly. An example import path:
	// 
	// alias_name "<cue_module>/{path}:<name_of_directory_package>"
)

fruit_configs: fruits.Banana.config +
	fruits.Apple.config

vegetable_configs: vegetables.Lettuce.config +
	vegetables.Tomato.config

configs: fruit_configs + vegetable_configs
