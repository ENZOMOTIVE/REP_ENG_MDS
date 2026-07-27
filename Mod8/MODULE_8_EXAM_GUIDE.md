# Reproducibility Engineering - Module 8 Exam Guide

> High-yield guide to every supplied Module 8 item: relational/XML/JSON comparison, JSON and JSON Schema, schema composition, HDF5 and `h5py`, the Visitor pattern, the solved in-class sheet, and the DuckDB/tidy-data lab.

## How to use this before the exam

If time is short, study in this order:

1. Memorize Section 1 and the JSON Schema truth table.
2. Work through every answer in the solved In-Class Sheet 8 section.
3. Be able to write the HDF5 weather-station code from memory.
4. Learn the three tidy-data rules and the `PIVOT`/`UNPIVOT` patterns from Lab Sheet 8.
5. Finish with the traps, model answers, and closed-book self-test.

Priority guide:

- **Highest priority:** JSON ordering, `properties` versus `required`, extra properties, `allOf`/`anyOf`/`oneOf`, HDF5 groups/datasets/attributes, and all in-class answers.
- **High priority:** when to choose HDF5, partial I/O, metadata, Visitor benefits/drawbacks, and the lab's data-reshaping SQL.
- **Recognition priority:** HDF5 drivers/tools, old Python 2 syntax in the excerpt, and DuckDB GUI setup details.

---

## 1. The entire module in two pages

### Five rules that unlock most questions

1. **Relational data is tabular; XML and JSON are hierarchical; HDF5 is a binary hierarchy optimized for large numerical arrays.**
2. **JSON objects are unordered mappings, but JSON arrays are ordered sequences.** Do not call all JSON unordered.
3. **`properties` does not make a property mandatory.** Only `required` does that, and extra properties remain allowed unless the schema explicitly forbids them.
4. **JSON Schema composition is Boolean logic:** `allOf` = AND, `anyOf` = inclusive OR, `oneOf` = exactly one/XOR, `not` = negation.
5. **HDF5 = GDA:** **G**roups organize, **D**atasets store array data, **A**ttributes store small metadata.

### Format comparison to memorize

| Feature | Relational | XML | JSON | HDF5 |
|---|---|---|---|---|
| Main structure | Flat tables of rows and columns | Ordered element tree with text and attributes | Tree of objects, arrays, and scalar values | File-system-like hierarchy of groups and array datasets |
| Typical schema | Required and fixed in advance (lecture contrast) | Flexible/self-describing; optional DTD or XML Schema | Flexible/self-describing; optional JSON Schema | Dataset type/shape are stored; overall application layout is usually a convention |
| Main query/access style | SQL | XPath/XQuery/XSLT | Lecture-era answer: no mature widely used query language; usually manipulated in a program | Path lookup and array slicing through an HDF5 API such as `h5py` |
| Ordering | A relation is unordered; query output needs `ORDER BY` | Child/document order matters; attributes are unordered | Object property order does not matter; array order does | Array positions are ordered/indexed; groups act like named containers |
| Typical implementation | Mature native relational DBMS | Lecture-era answer: often an XML layer over a relational implementation | Closely coupled to program objects/parsers and document/NoSQL exchange | Binary open format plus HDF5 library and language bindings |

The in-class comparison table contains only the first three formats. HDF5 is included here to make the choice question easier. [IC8 p.1; HDF5 pp.1-7]

### JSON Schema validator data flow

```text
JSON instance + JSON Schema -> validator -> valid / invalid + validation errors
```

- The **instance** is the data being checked.
- The **schema** is another JSON document containing rules.
- The **validator** evaluates the instance against those rules.
- The result is a Boolean validity decision, normally accompanied by useful error information. [IC8 p.2; JS]

### Product-schema rules from the sheet

```text
root                 must be an object
productId            integer, required
productName          string, required
price                number, required, strictly greater than 0
tags                 optional array
tags items           strings
tags length          at least 1
tags duplicates      forbidden
unknown properties   allowed by default
```

### Composition truth table to memorize

For these two subschemas:

```text
A = { "type": "string" }
B = { "maxLength": 5 }
```

| Instance | A | B | `allOf` | `anyOf` | `oneOf` |
|---|:---:|:---:|:---:|:---:|:---:|
| `"foo"` | T | T | T | T | **F** |
| `"a"` | T | T | T | T | **F** |
| `"1234567890"` | T | F | F | T | **T** |
| `42` | F | T | F | T | **T** |

The surprising cell is `B(42) = true`: `maxLength` applies to strings and does not reject a number. A type-specific keyword does **not** silently add a type check. Add `"type": "string"` when the type matters. [IC8 pp.4-5; COMB]

### HDF5 mental picture

```text
weather.hdf5
/
+-- 15                         group
|   +-- temperature            dataset [18.2, 18.4, ...]
|   |   +-- attrs: delta, start_time, unit
|   +-- wind                   dataset [3.1, 3.3, ...]
|       +-- attrs: delta, start_time, unit
+-- 20                         group
    +-- temperature            dataset [64.0, 65.0, ...]
        +-- attrs: delta, start_time, unit

root attrs: description
```

### Visitor in one sentence

Use **Visitor** when operations change more often than the composite object structure: a Traverser walks the Composite, the Visitor collects exposed state and centralizes new operations. This makes operations easy to add but weakens encapsulation and makes structural changes harder. [VIS pp.628-629]

### Tidy data in one sentence

```text
one variable per column + one observation per row + one value per cell
```

Fast reshaping rule:

```text
variable names stored in rows       -> PIVOT wider
variable values embedded in headers -> UNPIVOT longer
multiple values inside one cell      -> split
one variable split across columns    -> concatenate
```

---

## 2. Relational, XML, JSON, and equivalence

### Relational data

- Data is represented by relations/tables.
- Columns represent attributes/variables and rows represent tuples/observations.
- The schema defines names, types, keys, and constraints before or alongside loading the data.
- SQL provides standardized declarative querying, joins, grouping, aggregation, and constraints.
- A relation has no inherent row order. `ORDER BY` is required when result order matters.
- Hierarchies normally require several tables connected through keys and joins.

Best fit: strongly structured data, integrity constraints, relationships, transactions, joins, and ad hoc queries.

### XML

