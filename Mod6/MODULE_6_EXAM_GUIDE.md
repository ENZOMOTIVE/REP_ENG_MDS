# Reproducibility Engineering - Module 6 Exam Guide

> A self-contained, exam-focused guide to every supplied Module 6 item: database architectures, SQLite, Docker Compose with PostgreSQL, deterministic SQL, foreign data wrappers, database replication, reproducible binary builds, ReproTest, out-of-tree builds, and Make.

## How to use this before the exam

If time is short, revise in this order:

1. Memorize the **8 SQLite features** and the **5 cases where SQLite is a poor choice**.
2. Redraw the **client/server versus SQLite** architecture from memory.
3. Fill in the **PostgreSQL Compose file** without looking.
4. Learn the exact answers to the **foreign-table questions**.
5. Memorize the C macro rule: **constant and `__LINE__` can reproduce; `__FILE__` and `__TIME__` can vary**.
6. Understand **ReproTest** and **Make's dependency propagation** rather than memorizing commands blindly.
7. Finish with the solved questions, exam traps, and 2-minute recall sheet.

Priority key used below:

- **P1 - must know:** directly asked in an in-class or lab question.
- **P2 - should know:** explanation needed to justify a P1 answer.
- **P3 - recognize:** supplementary detail that can strengthen a long answer.

---

## 1. P1 core answers at a glance

### Database architectures

```text
Traditional client/server RDBMS

client host(s)                                      server side
+-----------------------------+      network      +----------------------+
| user application            | <---------------> | RDBMS server         |
| + DB client library         |                   | + DB file(s)         |
+-----------------------------+                   +----------------------+

SQLite serverless architecture

+-----------------------------------------------------------------------+
| one local host                                                        |
| user application + SQLite library <-----------> SQLite file(s)         |
| user application + SQLite library <-----------> same SQLite file(s)    |
+-----------------------------------------------------------------------+
```

- A client/server DBMS has a separate server process, network boundary, client library, and server-managed files.
- SQLite embeds the database engine as a library in each application; applications access a local database file directly. There is no database server or database network protocol in between. [IC1; SQ2-5]

### SQLite: 8 features and 5 limits

Initials mnemonic: **SZCS-STFH** - **S**erverless, **Z**ero Configuration, **C**ross-Platform, **S**elf-Contained; **S**mall Runtime Footprint, **T**ransactional, **F**ull-Featured, **H**ighly Reliable.

```text
8 FEATURES
Serverless | Zero Configuration | Cross-Platform | Self-Contained
Small Runtime Footprint | Transactional | Full-Featured | Highly Reliable

5 POOR-FIT CASES
High Transaction Rates | Extremely Large Datasets | Access Control
Client/Server | Replication
```

Public-domain exam line: SQLite's legal status makes the exact engine easy to inspect, archive, modify, bundle, and redistribute, but you must still preserve the exact version/build/modifications and the rest of the experiment.

### The completed Compose values

```text
image             postgres:16        (both services)
database          benchdb
user              lab
password          labpw
host:container    5433:5432
volume            pgdata:/var/lib/postgresql/data
dependency/host   db
```

Inside the Compose network, the benchmark client connects to **`db:5432`**. From the host, PostgreSQL is exposed at **`localhost:5433`**. A named volume survives ordinary `docker compose down`. [IC3-5]

### Foreign-table rule

```text
CREATE FOREIGN TABLE = register metadata, not prove that the source works
SELECT from it        = open/read/parse the external source
file_fdw CSV          = no index on the raw file -> predicates may still scan all rows
```

For the sheet: successful creation proves **none** of existence, readability, or parseability. All three queries in Question 7 can require a complete CSV scan. [IC6]

Deterministic-SQL rule: no `ORDER BY` means no promised order; a non-unique `ORDER BY` leaves ties unspecified; `LIMIT`/`OFFSET` need a stable total order and a frozen input state.

### Reproducible binary-build rule

```text
same source + same visible behavior  DOES NOT imply  same binary bytes

compiler + version + flags + dependencies + path + time + environment
                    can all affect the artifact
```

For the four C programs on Lab page 8, **2** permit bitwise-identical builds under the question's assumptions: the constant program and the `__LINE__` program. `__FILE__` can encode a changing path; `__TIME__` encodes the build time. [L8]

ReproTest rule: build twice under deliberately varied environments and compare declared artifacts. To force the lab's non-debug build to fail, replace the stable `__LINE__` with `__TIME__`.

### Make rule

```make
target: prerequisites
	command that creates target
```

If a prerequisite is newer than its target, Make rebuilds the target. The new target then makes its dependants out of date, so rebuilding propagates down the dependency graph. Changing `generate_chart.py` therefore recreates **`results/chart.pdf` and `experiment.pdf`**, not the raw results. [L9-10]

---

## 2. Client/server RDBMS versus SQLite - P1

### Exact labels for In-Class Question 1

#### Figure (a): traditional client/server RDBMS

- Caption: **Traditional RDBMS client/server architecture**.
- Each left dotted box: **client host**.
- Large blue rectangle: **user application**.
- Small white rectangle attached to it: **DB client library**.
- Red arrows between clients and server: **network**.
- Server-machine icon: **RDBMS server**.
- Cylinder with document icons: **DB file(s)**.

The client library exposes an API, sends commands across the network, and receives results. The server owns connection handling, query processing, caching, concurrency control, and access to the database files. [IC1; SQ3-4]

#### Figure (b): SQLite

- Caption: **SQLite serverless architecture**.
- Large blue rectangle: **user application**.
- Small white rectangle attached to it: **SQLite library**.
- Cylinder with a document: **SQLite file(s)**.
- The enclosing dotted region represents the local **client host**.
- There is **no DB client library, network link, or separate RDBMS server**.

Several applications can be called "SQLite clients," but that wording does not imply a server. Each application contains or links the SQLite engine and accesses the shared file directly. [SQ4-5]

### Comparison table

| Question | Client/server RDBMS | SQLite |
|---|---|---|
| Where is the engine? | Separate server process/system | Library embedded in the application |
| How does the application reach data? | Client library over a network/protocol | Library reads/writes the local file directly |
| Storage | Usually multiple server-managed files | Entire database packaged as one cross-platform file in the course model |
| Setup | Server installation, accounts, configuration, startup, network | Open or create a file; no server setup |
| Concurrency | Designed for many clients; may use row/table-level locking and parallelism | Multiple readers, but writes to one database are serialized by file locking |
| Security | DB authentication, roles, grants, and network controls | Mainly filesystem permissions; no native per-user DB authentication |
| Scaling/remote access | Appropriate for centralized access by many machines | Best for local storage, not a shared network filesystem |
| Replication | Commonly supported | No built-in real-time replication in the assigned excerpt |
| Reproducibility strength | Topology can be described with Compose; central state can be administered | Very easy to package, copy, archive, hash, and distribute |
| Reproducibility risk | More versions, configuration, services, network, credentials, timing, and state | Engine version/build flags, file state, pragmas, extensions, and host filesystem can still matter |

### Model answer: which is easier to reproduce?

SQLite often reduces the **setup effort** because the engine and data can be distributed with the application, with no independent server or network configuration. Its single cross-platform file is easy to version, checksum, archive, and transfer. That does not make every SQLite experiment automatically reproducible: the exact SQLite version, compile options, schema, data state, queries, parameters, pragmas, extensions, and application code still need to be preserved.

