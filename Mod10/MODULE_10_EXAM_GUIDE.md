# Reproducibility Engineering - Module 10 Exam Guide

> An exam-focused guide to every supplied Module 10 source: remote experiments, self-contained execution packages, SQPolite, long-term reproducibility, container secret handling, LLM temperature and seed, JSON Schema, and constrained decoding.

## How to use this guide

1. Read **Section 1** and memorize the five-step remote pipeline, the three secret methods, and the two LLM rules.
2. Redraw the in-class diagrams from **Section 2** without looking.
3. Learn the exact lab answers in **Sections 5-7**, especially the two multiple-choice answers.
4. Finish with the exam traps, two-minute recall sheet, and closed-book self-test.

Priority:

- **A - must know:** the five remote-workflow actions; execution-package contents; secret exposure; temperature versus seed; prompt-only versus constrained output; `oneOf` versus `anyOf`; the two lab MC answers.
- **B - understand:** SQPolite's fork/patch/package design, the exact experiment flow, and long-term reproducibility threats.
- **C - recognition:** detailed build commands, clean Git-history practices, and the walkthrough's individual repository names.

With the exam on **29 July 2026**:

- **27 July:** learn Sections 1-2 and redraw both remote-workflow diagrams twice from memory.
- **28 July:** work through Sections 5-7, then take the self-test closed-book and repair every missed answer.
- **Exam morning:** read only Section 10, the two MC answers in Section 1.6, and the schema set `{12000, 12001, 12002}`.

> **The whole module in six lines**
>
> - **B-P-D-R-V:** **B**uild in a controlled container, **P**ackage a self-contained experiment, **D**eploy it, **R**un on the target, **V**isualize back in the controlled environment.
> - The target may be special hardware and may have **no Docker**; ship an execution package, not an assumption about the target.
> - **E-E-F:** a direct **E**nvironment variable is exposed by inspection; a `.env` file is still an injected **E**nvironment variable; a mounted **F**ile hides the value from container environment metadata.
> - **Temperature shapes; seed repeats:** temperature changes the token distribution, while a seed repeats pseudorandom draws for an otherwise fixed setup.
> - **Structured output guarantees shape, not truth**, and only for schema features the tool actually translates and enforces.
> - `anyOf` means **at least one** branch; `oneOf` means **exactly one** branch.

---

## 1. High-yield module map

### 1.1 Remote experiments: the answer-first version

```text
source repos + binaries + patch stack -> [Docker build environment]
                                        (it integrates these inputs)
reproducible build recipe            => [Docker build environment]  (1)
[Docker build environment]           => [experiment execution package]  (2)
[experiment execution package]       -- deploy/copy --> cloud or local HW  (3)
cloud or local HW                    => raw measured results  (4)
raw results                          => charts, tables, and paper  (5)
```

The five numbered actions from the in-class sheet are:

1. A build recipe produces a controlled, host-independent Docker build environment, which integrates the binaries, source repository, and patch stack and builds the measurement binaries.
2. That environment produces a self-contained **experiment execution package**.
3. Copy/deploy the package to cloud or local target hardware without depending on target-provided artifacts.
4. Run the experiments; the runs produce raw measured data/results.
5. Post-process, evaluate, and visualize the results with scripts from the package. [IC1-2; NV3-4]

The page-1 labels are:

| Position in the picture | Correct label |
|---|---|
| Gear before the upper-left box | **build artefacts** |
| Upper-left box copied to the target | **experiment execution package** |
| Gear on the target | **run experiments** |
| `.csv` file on the target | **measured data** |
| Gear producing the plot/paper back in the container | **generate graphs and paper** |

### 1.2 The package-content mnemonic

Memorize **B-D-D-E**:

- **Binaries** compiled for the target;
- **Data**, or a deterministic data generator;
- **Dispatcher** that runs all measurements consistently;
- **Evaluation** and visualization scripts.

A strong package also records exact versions, parameters, checksums, licenses, raw outputs, and target hardware/runtime configuration.

**Diagram warning:** B-D-D-E is a completeness mnemonic, not the literal order of the three blanks inside Figure 1. Those inner boxes are **Evaluation | Dispatcher | Data + Generators**; **Binaries** appears separately in the top input row.

### 1.3 Secrets: the comparison to memorize

| Method | Where the value is inside the container | Does `docker inspect` expose the value? | What it improves |
|---|---|---:|---|
| `docker run -e OPENAI_API_KEY` | Environment variable | **Yes, plaintext** | Runtime injection; avoids baking it into the image |
| Compose `env_file: .env` | The **same environment variable** | **Yes, plaintext** | Keeps the literal out of the typed shell command and authored Compose YAML; centralizes local configuration |
| Read-only bind-mounted file | File such as `/run/secrets/openai_api_key` | **Normally no value**; it shows path/mount metadata | Keeps the value out of container environment metadata |

`.env` is **not encryption**, a mounted file is not magic, and both host files must be protected. Use **both** `.gitignore` and `.dockerignore`: the first prevents commits; the second excludes files from the Docker build context. [L1-3]

### 1.4 LLM reproducibility: the decision table

| Setting on the same controlled local CPU stack | Expected course answer |
|---|---|
| `temperature=0`, no seed | Greedy and deterministic; repeated responses are identical |
| `temperature=0`, different seeds | Normally the same response; there is no random token sampling for the seed to control |
| Nonzero/default temperature, fixed seed | Repeated identical requests reproduce the same pseudorandom choices |
| Same seed, different temperatures | Each fixed configuration can repeat, but the outputs may differ because the probability distribution changed |
| Higher temperature | Flatter distribution, more diversity, and more chance of low-probability tokens |

