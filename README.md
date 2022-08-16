# greymatter.io Gitops Examples

An example for a dev-team GitOps repository usng CUE :rocket:

## Prerequisites

* `greymatter` CLI v4.1.2+
* [CUE](https://cuelang.org/docs/install/)
* `jq`

## Getting Started

### Setting up the repo

Install the greymatter-cue submodule so you can evaluate CUE:

```sh
./scripts/setup
```

After the initial setup, you can run bootstrap to upgrade the greymatter-cue
API definitions:

```sh
./scripts/bootstrap
```

### CUE

We write mesh configurations in [CUE](https://cuelang.org/), a fantastic data
validation language. It's quite cutting edge, but not hard to learn. We put
together a quick crash course you can read in TUTORIAL.md. You can also
checkout the official [CUE documentation](https://cuelang.org/docs/), [cuetorials](https://cuetorials.com/),
and the [CUE playground](https://cuelang.org/play/#cue@export@cue).

## Project Layout

* `cue.mod`: A directory that marks this repo as a cue module. This dir is
  managed by the `cue` CLI.
* `cue.mod/module.cue`: Contains our module name: "examples.local". CUE modules
  are logical groupings of packages and enable certain features like imports.
* `cue.mod/pkg`: A package that holds all greymatter.io and Envoy config
  CUE schemas.
* `greymatter`: A directory of example CUE configs. These configs are all known
  to work with greymatter.io `v1.7.0+`.
* `./greymatter/inputs.cue`: A CUE file in `package examples` that contains
  defaults, overrides, and user generated values.
* `./greymatter/intermediates.cue`: A CUE file in `package examples` containing
  default greymatter.io configurations. Many default HTTP filter configs can be
  found in this file.
* `EXPORT.cue`: A file storing the final CUE keys to export. The fields must be
  structured as arrays of configs, so that the greymatter.io CLI can parse it. 
* `k8s`: Kubernetes manifests for the example services.
* `TUTORIAL.md`: an introduction to CUE.

## Explore Config Outputs

The `EXPORT.cue` file renders your configurations you've defined in the
`examples` package. This includes all defaults defined in
`greymatter/inputs.cue`, all default configurations in
`greymatter/intermediates.cue`, and your final service configurations in
`greymatter/core` and `greymatter/grocerylist`.

You can evaluate the final output by running the following commands:

```sh
# evaluate the grocerylist_config configurations
cue eval -c EXPORT.cue --out json -e grocerylist_config

# evaluate all configurations
cue eval -c EXPORT.cue --out json -e configs

# evaluate full output of EXPORT.cue
cue eval EXPORT.cue
```

## Applying Configs to a Mesh

To apply the configurations for these services, use the `greymatter sync` command:

```sh
greymatter sync --report cue -e configs
```

Or you can launch a sync container with the `greymatter k8s sync` command.

Make sure to apply the starter k8s manifests in the `./k8s` folder.

## Troubleshooting and Gotchas

* Deployed services not running with a sidecar?
  You need to add gitops-examples to the `watched_namespace` array in the operator configs.
* Make sure your CLI configuration file includes a catalog block with a host string that contains the url prefix to catalog.
  e.g. http://domain.com/services/catalog
* Make sure your intermediates.cue's package matches your service cue's package. If they do not, then CUE will not evaulate them together.
