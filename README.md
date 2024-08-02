
```
version: "3"
services:


  yarrml-rdfizer: 
    image: markw/yarrrml-rml-ejp:0.1.1
    environment:
      - SERIALIZATION=nquads
    ports:
      - "4567:4567"
    volumes:
      - ./data:/mnt/data
```

Put your data and your yarrrml files in the ./data folder, following these naming conventions:

CARE.csv
CARE_yarrrml.yaml

In your YAML file, the "access" clause should point to `/mnt/data`  (`/mnt/data/CARE.csv` for example)

```
sources:
  policy:
    access: /mnt/data/CARE.csv
    referenceFormulation: csv
    iterator: "$"
```
