
```
version: "3"
services:


  yarrml-rdfizer: 
    image: markw/yarrrml-rml-ejp:0.0.3
    container_name: yarrrml-rdfizer
    environment:
      # choices: nquads (default), trig, trix, jsonld, hdt, turtle
      - SERIALIZATION=nquads
    ports:
      - "4567:4567"
    volumes:
      - ./data:/mnt/data
```

Put your data and your yarrrml files in the ./data folder, following these naming conventions:

XXX.csv
XXX_yarrrml.yaml

or 

YYY.json
YYY_yarrrml.yaml

In your YAML file, the "access" clause should point to `/mnt/data`  (`/mnt/data/XXX.csv` for example)

```
sources:
  policy:
    access: /mnt/data/data.json
    referenceFormulation: jsonpath
    iterator: "$.policies[*]"
```

## Examples for ODRL

Exemplar output from the ODRL Builder (https://hub.docker.com/r/markw/odrl-builder-translator) and its 
associated YARRRML template are in the ./examples folder.

`odrl.json`  is the output from the builder tool
`odrl_yarrrml.yaml` is the template to convert that output into ODRL-compliant triples
