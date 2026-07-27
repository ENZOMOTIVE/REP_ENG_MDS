# Reproducibility Engineering - Module 7 Exam Guide

> Exam-first coverage of every Module 7 source: Wickham's assigned *Tidy Data* Sections 1-3, Badia's assigned SQL restructuring and metadata sections, In-Class Sheet 7, and Lab Sheet 7 on reproducible DBMS benchmarking.

## How to use this guide before the exam

If time is short, study in this order:

1. Memorize the three tidy-data rules, five messy forms, and their repairs.
2. Be able to write both earthquake transformations: wide-to-long and long-to-wide.
3. Memorize fraction versus odds versus odds ratio, including the handedness answers.
4. Learn the two independent workflow axes and the six action-log fields.
5. Learn the three lab multiple-choice answers and the `ORDER BY` rule.
6. Read the Dockerfile/Compose answers once, then finish with the two-minute sheet and self-test.

This guide deliberately distinguishes the **assigned tidy-data lecture material** from **Lab Sheet 7**, whose topic is database architectures and benchmarking. Both are included because both are in `Mod7`.

---

## 1. The whole module in one page

### Tidy data: the mapping to memorize

| Meaning | Physical layout |
|---|---|
| Each **variable** | one **column** |
| Each **observation** | one **row** |
| Each type of **observational unit** | one **table** |
| Each **value/entry** | one **cell** |

Fast mnemonic: **Var -> Col; Obs -> Row; Type -> Table; Value -> Cell.** The first three are Wickham's tidy-data rules; value-to-cell is the worksheet's useful extension.

The article's motivating number is **80%**: it is often said that 80% of data-analysis effort is spent cleaning and preparing data. It is a quoted motivation, not a measurement performed by Wickham.

### The five messy forms

| Messy structure | Repair | Assigned example |
|---|---|---|
| Headers contain values | **Melt/stack**: columns -> rows | income bands, `wk1...wk75`, `y2000...` |
| One column contains several variables | **Split** it | `m014` -> sex `m`, age `0-14` |
| Variables occur in rows and columns | **Melt, then cast/unstack** | weather `d1...d31` and `tmin/tmax` |
| Several observational-unit types share a table | **Split/normalize** | song facts versus weekly ranks |
| One observational-unit type is spread across files/tables | Add the source variable, then **append/union** | one file per year |

Direction rules and terminology:

```text
Wickham: melt = columns -> rows; cast = rows -> columns
Modern tools often say: unpivot = columns -> rows; pivot = rows -> columns
Badia uses "pivoting" more broadly for restructuring in either direction
```

### Probability language

For a property with `yes` and `no` counts:

```text
fraction/probability = yes / (yes + no)
odds                = yes / no
odds ratio          = odds in group 1 / odds in group 2
```

For left-handedness in the sheet:

```text
male fraction left-handed = 9 / 52 = 0.1731
male odds left-handed     = 9 / 43 = 0.2093
male:female odds ratio    = (9/43) / (4/44) = 2.3023
```

### SQL reshape formulas

```text
wide -> long: VALUES + CROSS JOIN + CASE
long -> wide: SUM(CASE ...) + GROUP BY
```

### Workflow formula

Two **independent** questions:

1. Was the old representation preserved? **destructive / non-destructive**
2. Can the transformation itself be inverted? **reversible / non-reversible**

For every action record:

```text
TARGET - ACTION - PARAMETERS - WHEN - WHY - WHO
```

### Lab formula

```text
embedded SQLite: BenchBase + DBMS library in one application/container
client-server PostgreSQL: BenchBase client container -> network -> server container

reproducible benchmark:
pin source/version + same workload + fresh state + same host + record output/context

reproducible SQL row choice:
ORDER BY a total key; LIMIT without a unique tie-breaker is not deterministic
```

---

## 2. What tidy data means

### Structure is not semantics

Most statistical data is physically rectangular, but rows and columns alone do not reveal its meaning. The same underlying values can be transposed or arranged differently. Tidy data links the **semantics** of the data to a standard **structure**. [TD2-3]

- A **value** is one datum, normally numeric or textual.
- A **variable** contains values measuring the same attribute across units, such as height, temperature, or duration.
- An **observation** contains the values measured on the same unit across attributes, such as one person, day, or race.
- An **observational-unit type** is the entity or grain being observed, such as a person, a person-day, or a calendar day.

Before judging a table, finish this sentence:

> **One row represents ...**

If that sentence changes from row to row, or a row packs several separate trial observations into cells without explicit aggregation, the table is not tidy. A row may legitimately summarize many trials when the summary statistic/count and its grain are explicit.

### Variable definitions depend on the analysis

The distinction is semantic, not purely mechanical:

- `height` and `weight` naturally look like two variables.
- `height` and `width` might instead be values of a `dimension` variable.
- `home_phone` and `work_phone` may be two variables, or the useful variables may be `phone_number` and `phone_type` in fraud analysis.

A useful diagnostic from Wickham is that functional relationships are easier to express between variables, while comparisons are easier between groups of observations. [TD4]

### Multiple observational-unit types

One study can need multiple tidy tables. An allergy study might have:

- `person(person_id, age, sex, race)` - one row per person;
- `symptom(person_id, date, sneezes, eye_redness)` - one row per person-day;
- `weather(date, temperature, pollen)` - one row per day.

Combining all three grains in one table repeats facts and creates update anomalies. Separate tables can be linked with keys.

### Missing observations versus structural missing values

- If a measurement **should have been made but was not**, retain an explicit missing value.
- If the measurement is **logically impossible** and its absence can be reconstructed, it is structurally missing and may be omitted.

Example: an absent treatment result that should exist is real missingness; a pregnancy measurement for an impossible subject category can be structural missingness. Do not casually delete all `NULL`/missing values. Experimental design determines their meaning. [TD3-4]

### Fixed and measured variables

- **Fixed variables** describe the experimental design and are known in advance; database terminology often calls them dimensions.
- **Measured variables** are the quantities actually observed.

Ordering rows or columns does not change tidiness, but a readable table normally puts fixed variables before measured variables, keeps related columns together, and orders rows by the fixed variables. [TD5]

### Why tidy data helps

- Every tool can find a variable in the same place: a column.
- Aggregation and vectorized operations become straightforward.
- Values from the same observation stay paired in one row.
- Tool output needs less ad-hoc conversion before becoming another tool's input.
- A small set of reshape operations handles many apparently different datasets.

Important: **tidy is not a synonym for clean, correct, complete, normalized for every purpose, or error-free**. Tidiness describes structure. A tidy table can still contain impossible ages, duplicates, bias, or missing data.

Wickham relates tidy data to Codd's third normal form, but frames the constraints in statistical language and focuses on a dataset rather than an entire relational database. [TD4]

---

## 3. The five forms of messy data in detail

### 3.1 Column headers are values

Presentation tables often turn values of a variable into headings.

```text
religion | <$10k | $10-20k | $20-30k | ...
```

The real variables are:

```text
religion | income_band | frequency
```

**Melt/stack** the income columns:

1. Keep columns that already represent variables; Wickham calls these `colvars`.
2. Move every other former header into one new variable.
3. Move the corresponding cells into one value variable.
4. Rename generic `column` and `value` fields to their meanings, here `income_band` and `frequency`.

The same diagnosis applies to Billboard columns `wk1` through `wk75`: week numbers are values of `week`; ranks are values of `rank`. After melting, derive the calendar date from entry date and week if needed. [TD5-8]