- XML represents a rooted, hierarchical document tree.
- Elements can contain text, attributes, and child elements.
- Child/document order is meaningful; XML attributes themselves are unordered.
- A document can be used without a schema, or validated with a DTD/XML Schema.
- XPath navigates paths; XQuery queries and constructs XML; XSLT transforms it.
- XML is verbose but supports document-oriented features such as mixed text and markup.

Best fit: marked-up documents, mixed content, namespaces, established XML ecosystems, and data where document order matters.

#### XML validation - recognition material from the Widom resource

- **Well-formed XML** obeys XML syntax: one root element, properly nested and matching tags, quoted attribute values, and case-sensitive names.
- **Valid XML** is well-formed **and** conforms to a declared schema such as a DTD or XML Schema/XSD.
- A **DTD** declares allowed elements, attributes, content structure, and occurrence. Common markers are:

```text
?  zero or one
*  zero or more
+  one or more
```

- DTD attribute type `ID` gives a unique identifier; `IDREF` refers to one declared ID; `IDREFS` contains several references.
- **XML Schema/XSD** is itself written in XML and supports richer primitive types, complex types, namespaces, numerical/string restrictions, and cardinality rules such as `minOccurs`/`maxOccurs`.
- A well-formed document can still be invalid against its DTD/XSD, just as syntactically valid JSON can fail a JSON Schema.

### JSON

JSON values are:

```text
object | array | string | number | boolean | null
```

- An **object** maps string property names to values: `{ "name": "Ada" }`.
- An **array** is an ordered sequence: `["home", "green"]`.
- JSON is lighter than XML and maps naturally into dictionaries/objects, lists/arrays, and scalar values in programming languages.
- JSON itself does not require a schema. JSON Schema adds optional validation rules.
- Strict JSON has no comments and no trailing commas; property names and strings use double quotes.
- Property names are case-sensitive: `productName` and `ProductName` are different.

JSON was designed as a compact serialization/interchange form for program data and maps directly to common dictionaries/objects and lists/arrays. Compared with XML, it is generally less verbose and has a smaller conceptual model. XML and JSON are both useful for flexible or semi-structured data, but flexibility trades away some guarantees that a schema can restore.

Best fit: APIs, configuration, lightweight data interchange, nested application data, and human-readable structured data.

### The ordering rule examiners like

```text
Relational relation: unordered
XML child nodes:      ordered
JSON object members:  unordered
JSON array items:     ordered
```

Consequences:

- Reordering object properties does not change the JSON value.
- Reordering array items normally does change the JSON value.
- A textual `diff` detects serialization differences; it does not decide structural or semantic equivalence.
- SQL can return rows in any order unless `ORDER BY` is present.

### Three different kinds of equality

| Kind | Question | Example |
|---|---|---|
| Syntactic/textual equality | Are the serializations character-for-character or byte-for-byte equal? | Whitespace or property reordering breaks it. |
| Structural equality | Do they represent the same data structure/value? | Object member order is ignored; array order is preserved. |
| Semantic equivalence of schemas | Do both schemas accept exactly the same set of instances? | Different schema syntax can still impose the same constraints. |

Example:

```json
{"x": 1, "tags": ["a", "b"]}
{"tags": ["a", "b"], "x": 1}
```

These are textually different but structurally equivalent. Replacing the second array with `["b", "a"]` makes them structurally different.

---

## 3. JSON Schema - the scoring core

### What JSON Schema provides

Validating an instance against a schema can:

- reject wrong top-level or property types;
- enforce required properties and numerical/string/array constraints;
- catch errors at a system boundary instead of much later in an analysis;
- give producers and consumers an explicit data contract;
- document expected structure and meaning;
- support editor hints, generated forms/code, tests, and automated validation;
- improve interoperability and consistency across tools and experiments.

A schema only checks rules it actually expresses. A schema cannot prove that a scientifically wrong value is correct merely because the value has the expected type and range.

Keep two validity levels separate:

- **Syntactic validity:** the text obeys JSON grammar.
- **Schema validity:** the parsed JSON instance satisfies a particular JSON Schema.

A document can be valid JSON syntax and still be invalid against the product schema.

### Anatomy of the assigned product schema

```json
{
  "title": "Product",
  "description": "A product from Acme's catalog",
  "type": "object",
  "properties": {
    "productId": {
      "description": "The unique identifier for a product",
      "type": "integer"
    },
    "productName": {
      "description": "Name of the product",
      "type": "string"
    },
    "price": {
      "description": "The price of the product",
      "type": "number",
      "exclusiveMinimum": 0
    },
    "tags": {
      "description": "Tags for the product",
      "type": "array",
      "items": { "type": "string" },
      "minItems": 1,
      "uniqueItems": true
    }
  },
  "required": ["productId", "productName", "price"]
}
```

Keyword map:

| Keyword | Meaning in this schema |
|---|---|
| `title`, `description` | Annotations for humans/tools; they do not reject an instance. |
| `type: object` | The root instance must be an object. |
| `properties` | If a named property exists, validate its value using the nested schema. |
| `required` | The listed property names must exist. |
| `type: integer` | Value must be an integer. |
| `type: number` | Value may be an integer or non-integer number. |
| `exclusiveMinimum: 0` | Value must be strictly greater than zero. |
| `type: array` | Value must be an array. |
| `items` | Every array item must satisfy the given schema. |
| `minItems: 1` | The array cannot be empty. |
| `uniqueItems: true` | No two array items may be equal. |

### The two defaults students confuse

#### Defined does not mean required

This schema is valid for `{}`:

```json
{
  "type": "object",
  "properties": { "name": { "type": "string" } }
}
```

`properties` says what to do **if** `name` appears. Add `"required": ["name"]` to demand its presence.

#### Unlisted does not mean forbidden

Unknown properties are accepted by default. To close an object schema, add:

```json
"additionalProperties": false
```

The product schema does not contain that keyword, so a valid product may also have `"discount": 0.1`.

### Progressive validation

When asked whether an instance is valid "up to line N," apply only the constraints introduced by that prefix:

1. `title` and `description` are annotations, so all JSON instances still pass.
2. `type: object` rejects strings, numbers, arrays, booleans, and `null` at the root.
3. `properties` constrains only matching, present properties.
4. `required` finally makes selected names mandatory.