A client/server DBMS introduces more components, but it may be the correct experimental platform when the claim concerns concurrency, transactions under load, access control, replication, or server behavior. Docker Compose can record the topology, images, environment, network names, ports, and volumes, but the database's initial state and readiness must also be controlled.

Exam technique: do not say "SQLite is always more reproducible." Say **why its simpler architecture reduces certain dependencies**, then state the workload limitations.

---

## 3. The eight SQLite features - P1

| Feature | Course definition | Reproducibility relevance | Remaining caveat |
|---|---|---|---|
| **Serverless** | No separate server process; the library accesses storage directly. | Removes server installation, startup, network, and server/client compatibility steps. | The library version, compile options, filesystem, and DB state still matter. |
| **Zero Configuration** | Creating an instance is as easy as opening a file. | Fewer undocumented setup steps and lower barrier for an independent rerun. | Application pragmas, extensions, paths, and schema initialization must still be recorded. |
| **Cross-Platform** | The whole DB resides in a portable file format. | The same artifact can be transferred, archived, hashed, and opened on different platforms. | Cross-platform file format does not guarantee identical query timing or floating-point behavior. |
| **Self-Contained** | One library contains the complete DB system and integrates with the host application. | Bundling it with the application can freeze the engine version and remove an external runtime dependency. | A dynamically linked or silently upgraded library can reintroduce version drift. |
| **Small Runtime Footprint** | Small code and memory requirements. | Easier to package and run on constrained or clean systems; lowers reproduction cost. | Small is not the same as fully specified. |
| **Transactional** | Transactions are ACID-compliant and safe across processes/threads. | Atomic state changes reduce partially written or corrupted experimental state. | ACID safety does not imply high write concurrency or deterministic query order. |
| **Full-Featured** | Supports most SQL92/SQL2 query features. | Familiar declarative SQL makes workflows easier to inspect and transfer. | "Most" is not "all"; dialect, typing, functions, and query plans can differ across DBMSs. |
| **Highly Reliable** | SQLite is tested and verified aggressively. | Fewer defects and strong compatibility reduce tool-induced reproduction failures. | Reliability does not compensate for missing data, code, or provenance. |

Mnemonic expansion:

```text
S Z C S S T F H
Serverless, Zero configuration, Cross-platform, Self-contained,
Small footprint, Transactional, Full-featured, Highly reliable
```

### ACID in one line each - P2

- **Atomicity:** a transaction happens completely or not at all.
- **Consistency:** a transaction takes the database from one valid state to another, respecting declared constraints.
- **Isolation:** concurrent transactions do not observe unsafe intermediate effects, according to the isolation rules.
- **Durability:** committed changes survive failures covered by the system's guarantees.

ACID and concurrency are not synonyms. SQLite can preserve transactional correctness while serializing writes, which limits high write throughput.

### Reliability details from the assigned excerpt - P3

The textbook excerpt reports, for the version discussed there:

- more than 10 million unit and query tests;
- a pre-release soak test of more than 2.5 billion tests;
- 100% statement and branch coverage, including out-of-memory and out-of-storage cases;
- a strong history of backward-compatible file formats, SQL syntax, APIs, and behavior. [SQ7-8]

These numbers are recognition-level details, not a substitute for the eight feature names.

---

## 4. SQLite licensing, use cases, and limits

### Public-domain source code - P1

The in-class sheet asks for consequences of SQLite being in the public domain and free to use for any purpose. [IC2; SQ7]

Positive consequences for reproducibility:

- researchers may inspect and audit the implementation;
- the exact source or compiled library may be redistributed with an artifact package;
- the engine can be embedded without a license-negotiation barrier;
- an old version can be archived, built, modified, and ported for a future rerun;
- independent teams can examine implementation details instead of depending on a closed vendor.

Important limitation:

- legal availability is **not** reproducibility by itself;
- public-domain status does not identify which version, commit, compile flags, patches, or extensions were used;
- there is no obligation to publish private modifications, so a researcher must deliberately release the exact modified source or binary;
- data, queries, schema, configuration, application code, and execution instructions are still required.

Strong exam sentence:

> SQLite's public-domain status removes legal barriers to inspecting, modifying, archiving, and redistributing the exact engine, but reproducibility still requires the experimenter to identify and preserve the exact version and all other artifacts.

### Good use cases - P3

The assigned chapter presents SQLite as a complement to, not a universal replacement for, a server RDBMS:

- **application files:** configuration, state, caches, document containers;
- **application cache:** temporary or in-memory relational processing;
- **archives/data stores:** a portable, read-only or distributable multi-table file;
- **client/server stand-in:** demos, evaluation copies, testing, and bug reports;
- **teaching tool:** almost no setup and easy sharing;
- **generic SQL engine:** virtual tables expose logs or other data to SQL. [SQ10-14]

Other features worth recognizing:

- dynamic typing;
- attaching multiple database files to one connection;
- fully in-memory databases;
- virtual tables backed by code or external data. [SQ6, SQ12, SQ14]

### The five cases where SQLite is not the best choice - P1

#### 1. High transaction rates

SQLite uses file locking. Multiple connections can read, but a write requires exclusive coordination and write transactions are serialized. A client/server DBMS is normally better for many concurrent writers or very high transaction throughput.

#### 2. Extremely large datasets

Everything is in one file and one filesystem. Multi-gigabyte data may stress random access, backup, transfer, and filesystem behavior. The issue is practical performance and management, not that SQLite becomes non-relational.

#### 3. Access Control

SQLite relies mainly on filesystem permissions: read/write, read-only, or no access. Anyone with direct write access to the file can bypass application-level authorization. Use a server DBMS for sensitive multi-user data requiring authentication, roles, and grants.

#### 4. Client/Server

SQLite has no native database network server. Letting several computers modify one SQLite file on a network filesystem is dangerous because network file locking may be unreliable. A web server can still use SQLite safely when its processes are on the same machine and access local storage.

#### 5. Replication

The assigned excerpt says SQLite has no internal transaction-safe replication or redundancy. Copying the file is only a simple snapshot strategy and must not race with modification. Use a more capable RDBMS when real-time replication/failover is required. [IC3; SQ14-16]

Exact-label cue: **HTR - ELD - AC - C/S - R** = High Transaction Rates; Extremely Large Datasets; Access Control; Client/Server; Replication. Do not turn "extremely large" into a fixed size threshold.

### Snapshot caveat - P2

For an exam answer, lead with the course's single-file portability advantage. In an actual artifact package, capture a **consistent, quiescent snapshot** or use the database's backup mechanism rather than blindly copying a live database. Also preserve any relevant journal/WAL state and record the engine version.

---

## 5. Docker Compose with PostgreSQL - P1

### Exact completed answer to In-Class Question 5

```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: benchdb
      POSTGRES_USER: lab
      POSTGRES_PASSWORD: labpw
    ports:
      - "5433:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  bench:
    image: postgres:16
    depends_on:
      db:
    environment:
      PGPASSWORD: labpw
    command: >
      bash -c "
        pgbench -i -h db -U lab benchdb &&
        pgbench -h db -U lab -T 30 benchdb
      "

volumes:
  pgdata:
```