A wide layout may still be convenient for data entry, compact display, or matrix computation. **Messy for analysis does not mean useless for every purpose.**

### 3.2 Multiple variables in one column

The tuberculosis header `m014` combines two variables:

```text
m       -> sex = male
014     -> age = 0-14
```

Repair:

1. Melt the demographic columns into a temporary column/value pair.
2. Split the compound heading into `sex` and `age` using a delimiter, position/regular expression, or lookup table.
3. Rename the measured value `cases`.

Target shape:

```text
country | year | sex | age | cases
```

This shape also makes it easy to join population data and calculate rates. Preserve the difference between count `0` and missing: it can reflect how the data was collected. [TD8-9]

### 3.3 Variables in both rows and columns

The weather example contains:

- ordinary columns `id`, `year`, and `month`;
- day values hidden in headers `d1...d31`;
- variable names `tmin` and `tmax` stored as row values in `element`.

Repair:

1. Melt `d1...d31` so day becomes a value.
2. combine year, month, and day into `date`;
3. omit only reconstructible structural dates, such as February 30;
4. cast/unstack `element` so `tmin` and `tmax` become columns.

Final grain: one row per weather station-day. [TD8-10]

### 3.4 Multiple observational-unit types in one table

Billboard data contains facts about two units:

```text
song(song_id, artist, track, duration, ...)
ranking(song_id, date_or_week, rank)
```

If song metadata is repeated on every weekly rank row, the same fact is stored many times and can become inconsistent. Split the table and link it with `song_id`. This is normalization: express each fact once. [TD10-11]

Many analysis tools expect one rectangular table, so analysis may later join the normalized tables. The tradeoff is:

```text
normalized storage -> less redundancy and inconsistency
denormalized analysis table -> easier input for many analytical tools
```

### 3.5 One observational-unit type across files/tables

If each file contains the same type of record and has the same schema:

1. read each file;
2. add a source column, since the filename may encode year, location, or person;
3. append all rows.

If schemas, names, file formats, or missing-value conventions changed, first tidy files individually or in compatible groups, then combine them. [TD11-12]

---

## 4. Restructuring data with SQL

### The three cases in Badia Section 3.4.1

| Situation | Main SQL operation |
|---|---|
| Related objects/multivalued attributes connected by identifiers | `JOIN` on primary/foreign keys |
| Same kind of data split among compatible tables | set operation, usually `UNION ALL` |
| Values of an implicit variable are encoded in rows or column names | pivot/unpivot with `CASE`, or a DBMS-specific operator |

In spreadsheets and files, connecting identifiers may exist without declared key constraints. Finding the true key is then part of restructuring. [SQL-R159-160]

### Wide-to-long earthquake transformation

Source:

```text
earthquakes(magnitude, y2000, y2001, y2002)
```

Target:

```text
earthquakesTidy(magnitude, year, numberquakes)
```

The literal In-Class Sheet 7 template is completed by this non-aggregate, PostgreSQL-style version: [IC3]

```sql
CREATE TABLE earthquakesTidy AS
SELECT
    magnitude,
    year,
    CASE
        WHEN year = 2000 THEN y2000
        WHEN year = 2001 THEN y2001
        WHEN year = 2002 THEN y2002
        ELSE 0
    END AS numberquakes
FROM earthquakes
CROSS JOIN (VALUES (2000), (2001), (2002)) AS temp(year);
```

What happens:

1. `VALUES` creates a three-row table `temp(year)`.
2. `CROSS JOIN` pairs every magnitude row with every year, producing `3 * 3 = 9` rows.
3. `CASE` chooses the source column matching the generated year.
4. The chosen value becomes the measured variable `numberquakes`.

The comma form in the sheet means the same cross product:

```sql
FROM earthquakes,
     (VALUES (2000), (2001), (2002)) AS temp(year)
```

The assigned book uses an aggregate variant: [SQL-R161-162]

```sql
CREATE TABLE earthquakesTidy AS
SELECT
    magnitude,
    year,
    SUM(
        CASE
            WHEN year = 2000 THEN y2000
            WHEN year = 2001 THEN y2001
            WHEN year = 2002 THEN y2002
            ELSE 0
        END
    ) AS numberquakes
FROM earthquakes
CROSS JOIN (VALUES (2000), (2001), (2002)) AS temp(year)
GROUP BY magnitude, year;
```

The worksheet has no space after `FROM` for this `GROUP BY`, so use the first form when filling its literal blanks; recognize the second as the source-book form.

### Cross-product result before `CASE`

One legal display of the nine logical rows is:

| magnitude | year | y2000 | y2001 | y2002 |
|---|---:|---:|---:|---:|
| 4.0-4.9 | 2000 | 7425 | 7456 | 7489 |
| 5.0-5.9 | 2000 | 1318 | 1299 | 1312 |
| 6.0+ | 2000 | 165 | 174 | 160 |
| 4.0-4.9 | 2001 | 7425 | 7456 | 7489 |
| 5.0-5.9 | 2001 | 1318 | 1299 | 1312 |
| 6.0+ | 2001 | 165 | 174 | 160 |
| 4.0-4.9 | 2002 | 7425 | 7456 | 7489 |
| 5.0-5.9 | 2002 | 1318 | 1299 | 1312 |
| 6.0+ | 2002 | 165 | 174 | 160 |

Without `ORDER BY`, SQL does not guarantee this physical output order.

### Tidy earthquake result

| magnitude | year | numberquakes |
|---|---:|---:|
| 4.0-4.9 | 2000 | 7425 |
| 4.0-4.9 | 2001 | 7456 |
| 4.0-4.9 | 2002 | 7489 |
| 5.0-5.9 | 2000 | 1318 |
| 5.0-5.9 | 2001 | 1299 |
| 5.0-5.9 | 2002 | 1312 |
| 6.0+ | 2000 | 165 |
| 6.0+ | 2001 | 174 |
| 6.0+ | 2002 | 160 |

### Long-to-wide conditional aggregation

```sql
SELECT
    magnitude,
    SUM(CASE WHEN year = 2000 THEN numberquakes ELSE 0 END) AS y2000,
    SUM(CASE WHEN year = 2001 THEN numberquakes ELSE 0 END) AS y2001,
    SUM(CASE WHEN year = 2002 THEN numberquakes ELSE 0 END) AS y2002
FROM earthquakesTidy
GROUP BY magnitude;
```

Why `GROUP BY magnitude` is required:

- the long table has three rows per magnitude;
- the wide result needs one row per magnitude;
- each `CASE` selects one year's value and supplies zero for the others;
- `SUM` collapses the three rows;
- SQL requires the selected non-aggregate `magnitude` to be grouped.

With exactly one row per magnitude-year, each `SUM` has one nonzero input. `MAX(CASE ...)` would also work under that uniqueness assumption. [IC4; SQL-R162-163]

Recognition-level alternative: PostgreSQL's `crosstab` facility spreads category values into columns. It takes an input-data query that supplies row/category/value data and a category query that fixes the output-column order. Manual `CASE` SQL remains the exercise priority.

### Dummy variables / one-hot encoding

The reading uses several names: dummy, indicator, design, one-hot, Boolean, binary, or qualitative variables. They convert categorical values into numeric inputs.

For categories `A`, `B`, and `C`:

```sql
SELECT
    name,
    SUM(CASE WHEN category = 'A' THEN 1 ELSE 0 END) AS A,
    SUM(CASE WHEN category = 'B' THEN 1 ELSE 0 END) AS B,
    SUM(CASE WHEN category = 'C' THEN 1 ELSE 0 END) AS C
FROM Data
GROUP BY name;
```