### Composition operators

| Operator | Logic | Valid exactly when... |
|---|---|---|
| `allOf` | AND | every subschema validates |
| `anyOf` | inclusive OR | at least one subschema validates |
| `oneOf` | exactly-one/XOR | exactly one subschema validates |
| `not` | NOT | the nested subschema does not validate |

Do not read `oneOf` as ordinary English "one or more." If two alternatives both match, `oneOf` fails.

### Type-specific keyword trap

This schema by itself does not require a string:

```json
{ "maxLength": 5 }
```

It constrains string instances, while a number such as `42` is not rejected by `maxLength`. The safe explicit form is:

```json
{ "type": "string", "maxLength": 5 }
```

This explains every surprising answer in questions 6-8.

### Structural versus semantic schema equivalence

```json
{ "oneOf": [{"type": "string"}, {"type": "integer"}] }
```

and

```json
{ "anyOf": [{"type": "integer"}, {"type": "string"}] }
```

are not structurally equivalent: the operator and array order differ. They are semantically equivalent because no instance can be both a JSON string and a JSON integer. For disjoint alternatives, "at least one" and "exactly one" accept the same set. [IC8 p.5]

Counterexample showing that this is not generally true:

```json
{
  "anyOf": [
    {"type": "number"},
    {"type": "integer"}
  ]
}
```

An integer matches both branches, so it passes `anyOf` but would fail the corresponding `oneOf`.

### Tutorial extras - lower priority

The assigned step-by-step tutorial also introduces these reusable-schema ideas:

| Keyword | Purpose |
|---|---|
| `$schema` | Declares the JSON Schema dialect/meta-schema, such as Draft 2020-12. |
| `$id` | Gives a schema resource a canonical URI/base identifier. |
| `$ref` | Reuses another schema resource instead of duplicating its rules. |

The empty schema `{}` contains no constraints and accepts every JSON instance.

Nested object schemas have their own scope. For example:

```json
{
  "type": "object",
  "properties": {
    "dimensions": {
      "type": "object",
      "properties": {
        "length": {"type": "number"},
        "width": {"type": "number"},
        "height": {"type": "number"}
      },
      "required": ["length", "width", "height"]
    }
  }
}
```

The inner `required` applies to the `dimensions` object, not the root. It requires `length`, `width`, and `height` **if `dimensions` exists**; it does not make the outer `dimensions` property mandatory. A separate geographical-location schema in the tutorial requires `latitude` and `longitude`, constraining latitude to `[-90, 90]` and longitude to `[-180, 180]`. Reusing it through `$ref` avoids copying rules and gives several documents one maintainable definition. [JS]

---

## 4. Solved In-Class Exercise Sheet 8

### Question 1 - compare relational, XML, and JSON

Use the first three columns of the comparison table in Section 1. A compact exam answer is:

| Feature | Relational | XML | JSON |
|---|---|---|---|
| Structure | Tables | Element tree | Objects and arrays |
| Schema | Required and fixed in advance | Flexible/self-describing; optional DTD/XML Schema | Flexible/self-describing; optional JSON Schema |
| Queries | Mature relational algebra/SQL | Established XPath/XQuery/XSLT | Lecture-era answer: no mature widely used language; normally programmatic |
| Ordering | Relations unordered | Document/child order meaningful | Objects unordered, arrays ordered |
| Implementation | Mature native relational DBMS | Historically often an XML layer over a relational engine | Closely tied to program objects/parsers and document/NoSQL exchange |

The query and implementation cells reflect the assigned lecture's February 2012 context. It mentions proposals such as JSONPath, JSON Query, and Jaql, but no mature widely used JSON query language or common standalone native JSON DBMS at that time. Modern products offer more JSON querying; reproduce the historical course contrast in this question. XML is normally a tree, although links can encode graph-like relationships.

### Question 2 - are the two product instances structurally equivalent?

**Intended answer: No, because the order of the array items differs.**

- Moving `price` before or after `tags` does not matter because object property order is insignificant.
- `tags: ["home", "green"]` and `tags: ["green", "home"]` differ because array order is significant.
- A textual `diff` is not the test for structural equivalence.

Source-sheet warning: the right-hand example visibly lacks a comma after its `tags` array and has a trailing comma after `price`; strict JSON would therefore reject that serialization. Because the sheet calls both values "JSON instances" and offers the array-order answer, the conceptual question clearly assumes those punctuation slips are corrected.

### Question 3 - label the validation diagram

```text
top input:    JSON Schema
bottom input: JSON Instance
middle:       JSON Validator
output:       Validation result (valid/invalid, usually with errors)
```

### Question 4 - benefits of validation

Model answer:

> JSON Schema makes the expected data structure explicit and machine-checkable. Validation catches missing required properties, wrong types, invalid ranges, malformed arrays, and other contract violations early. This improves consistency, documentation, interoperability, testing, and error reporting. It verifies only encoded constraints, not the scientific truth of the values.

### Question 5 - product-schema statements

| Statement | Answer | Reason |
|---|:---:|---|
| Left product is valid through line 3 | **True** | `title` and `description` are annotations only. |
| `"Hello world!"` is valid through line 3 | **True** | No validation constraint has appeared yet. |
| Left product is valid through line 4 | **True** | It is an object. |
| `"Hello world!"` is valid through line 4 | **False** | `type: object` rejects a string. |
| `{"foo": 42}` is valid through line 28 | **True** | It is an object; unknown properties are allowed; `required` is not included yet. |
| `{"ProductName": 42}` is valid through line 28 | **True** | Names are case-sensitive, so this is an unconstrained extra property. |
| `{"ProductName": 42}` is valid against the full schema | **False** | It lacks exact required names `productId`, `productName`, and `price`. |
| Original left product is valid against the full schema | **True** | All required values and tag constraints pass. |
| Product with `"tags": []` is valid | **False** | Violates `minItems: 1`. |
| Product with duplicate `"special offer"` tags is valid | **False** | Violates `uniqueItems: true`. |
| Valid product plus `"discount": 0.1` is valid | **True** | Extra properties are allowed by default. |

### Questions 6-8 - `allOf`, `anyOf`, `oneOf`

With branches `type: string` and `maxLength: 5`:

- **Q6 `allOf`:** valid: `"foo"`, `"a"`; invalid: `"1234567890"`, `42`.
- **Q7 `anyOf`:** all four instances are valid.
- **Q8 `oneOf`:** valid: `"1234567890"`, `42`; invalid: `"foo"`, `"a"` because each short string matches both branches.

Deeper shortcut: Q7 accepts every possible JSON value - strings pass the first branch and non-strings are not rejected by `maxLength`. Q8 rejects precisely strings of length at most five; long strings and non-strings match exactly one branch.

### Question 9 - compare the two schemas

**Only "The schemas are semantically equivalent" is true.**

- They both accept exactly JSON strings and JSON integers.
- The type alternatives are disjoint, so `anyOf` cannot match two branches at once.
- They are not structurally equivalent.
- There is no instance accepted by the right schema but rejected by the left.

### Question 10 - when to choose HDF5

Choose HDF5 when:

- numerical arrays are large;
- only slices/subsets should be read into memory;
- high-throughput binary I/O matters;
- data naturally forms a hierarchy;
- related data and metadata should live together;
- compression, extensible datasets, or parallel access are useful;
- a self-describing, cross-platform scientific format is needed.

Prefer XML or JSON when:

- data is small enough that text overhead is unimportant;
- human readability, manual editing, textual diffing, or web/API interchange dominates;
- the data is document-oriented or highly irregular rather than large homogeneous arrays.

Prefer a relational database when joins, constraints, transactions, relationships among tables, concurrent updates, or flexible ad hoc queries dominate.

### Question 11(a) - CSV layout benefits and drawbacks

Benefits:

- simple, human-readable, and widely supported;
- easy to inspect and exchange;
- fits tabular tools and relational loading;
- each individual measurement table is straightforward.

Drawbacks:

- the station hierarchy is implicit and spread across tables/files;
- metadata is separated from the measurements it describes;
- station/time identifiers are repeated;
- for regular sampling, explicit times repeat information already implied by `time[i] = start_time + i * delta`;
- the absence of station 20 wind data must be inferred;
- units can differ by station and are easy to detach or misuse;
- Celsius and Fahrenheit values occupy the same generic measurement column, inviting unit mistakes;
- the metadata table is an entity-attribute-value layout whose `value` column mixes numbers and strings;
- CSV has weak type/schema support and no built-in metadata model;
- large multidimensional numerical data, compression, and efficient arbitrary slicing are awkward.

### Question 11(b) - completed `h5py` code

```python
import time
import numpy as np
import h5py


def main():
    temperature_station_15 = np.array([18.2, 18.4, 18.7, 19.0, 19.1])
    wind_station_15 = np.array([3.1, 3.3, 2.8, 4.0, 3.7])
    temperature_station_20 = np.array([64.0, 65.0, 66.1, 65.8])
    start_time = 0  # In a real file, use a proper timestamp.

    with h5py.File("weather.hdf5", "w") as f:
        f["/15/temperature"] = temperature_station_15
        f["/15/temperature"].attrs["delta"] = 5.0
        f["/15/temperature"].attrs["start_time"] = start_time
        f["/15/temperature"].attrs["unit"] = "degree Celsius"

        f["/15/wind"] = wind_station_15
        f["/15/wind"].attrs["delta"] = 5.0
        f["/15/wind"].attrs["start_time"] = start_time
        f["/15/wind"].attrs["unit"] = "m/s"

        f["/20/temperature"] = temperature_station_20
        f["/20/temperature"].attrs["delta"] = 10.0
        f["/20/temperature"].attrs["start_time"] = start_time
        f["/20/temperature"].attrs["unit"] = "degree Fahrenheit"

        f.attrs["description"] = (
            "Temperature and wind measurements from weather stations 15 and 20"
        )


if __name__ == "__main__":
    main()
```

The exact descriptive string is not important; attaching it to `f.attrs` makes it root/file-level metadata. Paths such as `/15/temperature` identify datasets; attributes belong to the dataset whose values they describe.

The printed template itself contains an extra `]` in the station-20 `delta` line and a stray quote around the station-15 wind `unit` blank. The completed version above is the syntactically corrected intended code.

---

## 5. HDF5 and `h5py` in depth

### Why the format exists

The reading begins with an endianness failure: raw floating-point bytes written on a little-endian machine were interpreted on a big-endian machine as values around 40 orders of magnitude too small. The lesson is broader than byte order:

> A storage-format decision is also a communication and reproducibility decision.

A standard self-describing format records enough structure and type information for different programs and machines to interpret the same data consistently. HDF5 handles cross-platform representation details such as endianness. [HDF5 pp.1-7]

### The three public data-model objects

| Object | Analogy | Purpose |
|---|---|---|
| **Group** | Directory/folder | Contains named groups and datasets; creates hierarchy. |
| **Dataset** | Typed NumPy-like array on disk | Stores homogeneous numerical or other array data with a shape and dtype. |
| **Attribute** | Small key-value annotation | Stores metadata attached directly to a group or dataset. |

Rule of thumb: put large or sliceable data in a dataset; put small descriptive facts such as units, timestamps, and sampling intervals in attributes.

### HDF5 is three related things

1. An open file specification and data model.
2. A maintained library, originally in C, with language bindings.
3. An ecosystem of clients and scientific platforms such as Python, MATLAB, IDL, Java, and others.

An organization can define an **application format within HDF5**: for example, one group per station, named datasets for measurements, and agreed attribute names. HDF5 supplies the container semantics; the community supplies the domain convention.

Architecture to recognize:

```text
user code
  -> h5py or PyTables
  -> HDF5 C API and public groups/datasets/attributes
  -> internal structures and a 1-D logical address space
  -> file driver
  -> operating-system storage
```

Group members are internally indexed with B-trees for efficient lookup even when a group contains many objects. `h5py` closely exposes native HDF5 concepts; PyTables builds additional scientific-database features such as indexing on top of HDF5.

### Why hierarchy beats a flat naming convention

A flat archive might need names such as:

```text
temperature_15
delta_temperature_15
wind_15
delta_wind_15
temperature_20
...
```

HDF5 expresses the relationship directly:

```text
/15/temperature
/15/wind
/20/temperature
```

