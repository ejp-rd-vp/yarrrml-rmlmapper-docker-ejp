
```
version: "3"
services:

  
  yarrml-rdfizer: 
    image: markw/yarrrml-rml-ejp:0.0.1
    container_name: yarrrml-rdfizer
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