Mathematically, `n - 1` indicators can encode `n` categories because the omitted category is inferred when all others are zero. The reading notes that all `n` columns are nevertheless customary for many ML/data-mining inputs. [SQL-R163-165]

Likely variant:

```sql
SELECT
    student_name,
    MAX(CASE WHEN exam = 'midterm' AND score > 60 THEN 1 ELSE 0 END) AS midterm,
    MAX(CASE WHEN exam = 'final'   AND score > 60 THEN 1 ELSE 0 END) AS final
FROM grades
GROUP BY student_name;
```

---

## 5. Contingency tables, fractions, odds, and odds ratios

### Tidy representation

The displayed contingency table is:

| sex | right-handed | left-handed | total |
|---|---:|---:|---:|
| Male | 43 | 9 | 52 |
| Female | 44 | 4 | 48 |
| Total | 87 | 13 | 100 |

A **contingency table** displays joint counts for combinations of two categorical variables and gives a basic view of their association/interrelation.

- `52`, `48`, `87`, and `13` are **marginal totals**.
- `100` is the **grand total**.
- Marginals are derived and should not be inserted as primitive observations alongside the four cells.

Store one row per sex-handedness combination:

```sql
CREATE TABLE handedness_counts (
    sex          VARCHAR(6),
    handedness   VARCHAR(5),
    n            INTEGER NOT NULL CHECK (n >= 0),
    PRIMARY KEY (sex, handedness)
);

INSERT INTO handedness_counts (sex, handedness, n) VALUES
    ('Male',   'Right', 43),
    ('Male',   'Left',   9),
    ('Female', 'Right', 44),
    ('Female', 'Left',   4);
```

This is tidy **aggregated** data: each row is one combination, and `n` is its measured count. Individual-level data would instead have one row per person.

### Marginal queries

```sql
SELECT sex, SUM(n) AS total
FROM handedness_counts
GROUP BY sex;
```

Result: Male `52`; Female `48`.

```sql
SELECT handedness, SUM(n) AS total
FROM handedness_counts
GROUP BY handedness;
```

Result: Right `87`; Left `13`.

Trap: `COUNT(*)` returns `2` rows per group in this aggregated table, not the number of people. Use `SUM(n)`.

### Fraction of males who are left-handed

```text
P(Left | Male) = 9 / (43 + 9) = 9/52 = 0.1730769 = 17.31%
```

```sql
SELECT
    1.0 * SUM(CASE WHEN handedness = 'Left' THEN n ELSE 0 END)
        / NULLIF(SUM(n), 0) AS male_left_fraction
FROM handedness_counts
WHERE sex = 'Male';
```

`1.0 *` forces non-integer division; `NULLIF(..., 0)` avoids division by zero.

### Odds that a male is left-handed

Odds compare those with the property to those without it:

```text
odds(Left | Male) = male-left / male-right = 9/43 = 0.2093023
```

```sql
SELECT
    1.0 * SUM(CASE WHEN handedness = 'Left'  THEN n ELSE 0 END)
        / NULLIF(
            SUM(CASE WHEN handedness = 'Right' THEN n ELSE 0 END),
            0
          ) AS male_left_odds
FROM handedness_counts
WHERE sex = 'Male';
```

### Odds ratio

For this orientation, event `A` is left-handedness and condition `B` is being male:

| | Left | Right |
|---|---:|---:|
| Male | `a = 9` | `b = 43` |
| Female | `c = 4` | `d = 44` |

```text
OR = (a/b) / (c/d) = ad/bc
   = (9/43) / (4/44)
   = (9 * 44) / (43 * 4)
   = 2.3023
```

Interpretation: in this sample, the **odds** of left-handedness are about `2.30` times as high for males as for females. Reversing the comparison gives its reciprocal.

```sql
WITH cells AS (
    SELECT
        SUM(CASE WHEN sex = 'Male'   AND handedness = 'Left'  THEN n ELSE 0 END) AS a,
        SUM(CASE WHEN sex = 'Male'   AND handedness = 'Right' THEN n ELSE 0 END) AS b,
        SUM(CASE WHEN sex = 'Female' AND handedness = 'Left'  THEN n ELSE 0 END) AS c,
        SUM(CASE WHEN sex = 'Female' AND handedness = 'Right' THEN n ELSE 0 END) AS d
    FROM handedness_counts
)
SELECT 1.0 * a * d / NULLIF(b * c, 0) AS odds_ratio
FROM cells;
```

Do not confuse it with the risk ratio:

```text
(9/52) / (4/48) = 2.0769  -> risk/fraction ratio, NOT odds ratio
```

---

## 6. Workflows, destructive changes, and metadata

### Why workflows matter

Exploring, cleaning, and preparing data is **iterative**. EDA reveals problems, transformations reveal more structure, and later evidence can invalidate earlier assumptions. A **workflow** is the ordered sequence of actions applied to data or results of earlier actions. [SQL-M165]

### The two independent axes

| Axis | First class | Second class |
|---|---|---|
| Is the old representation retained? | **Destructive:** overwritten/lost | **Non-destructive:** old version remains |
| Can the transformation itself be inverted? | **Reversible:** original reconstructible | **Non-reversible:** information discarded |

The four combinations are possible:

| Mode | Reversible transformation | Non-reversible transformation |
|---|---|---|
| Destructive | in-place `x := x + 1`, assuming no overflow/rounding | in-place `TRIM(name)` or `DROP COLUMN` |
| Non-destructive | new column/table containing `x + 1` | new table containing trimmed names while raw table remains |

Key nuance: preserving a raw table lets the **workflow** return to it, but it does not make `TRIM` mathematically invertible from the trimmed result alone.

A destructive operation can be reversible. Concatenating two strings with a recorded separator that never occurs in either input can be undone by splitting. A non-reversible operation can be implemented non-destructively so the original is still available. Non-destructive work costs additional storage. [SQL-M165-166]

### SQL implementation patterns

Destructive in-place update:

```sql
UPDATE Data
SET attribute = function(attribute);
```

Non-destructive new attribute:

```sql
ALTER TABLE Data ADD COLUMN transformed datatype;

UPDATE Data
SET transformed = function(attribute);
```

Non-destructive new table/checkpoint:

```sql
CREATE TABLE NewData AS
SELECT
    ...,
    function(attribute) AS transformed
FROM Data;
```

Copying the entire dataset after every tiny action duplicates unchanged data and creates too many tables. A checkpoint is more sensible after a major transformation or a coherent batch. [SQL-M166]

### Views as executable workflow steps

```sql
CREATE VIEW CleanData AS
SELECT ...
FROM RawData
WHERE ...;
```

A normal view:

- stores its **query definition**, not an independent copy of rows;
- reruns that query when read;
- changes when its source tables change;
- consumes no extra table-data storage;
- can be defined on another view, forming a multi-step workflow;
- has its definition recorded by the catalog.

Therefore, a view preserves structural provenance, but it is **not a frozen snapshot**. The DBMS records **how** the view is defined, not the analyst's human **why**. [SQL-M166-169]

### Descriptive metadata, provenance, and lineage

- If metadata arrives with a dataset, EDA should verify that reality matches it.
- If it does not arrive, use EDA to create a description before serious analysis.
- Record every modified attribute, new attribute, derived dataset, and transformation.
- The chain of changes leading to a dataset is its **provenance/lineage**.

This supports repeatability, transparency, alternative analyses, sharing, publication, and auditing. Bad assumptions can be traced to the downstream products they affected. [SQL-M167]