This is the worksheet's literal fill-in: its blank is followed by a preprinted colon, producing `db:`. YAML parses that as a null value, and modern Compose rejects it because a long-form dependency value must be a mapping. For a directly runnable file, write the equivalent short form:

```yaml
depends_on:
  - db
```

Or use the long form with a real readiness condition and a matching health check. In the exam, follow the syntax printed in the question; in a real artifact, validate the Compose file with the installed Compose version.

Literal word-bank usage (enter only the token; punctuation shown on the sheet is already present):

| Blank | Value |
|---|---|
| both `image` blanks | `postgres:16` |
| `POSTGRES_DB` | `benchdb` |
| `POSTGRES_USER` | `lab` |
| `POSTGRES_PASSWORD` | `labpw` |
| host-port blank | `5433` |
| container-port blank | `5432` |
| DB-volume source blank | `pgdata` |
| `depends_on` key blank | `db` |
| `PGPASSWORD` | `labpw` |
| both `pgbench -h` values | `db` |
| top-level volume-name blank | `pgdata` |

### What each piece means

- **`services`** defines the containers that form the application.
- **`db`** is both the service name and the stable DNS hostname used inside the default Compose network.
- **`postgres:16`** selects the PostgreSQL major-version image; its default command starts a server.
- **`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`** initialize the database and account when the data directory is first created.
- **`"5433:5432"`** means `HOST_PORT:CONTAINER_PORT`.
- **`pgdata:/var/lib/postgresql/data`** mounts the named volume where PostgreSQL stores persistent state.
- **`bench`** reuses the image for its client programs but overrides the default server command.
- **`PGPASSWORD`** is read by PostgreSQL client tools; it is separate from the server image's initialization variable.
- **`pgbench -i`** initializes by dropping and recreating the four standard pgbench tables (`pgbench_accounts`, `pgbench_branches`, `pgbench_history`, and `pgbench_tellers`) by default. It is destructive to existing tables with those names, so never point it at valuable data carelessly.
- **`&&`** starts the timed benchmark only if initialization succeeds.
- **`-h db`** selects the server host, **`-U lab`** the DB user, and **`benchdb`** the database.
- **`-T 30`** runs the benchmark for 30 seconds.

### Network and port trap

```text
bench container -> db:5432
host machine    -> localhost:5433
```

Containers on the same Compose network use the **service name and container port**, not the published host port. The host-port mapping is needed only for access from outside that network.

### Volume and state trap

An ordinary:

```bash
docker compose down
```

removes service containers and the Compose network but preserves the named volume by default. This helps durability, but it can hurt experimental repeatability: the next run reuses the PostgreSQL cluster, catalogs, persistent configuration, and non-pgbench objects. In this exact setup, `pgbench -i` recreates the standard benchmark tables, so it does not retain accumulated rows in those four tables. PostgreSQL shared buffers die with the container; a separately surviving host OS page cache is not stored in the named volume.

Therefore a reproducible database experiment must state whether it starts from:

- a fresh empty volume;
- a versioned database dump;
- a filesystem snapshot;
- a named checkpoint/state;
- or the previous run's persistent state.

Do not casually use `docker compose down -v`: it removes the declared named volume and its data.

### `depends_on` is not readiness - P2

The intended dependency, when expressed with valid short syntax, records startup order. It does **not** prove that PostgreSQL has completed initialization and is accepting connections. The benchmark may race with server startup.

A stronger real experiment would use a PostgreSQL health check such as `pg_isready`, a `service_healthy` dependency, or explicit retry logic. Keep the exercise answer exactly as given, then mention readiness as the engineering improvement.

### Compose helps, but does not finish reproducibility

Also preserve or control:

- the exact image digest, not only a mutable tag;
- schema and initial data;
- PostgreSQL configuration and extensions;
- benchmark scale, clients, threads, duration, and random behavior;
- CPU, memory, storage, operating system/kernel, and competing load;
- clean versus warm caches;
- logs and exact output-processing scripts;
- secrets securely, without publishing real credentials.

---

## 6. Deterministic database experiments and SQL - P1/P2

The database is **stateful**. Reproducing the container image alone does not reproduce the database contents. Record the schema, exact data/snapshot, transaction state, initialization procedure, engine/configuration, query, parameters, and relevant external sources.

### SQL row order is not implicit

Without an `ORDER BY`, SQL does not promise a row order. A sequential scan, index scan, different query plan, parallel execution, changed statistics, or engine version may return the same set of rows in a different sequence.

```sql
-- Nondeterministic order
SELECT run_id, score
FROM measurements;

-- Still not a total order if scores tie
SELECT run_id, score
FROM measurements
ORDER BY score DESC;

-- Deterministic total order if run_id is a non-null unique key,
-- for example a PRIMARY KEY
SELECT run_id, score
FROM measurements
ORDER BY score DESC, run_id ASC;
```

Core rule: **order by enough columns to break every tie**.

### `LIMIT` and `OFFSET`

```sql
-- Unpredictable subset
SELECT * FROM measurements LIMIT 10;

-- Predictable only if the order is unique/total
SELECT *
FROM measurements
ORDER BY recorded_at, run_id
LIMIT 10;
```

`LIMIT 10` without a total order means "some ten rows," not a reproducible first ten. Different limits can even induce different query plans.

`OFFSET n` has the same ordering requirement: without a total order, which `n` rows are skipped is unspecified. Even with a total order, inserts/deletes between separate page requests can shift rows unless both requests use the same frozen snapshot; keyset/cursor pagination can avoid that drift. A large offset can also be inefficient because the server still computes the skipped rows.

### Other common nondeterminism

- `random()` or sampling without a recorded seed;
- current date/time, sequence values, generated IDs, or volatile functions;
- a live table changing during the experiment;
- order-sensitive aggregates such as concatenation without an internal order;
- floating-point aggregation in varying parallel orders;
- locale, collation, time zone, encoding, and null-order differences;
- `SELECT *` when the schema later changes;
- reading a mutable external file, service, or foreign server.

### Reproducible SQL checklist

1. Freeze or identify a database snapshot and schema version.
2. Preserve the query text, parameters, transaction/isolation context, and DBMS version.
3. Use a unique total `ORDER BY` when output sequence or `LIMIT` matters.
4. Seed controllable randomness and avoid or record volatile inputs.
5. Fix time zone, locale/collation, and encoding when they affect semantics.
6. Hash/archive external files and identify remote data versions.
7. Compare results as sets/multisets when order is irrelevant; use tolerances for justified floating-point differences.

Exam trap: deterministic **row order** and deterministic **row membership/value** are different requirements.

---

## 7. PostgreSQL foreign data wrappers - P1

### Mental model

A foreign data wrapper (FDW) lets PostgreSQL present an external source as a relational **foreign table**. The table definition is local metadata; the underlying data can remain in a file, another DBMS, or a service.

```text
SQL query -> PostgreSQL planner/executor -> FDW -> external source
                       |
                       +-> join with local PostgreSQL tables
```

The assigned PostgreSQL excerpt describes FDWs as a SQL/MED-style mechanism for querying external sources. [PG3-5]

### `file_fdw` setup sequence - P2

