# Reproducibility Engineering - Module 2 Exam Guide

## How to use this guide

This is the high-yield version of all four Module 2 PDFs. First memorize the three boxed frameworks below, then learn the explanations and the solved exercise answers. Page references use the source key at the end.

> **The whole module in three lines**
>
> - **DPC:** **D**epth = what is shared; **P**ortability = where it runs; **C**overage = how much can be rerun.
> - **PRE:** **P**rospective provenance = planned recipe; **R**etrospective provenance = actual run; workflow **E**volution = version history.
> - **BSG:** **B**ronze shares artifacts; **S**ilver adds setup, details, and determinism; **G**old adds one-command full automation.

---

## 1. What is a reproducible computational experiment?

An experiment developed at time `t`, on system `s`, with data `d` is reproducible if it can later be executed at time `t'`, on system `s'`, with the same or sufficiently similar data `d'`, and produce **consistent results**. Reproducing an experiment therefore needs more than its final plot. [V3]

### Minimum anatomy

1. **Input data description**
   - **By extension:** provide the actual data.
   - **By intention:** provide a precise procedure/script that obtains or derives the data.
2. **System description:** hardware, operating system, software, libraries, versions, and relevant configuration.
3. **Executable specification:** the ordered computational steps that derive the result.

The key idea is:

```text
inputs + environment + executable process -> result
```

A paper that supplies only prose, tables, or figures shows the result but usually does not preserve the full derivation.

### Three dimensions: Depth, Portability, Coverage

These dimensions are **independent criteria**, not three stages of one ladder. [V4; IC1]

| Dimension | Exam definition | Scale | Diagnostic question |
|---|---|---|---|
| **Depth** | How much of the experiment is made available | Figures only -> scripts and data -> raw/intermediate data -> full setup/protocol -> software and build environment | **What** was shared? |
| **Portability** | The range of environments in which it can be rerun | Original environment -> similar environment -> different environment | **Where** can it run? |
| **Coverage** | The fraction of the experiment that can be reproduced | Partial -> full | **How much** can be rerun? |

#### Depth in increasing order

1. Figures in the manuscript.
2. Figure-generating script or spreadsheet plus the appropriate data.
3. Raw data and intermediate results.
4. Full experimental setup: initialization, scripts, workload, configuration, and measurement protocol.
5. The software as a **white box** (source, configuration, build environment) or **black box** (executable).

#### Portability and terminology

The assigned article defines portability operationally:

- reruns in the **original environment** (the sheet's repeatability end of the progression);
- reruns in a **similar environment**, such as the same OS on another machine (reproducibility);
- reruns in a **different environment**, such as another OS or machine (the sheet's replicability end).

The exercise sheet paraphrases this range with *repeatable, reproducible,* and *replicable*. Those words are defined differently by different communities. In this exam, anchor your answer in **original / similar / different environment** rather than relying only on the labels. [V4; IC1]

#### Coverage example: special hardware

Suppose special hardware generated the raw data and other researchers cannot access it. Sharing the hardware output plus the entire downstream analysis still gives **partial reproducibility**. Data generation is not covered, but the analysis and plot generation are. This is better than making no part reproducible. [V4; IC1]

---

## 2. Workflows and provenance

### Workflows and dataflows

A workflow represents computational steps as **modules** connected by dependencies. Dependencies can be control-driven or data-driven. When they are data-driven, the workflow is a **dataflow**, naturally represented as a directed acyclic graph (**DAG**): nodes are modules and edges carry data between them. [V5]

A **workflow instance** combines this structure with one concrete configuration: its input data and parameter values.

Why workflows help reproducibility:

- The experiment has an explicit, executable structure.
- Repetitive tasks are automated.
- The system can capture provenance transparently.
- A visual interface can make composition understandable to non-programmers.
- Groups of modules can be abstracted to hide irrelevant detail.
- The same workflow can run with different inputs/parameters for parameter sweeps, sensitivity analysis, and side-by-side comparison.

Important limitation: a workflow is **not automatically portable**. Hard-coded paths, absent libraries, OS incompatibilities, changing dependencies, external services, or hardware differences can still prevent execution. [V7]

### The three provenance types

**Provenance** is information about where a result came from and how it was produced. Workflow systems can capture three types. [V6-7; IC1]

| Type | Meaning | Typical contents | Best mnemonic |
|---|---|---|---|
| **Prospective provenance** | The intended experiment specification | Modules, connections, inputs, parameters, workflow structure | **Recipe** |
| **Retrospective provenance** | What actually happened during one execution | Start/end times, machine, executed modules, intermediate dependencies, success/failure, errors | **Run diary** |
| **Workflow evolution provenance** | How the workflow changed over time | All versions, branches, edits, parameter/module changes, relation between versions | **Version tree** |

Exam traps:

- A workflow definition is **prospective**, even before it is executed.
- An execution log is **retrospective**, even if it contains an error.
- Evolution provenance records changes among workflow versions, not merely a list of output files.

### VisTrails: why it matters

VisTrails is a provenance-aware scientific workflow system built for exploratory work, where changing the workflow is normal. It manages computations, data, and provenance together. [V7-10]

High-yield features:

- A **version tree**: each node is a workflow version; each edge is an action or sequence of actions that transforms parent into child.
- Old versions are retained rather than overwritten, so users can branch, undo without losing results, compare versions, and reproduce earlier outputs.
- A workflow editor plus a visual spreadsheet for side-by-side results and parameter sweeps.
- Tags, annotations, authors, timestamps, notes, and searchable metadata.
- Provenance for data products, workflow specifications, and actual executions.
- Execution records with timings, errors, success/failure, and the system used.
- Workflow analogies and completion suggestions that reuse patterns from provenance.

A **vistrail** is the complete bundle of related workflows, the changes that distinguish their versions, and the provenance of their executions. A workflow DAG and a version tree must not be confused: DAG nodes/edges are modules/data dependencies; version-tree nodes/edges are workflow versions/edit actions. [V10-11]

#### Workflow upgrades

Software evolves and old modules become stale. VisTrails compares a workflow's module version with the available version and attempts an upgrade. A compatible interface may be upgraded automatically; complex changes need a developer-provided upgrade path or user intervention. Crucially, the upgrade itself is recorded as evolution provenance and the original workflow is retained. One can therefore compare the old version in a compatible virtual machine with the upgraded version. [V11-12]

#### Data versions and databases

- A filename is not enough because the file may be changed, moved, or deleted. VisTrails records a **content hash** to verify identity and can keep input, output, and intermediate files in a versioned repository. A hash only verifies content; it does **not preserve the file**. The repository supplies preservation and recovery.
- Output data can be strongly linked to the computation that generated it through matching hashes and provenance traces.
- Workflows are normally stateless and deterministic, while databases are **stateful** and change over time. VisTrails addresses this mismatch with temporal database states recorded in provenance, allowing an earlier state to be restored for reproduction. [V12-13]

#### Linking publications to computations

VisTrails can bind a figure to the exact workflow that generated it. Its LaTeX mechanism can recalculate a result and embed a link to the workflow, identified by a tag or unique ID. Readers can inspect, rerun, and modify the computation instead of seeing only a static picture. Similar mechanisms were developed for wikis, web pages, Word, PowerPoint, and the crowdLabs site. [V3-4, V14-16]

An **interactive visualization alone is not enough** if its underlying computation cannot be inspected or executed. Download/execute/modify access is preferable. crowdLabs reduces local setup through server-side execution, lets mashup users change parameters without local VisTrails installation, and supports comments. Retrospective dependency traces can also flag every result derived from a faulty input, such as a malfunctioning sensor. [V11, V14-16]

#### Limits and related tools - lower priority

End-to-end, long-term reproducibility can still fail because of specialized hardware, proprietary data, changing hardware/software, the work needed to wrap an existing experiment as a workflow, or interactive tools that cannot be wrapped cleanly. The transferable lesson is the provenance design, not dependence on one permanent tool. [V16-17]

Know the related-tool names only at recognition level:

- **Madagascar:** reproducible geophysics documents using SCons and LaTeX.
- **Sweave:** embeds R code in LaTeX to create dynamic reports.
- **ReproZip:** captures an existing experiment and packages what is needed to rerun it elsewhere; it also derives a workflow specification.
- **SOLE / Collage / SHARE:** respectively link scientific objects to papers, create executable papers, and share citable remote virtual machines.
- **VCR/VRI:** a Verifiable Result Identifier links a result to a repository containing both the result and its computational process. [V16-17]

#### Current maintenance status

**Time-stamped answer (27 July 2026): yes, with a qualification.** The original Python/PyQt implementation is legacy and had a hiatus, but the official project site says VisTrails is actively developed again as **VisTrailsJL**, a Julia reimplementation. The best conclusion is that the provenance ideas remain valuable, while the tool's own history demonstrates why software evolution is a threat to long-term reproducibility. See the [official VisTrails page](https://www.vistrails.org/index.php/Main_Page) and [VisTrailsJL repository](https://github.com/VIDA-NYU/VisTrailsJL). [IC1]

---

## 3. Bronze, Silver, and Gold reproducibility

Heil et al. define **computational reproducibility** as a third party obtaining the same results with the authors' published **data, trained models, and code**. The purpose is trust: outsiders can check accuracy, inspect implementation, and find biases or artifacts the original authors did not know about. [H1]

Reproducibility is a continuum measured by the time/effort needed to reproduce:

```text
"forever" / effectively impossible ---- Bronze ---- Silver ---- Gold ---- approximately zero effort
```

### The table to memorize exactly

The standards are **cumulative**: Gold includes Silver and Bronze; Silver includes Bronze. [H1; IC2]

| Requirement | Bronze | Silver | Gold |
|---|:---:|:---:|:---:|
| Data published and downloadable | ✓ | ✓ | ✓ |
| Trained models published and downloadable | ✓ | ✓ | ✓ |
| Source code published and downloadable | ✓ | ✓ | ✓ |
| Dependencies set up with one command |  | ✓ | ✓ |
| Key analysis details recorded |  | ✓ | ✓ |
| Random components made deterministic |  | ✓ | ✓ |
| Entire analysis reproducible with one command |  |  | ✓ |

Fast memory formula:

```text
Bronze = 3 artifacts
Silver = Bronze + 3 controls
Gold   = Silver + 1 complete command
```

### Why reporting is not enough

Reporting hyperparameters, architecture, data splitting, and known limitations resembles a **nutrition label**: it summarizes what the authors know, but it does not expose the complete executable process. Without data, model, and code, outsiders cannot rerun the analysis, reconstruct omitted implementation choices, or discover unknown bias after publication. [H1-2; IC2]

### Bronze = minimum artifact availability

#### 1. Data

- Publish the **raw form** of every dataset when the work first appears as a preprint or publication.
- Prefer a specialist repository, such as GEO for gene expression or BioImage Archive for microscopy.
- If no specialist repository exists, the article's stated rule is **Zenodo up to and including 50 GB; Dryad above 50 GB**.
- For an existing external dataset, provide the information and code needed to download and preprocess it.

#### 2. Trained models

- Publish the trained weights actually used to generate the reported results.
- Publishing every additional set of trained weights from a hyperparameter sweep is unnecessary if the reported result can be reproduced without it; those extra models may still have participated in tuning or model selection.
- Prefer a specialist model zoo; otherwise use an archival repository such as Zenodo.
- Models matter even when code exists: retraining costs time/compute, may be nondeterministic, and does not necessarily recover the model whose fairness, generalization, or learned artifacts must be examined.

#### 3. Source code

Code is often a more exact methods description than prose. It must cover data processing, model training, tuning, testing, figure generation, and final-result generation. A computational paper without code deserves skepticism similar to a paper without a methods section. [H2]

**Why GitHub plus Zenodo?** GitHub supports active development, collaboration, reuse, and Issues; Zenodo supplies a persistent, citable, archived snapshot. GitHub alone is mutable and is not the archival record required by the article. [H2; IC2]

### Silver = Bronze plus reproducible setup and control

Silver adds three requirements. [H2-3]

1. **One-command dependency setup.** Record dependency versions with tools such as Conda/Packrat or a suitable environment file. Guessing old versions is the paper's "package Battleship" problem.
2. **Key details documented.** Record execution order and instructions, OS version, wall-clock and CPU time, CPU/GPU models and counts, and CPU/GPU RAM. Order may be expressed in a README, numbered filenames, or an orchestration script. The paper requires OS, runtime, and resource details in **both the manuscript body and README**.
3. **Random components deterministic.** Seed pseudorandom generators and use deterministic framework modes where available.

Do not confuse the commands:

- **Silver:** dependencies are installed with one command.
- **Gold:** the entire analysis is reproduced with one command.

#### Containers help, but do not prove identity

Containers capture more of the software environment than a package list, but they do not fully isolate the computation from hardware. Different GPUs or drivers may yield different results, and some parallel operations remain nondeterministic. Containers can also preserve brittle old code. The article recommends that containerized code still work on a current version of at least one OS distribution. [H2-3]

### Gold = Silver plus full automation

One command must automate the **whole path**: data download, preprocessing, training, tables, figure generation, figure annotation, and final outputs. Merely running one selected script is not Gold. [H3]

Snakemake and Nextflow are examples of workflow managers. A shell script may start the pipeline, but workflow systems also help restart after errors, parallelize tasks, and show progress.

### Important caveats

#### Privacy-restricted data

- Put sensitive data in a journal-approved controlled-access repository; do not hide behind informal "available upon request."
- Models can leak training data, so researchers with privacy-constrained data should routinely use privacy-preserving training such as differential privacy; **Opacus** is the article's example library.
- If data cannot be public, the authors say the trained model **must be shared** to retain any hope of computational reproducibility. If neither data nor model is available, the code has little with which to operate.
- A model-only release helps but is **not full reproducibility**. [H3]

#### Compute-intensive analyses

If a full rerun is infeasible, publish intermediate outputs so reviewers can verify downstream stages. A workflow manager can track them. A lightweight demo - for example, a small web app or Colab notebook using a pretrained model - can support inspection. This increases **partial coverage** but is not a Gold-level full rerun. [H3-4; IC3]

#### Reusable software packages

Bronze/Silver/Gold primarily describe analyses. Reusable libraries need additional quality practices: unit tests, style consistency, clear documentation, and compatibility across major operating systems. [H4]

### Incentives

- **Journals:** make Bronze the minimum publication standard, optionally require Silver/Gold for all or analysis-focused papers, and verify compliance through reviewers or a dedicated reproducibility reviewer.
- **Badging:** an independent body verifies the achieved standard and awards a visible badge for papers, CVs, or biosketches. The career/reputation signal encourages authors to invest in reproducibility. Exam nuance: the badge verifies a reproducibility level; do not infer unrelated properties without evidence.
- **Reproducibility collaborator:** a person outside the primary authors' group reproduces the work using only the published artifacts and documentation. This is the CRediT **validation** role, and the collaborator should not have designed or implemented the original analysis. [H3]

The incentive argument is temporal: irreproducible practices may save the original authors effort now but create more work later for both them and future researchers. Rewarding reproducibility prevents that cost shifting. Pure computation should also be easier to repeat than wet-lab work, which adds variability from reagents, cell lines, and environmental conditions. [H4]

---

## 4. Lab knowledge: randomness, automation, and Docker

### Unix stream mechanics

The lab scripts separate data generation from analysis:

```bash
cat water.txt | python3 pplease.py
python3 pplease.py < water.txt > water_polite.txt
./pplease_stats.py water.txt water_polite.txt
```

- `stdin`: the program's input stream.
- `stdout`: the program's normal output stream.
- `|`: sends one command's stdout to the next command's stdin.
- `< file`: takes stdin from a file.
- `> file`: writes stdout to a file, replacing its contents.
- `./script`: runs an executable file from the current directory.

`pplease.py` independently adds `", please"` before a sentence's punctuation with probability `0.5`. `pplease_stats.py` compares original and generated sentences using minimum, maximum, and median character length, counting spaces and punctuation. [L1-2]

When an even number of sentence lengths is present, the median is the mean of the two middle values. Exact sample values depend on the sentence-boundary/tokenization rule expected by the course skeleton and tests, especially around newlines; do not silently substitute a different tokenizer. Running `./pplease_stats.py` directly also requires an appropriate shebang and executable permission; otherwise invoke it through `python3`. The sheet writes `python` in examples, but an Ubuntu 24.04 image that installs only `python3` must use `python3` consistently (or deliberately install an alias).

### Making randomness repeatable

A pseudorandom generator is deterministic once its initial **seed** is fixed. To make the experiment repeatable:

1. Set or accept a known seed once, before the first random draw; do not reseed for each sentence.
2. Record the seed. Preserve the supplied no-argument stdin/stdout interface: use a documented fixed/default seed, or make any seed option optional with a deterministic default.
3. Keep the input, code, generator/algorithm, dependency versions, and order/number of random calls fixed.
4. Run the generator and analysis through one script and compare every run with the first baseline.

Conceptual Python pattern:

```python
rng = random.Random(seed)
if rng.random() < 0.5:
    # append ", please" before the punctuation
```

Expected test logic: run 1 establishes the baseline; runs 2 through `n` must be identical. A fixed seed controls the Python experiment, but in ML, seeded code can still encounter nondeterministic GPU/framework operations. [L2-3; H3]

```bash
git pull
./run_experiment.sh recipe.txt 10
# Windows PowerShell equivalent:
./run_experiment.ps1 recipe.txt 10
```

The runner takes exactly two arguments - the input path and number of runs - and expects `pplease.py` and `pplease_stats.py` in the same directory.

### Reproducibility package checklist

The lab's Docker image should contain the input, generator, analysis script, experiment runner, runtime, metadata, and default command. [L4-5]

```Dockerfile
# Builds a reproducible package for the polite-text analysis
# Copyright 2026, Your Name
# SPDX-License-Identifier: MIT
FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="you@example.com"

RUN apt-get update && apt-get install -y \
    python3

WORKDIR /app

COPY recipe.txt pplease.py pplease_stats.py run_experiment.sh /app/

RUN chmod +x /app/run_experiment.sh && \
    sed -i 's/\r$//' /app/run_experiment.sh

CMD ["/app/run_experiment.sh", "recipe.txt", "10"]
```

Instruction meanings:

| Instruction | Meaning |
|---|---|
| `FROM` | Select the base image |
| `LABEL` | Add image metadata |
| `RUN` | Execute a command while building an image layer |
| `WORKDIR` | Set the working directory for later instructions/runtime |
| `COPY` | Copy files from the build context into the image |
| `CMD` | Supply the default command and arguments when a container starts |

`chmod +x` makes the runner executable. `sed -i 's/\r$//'` removes Windows carriage returns (CRLF line endings) so the shell script runs correctly on Linux.

Checklist to memorize:

- First one or two lines state the package's purpose.
- State copyright ownership.
- State the license with an SPDX identifier.
- Use a recent Ubuntu **LTS**, not `ubuntu:latest`.
- Use `LABEL org.opencontainers.image.authors=<email>` for the maintainer.
- Sort installed package names alphabetically.
- Remove dead code, including commented-out Docker instructions.
- Optional but stronger: pin exact dependency versions; for still stronger image identity, pin the base image by digest and preserve lock files.
- `docker run --rm image` removes the stopped container after execution; it does not remove the image.

Build and run:

```bash
docker build -t repeng_lab2 .
docker run --rm repeng_lab2
```

Even a corrected Dockerfile does **not guarantee the exact same rebuilt image years later**: mutable tags, changing package repositories, unpinned versions, and disappearing artifacts can change the build. Separately, even the same image may not guarantee the exact same **runtime result** when CPU/GPU/driver differences or nondeterministic operations matter.

### Dockerfile review answer key

1. **Line 4** violates the checklist: `ubuntu:latest` is not a specified recent LTS base.
2. **Line 6** violates it: a maintainer comment is not the required OCI authors `LABEL`.
3. Remove **line 20**: the commented-out `chmod` instruction is dead code.
4. **Yes**, violations remain: the installed packages are not alphabetically sorted. The correct order is `curl`, `git`, `python3`, `python3-pip`.
5. **No**, even after required fixes, exact long-term image identity is not guaranteed because the base contents and package versions are not fully pinned. [L6]

`COPY . /app` is broad and often undesirable, but it is **not** the violation targeted by this exercise's explicit checklist. `WORKDIR /app` is correct.

---

## 5. Solved in-class exercise answers

### Exercise 1: VisTrails

- **1(a):** depth; level of portability; coverage; the example gives **partial reproducibility**.
- **1(b):** prospective provenance; retrospective provenance; workflow evolution.
- **1(c):** as of 27 July 2026, **yes via VisTrailsJL**, while original Python VisTrails is legacy. The implementation changed, reinforcing the need to preserve provenance and upgrade paths.

### Exercise 2: Heil et al.

- **2(a) blank:** **trusted**. Motivation: machine-learning models can be opaque and hide bias; trust requires outsiders to reproduce and inspect them.
- **2(b) table:** memorize the seven-row Bronze/Silver/Gold table above.
- **2(c):** reporting exposes only known details/limitations and supplies no executable artifacts for rerunning or discovering unknown bias.
- **2(d):** **Zenodo** for up to 50 GB; **Dryad** for more than 50 GB, according to the assigned 2021 article.
- **2(e):** GitHub supports live development; Zenodo gives a persistent scholarly archive.
- **2(f):** containers do not isolate hardware; different GPUs/drivers and nondeterministic GPU operations can prevent bit-for-bit equality.
- **2(g):** verified reproducibility badges make the effort visible to journals, funders, hiring, and promotion committees, creating a career/reputation incentive.
- **2(h):** publish intermediate outputs and, if helpful, a lightweight demo so final stages/model behavior can be checked without the full expensive rerun.

### Exercise 3: describing methods and results

| Item | Answer | Completed collocation |
|---|---|---|
| (a) | **following** | prepared following Jude [2012] |
| (b) | **using** | using the same procedure |
| (c) | **selecting** | criteria for selecting subjects |
| (d) | **reducing** | by reducing the amount |
| (e) | **speaking** | generally speaking |
| (f) | **resulting** | the resulting solution |
| (g) | **taking** | taking advantage of |
| (h) | **subtracting** | subtracting the first from the second |
| (i) | **having** | having these features meant ... |

Remember: subtracting the first result **from** the second means `second - first`. [IC3-4]

### Exercise 4: highlighting drawbacks

| Item | Answer | Collocation |
|---|---|---|
| (a) | **shortcomings** | shortcomings of a method |
| (b) | **weakness** | a weakness with an argument |
| (c) | **appropriate** | appropriate for patients |
| (d) | **flawed** | experiments flawed by a fact/problem |
| (e) | **drawback** | a drawback to experiments |
| (f) | **misleading** | a misleading assumption |
| (g) | **speculative** | speculative claims |
| (h) | **conjectures** | findings are conjectures |
| (i) | **complicated** | unnecessarily complicated |
| (j) | **concern** | a source of concern |

---

## 6. Exam traps and scenario classification

### Frequent traps

- **Depth is not coverage:** sharing detailed information about only the analysis can be high depth for that part but still partial coverage overall.
- **Workflow is not provenance:** the planned workflow is prospective provenance; actual executions and changes require other provenance types.
- **Reporting is not reproducibility:** a perfect description without executable artifacts is insufficient.
- **The standards are cumulative:** missing a Bronze artifact means the work cannot be Silver or Gold.
- **One command has two meanings:** dependency installation is Silver; full analysis execution is Gold.
- **GitHub is not the archive:** pair active development with an archival snapshot.
- **A seed is necessary but not universally sufficient:** hardware/framework nondeterminism can remain.
- **A container is not a time machine:** it improves environment capture but does not guarantee bitwise identity or long-term availability.
- **Partial reproduction is still valuable:** special hardware or huge compute may make full coverage unrealistic.
- **A badge verifies the achieved reproducibility level; do not automatically treat it as evidence for unrelated scientific properties.**

### Practice classifications

1. **Data, trained model, and code are archived, but setup is manual.**  
   **Bronze.**

2. **Bronze artifacts plus one-command dependencies, all required execution/OS/time/resource details in the manuscript and README, and fixed randomness; several commands still run the analysis.**  
   **Silver, not Gold.**

3. **A single command runs everything, but the trained model is only in a mutable GitHub repository and not archived.**  
   It fails **Bronze**, so it cannot be Gold.

4. **The original machine can rerun every stage, but another OS cannot.**  
   Full **coverage**, potentially high **depth**, but low **portability**.

5. **Special equipment cannot be repeated, but raw output and every analysis step are archived.**  
   **Partial coverage** with useful downstream reproducibility.

6. **A log states that module B failed after 18 seconds on a named machine.**  
   **Retrospective provenance.**

7. **A DAG specifies modules A -> B -> C and their parameters.**  
   **Prospective provenance.**

8. **A tree records that one workflow branch changed a filter and another changed a plotting module.**  
   **Workflow evolution provenance.**

---

## 7. Final 2-minute recall sheet

```text
REPRODUCIBLE EXPERIMENT
  data (actual or derivation) + system + executable steps -> consistent result

DPC
  Depth       = how much material is available
  Portability = original / similar / different environment
  Coverage    = partial / full experiment

PRE PROVENANCE
  Prospective = intended recipe
  Retrospective = actual execution
  Evolution   = workflow versions and changes

BSG
  Bronze = data + trained model + code
  Silver = Bronze + one-command deps + key details + deterministic components
  Gold   = Silver + entire analysis in one command

PRACTICAL
  seed + record it + freeze inputs/code/environment/call order
  archive artifacts + manage versions + automate pipeline
  container helps, but hardware/drivers and mutable dependencies still matter

NUMBERS
  3 reproducibility dimensions
  3 provenance types
  7 Bronze/Silver/Gold requirements
  Zenodo <= 50 GB; Dryad > 50 GB (assigned 2021 article)
```

## Source key

- **V** - [Reproducibility Using VisTrails](2-Levels_of_reproducibility_and_provenance/VisTrails.pdf), cited by PDF page.
- **H** - [Reproducibility standards for machine learning in the life sciences](2-Levels_of_reproducibility_and_provenance/reproducibility_life_sciences.pdf), cited by PDF page.
- **IC** - [In-Class Exercise Sheet 2](2-Levels_of_reproducibility_and_provenance/SoSe_2026_RepEng_IC_2___Levels_and_Provenance.pdf), cited by PDF page.
- **L** - [Lab Exercise Sheet 2](Lab_Session_2/Sheet_2.pdf), cited by PDF page.