Metadata sits on the relevant object instead of in a distant lookup table. This reduces naming hacks and makes a file explorable.

### Partial I/O

```python
dataset = f["/15/temperature"]
first_ten = dataset[0:10]
every_other = dataset[0:10:2]
```

`dataset` is a proxy for data on disk. Slicing asks HDF5 to read only the selected region into memory. This is crucial when the complete dataset is hundreds of gigabytes or larger.

Contrast with NumPy slicing:

- A NumPy slice is commonly a **view** into the same in-memory array; changing it can change the original.
- A slice read from an HDF5 dataset returns an in-memory **copy** of the disk data.

### Allocation and compression

The reading emphasizes that a declared dataset can be much larger than currently written data, with storage allocated as needed. HDF5 also supports transparent dataset-level compression:

```python
compressed = f.create_dataset(
    "comp",
    shape=(1024,),
    dtype="int32",
    compression="gzip",
)
compressed[:] = np.arange(1024)
```

Compression is transparent to later reads. Chunk layout and access patterns affect performance, so write/read in sensible blocks rather than one scalar at a time.

### Common creation and access patterns

```python
with h5py.File("weather.hdf5", "w") as f:
    f["/15/temperature"] = np.array([18.2, 18.4])
    f["/15/temperature"].attrs["unit"] = "degree Celsius"
```

The context manager closes the file even if an exception occurs.

File modes:

| Mode | Meaning |
|---|---|
| `"r"` | Read-only; file must exist. |
| `"r+"` | Read and write; file must exist. |
| `"w"` | Create a new file, overwriting an existing file. |
| `"w-"` or `"x"` | Create, but fail if the file already exists. |
| `"a"` | Read/write; create if absent. |

For reproducible code, state the mode explicitly. Do not depend on the old excerpt's historical default behavior.

The excerpt predates Python 3's dominance. Translate its old syntax when using current Python:

```text
print x or print "%s" % x  -> print(x) or print(f"{x}")
mapping.iteritems()         -> mapping.items()
implicit h5py file mode     -> pass "r", "w", "a", etc. explicitly
```

### NumPy and HDF5 types

- A NumPy array has a fixed `dtype`, shape, and memory representation.
- An HDF5 dataset likewise has a fixed type and shape.
- `h5py` maps HDF5 types to NumPy dtypes, enabling efficient interchange.
- Appropriate types matter for correctness, file size, and performance.

### Where HDF5 is the wrong tool

HDF5 is not a replacement for every database or text format:

- Use a relational DBMS when relationships, joins, constraints, transactions, or multi-user query/update behavior dominate.
- Use CSV for tiny, simple 1D/tabular datasets that must open everywhere without a special library.
- Use JSON for lightweight nested API/configuration data.
- Use XML for ordered/mixed-content documents and XML-specific standards.
- Binary HDF5 is not pleasant to inspect in a text editor, review with a normal line diff, or merge in Git.

### Tools to recognize

- **HDFView:** graphical HDF5 browser; displays hierarchy, data, and attributes.
- **ViTables:** graphical viewer oriented toward PyTables but able to read generic HDF5.
- **`h5ls`:** lists groups/datasets; `h5ls -vlr file.hdf5` gives verbose recursive metadata.
- **`h5dump`:** prints metadata and actual stored values in a verbose textual representation.

Independent inspection is a reproducibility practice: it can reveal wrong dtypes, shapes, paths, or attributes before archival/sharing.

### File drivers - recognition level

| Driver | Purpose |
|---|---|
| `core` | Keep the HDF5 image in memory for fast access; with `backing_store=True`, load an existing image on open and save it on close. |
| `family` | Split one logical HDF5 file into fixed-size file members. |
| `mpio` | Parallel access by multiple processes through MPI. |

Drivers change storage mechanics underneath the same high-level group/dataset/attribute interface.

Recognition-only feature: an HDF5 **user block** is arbitrary prefix data before the HDF5 payload. Its size is a power of two and at least 512 bytes. Do not modify that prefix while the file is open through HDF5.

### Visitor pattern and hierarchical traversal

The assigned design-pattern excerpt presents these roles:

```text
Composite object hierarchy <- walked by Traverser <- guides Visitor
Visitor collects exposed state -> Client asks for operations/results
```

Why use it:

- operations can be added without placing each new method in every composite class;
- operation code is centralized in the Visitor;
- the composite structure itself need not be rewritten for each new calculation.

Costs:

- composite classes must expose state, weakening encapsulation;
- the traversal logic and Visitor depend on the structure;
- adding/changing composite element types is harder than adding a new operation.

HDF5 is a natural use case: files contain arbitrarily deep groups and datasets. A library-supplied visitor/traversal facility can systematically reach every object, avoiding fragile hand-written nested loops. The HDF5 reading recommends using its Visitor feature before manual recursion. [HDF5 p.13; VIS pp.628-629]

---

## 6. Lab Sheet 8 - DuckDB and tidy-data transformations

The lab inside the Module 8 folder focuses on tidy data and DuckDB. It is separate from the hierarchical-format in-class topic, but it is still supplied Module 8 exam material.

The referenced `countries_*.sql` fixture files are not present in this workspace. The solutions below were checked against every printed table/schema and current DuckDB syntax, but complete hidden-dataset row counts cannot be reproduced locally.

### Setup facts - recognition level

- DuckDB is embedded and column-oriented, optimized for analytical/OLAP work.
- SQLite is embedded and row-oriented, optimized for transactional/OLTP work.

Local startup:

```bash
cd LabSession8/duckdb-local
docker compose up -d
```

GUI: `http://localhost:4213`

On `narrow-sea`:

```bash
cd LabSession8/duckdb-narrow-sea
MY_PORT=$(get_my_port) docker compose up -d
```

Then open the tunnel **from the local machine**:

```bash
ssh -L <PORT>:localhost:<PORT> \
  <FIM-ACCOUNT>@narrow-sea.sdbs.fim.uni-passau.de
```

The SSH connection must stay open. The GUI configuration/notebook list does not persist across container restarts; the database file in the volume does. Reattach with the same path and save important SQL outside the UI. [L8 pp.1-2]

### The tidy-data test

Ask three questions:

1. Does every variable have its own column?
2. Does every observation have its own row?
3. Does every cell contain one value?

Tidiness depends on the observational unit. In the WHO data, one observation is identified by country, year, new/old status, disease type, sex, and age group, with the case count as its measurement.

### Rows to columns - `countries_long`

Input shape:

```text
country | year | type       | count
...     | 1999 | cases      | 745
...     | 1999 | population | 19987071
```

Why untidy: `type` contains the names of two variables and one country-year observation is split across rows.

Desired shape:

```text
country | year | cases | population
```

Using DuckDB `PIVOT`:

```sql
PIVOT countries_long
ON type IN ('cases', 'population')
USING first(count)
GROUP BY country, year
ORDER BY country, year;
```

Without `PIVOT`:

```sql
SELECT
    country,
    year,
    MAX(CASE WHEN type = 'cases' THEN count END) AS cases,
    MAX(CASE WHEN type = 'population' THEN count END) AS population
FROM countries_long
GROUP BY country, year
ORDER BY country, year;
```

`first`/`MAX` is safe only if `(country, year, type)` identifies one intended value. An aggregate is required by pivot syntax, but a careless aggregate can hide duplicate-data problems.

### Columns to rows - `countries_wide`

Input shape:

```text
country | year_1999 | year_2000
```

Why untidy: values of the variable `year` are encoded in column names, while one measurement variable, `cases`, is spread over several columns.

Desired shape:

```text
country | year | cases
```

Using `UNPIVOT`:

```sql
WITH long_form AS (
    UNPIVOT countries_wide
    ON year_1999, year_2000
    INTO
        NAME year_column
        VALUE cases
)
SELECT
    country,
    CAST(SUBSTRING(year_column, 6) AS INTEGER) AS year,
    cases
FROM long_form
ORDER BY country, year;
```

Dynamic version:

```sql
WITH long_form AS (
    UNPIVOT countries_wide
    ON COLUMNS(* EXCLUDE (country))
    INTO NAME year_column VALUE cases
)
SELECT
    country,
    CAST(SUBSTRING(year_column, 6) AS INTEGER) AS year,
    cases
FROM long_form
ORDER BY country, year;
```

Without `UNPIVOT`:

```sql
SELECT country, 1999 AS year, year_1999 AS cases
FROM countries_wide

UNION ALL

SELECT country, 2000 AS year, year_2000 AS cases
FROM countries_wide

ORDER BY country, year;
```

Use `UNION ALL`: plain `UNION` removes duplicates and can destroy valid repeated observations.

### Split compound cells - `countries_rate`

Input:

```text
country | year | rate
...     | 1999 | 745/19987071
```

Why untidy: `rate` stores two values, cases and population, in one cell.

Full solution using the functions hinted in the sheet:

```sql
CREATE OR REPLACE TABLE countries_rate_tidy AS
WITH prepared AS (
    SELECT
        country,
        CAST(year AS VARCHAR) AS year_text,
        rate,
        STRPOS(rate, '/') AS slash_position
    FROM countries_rate
)
SELECT
    country,
    LEFT(year_text, 2) AS century,
    SUBSTRING(year_text, 3, 2) AS year_within_century,
    CAST(LEFT(rate, slash_position - 1) AS BIGINT) AS cases,
    CAST(SUBSTRING(rate, slash_position + 1) AS BIGINT) AS population
FROM prepared;
```

Key details:

- `STRPOS` and `SUBSTRING` use 1-based positions.
- Subtract one to exclude `/` from the left field.
- Add one to start immediately after `/`.
- Keep `year_within_century` as text so `00` stays `00`.
- Here `century` means the first two digits, not the formal Gregorian century number.

Shorter DuckDB alternative:

```sql
SELECT
    country,
    LEFT(CAST(year AS VARCHAR), 2) AS century,
    SUBSTRING(CAST(year AS VARCHAR), 3, 2) AS year_within_century,
    CAST(SPLIT_PART(rate, '/', 1) AS BIGINT) AS cases,
    CAST(SPLIT_PART(rate, '/', 2) AS BIGINT) AS population
FROM countries_rate;
```

### Concatenate the year again

```sql
SELECT
    country,
    CAST(century || year_within_century AS INTEGER) AS year,
    cases,
    population
FROM countries_rate_tidy;
```

If `00` was incorrectly converted to integer `0`, pad it first:

```sql
CAST(
    CAST(century AS VARCHAR)
    || LPAD(CAST(year_within_century AS VARCHAR), 2, '0')
    AS INTEGER
) AS year
```

Otherwise `20 || 0` becomes `200`, not `2000`.

### WHO case study - unpivot then parse headers

Encoded name:

```text
new_sp_m014
 |   | |--- age_group = 014
 |   |----- sex = m
 |--------- type = sp
----------- new_or_old = new
```

Desired columns:

```text
country | iso2 | iso3 | year | new_or_old | type | sex | age_group | value
```

Solution:

```sql
CREATE OR REPLACE TABLE countries_who_tidy AS
WITH long_form AS (
    UNPIVOT countries_who
    ON COLUMNS(* EXCLUDE (country, iso2, iso3, year))
    INTO
        NAME encoded_variable
        VALUE value
)
SELECT
    country,
    iso2,
    iso3,
    year,
    SPLIT_PART(encoded_variable, '_', 1) AS new_or_old,
    SPLIT_PART(encoded_variable, '_', 2) AS type,
    LEFT(SPLIT_PART(encoded_variable, '_', 3), 1) AS sex,
    SUBSTRING(SPLIT_PART(encoded_variable, '_', 3), 2) AS age_group,
    value
FROM long_form;
```

Keep `age_group` textual so `014` retains its leading zero. Exclude **every** metadata column from the dynamic unpivot.

DuckDB's ordinary `UNPIVOT` omits null-valued measurements. Zero is a real observed value and must not be treated as null. If missing observations must be retained, use an appropriate `INCLUDE NULLS` form or a manual transformation and state the desired semantics.

### Discretization

Required ranges:

```text
Low:    value < 50
Medium: 50 <= value < 500
High:   value >= 500
```

```sql
SELECT
    *,
    CASE
        WHEN value IS NULL THEN NULL
        WHEN value < 50 THEN 'Low'
        WHEN value < 500 THEN 'Medium'
        ELSE 'High'
    END AS severity_level
FROM countries_who_tidy;
```