```sql
CREATE EXTENSION file_fdw;

CREATE SERVER local_files
FOREIGN DATA WRAPPER file_fdw;

CREATE FOREIGN TABLE experiment_meminfo (
    key   text,
    value text
)
SERVER local_files
OPTIONS (
    filename '/proc/meminfo',
    format 'csv',
    delimiter ':'
);

SELECT * FROM experiment_meminfo;
```

General sequence:

1. install/register the wrapper;
2. define a foreign server;
3. define a foreign table and its source/options;
4. create a user mapping where the wrapper/source requires one;
5. grant privileges;
6. query the foreign table;
7. drop it when no longer needed.

`file_fdw` reads files visible to the **PostgreSQL server process**, not files on the SQL client's laptop. In a containerized setup, path and permission interpretation occurs in the server container's filesystem/namespace. File access through `file_fdw` is read-only; other wrappers can have different capabilities.

### Historical web-service example - P3

The scanned book then uses the historical `www_fdw` wrapper and a Twitter JSON endpoint to illustrate a non-file source. The details are obsolete, but the architecture lesson remains:

```text
CREATE EXTENSION wrapper
  -> CREATE SERVER with source-specific options/URI
  -> CREATE USER MAPPING for external identity/context
  -> CREATE FOREIGN TABLE with request and response fields
  -> GRANT SELECT
  -> query through ordinary SQL
```

Each wrapper defines its own options, formats, pushdown behavior, and read/write capabilities. A **user mapping does not itself grant SQL privileges**; the excerpt separately issues `GRANT SELECT`. Do not memorize the defunct Twitter endpoint or assume the old wrapper's limitations describe every current FDW. [PG4-5]

### Exact answer: successful `CREATE FOREIGN TABLE`

**Correct: None of these options.** [IC6]

The successful statement does not prove that:

- `/proc/meminfo` exists when accessed;
- the PostgreSQL server process can read it;
- every line matches the declared two-column CSV format.

The definition can be accepted before the source is opened and parsed. Those failures may appear only when a query executes.

### Exact true/false answers

| Statement | Answer | Reason |
|---|:---:|---|
| Unreadable file or bad format may become visible only when queried. | **True** | Source access/parsing is deferred. |
| `SELECT * FROM experiment_meminfo` reads and parses the external file. | **True** | A scan invokes `file_fdw` against the source. |
| `WHERE key = 'MemTotal'` can use an index on `/proc/meminfo`. | **False** | The raw proc file has no PostgreSQL index. |
| Scanning `/proc/meminfo` is usually cheap because it is small. | **True** | A full scan is tiny in this example. |
| A selective predicate on a very large CSV is guaranteed efficient. | **False** | Selectivity does not create random access or an index; the file may still be fully scanned and parsed. |
| Joining the foreign table with local base tables is possible and also very efficient. | **False as written** | The join is possible, but efficiency is not guaranteed; external scans, weak statistics, and limited pushdown can make it expensive. |

### Exact answer to Question 7

For a large CSV foreign table, check **all three queries**:

```sql
SELECT * FROM measurements;
SELECT * FROM measurements WHERE run_id = 42;
SELECT COUNT(*) FROM measurements;
```

- `SELECT *` needs every row.
- `COUNT(*)` must determine the number of rows.
- `WHERE run_id = 42` still normally scans/parses the raw flat file because there is no index to jump to matching records.

### Reproducibility implications

FDWs improve integration and make external data queryable with SQL, but they add dependencies:

- source path/URL and availability;
- source contents and version at query time;
- wrapper and PostgreSQL versions;
- schema/type mapping and parsing options;
- permissions, credentials, network, and remote service behavior;
- which predicates/aggregations are pushed to the remote source;
- query plan, statistics, and performance.

A foreign-table definition is **not a snapshot**. Archive/hash the external input or record an immutable source version if a later rerun must see the same rows.

---

## 8. PostgreSQL replication excerpt - P3

The supplied PostgreSQL book pages include the end of an older replication walkthrough before the FDW section. The transferable concepts are:

- a primary (called **master** in the older text) produces write-ahead log (WAL);
- a standby (called **slave** there) replays WAL from the primary/archive;
- the standby can normally be queried but is not independently writable;
- a trigger/failover action promotes the standby after it replays the WAL available to it;
- the excerpt warns that **unlogged tables do not participate in replication**. [PG2]

Reproducibility lesson:

- replication improves availability and preserves a changing copy, but a live replica is not an immutable experimental snapshot;
- identify a consistent point in the WAL/history, plus schema, configuration, and external dependencies;
- lag or promotion timing can otherwise expose a different state; with asynchronous replication, the newest primary commits can be absent when promotion occurs;
- data omitted from replication must be captured separately.

The exact `recovery.conf` commands in this older excerpt are version-specific and obsolete in modern PostgreSQL. Learn the WAL/standby/failover concept unless the examiner explicitly asks for the assigned historical syntax.

---

## 9. Functional equivalence versus bitwise identity - P1

### Definitions

- **Functionally equivalent:** programs satisfy the same relevant behavioral specification for the tested inputs/environment.
- **Bitwise identical:** the complete output files contain exactly the same bytes.

Bitwise identity is stronger. Two binaries may print the same output while differing in machine instructions, layout, build IDs, debug metadata, paths, timestamps, padding, or symbol tables.

Useful checks:

```bash
./hello-gcc
./hello-clang

cmp -s hello-gcc hello-clang
sha256sum hello-gcc hello-clang
```

- Equal normal SHA-256 checksums are practical evidence of byte identity.
- Different checksums prove the binaries differ, but do not explain where; use a structural comparison tool such as `diffoscope` for diagnosis.

### Different compilers

```bash
gcc hello.c -o hello-gcc
clang hello.c -o hello-clang
```

Expected result for the simple greeting program:

- same visible function/output;
- not normally bitwise identical.

Reason: GCC and Clang can use different code generation, link behavior, runtime metadata, section ordering, and build identifiers even from the same source. [L1-2]

### Different optimization flags

```bash
gcc -O0 hello.c -o hello-O0
gcc -O2 hello.c -o hello-O2
```

Expected result:

- intended visible behavior remains the same for well-defined code;
- binary bytes normally differ because instructions, layout, inlining, and metadata differ.

Optimization can expose undefined behavior in faulty C code, so functional equivalence is not universally guaranteed.

### Debug information

```bash
gcc hello.c -o hello-gcc
gcc -g hello.c -o hello-debug
```

`-g` adds debugging information such as source filenames, line mappings, symbols, and compilation-directory metadata. The executables may behave the same but will not normally be byte-identical. Debug paths are a common reproducible-build failure. [L2, L5]

### Output filename nuance

Changing only `-o hello-a` to `-o hello-b` does not normally have to alter a simple ELF binary. In the lab's time-macro experiment, different builds can differ because `__TIME__` changed; the second output path mainly allows both artifacts to be kept for comparison. Attribute the difference to the input that actually changed.

### Course-experiment answer matrix

Assume the simple, well-defined greeting program and treat its exact observable output as part of the functional specification:

| Comparison | Functionally equivalent? | Bitwise identical? | Exam reason |
|---|:---:|:---:|---|
| GCC build versus Clang build | **Yes** | Normally **No** | Same greeting; compiler/code-generation metadata can differ. |
| `-O0` versus `-O2` | **Yes** | Normally **No** | Defined behavior is preserved; instructions/layout can differ. |
| no `-g` versus `-g` | **Yes** | Normally **No** | Debug metadata changes bytes, not the normal greeting. |
| `__TIME__` differs between builds | **No** | **No** | The printed timestamp and embedded string differ. |
| `__FILE__` sees different path spellings | **No** | **No** | The printed path and embedded string differ. |

The first two functional answers rely on a well-defined program. If an examiner instead defines the function loosely as "print some build time/path," state that alternative specification before judging equivalence.

---

## 10. Preprocessor macros and reproducible builds - P1

| Macro | Expansion | Reproducibility risk |
|---|---|---|
| `__FILE__` | Source-file path/name as seen by the preprocessor | Different invocation/build paths can embed different strings. |
| `__LINE__` | Current source line number | Stable if the source layout is unchanged; not dependent on day or build directory. |
| `__TIME__` | Compilation time as a string | Different build times can change output and binary bytes. |
| `__DATE__` | Compilation date as a string | Different build dates can change bytes. |

### Time experiment

```c
printf("%s: Hello World\n", __TIME__);
```

The preprocessor replaces `__TIME__` during compilation. The executable contains that string; sleeping after compilation does not change it.

Two builds in different seconds can therefore:

- print different timestamps;
- contain different constant bytes;
- fail bitwise comparison.

If "functionally equivalent" means exact observable output, they are not equivalent. If the specification merely says "print the build time and greeting," both implement the same general function; state which criterion you are applying.

### File-path experiment

```bash
cd /home/repro/task2
gcc hello.c -o hello-file

cd /home/repro
gcc task2/hello.c -o hello-file2
```

With `__FILE__`, one build can embed `hello.c` and the other `task2/hello.c`. The programs then have different output and different bytes even though the underlying source file is the same. [L3]

### Exact multiple-choice answer from Lab Question 6(a)

| Program | Variable input? | Allows a bitwise-identical build under the question's assumptions? |
|---|---|:---:|
| constant `"Hello World"` | none in the snippet | **Yes** |
| `__FILE__` | build/source path | **No in the intended path-varying scenario**; it can reproduce if both builds expose the same filename or normalize paths. |
| `__TIME__` | build time | **No under ordinary separate builds**; a fixed build epoch can normalize it. |
| `__LINE__` | fixed source line | **Yes** |

**Expected sheet answer: 2 programs - Programs 1 and 4**, assuming the path spelling varies and no fixed build epoch is used. [L8]

This answer isolates the shown source-level factors. Real bitwise identity also requires a controlled compiler, linker, libraries, options, and environment.

### Common causes and mitigations

| Cause | Typical mitigation |
|---|---|
| Embedded time/date | Use a documented fixed build epoch such as `SOURCE_DATE_EPOCH`; avoid volatile macros. |
| Absolute build/source path | Use stable paths or compiler prefix-map options such as `-ffile-prefix-map` / `-fdebug-prefix-map`. |
| Compiler/linker drift | Pin and archive toolchain versions and flags. |
| Dependency drift | Lock/archive dependencies and base images. |
| Locale/time zone/hostname/user | Normalize or explicitly set them. |
| Unstable file ordering | Sort inputs and archive members deterministically. |
| Randomness | Set and record seeds; make generation order stable. |
| Parallel race/order | Fix the build rule or ordering; do not merely hope a single-threaded build hides it. |
| Build IDs/metadata/permissions | Configure deterministic values and normalize metadata/umask. |

---

## 11. ReproTest - P1

### What it does

ReproTest builds an artifact twice under deliberately different simulated environments and compares the outputs. It tests whether the build is robust to irrelevant environmental variation. [L4-5]

Default variations can include:

- environment variables and executable path;
- build path and home directory;
- time and time zone;
- locale;
- user/group and umask;
- hostname/domain;
- file ordering;
- kernel, CPU count, and address-space behavior.

Core lab commands:

```bash
reprotest 'gcc hello-line.c -o hello-line' hello-line

reprotest 'gcc -g hello-line.c -o hello-line' hello-line
```

Interpretation:

- first command succeeds -> the tested non-debug build produced identical `hello-line` artifacts across ReproTest's variations;
- debug command fails -> the binaries differ, commonly because debugging metadata embeds the changed build directory/source path.

### Where is the difference?

Debug-path information lives in dedicated binary debug metadata/sections (for example DWARF information). It is not an ordinary runtime stack or heap value. If the question forces the simplified C-memory vocabulary, an embedded path string is closest to **read-only constant data**, not a local stack variable, heap allocation, or mutable global. The actual machine instructions can still be functionally identical.

### How to make the non-debug test fail

Change the stable `__LINE__` macro to **`__TIME__`**. ReproTest varies time, so the changed compilation-time string becomes part of the normal artifact and comparison fails even without debug information.

`__FILE__` is path-sensitive in the earlier lab experiment, but it is not the safest answer here: if both ReproTest builds invoke the compiler with the same relative spelling `hello-line.c`, the macro can remain identical even though the absolute build directories differ. It fails only when the expanded path itself changes. For the stated ReproTest task, answer **`__TIME__`**.

### Docker requirements and warning

The lab installs `reprotest`, `disorderfs`, and `faketime`, then runs:

```bash
docker build -t lab6-4 .
docker run -it --privileged lab6-4
```

`--privileged` is required by this lab setup but grants broad host-facing capabilities. Do not treat privileged containers as a normal reproducibility best practice; use them only in a controlled environment for a justified test.

### ReproTest result is scoped

Passing means "reproducible under the variations and artifacts tested." It does not prove source correctness, security, semantic correctness on every platform, or reproducibility under an untested compiler/hardware change.

---

## 12. C memory vocabulary - P2

The lab supplies this simplified process-memory model for discussing where build differences appear. [L6]

```text
Highest addresses
+------------------+
| Stack            | local variables; calls add frames; usually grows downward
+------------------+
| Heap             | dynamically allocated runtime data
+------------------+
| Globals          | long-lived mutable global/static variables
+------------------+
| Constants        | read-only literals/data
+------------------+
| Code             | read-only machine instructions
+------------------+
Lowest addresses
```

Do not say that all bytes in an executable map neatly to one of these runtime regions. Object/executable files also contain symbol tables, relocation data, debug sections, headers, and other metadata that may not be loaded as ordinary program memory.

---

## 13. Building Python from source and out-of-tree builds - P2

Lab sequence:

```bash
mkdir task3
cd task3

curl -O "https://www.python.org/ftp/python/3.12.3/Python-3.12.3.tgz"
tar -xvf Python-3.12.3.tgz

mkdir build
cd build
../Python-3.12.3/configure \
  --prefix=$HOME/Python-3.12.3-custom

make -j $(nproc)
```

- `curl -O` downloads using the remote filename.
- `tar -xvf` extracts the archive verbosely.
- running `configure` from `build/` creates an **out-of-source/out-of-tree** build.
- `--prefix` chooses the eventual installation prefix.
- `make -j $(nproc)` permits roughly one job per available logical CPU; it is faster but increases load and can expose missing dependency/order rules.

### Why out-of-tree is good practice

- generated files do not pollute or overwrite the source tree;
- cleaning is easy: remove one build directory while preserving source;
- multiple configurations/toolchains can be built side by side from one source tree;
- it is easier to see which files are original inputs and which are derived outputs;
- stale outputs are less likely to be accidentally committed or packaged;
- clean rebuilds and comparisons become easier to automate.

