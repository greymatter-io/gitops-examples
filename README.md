# produce-aisle

A test gitops repository for `greymatter sync`


## Getting Values

```
cue export ./1.7/ -e 'clusters["apple-local"]'
```

With our script

```
./export.sh domains | jq --sort-keys '.[] | select(.domain_key == "lettuce")'
```
_In this example we export the lettuce domain_