Real-world systems can still differ after model, weights, quantization, server/sampler version, prompt, hardware, drivers, floating-point order, or parallelism changes. For the sheet's explicit local-CPU scenario with such changes excluded, choose the simplified answer above. [L4-5, L8]

### 1.5 Structured output: the guarantee ladder

| Method | What is guaranteed? |
|---|---|
| Schema written only in the prompt | Nothing formal; the model may ignore it or add prose |
| Constrained decoding | A successful, complete output conforms to the generated grammar |
| Grammar from a JSON Schema | Conformity only to the schema features correctly supported by that converter/tool |
| Independent full-schema validation | If the validator accepts the instance, it satisfies that validator's implemented schema semantics |

None of these alone proves that the answer is factually correct or fulfills a semantic request such as “return the smallest valid number.” **Valid structure is not valid meaning.** [L6-8]

### 1.6 The two multiple-choice answers

1. Local llama.cpp, CPU, same machine, `temperature=0.0`: **Yes - deterministic without also requiring a seed**, under the question's stated exclusions.
2. Constrained decoding with numeric bounds and `oneOf`: **The instance is guaranteed only to match the schema features the tool actually supports.** [L8]

---

## 2. Remote experiments and reproduction packages

### 2.1 Why the ordinary container story is insufficient

Some experiments must run on a remote cloud instance, an HPC node, an ARM board, a GPU server, a measurement appliance, or other special hardware. That target may not allow Docker at all. Even when Docker runs there, measuring inside a container can change the conditions being measured.

The solution is to separate three concerns:

1. **Build in a controlled environment.** Use a recorded recipe to compile target binaries and assemble all required files.
2. **Measure on the real target.** Copy a neutral, self-contained execution package and run it with minimal target assumptions.
3. **Analyze in a controlled environment.** Copy raw results back and regenerate charts, tables, and the paper reproducibly.

The container therefore controls the **build and analysis**, while the execution package crosses the boundary to the measurement target. “Just run the same container everywhere” is not the answer to this module. [IC1; NV3-4]

Terminology distinction:

- The **reproduction package** is the overall published/archived setup: build recipe and sources, controlled environment, deployable payload, raw results, analysis, documentation, and provenance.
- The **experiment execution package** is the self-contained deployable subset produced for the measurement target.

### 2.2 Exact answer to In-Class Exercise 1

Read the diagram clockwise:

```text
DOCKER/CONTROLLED SIDE                         TARGET PLATFORM

build artefacts
      |
      v
[experiment execution package]  --copy-->  [unpacked execution package]
                                                   |
                                                   v
                                           run experiments
                                                   |
                                                   v
                                            measured data (.csv)
                                                   |
                                      package/copy results back
                                                   |
                                                   v
[result files]  <----------------copy---------- [result archive]
      |
      v
generate graphs and paper
```

The direction matters: executable artifacts travel **to** the target; measured data travel **back** to the controlled analysis environment. [IC1]

### 2.3 Exact answer to In-Class Exercise 2

The symbols mean:

- `A -> B`: **B integrates A**.
- `A => B`: **B is produced by A**.
- Dashed arrow: **temporal flow**, not an artifact dependency.

The five actions are:

| Number | Exam-ready wording |
|---:|---|
| **1** | The build recipe produces a static Docker build environment; that container integrates the binaries, source repository, and patch stack and builds the experiment artifacts. |
| **2** | The controlled environment produces the self-contained experiment execution package. |
| **3** | Deploy the package to a cloud system or local target hardware. |
| **4** | Run the experiments; each deployment produces raw results. |
| **5** | Post-process, evaluate, and visualize those results to produce charts/tables. |

The blank boxes in the original article are:

| Position | Label |
|---|---|
| Top left | **Binaries** |
| Top center | **Public Git Repository** |
| Top right | **Patch Stack** |
| Left of the large center box | **Build Recipe** |
| Large center box | **Docker Container** |
| Large lower box | **Experiment Execution Package** |
| Inside that package, left to right | **Evaluation**, **Dispatcher**, **Data + Generators** |
| Right-side left path | **Cloud Deployment -> Results A -> Charts A** |
| Right-side right path | **Local HW Deployment -> Results B -> Charts B** |

Their dependency/production flow is:

```text
Binaries + Public Git Repository + Patch Stack  ->  Docker Container
Build Recipe                                      =>  Docker Container (1)
Docker Container                                  =>
Experiment Execution Package
  [Evaluation | Dispatcher | Data + Generators]
                         deploy to
  [Cloud Deployment | Local HW Deployment]
                         =>
       [Results A | Results B]
                         =>
        [Charts A | Charts B]
```

This exact interpretation is stated in the caption of Figure 1 in the assigned article. [IC2; NV4]

### 2.4 What must be reproducible at each stage

| Stage | Preserve/control | Typical failure |
|---|---|---|
| Build | Source revision, compiler, libraries, build flags, patches, locale, build recipe | A mutable `HEAD` or package repository now yields different binaries |
| Package | Target binaries, input/generator, scripts, configuration, expected layout, checksums | A dependency is silently assumed to exist on the target |
| Deploy | Transfer procedure, target identity, permissions, architecture | Package works only on the author's machine |
| Run | Dispatcher, order, repetitions, warm-up, seeds, environment and hardware state | Manual steps or different target tunables change measurements |
| Analyze | Raw results, parser, statistical method, plotting and paper build | Only final plots are archived, so the derivation cannot be checked |

For performance experiments, “Linux version X, machine Y, 24 GiB RAM” is not a complete environment description. Kernel extensions, frequency governors, schedulers, CPU isolation, caches, firmware, background load, compiler flags, database configuration, and many other tunables can change measurements substantially. [NV3]

### 2.5 Terminology and the article's two pillars

The assigned article uses the course's current ACM convention:

- **Repeatable:** the **same team**, using the **same experimental setup**, reliably obtains the same result in later trials.
- **Reproducible:** a **different team**, using the **same experimental setup**, obtains the same result.

Terminology is not globally standardized, and ACM changed these definitions on **24 August 2020**. In an exam, state the convention and classify from team plus setup rather than relying on an unexplained label. [NV1]

The assigned *Nullius in Verba* article advocates two broad pillars:

1. A **multi-stage reproduction package**: deterministically build executable artifacts - ideally bitwise-identical where feasible - bundle artifacts/data/instrumentation into a self-contained collection, then execute and validate measurements on the required hardware.
2. **Long-term availability**: use mature, community-supported open tools, archived formats, and conventions that have a realistic chance of remaining usable for decades. [NV1-3]

`Nullius in verba` is the Royal Society motto commonly rendered as **“take nobody's word for it.”** The reproducibility lesson is that a result should be independently inspectable and rerunnable, not merely asserted.

### 2.6 Long-term reproducibility

A Dockerfile or repository that builds today is not automatically a durable archive. External state changes:

- base-image tags are replaced or removed;
- package repositories and package versions change;
- runtime configuration changes beyond the distribution/kernel label;
- Git repositories disappear or move between hosts;
- projects become unmaintained;
- download links and signing keys expire;
- proprietary services, licenses, or hardware vanish.

The walkthrough's goal is a **complete, self-contained environment** that can still be built or run “on an island” without Internet access, or decades after the original repositories disappear. [W15]

A durable release should therefore archive the exact repository state, source dependencies, patches, pre-built image or reproducible image inputs, experiment package, measured data, checksums, documentation, and license information under a persistent identifier. A DOI helps locate an object; it does not prove that the object is complete or executable. The SQPolite project explicitly distinguishes its DOI-archived, external-resource-free release from its Internet-dependent from-scratch build, which is **not** expected to work forever. [SQ]

The scratch Dockerfile itself makes the lesson concrete: it starts from a tag, contacts live Ubuntu/R package repositories, installs packages without complete version pins, and clones some live Git repositories. It is a useful readable recipe for rebuilding now, but external services can make the same instructions fail or produce different content later. The archived image, sources, measured data, and checksums are the durable path.

---

## 3. SQPolite: the worked blueprint

### 3.1 What the fictional experiment does

SQPolite modifies SQLite for an intentionally playful research question: does treating the database politely affect behavior and latency?

- An ordinary query begins with `SELECT`.
- A polite query begins with `PLEASE SELECT`.
- The modified parser accepts the new `PLEASE` keyword.
- A separate `pplease(text)` extension represents output-side politeness by randomly adding `, please.` at sentence endings about half the time.
- Impolite queries may receive a randomized delay of roughly 250-499 ms on about one quarter of eligible `SELECT` operations, creating a measurable latency difference.
- The experiment runs TPC-H queries in polite and impolite variants, records timings, plots measurements, and incorporates plots into a paper. [W3-14; SQ; SQLITE]

The purpose is not the scientific claim. The project is a blueprint showing how modified third-party software, data generation, measurements, analysis, and paper generation fit into one traceable package.

The polite and impolite workloads are paired: their substantive SQL is the same except that the polite files replace relevant `SELECT` tokens, including nested queries, with `PLEASE SELECT`. This design enables result validation while comparing latency behavior. However, the supplied `latency.c` driver passes a null row callback to `sqlite3_exec`; it aborts on SQL errors but discards returned tuples and does **not** compare them with expected results. Output validation is an architectural requirement depicted in the walkthrough, not a feature actually completed by this demo harness. [W3; SQLITE]

### 3.2 Component map

| Component | Role |
|---|---|
| `lfd/sqlite` / `sqpolite` | Fork of SQLite containing the research changes |
| `pplease` / `pplease.so` | Custom SQLite function/extension that makes returned text more polite |
| `TPCH-sqlite` | SQLite-compatible TPC-H setup |
| `tpch-dbgen` | Deterministic TPC-H data generator |
| `TPCH-sqlite.diff` | Small local patch that makes the setup invoke `sqpolite` instead of `sqlite3` |
| `queries.impolite/` | Standard `SELECT` query workload |
| `queries.polite/` | Matching workload with every relevant `SELECT` changed to `PLEASE SELECT` |
| `prepare_data.sh` | Builds the generator/database and creates scale-factor datasets |
| `dispatch.sh` | Runs selected queries repeatedly and records results plus target configuration |
| `doall.sh` | Runs the standard polite and impolite measurement scenarios |
| `Dockerfile` | Constructs the build/analysis environment and the deliverable tarball |
| paper repository | R/knitr/LaTeX sources that turn measurements into plots and a PDF |

In the reference implementation, `doall.sh LABEL` invokes polite and impolite measurements at scale factor `0.1`, 25 requested iterations per selected query. `dispatch.sh` runs queries 1-12, 14-16, 18, 19, and 21; it skips 13, 17, 20, and 22 because their much longer runtimes would dominate and obscure the plots. It writes `results.csv` and is intended to capture `/proc` configuration such as CPU information, kernel configuration, modules, command line, and cgroups. [SQ]

Code-audit nuances:

- The latency driver sets timestamp 0 before execution and loops while `count < iterations`; a requested value of 25 therefore executes each selected query **24 times** and emits 24 measurement rows.
- The dispatcher checks relative names such as `cpuinfo` before trying to copy `/proc/cpuinfo`. In an ordinary working directory those checks fail, so the target metadata will normally not be copied.

The design lesson is to record the planned count and target metadata, then test that the automation actually does so.

The ideal Figure 1 package contains Evaluation. The actual `deliverable.tar.bz2` contains the paired queries, `TPCH-sqlite/` and its generator, compiled `bin/`, `doall.sh`, `dispatch.sh`, and `prepare_data.sh`; the paper/R/knitr evaluation sources remain separately under `/home/repro/paper` in the container. This implementation gap also explains why the demonstration is not fully one-command Gold. [SQ]

