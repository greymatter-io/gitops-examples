# What you need to know about CUE

## Basics

When CUE is exported to JSON, every value in every (processed) file is unified 
into one giant object.

```bash
% echo 'name: "Vlad"' > /tmp/name.cue
% echo 'disposition: "cheerful"' > /tmp/disposition.cue
% cue export /tmp/name.cue /tmp/disposition.cue 
{
    "name": "Vlad",
    "disposition": "cheerful"
}
```
_Note: export is a command to take cue files and render them to JSON_

CUE is a _superset_ of JSON. So it must render to either a top-level array, or a 
top-level object, but not both at the same time. Otherwise, unification fails.

```bash
% echo '[1, 2, 3]' > /tmp/array.cue
% echo '{"key": "value"}' > /tmp/object.cue
% cue export /tmp/array.cue /tmp/object.cue 
conflicting values [1,2,3] and {key:"value"} (mismatched types list and struct):
    ../../../../tmp/array.cue:1:1
    ../../../../tmp/object.cue:1:1
```

If you want to use hyphens in your keys, they must be quoted.

```bash
% echo 'works_fine: true' > unquoted_key.cue
% echo '"needs-quotes": true' > quoted_key.cue
% cue export /tmp/unquoted_key.cue /tmp/quoted_key.cue 
{
    "works_fine": true,
    "needs-quotes": true
}
```

_Tip: try unquoting the key with the hyphen_


Unification doesn't just unify across files, it is also a **global merge** of 
all types and values. The following fails, because the **types** are different.

```bash
% echo 'foo: "baz"' > /tmp/string_value.cue
% echo 'foo: 100' > /tmp/integer_value.cue
% cue export /tmp/string_value.cue /tmp/integer_value.cue 
foo: conflicting values "baz" and 100 (mismatched types string and int):
    ../../../../tmp/integer_value.cue:1:6
    ../../../../tmp/string_value.cue:1:6
```

But even if we quote the integer, it still fails, because the **values**
conflict and there is no way to unify everything into a top-level object.

```bash
% echo 'foo: "baz"' > /tmp/string_value.cue
% echo 'foo: "100"' > /tmp/integer_value.cue  # a string now
% cue export /tmp/string_value.cue /tmp/integer_value.cue
foo: conflicting values "100" and "baz":
    ../../../../tmp/integer_value.cue:1:6
    ../../../../tmp/string_value.cue:1:6
```

## Types and Values, `export` vs. `eval`

The `export` command unifies a bunch of files and emits a data format. We've
seen JSON, but you can export YAML, too.

```bash
% echo "primes: [1,2,3,5]" | cue export --out yaml - 
primes:
- 1
- 2
- 3
- 5
```

The `eval` command is different. It unifies and emits CUE itself.

```bash
% echo 'primes: [1,2,3,5], name: "carlos"' | cue eval -
primes: [1, 2, 3, 5]
name: "carlos"
```
_Tip: Multiple key-value pairs on one line is valid if they're comma-separated_

One of the uses of `eval` is transforming JSON into CUE.

```
% echo '{"primes": [1,2,3,5], "name": "carlos"}' | cue eval -
primes: [1, 2, 3, 5]
name: "carlos"
```

The `eval` command is also used for debugging the more advanced concepts of CUE.
Here we unify a **type constraint** on the key foo, with a concrete string value "baz".

```
% echo 'foo: string, foo: "baz"' | cue eval -        
foo: "baz"
```

CUE's unification will prefer concrete values when emitting CUE.

Importantly, concrete values are **required** for `export`! This `export` fails, 
because we don't provide a concrete value for the "age" key in our schema.

```
% echo 'name: string, age: int' > /tmp/schema.cue
% echo 'name: "Natasha"' > /tmp/concrete_values.cue
% cue export /tmp/concrete_values.cue /tmp/schema.cue 
age: incomplete value int
```

But `eval` succeeds. The `eval` unification _prefers_ concrete values but does
not require them.

```
% cue eval /tmp/concrete_values.cue /tmp/schema.cue 
name: "Natasha"
age:  int
```

CUE is all about defining schemas, after all.

## Setting default values

Default values are marked with an asterisk.

```cue
// Port is either some integer, or 8080 if not provided
port: int | *8080
```

```bash
% cue export /tmp/default_values.cue
{
    "port": 8080
}
```

## Constraining values, enum-style

Specific concrete values of a field can be constrained like this

```cue
// Must be one of these values
severity: "high" | "medium" | "low"
```

```
% echo 'severity: "high" | "medium" | "low"' > /tmp/severity.cue
% echo 'severity: "unknown"' | cat /tmp/severity.cue - | cue eval -
severity: 3 errors in empty disjunction:
severity: conflicting values "high" and "unknown":
    -:1:11
    -:2:11
severity: conflicting values "low" and "unknown":
    -:1:31
    -:2:11
severity: conflicting values "medium" and "unknown":
    -:1:20
    -:2:11

```

CUE calls these [disjunctions](https://cuelang.org/docs/tutorials/tour/types/disjunctions/)

## Defining Variables

CUE has "definitions", and you can use them like you would variable declarations
in other languages.

```
#DashboardPort: 1337

configs: {
    host: "localhost"
    port: #DashboardPort
}
```

But definitions are also for defining [struct types](https://cuelang.org/docs/tutorials/tour/types/optional/).

```
#Address: {
    street: string
    city:   string
    // postal_code is optional
    postal_code?:   string
}
```

## Type constraints with Structs

We can use the `&` symbol to apply a type definition to some concrete values,
and CUE will make sure we don't pass any illegal values.

Let's use that `#Address` definition from before.

```cue
// File: /tmp/destinations.cue

#Address: {
    street: string
    city:   string
    // postal_code is optional
    postal_code?:   string
}

white_house: #Address & {
    street: "1600 Penn. Ave."
    city:   "Washington"
}

louvre_museum: #Address & {
    street:      "99 rue de Rivoli"
    city:        "Paris"
    postal_code: "75001"
}
```

And note that **postal_code** is omitted from export, if not provided.

```
% cue export /tmp/destinations.cue
{
    "white_house": {
        "street": "1600 Penn. Ave.",
        "city": "Washington"
    },
    "louvre_museum": {
        "street": "99 rue de Rivoli",
        "city": "Paris",
        "postal_code": "75001"
    }
}
```

Interestingly, optional fields are also omitted from `eval`, if not required.

```txt
% cue eval /tmp/destinations.cue
#Address: {
    street: string
    city:   string
}
white_house: {
    street: "1600 Penn. Ave."
    city:   "Washington"
}
louvre_museum: {
    street:      "99 rue de Rivoli"
    city:        "Paris"
    postal_code: "75001"
}
```
