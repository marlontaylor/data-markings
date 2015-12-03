# STIX 2.0 Proposal: Application of Data Markings

This proposal contains a detailed specification of [Option 5](https://github.com/STIXProject/specifications/wiki/Idea-Exploration%3A-Data-Markings-Alternatives#option-5-choice-of-object-level-or-xpath) to allow top-level markings that are easy to use as well as field-level markings. ([Use Case](https://github.com/STIXProject/use-cases/wiki/Asserting-Data-Markings-on-Content#advanced)).

## Scope

The scope of this specification is only in defining *what markings apply to*, not to the definition of the markings themselves. Assume the following preconditions:

* One or more marking models are defined (e.g. TLP, copyright, terms of use)
* STIX 2.0 top-level objects may not be embedded in other top-level objects
* STIX 2.0 top-level objects are to be determined, but minimally include all STIX 1.2 top-level objects (pending changes)

## Overview

This approach maintains the current (STIX 1.2) pattern for applying field-level markings but adds an additional capability to support more basic markings.

* **Level 1 Markings**: Level 1 markings are the new capability that allow marking at two levels: the package as a whole, and top-level objects.  
* **Level 2 Markings**: Level 2 markings are the current capability that allow marking at any level (down to the individual field).

## Data Model & Specification

### Marking Definitions

Per the general philosophy of preferring referencing content to embedding content, marking definitions are defined once in the package and then referenced. Definitions are contained as an array in the (optional) `marking_definitions` key. Note that marking references may also (per agreement of the sharing community) refer to markings defined outside the instance document to either well-known markings (e.g. TLP) or to markings defined in another document.

Both Level 1 and Level 2 markings refer to markings defined in this marking structure.

### Level 1 Markings

Level 1 markings allow producers to mark entire packages and top-level objects with marking statements via a more straightforward approach.

#### Package-level markings

Each STIX 2.0 package MAY contain a list of marking references. In the JSON MTI specification, the `marking_refs` key contains this list as a JSON array.

Markings referenced from this key apply to all top-level objects contained in the package and to the package itself.

#### Object-level markings

Each STIX 2.0 top-level object MAY contain a list of marking references. In the JSON MTI specification, the `marking_refs` key contains this list as a JSON array.

Markings that are referenced from this key apply to the object itself. Additionally, they override any markings **of the same type** applied at the package level. In other words, if the marking type in the object-level `marking_refs` matches a type that was applied at the package-level, the markings defined at the package level **do not** apply to that object.

### Level 2 Markings

Level 2 markings allow producers to marking individual fields with marking statements via the STIX 1.2 approach.

#### Package-level markings

Each STIX 2.0 package MAY contain a list of structured markings. In the JSON MTI specification, the `structured_markings` key contains an array of controlled structures along with a reference to which marking definitions they apply to. Each object in the `structured_markings` array consists of an object with two keys:

* `controlled_structure`: contains a list of controlled structures, each of which is a representation of the fields that the referenced marking are applied to. In the JSON MTI specification, the format of this is a JSONPath entry. For the purposes of evaluating the JSONPath, the package is considered to be the root of the document.
* `marking_refs`: contains a list of references to the marking definitions to be applied

Level 2 markings at the package level that specify fields already marked by level 1 markings **of the same type** override those markings for those fields. Similarly, Level 2 markings that target the same fields as Level 2 markings **of the same type** that appear earlier in the list of package markings override those markings.

#### Object-level markings

Each STIX 2.0 top-level object MAY contain a list of structured markings. In the JSON MTI specification, the `structured_markings` key contains an array of controlled structures along with a reference to which marking definitions they apply to. Each object in the `structured_markings` array consists of an object with two keys:

* `controlled_structure`: contains a list of controlled structures, each of which is a representation of the fields that the referenced marking are applied to. In the JSON MTI specification, the format of this is a JSONPath entry. For the purposes of evaluating the JSONPath, the package is considered to be the root of the top-level object.
* `marking_refs`: contains a list of references to the marking definitions to be applied

Level 2 markings at the package level that specify fields already marked by level 1 markings **of the same type** override those markings for those fields. Similarly, Level 2 markings that target the same fields as Level 2 markings **of the same type** that appear earlier in the list of object markings or in the list of package markings override those markings.

## Conformance Requirements

A **Level 0 Markings Processor** is not able to process data markings. A **Level 1 Markings Processor** is only able to process Level 1 data markings. A **Level 2 Markings Processor** is able to process both Level 1 markings and Level 2 markings.

### Level 0
* **0.1**: A Level 0 processor who receives a document that contains either Level 1 or Level 2 markings at the package level (in the MTI specification, contains the `marking_refs` or `structured_markings` keys and the corresponding values are not empty arrays) **MUST** reject the document.  
* **0.2**: A Level 0 processor who receives a document that DOES NOT contain Level 1 or Level 2 markings at the package level (in the MTI specification, does not contain the `marking_refs` or `structured_markings` keys or the corresponding values are present but contain an empty array) **MAY** accept the document.  
* **0.3**: A Level 0 processor processing a document that contains an object with Level 1 or Level 2 markings (in the MTI specification, the object contains the `marking_refs` or `structured_markings` keys and the corresponding values do not consist of empty arrays) **MUST** reject the object. It **MAY** continue to process the rest of the document.  

### Level 1  
* **1.1**: A Level 1 processor who receives a package that contains Level 2 markings at the package level (in the MTI specification, contains the `structured markings` key and the value does not consist of an empty array) **MUST** reject the document.  
* **1.2**: A Level 1 processor who receives a document that DOES NOT contain Level 2 markings at the package level (in the MTI specification, does not contain the `structured_markings` key or the value consists of an empty array) **MAY** accept the document.  
* **1.3**: A Level 1 processor processing a document that contains an object with Level 2 markings (in the MTI specification, the object contains the `structured_markings` key and the value does not contain an empty array) **MUST** reject the object. It **MAY** continue to process the rest of the document.  
* **1.4**: A Level 1 processor **MUST** process all Level 1 markings per the mechanisms outlined in this specification.  

### Level 2  
* **2.1**: A Level 2 processor **MUST** process all Level 1 and Level 2 markings per the mechanisms outlined in this specification.

### Marking Precedence
* **3.1**: Level 1 and Level 2 processors **MUST** honor the following order of precedence:  
  * Level 2 markings at the object level (in reverse order of occurrence)
  * Level 2 markings at the package level (in reverse order of occurrence)
  * Level 1 markings at the object level
  * Level 1 markings at the package level

### Resolving references
* **4.1**: Level 1 and Level 2 processors that are unable to resolve a reference to a marking definition **MUST** reject content marked by that definition.

## Examples

### Marking Definitions

In this example, two marking definitions are represented. They are not applied anywhere via either Level 1 or Level 2 markings.

```json
{
  "stix_version": "2.0",
  "marking_definitions": [
    {
      "id": "us-cert:TLP-GREEN",
      "marking_type": "tlp",
      "tlp": "GREEN"
    },
    {
      "id": "example.com:copyright-1234",
      "marking_type": "simple",
      "statement": "Copyright 2015, Example Inc."
    }
  ]
}
```

### Level 1 Examples

#### Marking the entire package

In this example, the entire document is marked TLP:GREEN.

```json
{
  "stix_version": "2.0",
  "marking_definitions": [
    {
      "id": "us-cert:TLP-GREEN",
      "marking_type": "tlp",
      "tlp": "GREEN"
    }
  ],
  "marking_refs": ["us-cert:TLP-GREEN"],
  "indicators": [
    {},
    {},
    {}
  ]
}
```

#### Marking individual objects

In this example, the first indicator is marked TLP:RED and the second is marked TLP:GREEN.

```json
{
  "stix_version": "2.0",
  "marking_definitions": [
    {
      "id": "us-cert:TLP-GREEN",
      "marking_type": "tlp",
      "tlp": "GREEN"
    },
    {
      "id": "us-cert:TLP-RED",
      "marking_type": "tlp",
      "tlp": "RED"
    }
  ],
  "indicators": [
    {
      "id": "indicator-1234",
      "marking_refs": ["us-cert:TLP-RED"],
      "title": "First indicator"
    },
    {
      "id": "indicator-4321",
      "marking_refs": ["us-cert:TLP-GREEN"],
      "title": "Second indicator"
    }
  ]
}
```

#### Overriding package markings

In this example, the package is marked TLP:GREEN but a single indicator in that package is marked TLP:RED. In this case, the package itself and the second indicator are considered GREEN but the first indicator is considered RED because a Level 1 marking of `type=tlp` at the object level overrides the same type applied at the package level.

```json
{
  "stix_version": "2.0",
  "marking_definitions": [
    {
      "id": "us-cert:TLP-GREEN",
      "marking_type": "tlp",
      "tlp": "GREEN"
    },
    {
      "id": "us-cert:TLP-RED",
      "marking_type": "tlp",
      "tlp": "RED"
    },

  ],
  "marking_refs": ["us-cert:TLP-GREEN"],
  "indicators": [
    {
      "id": "indicator-1234",
      "marking_refs": ["us-cert:TLP-RED"],
      "title": "First indicator"
    },
    {
      "id": "indicator-4321",
      "title": "Second indicator"
    }
  ]
}
```

### Level 2 Markings

#### Marking Individual Fields

In this example, the title field of the indicator is marked as TLP:RED. A Level 1 processor would accept the package but reject the indicator because it contains a Level 2 indicator.

```json
{
  "stix_version": "2.0",
  "marking_definitions": [
    {
      "id": "us-cert:TLP-RED",
      "marking_type": "tlp",
      "tlp": "RED"
    }
  ],
  "indicators": [
    {
      "id": "indicator-1234",
      "structured_markings": [
        {
          "controlled_structure": [
            "@.title"
          ],
          "marking_refs": ["us-cert:TLP-RED"]
        }
      ],
      "title": "First indicator"
    }
  ]
}
```

#### Overriding Package Markings

Here, the entire document is marked TLP:GREEN and later an indicator title is marked TLP:RED. Note that in this example, a Level 1 processor would be able to process the package and the second indicator but MUST reject the first indicator because it contains Level 2 markings.

```json
{
  "stix_version": "2.0",
  "marking_definitions": [
    {
      "id": "us-cert:TLP-RED",
      "marking_type": "tlp",
      "tlp": "RED"
    },
    {
      "id": "us-cert:TLP-GREEN",
      "marking_type": "tlp",
      "tlp": "GREEN"
    }
  ],
  "marking_refs": ["us-cert:TLP-GREEN"],
  "indicators": [
    {
      "id": "indicator-1234",
      "structured_markings": [
        {
          "controlled_structure": [
            "@.title"
          ],
          "marking_refs": ["us-cert:TLP-RED"]
        }
      ],
      "title": "First indicator"
    },
    {
      "id": "indicator-4321",
      "title": "Second indicator"
    }
  ]
}
```