Boundary checks:

```text
49 -> Low
50 -> Medium
499 -> Medium
500 -> High
```

Do not use `BETWEEN 50 AND 500`; SQL `BETWEEN` includes 500.

### Binarization and dummy variables

```sql
SELECT
    *,
    CASE WHEN age_group <> '014' THEN 1 ELSE 0 END AS is_adult,
    CASE WHEN sex = 'm' THEN 1 ELSE 0 END AS sex_m,
    CASE WHEN sex = 'f' THEN 1 ELSE 0 END AS sex_f
FROM countries_who_tidy;
```

Definitions:

- **Discretization:** map numeric ranges to categories such as Low/Medium/High.
- **Binarization:** map one condition to a binary indicator, such as child/adult.
- **Dummy variables / one-hot encoding:** create one indicator column per category.
- **Normalization:** rescale numerical values; it is not what the rating `CASE` does.
- **Pivoting:** change data layout; it is not a numerical encoding.

### Lab multiple-choice answers

1. Mapping cat ratings to `loves`, `likes`, `dislikes`, and `hates` is **discretization**.
2. The table with `rating_dry` and `rating_wet` is **not tidy**. `dry` and `wet` are values of a `food_type` variable embedded in headers. Tidy columns are:

```text
cat | food_brand | food_type | rating
```

Boundary traps in the supplied cat `CASE`:

```text
rating = 4.5 -> likes
rating = 2.5 -> dislikes
rating = 0.5 -> hates
```

The conditions use strict `>` comparisons and are evaluated from top to bottom. [L8 p.7]

---

## 7. Common exam traps

1. **JSON is not wholly unordered.** Objects are unordered; arrays are ordered.
2. **`diff` tests text, not structure.** Whitespace and object-property order can change without changing the JSON value.
3. **The sheet's right Q2 serialization has punctuation slips.** Answer the intended array-order concept if presented as the same conceptual question.
4. **`title` and `description` do not validate.** They are annotations.
5. **`properties` does not imply `required`.** A missing defined property is allowed unless listed in `required`.
6. **Unknown properties are allowed by default.** Use `additionalProperties: false` to reject them.
7. **Property names are case-sensitive.** `ProductName` does not satisfy required `productName`.
8. **`exclusiveMinimum: 0` means `> 0`, not `>= 0`.**
9. **`uniqueItems` checks duplicates; `minItems` checks length.** They solve different problems.
10. **A type-specific keyword does not add the type.** `maxLength` alone does not reject `42`.
11. **`anyOf` is inclusive OR.** One or several branches may match.
12. **`oneOf` is exactly one.** Two matches make the instance invalid.
13. **Different schema syntax may be semantically equivalent.** Compare accepted instance sets.
14. **Attributes are metadata, not the main large array.** Store large/sliceable values as datasets.
15. **HDF5 is not a relational DBMS.** It does not replace joins, relational constraints, or transaction-oriented querying.
16. **HDF5 slicing reads selected data from disk.** It does not first load the full file.
17. **NumPy slice and HDF5 slice differ.** NumPy often gives a view; HDF5 reads give a copy.
18. **`"w"` overwrites.** Use `"w-"`/`"x"` when accidental replacement must fail.
19. **Visitor trades encapsulation for extensibility of operations.** It is not free abstraction.
20. **Tidy direction matters.** Variable names in rows go wider; variable values in headers go longer.
21. **Use `UNION ALL` for reshaping.** `UNION` can delete legitimate duplicates.
22. **Preserve leading zeros.** Keep `00` and `014` as text until they no longer encode categories.
23. **`BETWEEN` is inclusive at both ends.** It would put 500 in the wrong severity bucket.
24. **`NULL` is not zero.** Missing case count and observed zero cases have different meanings.
25. **SQL result order is not guaranteed.** Add `ORDER BY` when output order is part of the answer.

---

## 8. Likely exam questions and model answers

### Compare relational, XML, JSON, and HDF5

> Relational data uses unordered tables under an explicit schema and is queried with SQL. XML uses an ordered element tree and optional DTD/XML Schema, commonly queried with XPath/XQuery. JSON uses unordered objects, ordered arrays, scalar values, and optional JSON Schema; its access/query mechanism depends on the program or document system. HDF5 is a binary hierarchy of groups, typed array datasets, and attributes, optimized for large scientific arrays, partial I/O, and metadata. The choice depends on joins/constraints, document semantics, interchange, or numerical-array performance.

### Explain why a JSON instance with an extra property can validate

> `properties` defines schemas for named properties but does not close the object. JSON Schema permits unmatched properties by default. The schema must say `additionalProperties: false` to reject extras.

### Explain why `42` passes `{ "maxLength": 5 }`

> `maxLength` constrains strings; it does not assert that the instance is a string. For a number, that keyword is not applicable and does not cause failure. Combine it with `type: string` when non-strings must fail.

### Distinguish `anyOf` and `oneOf`

> `anyOf` accepts an instance matching at least one branch, including several branches. `oneOf` accepts it only when exactly one branch matches. Therefore overlapping branches can make `oneOf` fail even though `anyOf` succeeds.

### Explain the HDF5 weather layout

> A root file contains station groups `15` and `20`. Measurement arrays are datasets below those groups, such as `/15/temperature` and `/15/wind`. Sampling interval, start time, and unit are attributes on each dataset, while a description is a root/file attribute. This co-locates data and metadata and permits path lookup and partial array reads.

### When is HDF5 better than JSON/XML, and when is it worse?

> HDF5 is better for very large homogeneous numerical arrays needing high performance, partial I/O, hierarchy, compression, and attached metadata. JSON/XML are better for small human-readable interchange or document/configuration data. HDF5 is binary, needs specialized libraries, is difficult to line-diff, and is not a substitute for relational joins or transactions.

### Explain Visitor's tradeoff

> Visitor centralizes operations that would otherwise be duplicated across composite classes. A Traverser guides it through the hierarchy, and new operations can be added by changing the Visitor rather than the Composite. The cost is exposed state and weaker encapsulation, plus tighter coupling to traversal and element structure, so structural changes become harder.

### Diagnose and fix an untidy table