Out-of-tree layout improves hygiene, but exact source, archive checksum, configure options, compiler/toolchain, dependencies, environment, and install steps must still be preserved.

### Other lab operational commands - P3

```bash
# Update the external course repository before starting.
git pull

# Generic Task 2 pattern; the sheet does not prescribe this image tag.
cd LabSession6/task2
docker build -t lab6-task2 .
docker run -it lab6-task2

# Copy the generated sine PDF from a container to the host's current directory.
docker cp <container_ID>:/home/repro/sin.pdf .
```

The actual Task 2/Task 5 Dockerfiles and scripts live in the external lab repository and are not included under `Mod6`, so exact unseen file listings, tags, and generated CSV names should not be fabricated. The commands above are the examinable host/container pattern from the sheet.

---

## 14. Make and dependency graphs - P1

### Core vocabulary

```make
target: prerequisite1 prerequisite2
	recipe command
```

- **target:** file/action to produce.
- **prerequisites:** files/targets used to produce it.
- **recipe:** shell command that updates it; traditional Make requires a tab at the start.
- A target is out of date when it is missing or older than a normal prerequisite.
- Make walks dependencies from the requested goal and runs only necessary recipes.

### Why Make matters for reproducibility

A Makefile records **prospective provenance** as an executable dependency graph. It reduces forgotten manual steps and recomputes derived artifacts after relevant input changes. It does not automatically pin software, capture data, remove nondeterminism, or prove that the declared graph is complete.

### Lab pipeline from Question 6(b)

```text
recipe.txt + pplease*.py + run_experiment.sh
                    └──> results/results.csv

generate_chart.py + results/results.csv
                    └──> results/chart.pdf

experiment.tex + results/chart.pdf
                    └──> experiment.pdf ──> all
```

Relevant Makefile:

```make
.PHONY: all clean

all: experiment.pdf

experiment.pdf: experiment.tex results/chart.pdf
	latexmk -pdf -interaction=nonstopmode -halt-on-error experiment.tex

results/chart.pdf: generate_chart.py results/results.csv
	python3 generate_chart.py results/results.csv 10 results/chart.pdf

results/results.csv: run_experiment.sh pplease.py pplease_split.py \
                     pplease_stats.py recipe.txt
	bash run_experiment.sh recipe.txt 10 42 make_run

clean:
	rm -f experiment.pdf results/chart.pdf
	rm -f results/results.csv results/polite_*.txt results/stats_*.txt
	latexmk -c
```

### Exact multiple-choice answer

After a successful `make all`, modifying `generate_chart.py` makes it newer than `results/chart.pdf`:

1. rebuild `results/chart.pdf`;
2. the new chart is now newer than `experiment.pdf`;
3. rebuild `experiment.pdf`.

**Correct: `results/chart.pdf` and `experiment.pdf`.** The raw results do not depend on the chart script, so they are not recreated. [L9-10]

### Practice propagation table

| Change | Rebuilt targets |
|---|---|
| `generate_chart.py` | `results/chart.pdf`, then `experiment.pdf` |
| `results/results.csv` | chart, then final PDF |
| `recipe.txt` or a `pplease`/runner script | results CSV, chart, final PDF |
| `experiment.tex` | final PDF only |
| unrelated `doAll.sh` not named in the graph | none |
| delete `results/chart.pdf` | chart, then final PDF |
| `make clean` | always runs because it is phony; removes generated files |

### `.PHONY`

```make
.PHONY: all clean
```

`all` and `clean` are actions, not meaningful files. Marking them phony ensures the recipes/dependencies are considered even if files named `all` or `clean` exist.

### Lab Task 5 reasoning

The separate sine-wave task's scripts and Makefile live in the external lab repository, not in the supplied Module 6 folder. Therefore the exact commands for 5(f-h) cannot be verified from the local materials. Do not present guessed filenames as supplied facts.

The natural graph implied by the sheet is:

```text
gen_df_sin.py ──> base CSV
base CSV + csv_noisy_sin.py ──> noisy/processed output
noisy/processed output + sin.tex ──> sin.pdf
```

Under that assumed graph, the intended propagation answers are:

- manually rerunning `csv_noisy_sin.py` updates its output, so only downstream `latexmk`/`sin.pdf` work reruns;
- changing sample size in `gen_df_sin.py` reruns the base-data generator, `csv_noisy_sin.py`, and `latexmk`;
- changing noise strength in `csv_noisy_sin.py` reruns that script and `latexmk`, but not the upstream base-data generator.

The exact LaTeX command printed on Lab page 7 is:

```bash
latexmk -pdf -interaction=batchmode -halt-on-error <tex-file>
```

This is separate from Question 6(b)'s supplied Makefile, which uses `-interaction=nonstopmode`. `latexmk` is useful because it reruns LaTeX as often as needed to resolve references.

Exam technique: draw arrows from each changed file to every target that transitively depends on it. Never rebuild an upstream prerequisite merely because a downstream file changed.

### Make limitations/traps

- Make normally uses modification times, not content hashes.
- Clock skew or preserved timestamps can confuse decisions.
- An omitted prerequisite makes the graph wrong and may leave stale output.
- A phony prerequisite forces rebuild behavior; use it deliberately.
- Successful automation can still produce a nondeterministic artifact.
- `make -n` previews recipes and is useful for checking your reasoning.

---

## 15. Solved question key

### In-Class Exercise Sheet 6

1. **Architectures:** (a) traditional client/server RDBMS; (b) SQLite serverless. Use the labels in Section 2.
2. **Eight SQLite features:** Serverless; Zero Configuration; Cross-Platform; Self-Contained; Small Runtime Footprint; Transactional; Full-Featured; Highly Reliable.
3. **Public domain:** exact code can legally be inspected, modified, archived, bundled, and redistributed; still record/release the exact version, patches, and other artifacts.
4. **Poor SQLite fits:** High Transaction Rates; Extremely Large Datasets; Access Control; Client/Server; Replication.
5. **Compose blanks:** use the completed YAML in Section 5.
6. **Creation conclusion:** none. True statements are delayed errors, `SELECT *` reads/parses, and the small-file scan is cheap. Index/guaranteed-selectivity/guaranteed-efficient-join claims are false.
7. **Large CSV scans:** all three listed queries can scan the entire file.

### Lab Exercise Sheet 6

#### Compiler comparison

- GCC versus Clang: normally same simple behavior, different binary bytes.
- Different optimization levels: normally same defined behavior, different bytes.
- `-g`: same normal behavior, different bytes/debug metadata.

#### Preprocessor/path comparison

- `__TIME__`: different compile times can change output and bytes.
- `__FILE__`: different path spelling can change output and bytes.
- `__LINE__`: stable when source layout is unchanged.

#### ReproTest

- normal stable-macro build: expected reproducible in the test;
- debug build: expected difference because changed build paths enter debug metadata;
- use `__TIME__` to force a non-debug failure under ReproTest's time variation.

#### Multiple choice

- Lab 6(a): **2** programs, Programs 1 and 4.
- Lab 6(b): **`results/chart.pdf` and `experiment.pdf`**.

---

## 16. Common exam traps

