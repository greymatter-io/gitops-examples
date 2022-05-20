# Grey Matter Produce Aisle

An example repository for writing Grey Matter CUE! :rocket:

## Prerequisites

* `greymatter` CLI v4.0.0+
* [CUE](https://cuelang.org/docs/install/)
* `jq`

## Getting Started
Install the greymatter-cue submodule so you can evaluate CUE:
```
./scripts/setup
```

After the initial setup you can run:
```
./scripts/bootstrap
```

To format or evaluate CUE, run the build script:
```
./scripts/build help
```

> NOTE: no args to the build script will evaluate whats in `EXPORT.cue`.

## Project Layout

* `cue.mod`: a directory that marks this repo as a cue module. This dir is
  managed by the `cue` CLI.
* `cue.mod/module.cue`: contains our module name: "produce.local". We use this
  name to import packages, for instance the `gm` package.
* `cue.mod/pkg`: a package that holds all the Grey Matter and Envoy config schemas in CUE.
* `services/inputs.cue`: a cue file in `package services` that contains defaults, overrides, and user inputted values.
* `services/intermediates.cue`: a cue file in `package services` that contains predefined mesh object templates that services 
  can override and use in their configuration files.
* `services/greymatter`: core Grey Matter service configurations 
* `services/hamburger`: an example application deployment
* `services/applie-pie`: an example application deployment with 2 separate services
* `services`:a directory of example service configs, and our concrete values. These
  configs are all known to work with Grey Matter `v1.7.0+`.
* `EXPORT.cue`: the end all final conglomerate of your mesh configurations in their respective groupings. These is what is meant
  to be evaluated when using the CUE cli and Grey Matter CLI sync. This file should be strictly structured as arrays with your configurations 
  to be exported.
* `TUTORIAL.md`: an introduction to CUE.

> NOTE: your input/intermediate CUE files should live in the same `package` as your mesh configurations. 

## Explore Config Outputs

The `EXPORT.cue` file renders your configurations you've defined in the service 
package. This includes all defaults defined in `inputs`, all templates in `intermediates`,
and your final service configurations in `services`.

You can check out rendered output by running commands like the following:
```bash
cue eval -c EXPORT.cue --out json -e greymatter_configs
cue eval -c EXPORT.cue --out yaml -e application_configs
cue eval -c EXPORT.cue --out json -e all_configs # a combined array of core service+application configs
```

If you want a full output of configs defined in the `EXPORT` file you can run:
```bash
cue eval EXPORT.cue
```

## Further Reading

For more information on how this CUE works inside a Grey Matter mesh, check out our
official documentation site: [docs.greymatter.io](https://docs-preview.greymatter.io)