Use this answer skeleton:

> The observational unit is ____. The table violates the rule ____ because ____. I would `PIVOT`/`UNPIVOT`/split/concatenate ____ so the final columns are ____. I would preserve identifiers and leading-zero categories as text, distinguish null from zero, and use `ORDER BY` only for presentation.

---

## 9. Final two-minute recall sheet

```text
FORMATS
  relational = flat tables, explicit schema, SQL, unordered relations
  XML        = ordered element tree, optional DTD/XSD, XPath/XQuery
  JSON       = unordered objects + ordered arrays, optional JSON Schema
  HDF5       = binary groups + datasets + attributes, partial numerical I/O

JSON SCHEMA
  properties != required
  unknown properties allowed unless additionalProperties: false
  exclusiveMinimum: 0 means > 0
  minItems checks count; uniqueItems checks duplicates
  title/description annotate; type/properties/required validate

BOOLEAN COMPOSITION
  allOf = AND
  anyOf = one or more
  oneOf = exactly one
  not   = NOT
  maxLength alone does not require a string

HDF5 = GDA
  Group     = hierarchy/container
  Dataset   = typed array on disk
  Attribute = small attached metadata
  slicing   = partial disk I/O
  w overwrites; w-/x fails if present; r reads; r+ updates; a creates/updates

VISITOR
  operation changes easy; structure changes hard
  centralized operations; weakened encapsulation

TIDY
  variable -> column
  observation -> row
  value -> cell
  names in rows -> PIVOT
  values in headers -> UNPIVOT
  several values in cell -> split
  preserve 00 and 014 as text

BOUNDARIES
  Low < 50; Medium [50,500); High >= 500
  4.5 likes; 2.5 dislikes; 0.5 hates
```

---

## 10. Closed-book self-test

1. Which parts of JSON preserve order?
2. Why is textual `diff` insufficient for structural equality?
3. What does the JSON Schema validation diagram consume and produce?
4. Do `title` and `description` reject any instances?
5. Does declaring a property under `properties` require it?
6. Why does a product with `discount` still pass the assigned schema?
7. What is the difference between `minimum: 0` and `exclusiveMinimum: 0`?
8. Why does `42` pass `{ "maxLength": 5 }`?
9. When does `oneOf` fail but `anyOf` pass?
10. Are the Q9 `oneOf(string, integer)` and `anyOf(integer, string)` schemas structurally or semantically equivalent?
11. Name the three main HDF5 object types.
12. Where should units and sampling interval be stored in the weather file?
13. Why can HDF5 handle data larger than RAM?
14. When should a relational database be preferred over HDF5?
15. What is the main Visitor benefit and its main cost?
16. State the three tidy-data rules.
17. Which direction transforms `type = cases/population` rows into columns?
18. Which direction transforms `year_1999` and `year_2000` columns into rows?
19. Why use `UNION ALL` rather than `UNION`?
20. Classify values 49, 50, 499, and 500 into severity buckets.
21. Why must age group `014` remain text?
22. Is a zero case count the same as `NULL`?

### Answers

1. Array item order matters; object property order does not.
2. It reports serialization differences such as whitespace or object member order, not data-model equivalence.
3. It consumes a JSON instance and JSON Schema and produces valid/invalid, normally with errors.
4. No; they are annotations.
5. No; only `required` demands presence.
6. Extra properties are allowed because `additionalProperties: false` is absent.
7. `minimum: 0` allows zero; `exclusiveMinimum: 0` requires a value greater than zero.
8. `maxLength` is a string-specific constraint and does not itself impose `type: string`.
9. When two or more branches match: `anyOf` needs at least one, while `oneOf` needs exactly one.
10. Semantically equivalent, not structurally equivalent.
11. Groups, datasets, and attributes.
12. As attributes on the relevant measurement dataset.
13. Dataset slicing performs partial I/O and loads only selected regions.
14. When joins, constraints, transactions, relationships, or concurrent query/update behavior dominate.
15. New operations are easy and centralized; encapsulation weakens and structural changes become harder.
16. One variable per column, one observation per row, one value per cell.
17. `PIVOT` rows to columns.
18. `UNPIVOT` columns to rows.
19. `UNION` removes duplicates; `UNION ALL` preserves all observations.
20. 49 Low, 50 Medium, 499 Medium, 500 High.
21. Integer conversion would destroy the meaningful leading zero and break comparisons such as `age_group = '014'`.
22. No. Zero is an observed value; `NULL` represents missing/unknown data.

---

## Sources covered

Every unique source supplied under `Mod8` was reviewed:

- **IC8** - [In-Class Exercise Sheet 8](./8-Hierarchical_Dataformats/SoSe_2026_RepEng_IC_8___Hierarchical_Data.pdf), all 7 pages, including visual inspection of the diagram and code blanks.
- **HDF5** - [Python and HDF5 excerpt](./8-Hierarchical_Dataformats/python_and_hdf5_excerpt.pdf), all 21 supplied pages.
- **VIS** - [Head First Design Patterns - Visitor excerpt](./8-Hierarchical_Dataformats/head_first_design_patterns_visitor.pdf), all 3 supplied pages.
- **L8** - [Lab Exercise Sheet 8](./Lab_Session_8/Sheet_8.pdf), all 7 pages. The copy under the exercises export is byte-for-byte identical, so it is not a second distinct source.
- **JS** - [JSON Schema step-by-step tutorial](https://json-schema.org/learn/getting-started-step-by-step), the public authoritative version of the assigned Stud.IP link.
- **COMB** - [JSON Schema composition reference](https://json-schema.org/understanding-json-schema/reference/combining), used by in-class questions 6-9.
- **W** - The assigned `Jennifer_Widom_on_XML_and_JSON.url` Stud.IP wrapper and the corresponding Stanford Databases semistructured-data material, used for the relational/XML/JSON comparison.
- [Official DuckDB `PIVOT` documentation](https://duckdb.org/docs/current/sql/statements/pivot)
- [Official DuckDB `UNPIVOT` documentation](https://duckdb.org/docs/current/sql/statements/unpivot)

The two `.url` files are authenticated Stud.IP wrappers. Their public authoritative targets were used where directly available; the actual concepts tested by those links are also reproduced in the in-class sheet.