1. **Serverless does not mean database-less.** The SQLite engine is embedded as a library and still manages a relational database file.
2. **"SQLite client" does not imply a client/server architecture.** It can mean an application directly using the SQLite library.
3. **ACID does not mean unlimited concurrency.** Correct serialized writes can still have low throughput.
4. **One cross-platform file does not capture the full experiment.** Preserve code, schema, queries, parameters, version, and state too.
5. **Public domain does not mean reproducible.** It removes a legal barrier; it does not identify the exact artifact.
6. **`5433:5432` is host:container.** Service-to-service traffic uses `db:5432`, not `localhost:5433`.
7. **`depends_on` is startup order, not readiness.** Add health/retry logic in a real experiment.
8. **A persistent volume can preserve unwanted history.** State must be reset or versioned deliberately.
9. **Changing Postgres initialization variables does not necessarily change an already initialized volume.** Initialization concerns the first empty-data-directory start.
10. **Foreign-table creation is not source validation.** Errors can wait until query time.
11. **A selective `WHERE` does not create an index on a CSV file.** It may still scan every row.
12. **A foreign table is not a snapshot.** The external source can change between runs.
13. **Same output does not imply same binary.** Compiler and metadata differences can remain.
14. **`__LINE__` is source-dependent but not time/path-dependent.** In the exact MCQ it is one of the two acceptable snippets.
15. **Debug data is not the runtime stack.** Paths usually differ in binary metadata/read-only data.
16. **Out-of-tree builds organize outputs; they do not pin inputs.**
17. **Make rebuilds downstream, not upstream.** Follow dependency arrows from changed prerequisite to dependant target.
18. **Without a total `ORDER BY`, row order and `LIMIT` subsets are not reproducible.** A non-unique sort key may still leave ties.
19. **Replication is not an immutable snapshot.** Identify the exact database state/WAL point.
20. **Passing ReproTest is evidence under tested variations, not proof of program correctness.**

---

## 17. Likely exam questions with model answers

### Q1. Why does SQLite's architecture help reproducibility?

SQLite embeds the engine in the application and stores the database in a portable file, so a rerun needs no separately configured server, network, service account, or compatible client/server pair. The file and library are easy to archive and distribute. A complete artifact must still preserve the exact engine/version/build, schema, DB state, queries, pragmas, extensions, and application code.

### Q2. Why might PostgreSQL still be the correct experimental system?

If the claim concerns concurrent transactions, high throughput, centralized multi-host access, roles/permissions, replication, or server query processing, SQLite does not model the required architecture. Reproducibility means faithfully capturing the relevant system, not replacing it with the simplest DBMS.

### Q3. What does `docker compose` capture and what remains external?

It captures service topology, image references, commands, environment, network names, ports, and volume mounts. It does not by itself freeze mutable image tags, DB contents, hardware/load, secrets, server readiness, random choices, or the exact state inside a persistent volume.

### Q4. Why can a foreign-table definition succeed for a nonexistent file?

`CREATE FOREIGN TABLE` registers schema and wrapper options. The wrapper may not open, read, or parse the source until planning/executing a query. Therefore creation alone verifies none of existence, server-process readability, or row-format correctness.

### Q5. Why might `WHERE run_id = 42` still scan a complete CSV?

A raw CSV has no PostgreSQL B-tree or random-access index. `file_fdw` may need to read and parse every row before locally testing the predicate. High selectivity reduces returned rows, not necessarily source I/O.

### Q6. How can two programs be functionally equivalent but not bitwise identical?

They may compute and print the same result while different compilers/options produce different machine code, section layout, build IDs, debug symbols, paths, timestamps, or padding. Functional comparison tests behavior; checksums/cmp test exact bytes.

### Q7. What does ReproTest add beyond building twice manually?

It systematically perturbs environmental factors such as build path, time, locale, user, umask, file ordering, and related settings, rebuilds, and compares artifacts. This exposes hidden dependencies that two builds in one unchanged shell might miss.

### Q8. Why is an out-of-tree build useful?

It separates source inputs from generated artifacts, enables clean deletion/rebuild and multiple configurations, reduces stale-output pollution, and makes artifact provenance easier to inspect. It still requires pinned toolchains, dependencies, flags, and environment.

### Q9. Why does changing `generate_chart.py` rebuild the final paper?

The script is a prerequisite of `results/chart.pdf`; that chart is a prerequisite of `experiment.pdf`. Make first rebuilds the stale chart, then sees that the chart is newer than the final PDF and rebuilds the PDF. The raw data is upstream and does not depend on the chart script.

### Q10. How do you make a `LIMIT` query reproducible?

Use `ORDER BY` on a total, stable ordering that includes a unique tie-breaker, freeze the input snapshot, and control collation/time zone and volatile functions when relevant. `ORDER BY score` alone is insufficient if multiple rows share the same score.

---

## 18. Short self-test

Answer these without looking back.

1. Where does the DB engine run in SQLite?
2. Which SQLite feature describes the portable file, and which describes the all-in-one engine library?
3. Name the five workloads for which the excerpt recommends considering a client/server RDBMS.
4. Does ACID compliance imply that many SQLite writers execute in parallel?
5. Which endpoint does `bench` use, and which endpoint does a host-side client use?
6. Why can `bench` use the hostname `db`?
7. Does `depends_on` prove that PostgreSQL can already accept SQL?
8. Why can retaining `pgdata` undermine a clean rerun?
9. What does successful `CREATE FOREIGN TABLE` prove about `/proc/meminfo`?
10. Why can `WHERE run_id = 42` still scan an entire CSV?
11. How do you make `ORDER BY score` deterministic when scores can tie?
12. Can GCC and Clang binaries have the same behavior but different hashes?
13. Which two of the lab's four C snippets permit bitwise-identical builds?
14. Why does `gcc -g` commonly fail when ReproTest varies build directories?
15. What does Make rebuild after `generate_chart.py` changes?
16. If `csv_noisy_sin.py` changes, should the upstream base-data generator rerun?
17. Why is an out-of-tree build useful?
18. Is a live replicated standby automatically an immutable experimental snapshot?
19. Recite all eight exact SQLite feature headings.
20. What does SQLite's public-domain status help you do, and what does it not guarantee?
21. Fill these Compose facts: two images; database; user; password; host-to-container port; named volume; service hostname.
22. What is the FDW Question 6 true/false vector, and how many Question 7 queries can scan the whole CSV?
23. Which macro reliably makes the non-debug ReproTest example fail when time is varied?
24. Why declare `all` and `clean` as `.PHONY`?

### Answers

