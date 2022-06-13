# Grey Matter Produce Aisle

An example for a dev-team GitOps repository usng CUE :rocket:

## Prerequisites

* `greymatter` CLI v4.0.0+
* [CUE](https://cuelang.org/docs/install/)
* `jq`

## Getting Started

### Setting up the repo

Install the greymatter-cue submodule so you can evaluate CUE:

```sh
./scripts/setup
```

After the initial setup, you can run bootstrap to upgrade the greymatter-cue API definitions:

```sh
./scripts/bootstrap
```

### Fetching the intermediates.cue

In order for the CUE to evaluate, you must combine it with an intermediates.cue file.
Intermediates holds the rules, mappings, and other advanced CUE constructs that allows
for an easier configuration experience.

According to our recommended GitOps flow, that file lives in an organization's 'core' repo
and is maintained by IT admins, SREs, or similar people.

If you are looking to run produce-aisle as a test, or otherwise do not have an enterprise 
intermediates, you can choose our gitops-core example default:

```sh
curl https://raw.githubusercontent.com/greymatter-io/gitops-core/main/gm/intermediates.cue | sed -E 's/package .+/package services/'  >> ./services/intermediates.cue
```

If you are basing your own "dev team" repository off produce-aisle, please go fetch it from there
and store it at services/intermediates.cue. You **must** ensure the intermediates.cue you download contains the same
package as your service CUE else CUE will not unify it.  

> We recommend adding a curl command to fetch your intermediates (like the one above) into the bootstrap or update scripts (./scripts/update) to assist with upgrades. 

Additionally, you may need to modify or replace the project's input.cue to include data set by enterprise 
IT admins that their intermediates.cue depends on.

### CUE

We write mesh configurations in [CUE](https://cuelang.org/), a fantastic data validation language. It's quite cutting edge,
but not hard to learn. We put together a quick crash course you can read in TUTORIAL.md. You can also checkout the official [CUE
documentation](https://cuelang.org/docs/), [cuetorials](https://cuetorials.com/), and the [CUE playground](https://cuelang.org/play/#cue@export@cue).

## Project Layout

* `cue.mod`: a directory that marks this repo as a cue module. This dir is
  managed by the `cue` CLI.
* `cue.mod/module.cue`: contains our module name: "produce.local". CUE modules are logical groupings of packages
   and enable certain features like imports.
* `cue.mod/pkg`: a package that holds all the Grey Matter and Envoy config schemas in CUE.
* `services/inputs.cue`: a cue file in `package services` that contains defaults, overrides, and user inputted values.
* `services/fruits`: an example application deployment
* `services/vegetables`: another example application deployment
* `services`:a directory of example service configs, and our concrete values. These
  configs are all known to work with Grey Matter `v1.7.0+`.
* `EXPORT.cue`: a file storing the final CUE keys to export. The fields must be structured as arrays of configs, else the greymatter
   CLI will not parse it. 
* `manifests`: example k8s manifests to test out the mesh configurations
* `TUTORIAL.md`: an introduction to CUE.

## Explore Config Outputs

The `EXPORT.cue` file renders your configurations you've defined in the service 
package. This includes all defaults defined in `inputs`, all templates in `intermediates`,
and your final service configurations in `services`.

You can check out rendered output by running commands like the following:

```sh
cue eval -c EXPORT.cue --out json -e fruit_configs # just the fruit configurations
cue eval -c EXPORT.cue --out yaml -e vegetable_configs # just the vegetable configurations
cue eval -c EXPORT.cue --out json -e configs # all the configurations
```

If you want a full output of configs defined in the `EXPORT` file you can run:

```sh
cue eval EXPORT.cue
```

## Applying Configs to a Mesh

To apply the configurations for the produce aisle services, use the `greymatter sync` comamnd:
```
greymatter sync --report cue -e configs
```

Or you can launch a sync container with the `greymatter k8s sync` command.

Make sure to apply the starter k8s manifests in `./manifets/`.

## Troubleshooting and Gotchas

* Deployed services not running with a sidecar?
  You need to add produce-aisle to the `watched_namespace` array in the operator configs.
* Make sure your CLI configuration file includes a catalog block with a host string that contains the url prefix to catalog.
  e.g. http://domain.com/services/catalog
* Make sure your intermediates.cue's package matches your service cue's package. If they do not, then CUE will not evaulate them together.
