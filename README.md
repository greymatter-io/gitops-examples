# produce-aisle (CUE Edition)

Here we demonstrate configuring a local mesh with configuration written entirely
in CUE, henceforth stylized as "CUE".





    



## Getting Values

```
cue export ./1.7/ -e 'clusters["apple-local"]'
```

With our script

```
./export.sh domains | jq --sort-keys '.[] | select(.domain_key == "lettuce")'
```
_In this example we export the lettuce domain_
