# produce-aisle (CUE Edition)

Here we demonstrate configuring a local mesh with configuration written entirely
in CUE.

## Project Layout

* **cue.mod** is a directory that marks this repo as a cue module. This dir is
  managed by the `cue` CLI.
* **cue.mod/module.cue** contains our module name: "produce.local". We use this
  name to import packages, for instance the `gm` package.
* **gm** is a package that holds all the Grey Matter schemas.
* **defaults.cue** is a cue file in `package mesh`.
* **1.7** is a directory of example mesh configs, our concrete values. These
  configs are all known to work with v1.7.0
* **comparison** is an export of a test mesh, used for comparing values emitted
  from CUE to the values emitted by our raw JSON configs.
* **export.sh** is a wrapper script that shells out to `cue` and `jq` to render
  mesh configs in a familiar format
* **sync.sh** wraps the latest `greymatter` CLI, and syncs the cue configs on
  disk to Control API.
* **TUTORIAL.md** is an introduction to CUE.

Note, **defaults.cue** could be named anything, and `package mesh` could just
as well be `package dodge_caravan`. All that matters is that both **defaults**
and the files in 1.7 declare the same package.

## Requirements

* A `greymatter` CLI built from the `main` branch. You need the _latest_ CLI.
* The `cue` CLI
* `jq`
* A local gm-e2e configuration, if you want to actually run this mesh.

## Explore Config Outputs

The **1.7** directory, when combined with **defaults.cue**, renders to a single
JSON object of the following shape (abridged).

```json
{
  "domains": {
    "pear": {
      "port": 9002,
      "domain_key": "pear",
      "zone_key": "default-zone",
      "name": "*"
    },
    "apple": {...},
    "banana": {...},
    "lettuce": {...},
    "edge": {...}
  },
  "clusters": {...},
  "listeners": {...},
  "proxies": {...},
  "routes": {...}
}
```

Render the entire object like this.

```
cue export ./1.7/
```

The immediate children of each mesh config type is a key that corresponds to
the primary key for that type. In our expanded example of above, the children
of "domains" correspond to the "domain_key" field. Under clusters, the child
keys would correspond to the "cluster_key" field, etc.

The sync.sh script extracts mesh configs from this object and applies them.

<details>
<summary>Sync output (requires latest CLI)</summary>

```
0 % ./sync.sh 
2021/10/24 15:21:23 type: domain code: 200 primary key: apple
2021/10/24 15:21:23 type: domain code: 200 primary key: banana
2021/10/24 15:21:23 type: domain code: 200 primary key: edge
2021/10/24 15:21:23 type: domain code: 200 primary key: lettuce
2021/10/24 15:21:23 type: domain code: 200 primary key: pear
2021/10/24 15:21:24 type: cluster code: 200 primary key: apple-local
2021/10/24 15:21:24 type: cluster code: 200 primary key: apple
2021/10/24 15:21:24 type: cluster code: 200 primary key: banana-local
2021/10/24 15:21:24 type: cluster code: 200 primary key: banana
2021/10/24 15:21:24 type: cluster code: 200 primary key: control-api
2021/10/24 15:21:24 type: cluster code: 200 primary key: dashboard
2021/10/24 15:21:24 type: cluster code: 200 primary key: lettuce-local
2021/10/24 15:21:24 type: cluster code: 200 primary key: lettuce
2021/10/24 15:21:24 type: cluster code: 200 primary key: pear-local
2021/10/24 15:21:24 type: cluster code: 200 primary key: pear
2021/10/24 15:21:24 type: cluster code: 200 primary key: catalog
2021/10/24 15:21:24 type: listener code: 200 primary key: apple
2021/10/24 15:21:24 type: listener code: 200 primary key: banana
2021/10/24 15:21:24 type: listener code: 200 primary key: lettuce
2021/10/24 15:21:24 type: listener code: 200 primary key: pear
2021/10/24 15:21:24 type: proxy code: 200 primary key: apple
2021/10/24 15:21:24 type: proxy code: 200 primary key: banana
2021/10/24 15:21:24 type: proxy code: 200 primary key: edge
2021/10/24 15:21:24 type: proxy code: 200 primary key: lettuce
2021/10/24 15:21:24 type: proxy code: 200 primary key: pear
2021/10/24 15:21:24 type: route code: 200 primary key: apple-local
2021/10/24 15:21:24 type: route code: 200 primary key: apple
2021/10/24 15:21:24 type: route code: 200 primary key: banana-local
2021/10/24 15:21:24 type: route code: 200 primary key: banana
2021/10/24 15:21:24 type: route code: 200 primary key: control-api
2021/10/24 15:21:24 type: route code: 200 primary key: root
2021/10/24 15:21:24 type: route code: 200 primary key: lettuce-local
2021/10/24 15:21:24 type: route code: 200 primary key: lettuce
2021/10/24 15:21:24 type: route code: 200 primary key: pear-local
2021/10/24 15:21:24 type: route code: 200 primary key: pear
2021/10/24 15:21:24 type: route code: 200 primary key: catalog
```

</details>

Render individual sub-fields with the `-e` (expression) flag. We need quotes
to access keys that contain hyphens (see TUTORIAL).

```
cue export ./1.7/ -e 'clusters.apple'
cue export ./1.7/ -e 'clusters."apple-local"'
cue export ./1.7/ -e 'clusters["apple-local"]'
```

Our export.sh script converts the top-level subfields ("domains", "clusters", etc)
into arrays of objects that is easier for our sync script.sh to iterate.

```
./export.sh domains
```

## Repo Stats

Count lines of CUE

```
cat defaults.cue 1.7/*.cue | wc -l
```

Count lines of CUE without whitespace or comments

```
cat defaults.cue 1.7/*.cue | awk '!/^(\s*|\/\/.*)$/' | wc -l
```

_Note: we exclude the gm package from our count, because users will have that generated for them_