### What the DBMS catalog records

Typical system/catalog metadata includes:

- table and view names;
- schemas, column names, and data types;
- primary, unique, and foreign keys;
- users/roles and privileges;
- view definitions.

It does not automatically provide enough scientific meaning, quality assessment, or decision rationale.

PostgreSQL commands to recognize: [SQL-M168]

| Command | Meaning |
|---|---|
| `\l` | list databases |
| `\d` | list tables/views in the current database |
| `\dt` | tables only |
| `\dv` | views only |
| `\dp` | objects and access privileges |
| `\d name` | columns, types, and details for an object |
| `\dg` or `\du` | roles/users |

MySQL commands to recognize:

```sql
SHOW DATABASES;
SHOW SCHEMAS;
SHOW TABLES FROM database_name;
SHOW TABLES FROM database_name LIKE 'pattern';
SHOW CREATE TABLE table_name;
SHOW COLUMNS FROM table_name;
SHOW CREATE VIEW view_name;
```

### Attribute-level metadata

The reading proposes one row per attribute, with fields such as: [SQL-M168-169]

```text
attribute_name, representation, domain, provenance,
accuracy, completeness, consistency, currency,
precision, certainty
```

- `representation` should match the storage type/format.
- `domain` should explain real-world meaning and valid, invalid, and typical values in plain language.
- Quality fields describe fitness and reliability; not every field applies to every attribute, so some metadata `NULL`s are legitimate.

Helpful background from the referenced-but-unassigned Badia Section 1.4 (approximately pp. 25-28):

> Scope note: the assigned Section 3.5 gives the metadata field list; the short definitions below come from the earlier section it references. Prioritize the field list for the exam.

| Field | Meaning |
|---|---|
| accuracy | closeness to the true value |
| completeness | whether necessary values/scope are present |
| consistency | absence of contradictions |
| currency | how up to date the data is |
| precision | measurement resolution/granularity |
| certainty | confidence in the value/source |

### The action log: six items

Record for every transformation:

1. target attribute(s);
2. action/function;
3. parameter values;
4. when it happened;
5. why it happened;
6. who performed it.

Mnemonic: **TARGET - ACTION - PARAMETERS - WHEN - WHY - WHO**.

The SQL statement can often capture the first three. A timestamp reconstructs order and dependent changes. `why` is especially important and often omitted: later discoveries can overturn the assumption behind a cleaning choice. `who` supports legal, regulatory, and access audits. Views automatically retain their query definition, but still need an external record of `why`. [SQL-M169]

---

## 7. Complete In-Class Sheet 7 answer key

### Question 1: blanks

- `80%`
- each type of **observational unit** forms a table;
- each **observation** forms a row;
- each **variable** forms a column;
- each cell is an **entry** (one single value).

### Question 2(a): grade table

The student names are values of `student`, not three variables, so they must not be column names.

| student | exam | grade |
|---|---|---:|
| Rozz | midterm | 1.3 |
| Andrew | midterm | 2.0 |
| Susie | midterm | 1.7 |
| Rozz | final | 2.3 |
| Andrew | final | 1.7 |
| Susie | final | 1.0 |

### Question 2(b): student number plus grades

**Untidy** - sometimes described as *almost tidy*. It has columns and rows in sensible positions, but mixes two grains and repeats student metadata:

```text
students(student, stu_number)
grades(student, exam, grade)
```

`students`:

| student | stu_number |
|---|---:|
| Rozz | 666 |
| Andrew | 1969 |
| Susie | 314 |

`grades` is the six-row table from 2(a). The shared `student` key reconnects them.

### Question 2(c): choices and reaction times

**Untidy**: each subject row contains three observations; both sequence cells contain three values; trial number is implicit.

| subject_id | trial | choice | reaction_time |
|---:|---:|---|---:|
| 1 | 1 | A | 312.3 |
| 1 | 2 | B | 433.4 |
| 1 | 3 | B | 365.1 |
| 2 | 1 | B | 393.1 |
| 2 | 2 | A | 491.0 |
| 2 | 3 | B | 372.2 |
| 3 | 1 | B | 356.3 |
| 3 | 2 | A | 313.9 |
| 3 | 3 | A | 475.5 |
| 4 | 1 | A | 292.4 |
| 4 | 2 | B | 352.8 |
| 4 | 3 | B | 378.1 |

### Question 3: country subtables

**Untidy as one dataset**: `country` is hidden in table headings and one observational-unit type is split across tables.

| country | year | cases | population |
|---|---:|---:|---:|
| Afghanistan | 1999 | 745 | 19987071 |
| Afghanistan | 2000 | 2666 | 20595360 |
| Brazil | 1999 | 37737 | 172006362 |
| Brazil | 2000 | 80488 | 174504898 |
| China | 1999 | 212258 | 1272915272 |
| China | 2000 | 213766 | 1280428583 |

### Question 4: handedness

- (a) tidy primitive table: `(sex, handedness, n)` with the four rows `43`, `9`, `44`, `4`;
- (b) male `52`, female `48`: `GROUP BY sex` and `SUM(n)`;
- (c) right `87`, left `13`: `GROUP BY handedness` and `SUM(n)`;
- (d) male left-handed fraction: `9/52 = 0.1731`;
- (e) male left-handed odds: `9/43 = 0.2093`;
- (f) male-versus-female odds ratio: `(9/43)/(4/44) = 2.3023`.

The complete SQL is in Section 5.

### Question 5: earthquakes

- (a) tidy schema: `(magnitude, year, numberquakes)`, with nine rows;
- (b) the cross product has `3 * 3 = 9` rows and retains all original year columns;
- (c) `VALUES` + cross join + `CASE` creates long form;
- (d) `SUM(CASE ...)` + `GROUP BY magnitude` recreates wide form.

The complete SQL and both valid forward variants are in Section 4.

### Question 6: blanks

- **essentially iterative**;
- **workflow**;
- **destructive** and **non-destructive**;
- **reversible** and **non-reversible**.

### Question 7

```sql
ALTER TABLE Customers DROP COLUMN phone;
```

Answer: **None of these options**. It is destructive and non-reversible from the resulting table. Re-adding an empty `phone` column would not restore the values.

### Question 8

```sql
CREATE TABLE CleanCustomers AS
SELECT id, TRIM(name) AS name, email
FROM Customers;
```

Expected answer: **The action is non-destructive**.

`Customers` remains, but `TRIM` itself is non-reversible from `CleanCustomers` because the removed whitespace positions and counts are gone. The workflow can abandon the new table and return to the source; that is different from inverting `TRIM`.

### Question 9

Destructive but reversible example:

```sql
UPDATE Measurements
SET x = x + 1;
```

It overwrites `x`, but `x = x - 1` reverses it if overflow, rounding, and intervening changes are excluded.

### Question 10

Destructive and non-reversible example:

```sql
UPDATE Customers
SET name = TRIM(name);
```

The original whitespace is overwritten and cannot be inferred. `DROP COLUMN phone` is another valid answer.

---

## 8. Lab Sheet 7: database architectures and benchmarking

### What the lab compares

BenchBase is a multi-DBMS benchmark harness. The lab runs its YCSB workload against:

```text
Embedded setup
  [one container: BenchBase -> in-process SQLite -> database file]

Client-server setup
  [BenchBase client container] -- Compose DNS/TCP --> [PostgreSQL server container]
                                                        |
                                                  [named volume]
```