1. In the application's process as an embedded/linked SQLite library.
2. **Cross-Platform** describes the portable single file; **Self-Contained** describes the engine library.
3. High transaction rates, extremely large datasets, fine-grained access control, client/server use, and replication.
4. No. Transactional correctness can coexist with serialized writes.
5. `bench` uses `db:5432`; a client on the Docker host uses `localhost:5433`.
6. Compose puts both services on a default network and resolves the service name through internal DNS.
7. No. It controls startup order unless readiness is explicitly tied to a passing health check.
8. It preserves the PostgreSQL cluster, catalogs/schema, persistent configuration, and non-pgbench data/objects, so the next run may not start from the declared initial condition. It does not preserve PostgreSQL shared-buffer contents.
9. Nothing about existence, readability, or full parseability; those can fail at query time.
10. A flat file has no PostgreSQL index that lets `file_fdw` jump directly to matching rows.
11. Add a stable unique tie-breaker, for example `ORDER BY score, run_id`.
12. Yes. Behavior and byte identity are different properties.
13. Program 1 (constant) and Program 4 (`__LINE__`).
14. Debug metadata commonly records the compilation directory/source paths.
15. `results/chart.pdf`, followed by `experiment.pdf`.
16. No. Rebuild the changed noisy-data target and its downstream dependants, not independent upstream data.
17. It separates generated files from source, simplifies cleaning/comparison, and permits multiple configurations.
18. No. Identify and preserve a consistent DB state/WAL point.
19. Serverless; Zero Configuration; Cross-Platform; Self-Contained; Small Runtime Footprint; Transactional; Full-Featured; Highly Reliable.
20. It permits legal inspection, modification, archival, bundling, and redistribution of the exact code. It does not by itself identify the version or guarantee a reproducible experiment.
21. `postgres:16` and `postgres:16`; `benchdb`; `lab`; `labpw`; `5433:5432`; `pgdata`; `db`.
22. **T, T, F, T, F, F**; all **three** listed queries can scan the entire CSV.
23. `__TIME__`.
24. They are action/goal names rather than real output files; `.PHONY` prevents files named `all` or `clean` from suppressing the intended behavior.

---

## 19. Two-day revision plan

If time is short, prioritize **P1**, then **P2**, and skip **P3**. Do not try to read the guide linearly on the final morning.

### Day 1: database half

1. Read the database P1/P2 material in Sections 1-8.
2. Write the two architecture diagrams and label every component.
3. Recite `S Z C S S T F H` until all eight names are automatic.
4. Write the five poor-fit cases from memory.
5. Recreate the Compose YAML, then explain every blank aloud.
6. Answer the FDW true/false table without notes.
7. Practice deterministic `ORDER BY ... unique_id` examples.
8. Answer the database questions in Sections 17 and 18 closed-book; review only the mistakes.

### Day 2: build half

1. Read the build P1/P2 material in Sections 9-14.
2. Explain functional versus bitwise equivalence in two sentences.
3. Reproduce the macro table and the expected answer `2 = constant + __LINE__`.
4. Explain why `-g` fails ReproTest under changing build paths.
5. Draw the Make graph and predict rebuilds after changing each source.
6. Explain out-of-tree builds and the Python build commands.
7. Answer the build questions in Sections 17 and 18 closed-book; review only the mistakes.

### Final morning

- Read Sections 1, 15, 16, and 20.
- Fill the Compose file and macro MCQ once on blank paper.
- Do not spend final minutes memorizing obsolete replication syntax or the old Twitter FDW example.

---

## 20. Final 2-minute recall sheet

```text
ARCHITECTURES
  client/server = app + DB client library --network--> RDBMS server -> DB files
  SQLite       = app + SQLite library ----------------> SQLite file

SQLITE 8
  Serverless, Zero Configuration, Cross-Platform, Self-Contained,
  Small Runtime Footprint, Transactional, Full-Featured, Highly Reliable

PUBLIC DOMAIN
  lets you inspect/modify/archive/redistribute exact code
  does not identify the version or guarantee reproducibility

SQLITE NOT BEST FOR
  high transactions, huge data, fine access control, client/server, replication

COMPOSE
  postgres:16 | benchdb | lab | labpw
  host 5433 -> container 5432
  bench connects to db:5432
  pgdata -> /var/lib/postgresql/data
  down keeps named volume; depends_on does not mean ready

FDW
  CREATE defines metadata; SELECT validates/reads/parses
  creation proves none of exists/readable/parseable
  Q6 vector = T,T,F,T,F,F; Q7 = all three queries can scan
  no raw-file index; SELECT *, WHERE selective, COUNT(*) can all scan CSV

DETERMINISTIC SQL
  no ORDER BY = no order guarantee
  ORDER BY nonunique = ties still unspecified
  LIMIT needs a total order + frozen input state

BINARY BUILDS
  same behavior != same bytes
  compiler/version/flags/path/time/environment matter
  MCQ answer 2: constant + __LINE__
  risky: __FILE__, __TIME__
  -g may embed build paths

REPROTEST
  rebuild twice under varied environment, compare artifacts
  reliable non-debug failure macro = __TIME__

MAKE
  target: prerequisites
  newer prerequisite -> rebuild target -> rebuild downstream dependants
  generate_chart.py change -> chart.pdf + experiment.pdf
  .PHONY all clean = action names, not real output files

OUT-OF-TREE
  source stays clean; builds/configurations separated; easy clean rebuild
```

---

## 21. Source coverage and references

### Every supplied Module 6 item

- **IC** - [In-Class Exercise Sheet 6](6-DBMS-Architectures/SoSe_2026_RepEng_IC_6___Architectures.pdf), PDF pages 1-6.
- **L** - [Lab Exercise Sheet 6](Lab_Session_6/Sheet_6.pdf), PDF pages 1-10. The copy under the combined Exercises folder is byte-for-byte identical.
- **SQ** - [Using SQLite excerpt](6-DBMS-Architectures/using_sqlite_excerpt.pdf), PDF pages 1-17.
- **PG** - [PostgreSQL: Up and Running excerpt](6-DBMS-Architectures/PostgreSQL_up_and_running.pdf), PDF pages 1-5; the relevant printed book pages are 129-132.
- [Docker Compose for databases shortcut](6-DBMS-Architectures/Docker_compose_for_databases.url).
- [Nondeterministic SQL shortcut](6-DBMS-Architectures/Nondeterministic_SQL.url).
- [PostgreSQL Foreign Data Wrappers shortcut](6-DBMS-Architectures/PostgreSQL_Foreign_Data_Wrappers.url).

The three `.url` files are authenticated Stud.IP download wrappers, so their payloads are not independently readable without the course session. Their named topics overlap the supplied questions/excerpts and were cross-checked against the official references below. No inaccessible text was invented.

### Official cross-checks

- [Docker Compose networking](https://docs.docker.com/compose/how-tos/networking/)
- [Docker Compose startup order and readiness](https://docs.docker.com/compose/how-tos/startup-order/)
- [Docker Compose `down` and volumes](https://docs.docker.com/reference/cli/docker/compose/down/)
- [Official PostgreSQL container image variables](https://hub.docker.com/_/postgres)
- [PostgreSQL `file_fdw`](https://www.postgresql.org/docs/current/file-fdw.html)
- [PostgreSQL `LIMIT`/`OFFSET` and ordering](https://www.postgresql.org/docs/current/queries-limit.html)
- [PostgreSQL `pgbench`](https://www.postgresql.org/docs/16/pgbench.html)
- [PostgreSQL standby/recovery configuration](https://www.postgresql.org/docs/current/recovery-config.html)
- [GCC standard predefined macros](https://gcc.gnu.org/onlinedocs/cpp/Standard-Predefined-Macros.html)
- [GCC environment variables and reproducible-build inputs](https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html)
- [GNU Make manual](https://www.gnu.org/software/make/manual/make.html)
- [ReproTest manual](https://manpages.debian.org/testing/reprotest/reprotest.1.en.html)