### 3.3 Fork versus patch

| Technique | Advantage | Caveat |
|---|---|---|
| Fork the upstream project | Retains upstream commit history and attribution; research commits can be reviewed and later rebased | The remote host can disappear, so archive/pin the fork |
| Distribute an explicit patch | Clearly exposes the exact local change; simple, stable, automatable, and not inherently tied to Git | The patch applies only to the correct pinned base revision |
| Copy only the final modified tree | Easy snapshot | Hides which lines came from upstream, why they changed, and who is responsible |

The walkthrough uses a fork for the substantive SQLite research changes and a small patch for adapting `TPCH-sqlite`. Both strategies preserve the relationship to third-party code more clearly than an unexplained copied tree. [W4-8]

### 3.4 Clean history is communication

Research usually develops chronologically through partial commits, false starts, fixups, and transient debugging. The final reproduction package should preserve important design decisions but present them as a **logical series of orthogonal commits**: the smallest useful, reviewable increments with clear explanations and attribution.

The SQPolite fork demonstrates this contrast:

- `master` presents four clean conceptual commits: add politeness output, require/track polite input, add the impoliteness penalty, and add latency measurement.
- `devel_process` retains thirteen development commits, including fixups, renames, intermediate clocks, and later licensing cleanup.

Commit trailers such as `Signed-off-by`, `Reviewed-by`, and `Tested-by` create a trail of authorship, review, testing, and responsibility. Rewriting the presentation history is useful only before publication/shared reliance and must not erase credit or falsify what happened. [NV2; SQ]

### 3.5 Exact package workflow and commands

Recognition-level command sequence:

```bash
git clone https://github.com/lfd/icde2021_tutorial
cd icde2021_tutorial
docker build -t icde2021 .
```

Export the self-contained package from the image and send it to a target:

```bash
docker run --rm --entrypoint cat icde2021 \
  /home/repro/deliverable.tar.bz2 > /path/to/deliverable.tar.bz2
scp /path/to/deliverable.tar.bz2 host.domain.tld:
ssh host.domain.tld
tar xjf deliverable.tar.bz2
cd measure
```

Prepare data and measure:

```bash
./prepare_data.sh
./doall.sh TARGET_LABEL
```

The walkthrough's example label is:

```bash
./doall.sh docker
```

Copy the generated `res_*` folders back into `/home/repro/results`, then produce plots and the paper:

```bash
Rscript -e "require ('knitr'); knit ('paper.Rnw')"
pdflatex paper
biber paper
pdflatex paper
pdflatex paper
```

The README once calls the archive `measure.tar.bz2` in prose, but the Dockerfile and commands use `deliverable.tar.bz2`; follow the actual artifact name. [SQ]

### 3.6 Is `doall.sh` automatically Gold reproducibility?

**Not by itself.** The slide labels `./doall.sh docker` as end-to-end for the demonstrated measurement scenarios, but strict Gold reproducibility requires **the entire analysis** to run with one command: acquire/generate inputs, preprocess, measure, analyze, create/annotate figures, and generate final outputs. The reference README still invokes R/knitr and LaTeX separately. `doall.sh` is therefore an excellent dispatcher and a step toward Gold, not proof that every final-paper step is one-command automated. [W12-14; SQ]

---

## 4. Building and evaluating a remote-experiment package

### 4.1 Exam-ready design answer

If asked to design a package for a remote machine that cannot run Docker, write:

> I would use a pinned build recipe inside a controlled container to compile binaries for the target architecture. The build would create a self-contained execution archive containing the binaries, data or deterministic generators, configuration, dispatcher, and validation/evaluation scripts. I would checksum and copy that archive to the target, record the target's hardware and runtime configuration, and execute all trials through the dispatcher. Raw, immutable results and metadata would be copied back to the controlled analysis environment, where scripts regenerate every table, figure, and paper output. I would archive the recipe, exact source revisions, patches, package, raw results, image or dependencies, checksums, documentation, and licenses under a persistent identifier.

### 4.2 Result validation

Performance alone is insufficient. A fast system that returns the wrong answer has not won the benchmark. Record and check:

- exit status and error logs;
- expected versus actual query results;
- row counts, ordering rules, tolerances, or checksums as appropriate;
- whether every requested trial completed;
- raw timing values before aggregation;
- the association between a result and its exact configuration.

Choose the right equality notion: exact byte identity for deterministic artifacts, tolerance/permutation-aware equivalence where ordering or floating point permits it, and distributional/statistical comparison for stochastic or physical measurements.

### 4.3 Reproducibility limits

The package reduces uncontrolled variation but cannot make unlike hardware identical. CPU microarchitecture, storage, network, GPU, firmware, and thermal conditions may legitimately change performance. A good reproduction states which aspects should be identical - such as query answers and scripts - and which are expected to differ - such as absolute latency - then defines an appropriate comparison and tolerance.

---

## 5. Lab 10 secrets - exact solved answers

### 5.1 Rule zero

A real API key controls access and billing. Never:

- hard-code it in source or `compose.yaml`;
- pass the literal on a command line that enters shell history;
- use `ARG`, `ENV`, or `COPY` to bake it into an image/layer;
- commit it to Git;
- print it to logs as the teaching demos deliberately do.

Inject it **at runtime** and grant it only to the process that needs it. [L1]

### 5.2 Exercise 2.1 - environment variable

```bash
cd secrets/1-env-var
export OPENAI_API_KEY=sk-demo-1234567890abcdef
docker build -t env-demo-img .
docker run --name env-demo-1 -e OPENAI_API_KEY env-demo-img
```