| Property | Embedded SQLite | Client-server PostgreSQL |
|---|---|---|
| DBMS relationship | library runs in the application process | separate server process accepts client connections |
| Lab containers | BenchBase and SQLite in one | client and server in separate containers |
| Communication | in-process/file access | network protocol over Compose network |
| Deployment footprint measured | one runtime image | client image plus server image |
| DB storage/state | local SQLite file for the run; persistence depends on mounting | PostgreSQL named volume |

Do not define an architecture merely by container count. A MariaDB server and its client can share a container and still use a client-server architecture.

### Why the source commit is pinned

```bash
git clone https://github.com/cmu-db/benchbase
cd benchbase
git checkout 33c0047
```

The commit identifies the exact BenchBase source rather than whatever the moving default branch contains later. For stronger long-term packaging, also preserve dependencies and container images by immutable digest.

### YCSB workloads and output

The provided configurations run the same parameters for each DBMS but change connection details:

- `ycsb_read_only.xml`;
- `ycsb_mixed.xml`;
- `ycsb_write_only.xml`.

The pinned upstream BenchBase `sample_ycsb_config.xml` uses serializable isolation, batch size `128`, scale factor `1`, one terminal, a `60`-second run, and an offered rate near `10,000` requests/s; its SQLite loading uses one loader thread because writers are serialized. The actual course XML files are absent locally, so verify their values before claiming these are the exact lab settings. The general lesson is unchanged: workload controls—not merely filenames—must match for a fair comparison.

Each benchmark produces a `.summary.json`; the relevant key is:

```text
Throughput (requests/second)
```

The supplied plotter reads that value for each workload and writes:

```text
results/sqlite/throughput.pdf
results/postgres/throughput.pdf
```

The sample plots show roughly:

| DBMS | Mixed | Read-only | Write-only |
|---|---:|---:|---:|
| SQLite | 2110.7 | 10000.1 | 1114.5 |
| PostgreSQL | 4016.8 | 10000.7 | 2705.5 |

These are illustrative, **not constants to memorize**. Both sample read-only runs reach about 10,000 requests/s and are consistent with the upstream sample's offered-rate ceiling; the omitted course XMLs prevent confirming that cap locally. The shown PostgreSQL run is faster for mixed and write-only work. Values depend on hardware and current load. Only compare measurements made on the **same host** under comparable conditions. [L3; L6]

For this particular sample, PostgreSQL is about `4016.8/2110.7 = 1.90x` as fast on mixed work and `2705.5/1114.5 = 2.43x` as fast on write-only work. This does not prove that client-server architecture alone caused the difference.

### What makes the comparison credible

- same BenchBase source revision;
- equivalent YCSB workload parameters;
- same host hardware and comparable current load;
- fresh database state for each workload;
- separately named result directories;
- explicit DBMS/container versions;
- recorded throughput unit and raw JSON;
- preferably repeated runs, warm-up policy, and summary statistics.

The sheet's scripts start each PostgreSQL workload from a new database. State left by a previous write-heavy run would otherwise confound later results.

### Why plotting runs in a separate image

Python and plotting libraries are not part of the benchmark runtime. Keeping them in `benchbase-plot` prevents those dependencies from inflating the `benchbase-sqlite` image whose size is later measured. A bind mount lets the plotter read host results and write the PDF back to the host.

Key flags:

| Fragment | Meaning |
|---|---|
| `--rm` | remove the stopped plotting container |
| `-e MPLCONFIGDIR=/tmp/matplotlib` | give Matplotlib a writable config/cache path |
| `-v "$PWD:/work"` | bind-mount the lab directory at `/work` |
| `-w /work` | set the container working directory |
| final `sqlite` / `postgres` | argument selecting the result family |

### Image size is not benchmark throughput

The self-built SQLite image intentionally contains both build-time and runtime material. It is expected to be larger than a prebuilt runtime-only image because it can retain:

- full JDK and Git;
- source and `.git` history copied into the build;
- Maven wrapper/downloads and dependency cache;
- compiler/build outputs;
- the compressed distribution and extracted runtime.

A runtime image can use a multi-stage build and copy only the runnable distribution into a smaller final base. Image size measures deployment/storage footprint, not speed, memory use, database volume size, or scientific reproducibility by itself.

---

## 9. Worked Lab Sheet 7 implementation

### 9.0 Prepare the repositories

The worksheet first asks you to update the course/FIMGit repository, then clone BenchBase **outside** it so the external source tree is not accidentally nested in the course repository:

```bash
# In the course/FIMGit repository:
git pull

# Then move to its parent directory:
cd ..
git clone https://github.com/cmu-db/benchbase
cd benchbase
git checkout 33c0047
```

The commit pins the BenchBase source state; the repository boundary prevents the benchmark source from becoming an accidental course-repository addition.

### 9.1 BenchBase plus SQLite Dockerfile

Create this in the checked-out BenchBase repository root:

```Dockerfile
FROM eclipse-temurin:23-jdk

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN ./mvnw clean package -P sqlite \
    && mkdir -p /benchbase \
    && tar -xzf target/benchbase-sqlite.tgz \
        --strip-components=1 -C /benchbase

WORKDIR /benchbase
ENTRYPOINT ["java", "-jar", "benchbase.jar"]
```

Why each part exists:

| Part | Purpose |
|---|---|
| `eclipse-temurin:23-jdk` | required Java build/runtime base |
| install `git` | BenchBase's Maven build obtains revision/version information |
| `COPY . .` | copy the checked-out, pinned source into the image |
| `./mvnw ... -P sqlite` | use the project-pinned Maven wrapper and SQLite profile |
| `--strip-components=1` | place distribution contents directly in `/benchbase` |
| `WORKDIR /benchbase` | make relative runtime paths resolve correctly |
| `ENTRYPOINT` | start BenchBase while allowing the runner's benchmark arguments to be appended |

Build it:

```bash
docker build -t benchbase-sqlite .
```

This is intentionally a single-stage image for the lab comparison, so do not claim it is size-optimized.

### 9.2 Run SQLite and plot its results

From `LabSession7/`:

```bash
./run_sqlite_benchmark.sh

docker build -f Dockerfile.plot -t benchbase-plot .

docker run --rm -e MPLCONFIGDIR=/tmp/matplotlib \
    -v "$PWD:/work" -w /work benchbase-plot \
    plot_throughput.py sqlite
```

PowerShell runner:

```powershell
.\run_sqlite_benchmark.ps1
```

### 9.3 Measure image sizes in bytes

```bash
docker image inspect --format '{{.Size}}' \
    benchbase-sqlite

docker pull benchbase.azurecr.io/benchbase-sqlite

docker image inspect --format '{{.Size}}' \
    benchbase.azurecr.io/benchbase-sqlite
```

`.Size` is the image's byte size reported by Docker. Exact numbers vary by architecture/tag contents, so the exam-worthy answer is the method and the build-versus-runtime explanation.

### 9.4 Compose solution under stated assumptions

Because the referenced starter Compose file and JDBC XML are absent, this solution assumes the service hostname is `postgres` and the host result root is `./results`. It satisfies the PDF's requirements; if an omitted XML expects another hostname such as `db`, change the service key and JDBC hostname together.

```yaml
services:
  postgres:
    image: postgres:18.4
    environment:
      POSTGRES_DB: benchbase
      POSTGRES_USER: benchbase
      POSTGRES_PASSWORD: benchbase
    ports:
      - "127.0.0.1:54327:5432"
    volumes:
      - postgres-data:/var/lib/postgresql

  benchbase:
    image: benchbase.azurecr.io/benchbase-postgres
    depends_on:
      - postgres
    volumes:
      - ./config/postgres:/benchbase/config/postgres/lab7:ro
      - ./results:/benchbase/results

volumes:
  postgres-data:
```