The `-e OPENAI_API_KEY` form forwards the host variable without repeating its value in the `docker run` command.

```bash
docker inspect env-demo-1 2>/dev/null | grep -i openai
```

**Answer:** inspection exposes `OPENAI_API_KEY=...` in the container's configured environment. The container may already be stopped, but it was deliberately not run with `--rm`, so its metadata remains inspectable.

Compose version:

```bash
docker compose up
docker inspect env-demo 2>/dev/null | grep -i openai
```

The Compose entry `environment: - OPENAI_API_KEY` forwards the host value. Its command also contains a single `$OPENAI_API_KEY`, so Compose interpolates the value while parsing the YAML. **Inspection can expose the plaintext in both `Config.Env` and `Config.Cmd`.** By contrast, the direct `docker run` image command retains the variable reference in `Cmd`, but the value is still exposed in `Env`. [L2; LABCODE]

### 5.3 Exercise 2.2 - `.env` file

```bash
cd secrets/2-dotenv
cp .env.example .env
docker compose up
docker inspect dotenv-demo 2>/dev/null | grep -i openai
```

**Answer:** `env_file: .env` injects the value as the same container environment variable, so `docker inspect` still exposes it. Compose also uses the project `.env` for interpolation of the command's single `$OPENAI_API_KEY`, so the literal may appear in both `Config.Env` and `Config.Cmd`.

What improved:

- the literal is not typed in every command;
- it stays out of the committed Compose source if `.env` is ignored;
- per-machine configuration is centralized and replaceable.

What did **not** improve:

- `.env` is plaintext, not encrypted;
- the value remains visible in container environment metadata and to the process;
- a forgotten `.gitignore` can still leak it. [L2; LABCODE]

### 5.4 Exercise 2.3 - mounted read-only file

Create `secrets/openai_api_key` under `secrets/3-mounted-file/`, protect its permissions, and run:

```bash
docker compose up
docker inspect mounted-file-demo-1 2>/dev/null | grep -i openai
```

The Compose configuration mounts:

```text
./secrets/openai_api_key -> /run/secrets/openai_api_key:ro
```

and sets only:

```text
OPENAI_API_KEY_FILE=/run/secrets/openai_api_key
```

**Answer:** inspection can reveal the environment variable containing the **path** and the bind-mount source/destination, but not the secret file's contents. Inside the container, the key is stored in a read-only file rather than the environment. This Compose command uses `$$OPENAI_API_KEY_FILE`; `$$` deliberately escapes Compose interpolation so only the variable/path, not the file value, is retained in command metadata.

Improvement: less accidental exposure through environment dumps and `docker inspect`. Limitation: authorized processes, host administrators, and sufficiently privileged container/Docker users can still read the file. `:ro` prevents writes through that mount; it does not make the contents unknowable. [L3; LABCODE]

### 5.5 Exercise 2.4 - preventing accidents

The real-secret files that must never be committed are:

```text
2-dotenv/.env
3-mounted-file/secrets/openai_api_key
```

From the common `secrets/` directory, a precise `.gitignore` can contain:

```gitignore
2-dotenv/.env
3-mounted-file/secrets/
```

The corresponding build contexts should contain `.dockerignore` rules such as:

```dockerignore
.env
secrets/
```

Key distinctions:

- `.gitignore` prevents untracked files from being added to Git; it does **not** remove an already tracked secret.
- `.dockerignore` prevents matching files from entering the build context; `.gitignore` does not do that job.
- `.env.example` may be committed only with a dummy/placeholder value.
- If a real key was committed, removing the file is not enough: **revoke/rotate the key**, then deal with repository history under the appropriate policy. [L3]

---

## 6. Reproducible LLM output - temperature and seed

### 6.1 Local lab stack

The lab uses:

- Gemma 3 1B, quantized as `Q4_K_M`;
- llama.cpp on the CPU;
- an OpenAI-compatible Chat Completions endpoint;
- server address `127.0.0.1:11434`;
- model alias `gemma3:1b`;
- the OpenAI Python client with any nonempty dummy local API key. [L4; LABCODE]

Setup commands:

```bash
cd LabSession10/llm
docker compose up -d
python -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

The Compose file maps host `127.0.0.1:11434` to container port `8080` and uses a model-initialization service to download the GGUF file before starting the server.

On `narrow-sea`, the server is already running and the sheet says to use `python3`; on a local setup, the command name depends on the Python installation. [L4]

### 6.2 Temperature

For logits `z_i` and temperature `T > 0`, a common sampling rule is:

```text
p_i(T) = exp(z_i / T) / sum_j exp(z_j / T)
```

- Lower `T` sharpens the distribution toward high-logit tokens.
- `T -> 0` is implemented as greedy choice of the highest-scoring token; do not literally divide by zero.
- Higher `T` flattens the distribution and increases diversity/risk.

Temperature changes **which distribution is sampled**. It does not provide a random sequence by itself. [L5]

### 6.3 Seed

A seed initializes the pseudorandom number generator used during sampling. With the same prompt, messages, model/weights, sampler parameters, server implementation, seed, and execution conditions, it replays the same sequence of random choices.

A seed does **not**:

- repair a changed temperature or model;
- pin dependencies, prompt templates, or model files;
- remove hardware/framework nondeterminism;
- guarantee that a remote provider routes requests through an identical backend.

Mnemonic: **temperature shapes; seed repeats**.

### 6.4 Exact interpretation of the sheet's experiments

The script sends a new but identical request for every iteration.

#### (a) Temperature `0`, varied seed

```bash
python generate.py -t 0 -i 3
python generate.py -t 0 -s 1 -i 3
python generate.py -t 0 -s 999 -i 3
```

Expected: repeated outputs are identical, and changing the seed normally has no effect because greedy decoding does not draw a random token. If there were exact-score ties or an implementation-specific nondeterministic operation, a caveat could arise, but that is outside the sheet's intended controlled-CPU answer.

#### (b) Default temperature, seed `42`

```bash
python generate.py -s 42 -i 3
```

Expected: repeated identical requests reproduce the same sampled output because each request starts from the same seed and otherwise fixed configuration.

#### (c) Same seed, changed temperature

```bash
python generate.py -s 42 -t 0.7 -i 3
python generate.py -s 42 -t 1.5 -i 3
```

Expected: each command is repeatable within its own fixed configuration, but `0.7` and `1.5` can produce different texts. The same pseudorandom numbers are applied to different probability distributions. The higher temperature generally allows more varied/unlikely tokens. [L5; LABCODE]

### 6.5 What must be pinned for a reproducible LLM call

Record or archive:

- exact model and weight-file checksum;
- quantization format;
- prompt, system prompt, chat template, message order, and encoding;
- sampler/server version and all generation parameters;
- seed and request order;
- context size and truncation behavior;
- client/API version;
- hardware, backend, thread/parallelism, driver, and relevant flags.

The teaching Compose file is convenient, but mutable tags such as `ghcr.io/ggml-org/llama.cpp:server`, a model URL under `main`, and `openai>=1.0` are not long-term pins. For an archival experiment, pin an image digest, model checksum/revision, and exact client version.

---

## 7. Structured outputs - exact solved answers

### 7.1 Solve the schema by hand

The sheet uses:

```json
{
  "type": "integer",
  "anyOf": [
    { "type": "integer", "minimum": 3, "maximum": 1 },
    { "type": "integer", "minimum": 12000, "maximum": 12002 }
  ]
}
```

First branch:

```text
{n in integers | n >= 3 and n <= 1} = empty set
```

Second branch:

```text
{12000, 12001, 12002}
```

Because `anyOf` takes the union, the full valid set is:

```text
{12000, 12001, 12002}
```

The smallest valid instance is **12000**. [L6]

### 7.2 Exercise 4.1 - schema in the prompt

```bash
python schema_in_prompt.py -i 5
```

**Answer:** no, the model is not guaranteed to return a valid instance. The schema is ordinary prompt text. At the lab's high `temperature=2.0`, the model may emit prose, Markdown fences, a syntactically invalid number, an out-of-range value, or a number that is valid but not the smallest. Prompting changes likelihood, not the decoder's legal-token set. [L6; LABCODE]

### 7.3 Exercise 4.2 - constrained decoding

```bash
python structured_output.py -i 5
```

The script passes the schema in `response_format`; llama.cpp derives a grammar and masks tokens that would violate it.

**Exact lab result:** with the lab's llama.cpp server/toolchain and this supported schema, a successful generation is restricted to **12000, 12001, or 12002**. The output matches the internally generated grammar, which supports the used `integer`, `anyOf`, `minimum`, and `maximum` constraints.

General caveat: this is a guarantee of the generated grammar and the schema subset the converter faithfully supports, not an unconditional guarantee for every JSON Schema feature.

Not guaranteed:

- that the answer is the smallest (`12001` and `12002` are structurally valid);
- that the value is factually or semantically correct;
- that unsupported JSON Schema keywords were enforced;
- that a different converter/version creates identical constraints. [L6-8]

### 7.4 `anyOf` versus `oneOf`

- `anyOf`: an instance must satisfy **at least one** listed subschema.
- `oneOf`: an instance must satisfy **exactly one** listed subschema.

Formal memory aid:

```text
anyOf(x): count(matching branches) >= 1
oneOf(x): count(matching branches) == 1
```

Example with overlapping branches `0..10` and `5..15`:

- `7` is valid under `anyOf` because it satisfies at least one branch.
- `7` is invalid under `oneOf` because it satisfies **both**, not exactly one.

If branches do not overlap, as in `0..10` and `20..30`, the accepted value set happens to be the same for `anyOf` and `oneOf`. The definitions are still different.

### 7.5 Exercise 4.3 - why the empty `diff` matters

```bash
python json_schema_to_grammar.py schemas/number_oneof.json > oneof.gbnf
python json_schema_to_grammar.py schemas/number_anyof.json > anyof.gbnf
diff oneof.gbnf anyof.gbnf
```

**Observed answer:** `diff` prints nothing; the grammars are identical. The supplied converter routes `oneOf` and `anyOf` through the same union-generation logic. For the sheet's disjoint ranges, the accepted set is coincidentally correct for both. With overlapping alternatives, it loses `oneOf`'s exactly-one rule and can admit a value that violates the full schema.

Implication for reproducibility: two tools or versions can interpret/support the same schema differently. A run can be perfectly repeatable yet repeatedly enforce the wrong semantics. Pin and archive the converter/server version, keep the generated grammar, test important edge cases, and validate final instances with an independent full JSON Schema validator. [L7-8; LABCODE]

### 7.6 Solved Lab Exercise 5 multiple choice

#### 5(a)

**Correct option 2:**

> Yes - at `temperature=0` the result is deterministic on a local system if the model runs on a CPU.

Why the others fail:

- LLM output is not always random; greedy decoding is deterministic in the stated setup.
- A seed is unnecessary when no random sampling occurs.
- A GPU is not required and can introduce additional numerical/nondeterministic complications.

#### 5(b)

**Correct option 2:**

> The instance is only guaranteed to match the schema features the tool actually supports.

Why the others fail:

- constrained decoding cannot enforce semantics the tool ignored or mistranslated;
- numeric bounds are supported by some tools, so success is not impossible;
- structural validity does not guarantee semantic correctness. [L8]

---

## 8. Common exam traps

1. **Container is not execution package.** In the remote workflow, the container builds/analyzes; the tarball contains the files that can run on a target without Docker. The tutorial can run measurements inside the container as a demonstration, but its README says that is usually not recommended for research measurements.
2. **Deployment is not execution.** Step 3 copies/deploys; step 4 runs and produces results.
3. **Raw result is not final paper.** Step 4 produces data; step 5 evaluates and visualizes it.
4. **Docker does not erase hardware.** It controls much of the software environment but shares the host kernel and cannot make different CPUs/storage/GPUs identical.
5. **GitHub is not an archive.** A mutable repository or live clone dependency is weaker than an immutable, checksummed archival release.
6. **DOI is not executability.** A persistent link can point to an incomplete or broken package.
7. **Fork preserves provenance, not eternity.** Archive exact fork revisions and upstream bases.
8. **Patch needs a base.** A timeless-looking diff is useful only with the exact source revision to which it applies.
9. **`doall.sh` is not automatically full Gold.** The whole final analysis, including figures and paper outputs, must be one-command automated.
10. **`.env` does not hide a container environment variable.** It improves source/command hygiene, but `docker inspect` still reveals the injected value.
11. **`.gitignore` is not `.dockerignore`.** One controls Git tracking; the other controls the image build context.
12. **Read-only is not unreadable.** `:ro` blocks writes through the mount; authorized readers still see the key.
13. **A fixed seed is not universal determinism.** Freeze the rest of the model, software, prompt, sampler, call order, and execution stack.
14. **The same seed under a different temperature does not mean the same text.** The draws address a changed distribution.
15. **`temperature=0` course answer comes first.** Under the sheet's local-CPU exclusions, it is deterministic without a seed; add real-world caveats only after stating that answer.
16. **Prompted JSON is not constrained JSON.** A request to obey a schema remains probabilistic.
17. **Grammar validity is not full-schema validity.** The converter may omit semantics.
18. **Schema validity is not semantic truth.** A legal value may be wrong or fail “smallest.”
19. **`anyOf` is not exclusive OR.** It permits one or several matches; `oneOf` requires exactly one.
20. **An empty grammar diff can reveal a bug/limitation.** Repeatable translation is not necessarily faithful translation.

---

## 9. Likely exam questions and model answers

### “Why split build, execution, and analysis?”

Because the measurement target may be special hardware, may not support Docker, and must be measured under its real conditions. A controlled environment reproducibly builds a self-contained package; the target executes that package; raw data return to a controlled environment for reproducible analysis. This separates software construction from hardware-dependent measurement while retaining traceability.

### “What belongs in the execution package?”

Target binaries, data or deterministic generator, exact configuration, dispatcher, validation/evaluation scripts, and enough metadata/documentation to run without target-provided artifacts. Record checksums and target environment details; return raw outputs unchanged.

### “Why is the SQPolite patch useful?”

It isolates and documents the exact adaptation to third-party TPC-H code, can be reviewed and applied automatically, and does not require Git to understand the change. Reproducibility still requires the exact pinned base revision and archived patch.

### “Does `.env` secure an API key?”

It improves local organization and keeps the literal out of a command/Compose source, but Compose injects it as an ordinary environment variable. The plaintext remains in the file and in inspectable container metadata. Ignore the file, protect it, and prefer a mounted/runtime secret where appropriate.

### “How do temperature and seed interact?”

Temperature transforms the token probability distribution; the seed fixes the pseudorandom sequence sampled from it. The same seed and same temperature/setup can replay output. Changing temperature changes the distribution, so the same random sequence may select different tokens. At temperature zero, greedy decoding normally makes the seed irrelevant.

### “What does constrained decoding guarantee?”

It restricts generation to the tokens allowed by a grammar. If that grammar is faithfully derived from the supported parts of the schema, it guarantees conformity to those parts. It does not guarantee unsupported schema semantics, factual correctness, or a semantic objective such as choosing the smallest valid instance.

---

## 10. Final two-minute recall sheet

```text
REMOTE: B-P-D-R-V
  Build controlled artifacts
  Package self-contained experiment
  Deploy/copy to cloud or local target
  Run -> raw results
  Visualize/evaluate back in controlled environment

PACKAGE: B-D-D-E
  Binaries
  Data or deterministic generator
  Dispatcher
  Evaluation scripts

ARROWS
  A -> B  means B integrates A
  A => B  means B is produced by A
  dashed   means temporal flow

LONG TERM
  pin + vendor/archive + checksum + document + license
  GitHub != archive; DOI != proof it works; Docker != hardware identity

SECRETS: E-E-F
  -e ENV: inspect shows value
  .env: still ENV; inspect shows value
  mounted File: inspect shows path/mount, not file value
  .gitignore != .dockerignore

LLM
  Temperature shapes the probability distribution
  Seed repeats pseudorandom draws
  T=0 local CPU (stated exclusions): deterministic; seed not required
  same seed + changed T/model/setup: not necessarily same text

STRUCTURE
  prompt-only schema: no formal guarantee
  constrained decoding: grammar-valid output
  only supported/transformed schema features are guaranteed
  shape != truth; valid != smallest
  anyOf >= 1 matching branch
  oneOf == 1 matching branch
  valid set in lab = {12000, 12001, 12002}; smallest = 12000
  empty oneOf/anyOf grammar diff = converter collapses their semantics

MCQ
  5(a) option 2
  5(b) option 2
```

---

## 11. Closed-book self-test

1. Why might a remote experiment need an execution package even if the authors used Docker to build it?
2. Name actions 1-5 in the remote-workflow figure.
3. What four package components does B-D-D-E represent?
4. What do `->`, `=>`, and the dashed arrow mean in the article's figure?
5. Why is a live `git clone` inside a Dockerfile a long-term risk?
6. What does a fork preserve that a copied final tree may obscure?
7. Does `.env` change where the key is stored inside the container?
8. Which two ignore mechanisms protect against two different leak paths?
9. What information does `docker inspect` reveal for a mounted secret-file approach?
10. What does temperature change? What does seed change?
11. With temperature zero and seeds 1 and 999 on the sheet's local CPU setup, what should happen?
12. Why can the same seed produce different text after temperature changes?
13. Derive the complete valid set for the lab's impossible-first-branch schema.
14. What is the difference between `anyOf` and `oneOf`?
15. Why does the converter produce identical grammar for the sheet's `oneOf` and `anyOf` files, and why is that dangerous?
16. Does constrained decoding guarantee the smallest valid number?
17. State both Lab Exercise 5 correct options.
18. Why does `./doall.sh docker` not by itself prove strict Gold reproducibility?

### Answers

1. The target may not support Docker or must be measured directly; the build container creates a neutral self-contained package for it.
2. Build controlled environment/artifacts; produce package; deploy package; run/produce results; post-process/evaluate/visualize.
3. Binaries, Data/generator, Dispatcher, Evaluation.
4. Integration, production, and temporal order, respectively.
5. The repository/branch/content/network can change or disappear, so the same recipe may no longer retrieve the same source.
6. Upstream history, attribution, and the explicit relationship between upstream and research changes.
7. No. Compose injects it as the same environment variable.
8. `.gitignore` prevents Git tracking; `.dockerignore` excludes it from the Docker build context.
9. The secret-file path/environment variable and mount source/destination, but normally not the file contents.
10. Temperature changes the token distribution; seed initializes/repeats the sampler's pseudorandom draws.
11. Greedy output should be identical; the seed is irrelevant to ordinary temperature-zero decoding.
12. The same random numbers are used against a different probability distribution.
13. `{12000, 12001, 12002}`.
14. At least one matching branch versus exactly one matching branch.
15. The converter implements both as a union; disjoint examples coincide, but overlapping branches require exclusivity that the grammar loses.
16. No. Unless “smallest” is separately encoded/enforced, all three valid numbers remain legal.
17. Option 2 for both: deterministic local CPU at `temperature=0`; only supported schema features are guaranteed.
18. Strict Gold includes all steps through analysis, figures, and final outputs in one command; the README still uses separate R/knitr and LaTeX commands.

---

## 12. Source key and coverage audit

Page references mean PDF page numbers, counting the first PDF page as page 1.

- **IC** - [In-Class Exercise Sheet 10](./10_-_Remoteness/SoSe_2026_RepEng_IC_10___Remote_Experiments.pdf): both remote-workflow diagrams and SQPolite prompt.
- **L** - [Lab Exercise Sheet 10](./Lab_Session_10/Sheet_10.pdf): secrets, local LLM setup, temperature/seed, structured outputs, and multiple choice.
- **W** - [SQLite Walkthrough](./10_-_Remoteness/Material_for_in-class_students_need_not_prepare_this_ahead_of_time/SQLite_Walkthrough.pdf): SQPolite architecture, fork/patch/package design, Gold workflow, PDF generation, and long-term reproducibility. Although the folder says students need not prepare it ahead of class, it is included here at the appropriate priority.
- **NV** - Assigned article, [*Nullius in Verba: Reproducibility for Database Systems Research, Revisited*](https://cdn.lfdr.de/preprints/MaSc21.pdf), DOI [10.1109/ICDE51399.2021.00270](https://doi.org/10.1109/ICDE51399.2021.00270); the local [Stud.IP pointer](./10_-_Remoteness/Article_Nullius_in_Verba_Reproducibility_for_Database_Systems_Research,_Revisited.url) identifies it.
- **SQ** - [SQPolite/ICDE 2021 reference package](https://github.com/lfd/icde2021_tutorial), the public package identified by the local materials, plus its [Stud.IP pointer](./10_-_Remoteness/SQPolite_Reference_Project.url). The archived release is [Zenodo 10.5281/zenodo.4730023](https://doi.org/10.5281/zenodo.4730023).
- **SQLITE** - [SQPolite SQLite fork](https://github.com/lfd/sqlite): implementation of `PLEASE SELECT`, the delay and latency tool, plus the clean `master` and raw `devel_process` histories.
- **LABCODE** - [LabSession10 reference code](https://git.fim.uni-passau.de/koehnen/RepEng/-/tree/master/LabSession10), linked directly from Lab Sheet 10, including the Compose files, `generate.py`, schema scripts, and bundled llama.cpp converter.

Repository-dependent details were audited on 27 July 2026 at tutorial-package commit `22ba1c27ba194feef67c9464c7dce4a04f7d7a3e`, SQPolite clean-history tip `03592f284a310773efb0bd67590b045c48e2f1f1` (development-history tip `7dabf696d07cdc03e024b5366581989b5f323659`), and lab-repository commit `10833f719f2de024914a6d959d0498f4af59beaf`.

Coverage check:

| Supplied Module 10 item | Material integrated into this guide |
|---|---|
| Remote Experiments PDF | Both blank diagrams, arrow legend, all five actions, and the SQPolite walkthrough prompt |
| SQLite Walkthrough PDF | Architecture, fork/patch design, package structure, dispatcher, Gold standard, PDF generation, and long-term risks |
| *Nullius in Verba* article pointer | Two pillars, exact Figure 1 labels/caption, environment-description limits, logical history, and durability |
| SQPolite reference-project pointer | README commands, Dockerfile, patch, paired queries, scripts, archival release, and clean/raw Git histories |
| Lab Sheet 10 PDF | Every secrets task, model setup, all temperature/seed experiments, schema tasks, and both MC questions |

The copy of `Sheet_10.pdf` under the repository's consolidated exercises directory is byte-for-byte identical to the one under `Mod10`, so it adds no separate examinable content.