Important details:

- Inside the Compose network, BenchBase connects to host `postgres` on container port `5432`, not `localhost:54327`.
- `127.0.0.1:54327:5432` is the host-facing mapping.
- `:ro` makes benchmark configuration read-only.
- the results mount is writable so outputs reach the host.
- `postgres-data` is a named volume.
- For the official **PostgreSQL 18+** image, mount the volume at `/var/lib/postgresql`; the historical `/var/lib/postgresql/data` target applies to 17 and earlier. See the [official image documentation](https://hub.docker.com/_/postgres).
- `depends_on` controls startup order, not database readiness. A robust runner still waits/retries until PostgreSQL accepts connections.

### 9.5 Run PostgreSQL and plot its results

```bash
./run_postgres_benchmark.sh

docker run --rm -e MPLCONFIGDIR=/tmp/matplotlib \
    -v "$PWD:/work" -w /work benchbase-plot \
    plot_throughput.py postgres
```

PowerShell runner:

```powershell
.\run_postgres_benchmark.ps1
```

The script creates separate workload results, starts from a new PostgreSQL database, starts the service, and runs BenchBase as a one-off Compose container.

### 9.6 Size of the client-server setup

```bash
benchbase_pg_bytes=$(docker image inspect --format '{{.Size}}' \
    benchbase.azurecr.io/benchbase-postgres)

postgres_image_bytes=$(docker image inspect --format '{{.Size}}' \
    postgres:18.4)

echo $((benchbase_pg_bytes + postgres_image_bytes))
```

Compare that sum with the prebuilt `benchbase-sqlite` runtime image. The client-server sum will normally be larger because it includes both the BenchBase/PostgreSQL client runtime and a full PostgreSQL server, but report the measured values rather than assuming an ordering. This is the exercise-defined sum of image sizes; persistent database volume contents and runtime memory are not included, and shared layers may mean actual incremental disk use differs from the arithmetic sum.

### 9.7 What can and cannot be reproduced from this repository

`Mod7/Lab_Session_7/` contains only `Sheet_7.pdf`. The worksheet refers to lab assets that are **not present** in this repository:

- the SQLite and PostgreSQL YCSB XML configurations;
- the Bash and PowerShell benchmark runners;
- `plot_throughput.py` and `Dockerfile.plot`;
- the starter Compose file;
- actual `*.summary.json` output.

Therefore:

- the commands and proposed files above satisfy the PDF under the documented service-name and host-path assumptions;
- the throughput figures in Section 8 are the worksheet's illustrative figures;
- no local benchmark result or exact image-byte value should be invented;
- actual execution would require obtaining the omitted lab bundle first.

This distinction is itself a reproducibility lesson: a paper or worksheet that names an experiment is not enough if the executable configuration, scripts, versions, and raw results are missing.

---

## 10. Lab multiple-choice answer key

### 10.1 Question 4(a): PostgreSQL `file_fdw`

Correct option:

> **Queries read the external file through the foreign-data wrapper.**

Given a foreign table backed by `/data/measurements.csv`:

- `CREATE FOREIGN TABLE` creates catalog metadata; it does **not** import or copy the CSV into PostgreSQL.
- The PostgreSQL **server process** reads and parses the file when a query accesses the foreign table.
- The path is relative to the server/container's filesystem, not the SQL client's filesystem.
- Changing or deleting the file changes or breaks later query results.
- File existence, permission, and malformed-row failures may appear only at query time.
- PostgreSQL cannot create an ordinary local B-tree index on this `file_fdw` source.
- A selective `WHERE` clause is not a guarantee that the CSV will not be scanned.

Reproducibility consequence: preserve/checksum the input file and mount it at a stable, documented server-side path.

### 10.2 Question 4(b): MariaDB benchmark placement

Correct option:

> **Both configurations.**

- Configuration A can colocate the MariaDB server and `mariadb-slap` client in one container as separate processes.
- Configuration B can run the load generator and server in separate containers and connect through Compose DNS.

The architecture remains client-server in both cases. Container placement is a deployment choice; it does not turn a server DBMS into an embedded library.

Operational caveats:

- the server must be initialized and ready before the load generator starts;
- `depends_on` gives startup order only, not readiness;
- use a health check, `service_healthy`, or a retry/wait loop in a robust experiment;
- failures must propagate out of wrapper scripts instead of being silently ignored.

### 10.3 Question 4(c): reproducible SQL result order

Correct answer:

> **2 queries: I and IV.**

Assume `id` is a non-null primary key and the database snapshot does not change.

| Query | Guaranteed reproducible result/order? | Reason |
|---|---|---|
| I. `... ORDER BY id` | **Yes** | unique `id` defines a total order |
| II. no `ORDER BY` | **No** | relational results are unordered unless explicitly ordered |
| III. `... LIMIT 1` | **No** | any qualifying row may be selected |
| IV. `... ORDER BY id LIMIT 1` | **Yes** | selects the unique smallest `id` |
| V. `... ORDER BY value LIMIT 1` | **No** | tied minimum `value`s leave the chosen `id` unspecified |

Deterministic repair for V:

```sql
SELECT id, value
FROM items
ORDER BY value, id
LIMIT 1;
```

Rule to memorize:

> `ORDER BY` is deterministic only when the complete ordering key breaks every relevant tie. An index or stable-looking output is not a contract.

---

## 11. Highest-yield exam traps and answer templates

### Tidy-data traps

1. **Rectangular does not imply tidy.** First identify the row grain and semantic variables.
2. **Tidy does not imply clean.** Structural tidiness says nothing about correctness, duplicates, bias, or validity.
3. **One observational-unit type gets one table.** It is not one table per individual observation.
4. A name such as `y2000`, `wk1`, `Male`, or `Rozz` in a header may be a **value disguised as a column name**.
5. A cell such as `A,B,B` is not atomic when those elements are separate trial observations.
6. Repeating student or song metadata usually signals mixed grains and normalization need.
7. **Melt** moves columns to rows; **cast/pivot** moves rows to columns.
8. Do not drop all missing values. Distinguish an expected-but-missing measurement from reconstructible structural missingness.
9. A wide layout can be useful for human entry, compact display, or matrix computation even when it is untidy for analysis.

### SQL and numerical traps

1. On a tidy table of aggregated counts, totals use `SUM(n)`, not `COUNT(*)`.
2. Force non-integer division with `1.0 *`, `CAST`, or the DBMS equivalent.
3. Fraction/probability is `yes / total`; odds is `yes / no`.
4. `(9/52)/(4/48) = 2.0769` is a **risk ratio**, not the requested odds ratio.
5. The earthquake cross join creates all magnitude-year combinations; `CASE` selects the matching old column.
6. `3` earthquake rows times `3` generated years gives `9` rows.
7. `GROUP BY` determines output grain. Long-to-wide needs one output row per `magnitude`.
8. `SUM(CASE...)` and `MAX(CASE...)` agree only under suitable uniqueness assumptions.
9. No `ORDER BY` means no guaranteed order. `LIMIT` does not fix that.
10. An `ORDER BY` on a non-unique field still needs a unique tie-breaker for deterministic top-N selection.

### Workflow and metadata traps

1. **Destructive/non-destructive** and **reversible/non-reversible** are independent axes.
2. `TRIM` stays intrinsically non-reversible even if `CREATE TABLE AS` preserves the raw source.
3. Re-adding a dropped column does not recover the lost values.
4. A reversible update needs its assumptions: no overflow, rounding, concurrent mutation, or unknown parameters.
5. A normal view is a live query definition, not a frozen data snapshot.
6. The catalog records technical structure and view SQL, not the analyst's human rationale.
7. Provenance/lineage is the history of sources and transformations, not merely a schema description.
8. For every action, remember **target, action, parameters, when, why, who**.

### Lab traps

1. Embedded versus client-server describes process/library architecture, not simply the number of containers.
2. Inside Compose, use `postgres:5432`; `localhost:54327` is not the server from the client container's perspective.
3. A published port is not needed for container-to-container traffic; it is for host access.
4. `depends_on` does not prove that PostgreSQL is ready to accept SQL connections.
5. For official PostgreSQL 18 images, the persistent mount target is `/var/lib/postgresql`.
6. The sample read-only bars are consistent with the pinned upstream sample's offered rate near 10,000 requests/s, so they do not reveal maximum capacity; check the omitted course XML before claiming its exact cap.
7. One run on one machine does not establish a universal DBMS ranking.
8. Docker image bytes are not throughput, runtime memory, database volume size, or total disk usage.
9. `file_fdw` exposes external data; it does not import and index it as a local table.
10. `ENTRYPOINT ["java", "-jar", "benchbase.jar"]` allows runner-supplied benchmark arguments to append to the executable.

### Four reusable answer templates

#### Diagnose an untidy table

> One row currently represents **[state the present grain]**. This violates the tidy rule **[variable-column / observation-row / unit-type-table / atomic cell]** because **[name the hidden/repeated/mixed structure]**. The tidy grain should be **[one row per key]**, with columns **[list variables]**. Apply **[melt/split/cast/normalize/append]**.

#### Classify a transformation

> It is **[destructive/non-destructive]** because the previous representation **[is overwritten/is preserved]**. The function is **[reversible/non-reversible]** because **[the original can/cannot]** be reconstructed from the transformed result and recorded parameters alone.

Always answer both axes separately.

#### Explain a benchmark comparison

> Under the worksheet's same-host, equivalent-workload conditions, **[system]** achieved **[number/unit]** versus **[number/unit]**. This describes this run only. The result may also reflect offered-rate caps, DB state, resource allocation, warm-up, and current host load; repeated runs and variability are needed for a general claim.

#### Explain deterministic SQL

> SQL does not guarantee row order without `ORDER BY`. Here, **[ordering columns]** **[do/do not]** form a total key. Since **[tie explanation]**, add **[unique tie-breaker]** before applying `LIMIT`.

---

## 12. Practice test

Try these without looking at the answers. If time is very short, do questions 1-5, 9, 12-14, 18-20, 22-26, 29, 31-32, and 35-39.

### Questions

1. State the three primary tidy-data rules.
2. What does one cell contain under the course's extended mapping?
3. Explain the difference between an observation and an observational-unit type.
4. Is every tidy dataset clean? Why?
5. Name all five common messy forms and the primary repair for each.
6. Why can `home_phone` and `work_phone` either be two variables or values of a `phone_type` variable?
7. When may a structural missing value be omitted?
8. In the weather example, why are both melt and cast required?
9. Why is the wide grade table with student-name headers untidy, and what is its tidy schema?
10. Why should `student, stu_number, exam, grade` be split even though each cell is atomic?
11. Give the tidy key and columns for the choices/reaction-time data.
12. Compute the male left-handed fraction from the worksheet.
13. Compute the male left-handed odds.
14. Compute the male-versus-female left-handed odds ratio.
15. Why is `COUNT(*)` wrong for a four-row table whose `n` column stores population counts?
16. Name the three SQL restructuring situations and their usual operations.
17. How many rows result from crossing three earthquake rows with three years?
18. Write the wide-to-long earthquake pattern in words.
19. Write the long-to-wide earthquake pattern in words.
20. Why is `GROUP BY magnitude` necessary in the reverse pivot?
21. What is one-hot encoding, and why can `n-1` indicators represent `n` categories?
22. Classify `ALTER TABLE Customers DROP COLUMN phone` on both workflow axes.
23. Classify a `CREATE TABLE AS SELECT TRIM(name)` transformation on both axes.
24. Give an example that is destructive but reversible.
25. What does a normal SQL view store, and how does it react to source changes?
26. List the six fields of a transformation action log.
27. What metadata does the DBMS catalog know, and what important information does it usually not know?
28. Which PostgreSQL commands list databases, tables, views, privileges, object details, and roles?
29. Why is BenchBase plus SQLite called embedded while BenchBase plus PostgreSQL is client-server?
30. Why is the BenchBase source pinned to a commit?
31. Where does the BenchBase container connect to PostgreSQL from inside Compose?
32. What does `depends_on` guarantee, and what does it not guarantee?
33. Why should the plotting dependencies be kept outside the measured SQLite benchmark image?
34. What exactly does Docker image `.Size` measure for this exercise?
35. What conclusion can be drawn from both read-only plots reaching about 10,000 requests/s?
36. Does creating a `file_fdw` foreign table import or validate the whole file?
37. Which MariaDB placement configuration(s) are conceptually valid?
38. Of the five SQL-order queries in Lab Question 4(c), which two are deterministic?
39. Why is `ORDER BY value LIMIT 1` not enough, and how do you repair it?
40. Which promised lab artifacts are absent locally, and what does that prevent you from claiming?

### Answers

1. Each variable is a column; each observation is a row; each type of observational unit is a table.
2. One value/entry: an atomic datum for that row-column intersection.
3. An observation is one measured unit instance represented by a row; the observational-unit type is the entity/grain shared by observations and assigned to a table.
4. No. Tidy describes structure; values can still be wrong, duplicated, incomplete, or biased.
5. Headers-as-values -> melt; several variables in one column -> split; variables in rows and columns -> melt then cast; multiple unit types in one table -> normalize/split; one unit type across files -> add source variable and append.
6. Variable meaning depends on the analytical question: separate functional attributes may be columns, while comparison across phone types may be easier as repeated observations.
7. When the measurement is logically impossible and the absence can be reconstructed from the design.
8. Days in headers must move to rows; `tmin` and `tmax` stored as row values must then become variable columns.
9. Student names are values encoded as headers. Use `(student, exam, grade)`.
10. It mixes one-row-per-student metadata with one-row-per-student-exam measurements, repeating `stu_number`; split student and exam-result tables.
11. One row per `(subject_id, trial)`, with `choice` and `reaction_time` columns.
12. `9/52 = 0.1731`, about `17.31%`.
13. `9/43 = 0.2093`.
14. `(9/43)/(4/44) = (9*44)/(43*4) = 2.3023`.
15. It returns the number of stored aggregate rows, not the represented individuals; use `SUM(n)`.
16. Related tables -> join; same-schema partitions -> set operation/union; implicit variables in layout -> pivot/restructure.
17. `3 * 3 = 9`.
18. Generate year values, cross join with each wide row, and use `CASE` to select the matching year column; optionally aggregate by the new key.
19. Use conditional aggregation, `SUM(CASE WHEN year=... THEN value ELSE 0 END)`, and group by magnitude.
20. It sets the target grain to one row per magnitude and satisfies SQL's aggregation rule for the nonaggregated selected column.
21. It maps each category to binary indicator columns. One category is inferable when all other `n-1` indicators are zero, though all `n` are commonly emitted.
22. Destructive and non-reversible: values are overwritten/lost and cannot be reconstructed.
23. Non-destructive mode because the source table remains; `TRIM` itself is non-reversible because removed whitespace is absent from the result.
24. `UPDATE Measurements SET x=x+1`, assuming the same known inverse is safe and no information was lost.
25. A query definition, not independent table rows. Its result changes when referenced base data changes.
26. Target, action, parameters, when, why, who.
27. It knows objects, columns/types, keys, privileges, roles, and view definitions; it normally lacks full domain semantics, quality assessment, source history, and human rationale.
28. `\l`, `\dt`, `\dv`, `\dp`, `\d name`, and `\dg`/`\du`, respectively.
29. SQLite is an in-process library accessing its file directly; PostgreSQL is a separate server reached by a JDBC client over a protocol/network.
30. It fixes the exact source state so later default-branch changes cannot silently alter the build.
31. Service hostname `postgres`, container port `5432`—typically `jdbc:postgresql://postgres:5432/benchbase`.
32. Startup order; not application/database readiness.
33. Otherwise Python and Matplotlib inflate the benchmark image whose deployment size is being measured.
34. Docker's reported image byte size; not volumes, results, runtime memory, or necessarily extra physical disk bytes after shared layers.
35. Both bars are consistent with the pinned upstream sample's offered-rate ceiling; no maximum read-throughput ranking follows, but the omitted course XML must be checked before asserting its exact limit.
36. No. It registers metadata; the server reads/parses the external file at query time and can expose errors then.
37. Both configurations; colocating processes does not change the logical client-server architecture.
38. I (`ORDER BY id`) and IV (`ORDER BY id LIMIT 1`).
39. `value` can tie. Use `ORDER BY value, id LIMIT 1` with unique `id` as the tie-breaker.
40. Config XMLs, runners, plot script/image, starter Compose file, and raw result JSONs are absent; exact local throughput and image-byte results cannot be claimed.

---

## 13. A 48-hour exam plan

### First pass: concepts and recognition

1. Read Sections 1, 2, 3, 5, 6, and 10 of this guide.
2. Recite the three tidy rules and five messy forms without looking.
3. Redraw the handedness 2x2 table and calculate fraction, odds, and odds ratio.
4. Explain all three lab MCQs aloud in one sentence each.

### Second pass: production practice

1. Write both earthquake SQL transformations from memory.
2. Rebuild the three corrected schemas: grades, trials, and countries.
3. Fill the destructive/reversible 2x2 matrix with an example in every cell.
4. Write the Compose networking facts and deterministic-query repair from memory.

### Final pass: retrieval, not rereading

1. Do the practice test with closed notes.
2. Mark every answer that was slow or vague.
3. Re-read only those guide subsections.
4. Before the exam, read Section 14 once and stop cramming new details.

If forced to prioritize, the most exam-like material is the complete in-class answer key, the three lab MCQs, the earthquake SQL, contingency calculations, and workflow classifications.

---

## 14. Two-minute final recall sheet

```text
TIDY
  variable -> column
  observation -> row
  observational-unit type -> table
  value -> cell

FIVE MESSES
  headings are values       -> melt
  several vars in one col   -> split
  vars in rows and columns  -> melt, then cast
  several unit types        -> normalize/split tables
  one type across files     -> source column + append

SQL RESHAPE
  wide -> long = VALUES + CROSS JOIN + CASE
  long -> wide = SUM(CASE...) + GROUP BY

HANDEDNESS
  fraction = 9/52 = .1731
  odds     = 9/43 = .2093
  OR       = (9/43)/(4/44) = 2.3023
  count table totals use SUM(n), not COUNT(*)

WORKFLOW
  axis 1: destructive / non-destructive
  axis 2: reversible / non-reversible
  log: TARGET ACTION PARAMETERS WHEN WHY WHO
  view = live query definition, not snapshot

LAB
  SQLite = embedded/in process; PostgreSQL = separate client/server
  Compose client -> postgres:5432
  host -> 127.0.0.1:54327
  PG 18 volume -> /var/lib/postgresql
  depends_on != ready
  read-only ~10k likely reflects upstream rate cap; verify course XML; not max
  FDW reads external file at query time; no import/local index
  MariaDB answer = BOTH
  SQL answer = 2 (I and IV)
  deterministic top-1 -> ORDER BY value, id LIMIT 1
```

Last sanity check before submitting an answer:

```text
Did I state the row grain?
Did I distinguish probability from odds?
Did I answer both workflow axes?
Did I state GROUP BY/output grain?
Did I add a unique tie-breaker?
Did I avoid generalizing one benchmark run?
```

---

## 15. Source key and coverage

### Local Module 7 sources

- **IC** - [In-Class Exercise Sheet 7: Tidy Data](7-Tidy_Data/SoSe_2026_RepEng_IC_7___Tidy_Data.pdf), all 4 pages. References such as `[IC3]` mean PDF page 3.
- **L** - [Lab Sheet 7](Lab_Session_7/Sheet_7.pdf), all 8 pages. References such as `[L6]` mean PDF page 6.
- **TD** - [local assigned-reading shortcut](7-Tidy_Data/Article_on_tidy_data,_read_sections_1-3.url) for Hadley Wickham, *Tidy Data*, assigned Sections 1-3, article pages 1-12. Stable bibliographic source: [Journal of Statistical Software DOI](https://doi.org/10.18637/jss.v059.i10). `[TD8-10]` means article pages 8-10.
- **SQL-R** - [local assigned-reading shortcut](7-Tidy_Data/SQL_for_Data_Science,_chapter_3.4.1_on_restructuring_data.url) for Antonio Badia, *SQL for Data Science*, Section 3.4.1, approximately book pages 159-165. Stable source: [Springer chapter DOI](https://doi.org/10.1007/978-3-030-57592-2_3).
- **SQL-M** - [local assigned-reading shortcut](7-Tidy_Data/SQL_for_Data_Science,_chapter_3.5_on_metadata.url) for the same chapter, assigned Section 3.5 including 3.5.1, approximately book pages 165-169.

The `.url` files point through the course platform; the DOI links are stable bibliographic targets. Modern names such as `pivot_longer`/`pivot_wider` are useful equivalents, but the assigned Wickham paper's primary terms are **melt** and **cast**.

Scope note: the brief definitions of accuracy, completeness, consistency, currency, precision, and certainty in Section 6 are helpful background from Badia Section 1.4, which the assigned Section 3.5 references; Section 1.4 itself was not assigned in the Module 7 link.

### Coverage audit

- [x] All 4 in-class PDF pages visually inspected and solved.
- [x] All 8 lab PDF pages visually inspected and solved.
- [x] Wickham assigned Sections 1-3 covered through all five messy-data forms.
- [x] Badia Section 3.4.1 covered: joins, set operations, pivoting, earthquake SQL, and dummy variables.
- [x] Badia Section 3.5/3.5.1 covered: iterative workflow, both transformation axes, views, catalogs, metadata, provenance, and action logs.
- [x] Every in-class blank, table repair, calculation, and SQL completion answered.
- [x] Dockerfile, image-size commands, Compose solution with explicit assumptions, benchmark interpretation, and all three lab MCQs answered.
- [x] Absent lab assets and limits on reproducible claims documented.

---

**If you remember only twelve things:** three tidy rules; five messy-form repairs; `SUM(n)`; odds are yes/no; wide-to-long uses `VALUES + CROSS JOIN + CASE`; long-to-wide uses `SUM(CASE) + GROUP BY`; workflow has two independent axes; log target/action/parameters/when/why/who; views are live definitions; Compose uses `postgres:5432`; FDW reads at query time; deterministic `LIMIT` requires a unique tie-breaker.
