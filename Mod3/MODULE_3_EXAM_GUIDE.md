# Reproducibility Engineering - Module 3 Exam Guide

> High-yield guide with complete coverage of both local Module 3 sheets and an exam-focused, sourced summary of Zobel's assigned chapter on hypotheses, questions, and evidence. It includes the expected worksheet answers, reasoning for variants, and a final rapid-recall sheet.

## How to use this guide

If time is short, use this order:

1. Memorize **Section 1** and the compact frameworks: **PSUL**, **B-MEDS**, **PMSE**, and the dependency rule.
2. Learn the exact in-class answers in **Section 8** and the dependency-management answers in **Section 9**.
3. Understand equivalence and the runtime example in **Sections 5-6**; these are easy places to lose marks through overclaiming.
4. Read the lab workflow in **Section 7**, especially the four arguments, exact result path, CSV layout, Docker `CMD`, and source-versus-binary distinction.
5. Close the file and complete the self-test in **Section 12**. Re-read only what you miss.

Study priority: memorize Sections 1, 8, 9, and 11; understand the transferable reasoning in Sections 2-7; treat the explicitly labeled real-world nuances and variants as recognition-level material.

---

## 1. The whole module in 90 seconds

PSUL, B-MEDS, PMSE, and the dependency rule are guide-created memory aids, not terminology used by Zobel or the exercise sheets.

### 1.1 A good hypothesis: PSUL + B-MEDS

**PSUL** describes its quality:

```text
P  Precise
S  Specific
U  Unambiguous
L  Limited in scope, with limitations made clear
```

**B-MEDS** describes what an experimental hypothesis should identify:

```text
B  Baseline or comparator
M  Metric
E  Expected direction or effect size
D  Data, workload, or population
S  Scope and operating conditions
```

Full-mark construction pattern:

```text
Under [conditions], [method A] will [increase/decrease] [metric]
by [magnitude or threshold] relative to [baseline B] on [data/workload].
```

Example:

```text
Under high contention on TPC-C, system A will reduce mean query
latency by at least 20% relative to baseline B.
```

Avoid undefined or unqualified uses of words such as `better`, `improves performance`, `most`, `realistic`, `easy`, and `fast`.

### 1.2 The research logic

```text
topic/problem
  -> informal model or tentative hypothesis
  <-> specific research question
  -> observable prediction
  -> evidence/measurement
  -> argument linking evidence to the hypothesis
  -> support, refinement, or rejection
```

Evidence does not interpret itself. A result earns its meaning from the **connecting argument**.

### 1.3 Four forms of evidence: PMSE

| Form | Core idea | Main risk |
|---|---|---|
| **Proof** | Formally establishes a proposition; a disproof/counterexample establishes falsity | A proof can contain an error; real-world claims may resist formalization |
| **Model** | Mathematical description of the hypothesis/system | Simplifying assumptions may make it unrealistic |
| **Simulation** | Simplified/partial implementation, often with artificial data | Controlled and flexible, but may not transfer to reality |
| **Experiment** | Full test using an implementation and real or highly realistic data | Strong practical evidence, but directly covers only tested cases |

Do not call a program that merely evaluates a mathematical model an experiment on the real algorithm.

### 1.4 Occam's razor

If two hypotheses explain the observations **equally well**, prefer the simpler one. Simplicity is a tie-breaker, not a reason to ignore stronger evidence for a more complex hypothesis.

### 1.5 Experiment-section classifier

| Part | Diagnostic question | Typical content |
|---|---|---|
| **Setup** | What was tested, against what, and how? | Data, workload, baselines, metrics, hardware, procedure |
| **Result** | What was directly observed? | Numbers, comparisons, table/figure findings |
| **Discussion** | What might it mean and why? | Interpretation, possible causes, implications, limitations |

Signal words: `we evaluate` and `we measure` usually indicate **setup**; `X%` and `Figure shows` usually indicate **result**; `suggests` and `possibly because` usually indicate **discussion**.

### 1.6 Four comparison levels

| Object | Level | Definition |
|---|---|---|
| Data/output | **Bitwise identity** | Same representation, byte for byte |
| Data/output | **Structural equivalence** | Same logical content despite order/format differences |
| Programs | **Functional equivalence** | Same outputs for the same inputs |
| Programs | **Behavioral equivalence** | Same observable behavior under a stated observation model, possibly including I/O, timing, and side effects |

Same output does not imply same timing or side effects. Tests over a finite input set do not prove equivalence over every possible input.

### 1.7 Lab 3 in six lines

```text
Dispatcher arguments: input, runs, seed, label
Example: ./run_experiment.sh recipe.txt 10 42 exp1
Directory: results/recipe_runs_10_seed_42_exp1/
CSV header: run,original,polite
Docker default: recipe.txt, 10 runs, seed 42, label docker
doAll.sh: recipe.txt, 100 runs, seed 42, label doAll
```

Dependency multiple-choice rule:

```text
Ubuntu changes -> Source container may fail
Python changes -> Source container may fail
External API offline -> Both binary and source may fail
```

Why: a saved binary image freezes packaged layers, but it does not package a live external service.

---

## 2. Hypotheses, questions, predictions, and evidence

### 2.1 What a hypothesis does

A hypothesis is a clear, testable statement about how something behaves, interacts, or works. It converts a broad topic into a claim that determines: [Z: Hypotheses]

- what should be observed if the claim is right;
- what evidence should be collected;
- what could count against the claim;
- what measurements and conditions are required.

A **research question** asks what the study will determine. A **hypothesis** predicts or asserts an answer. A **prediction** states an observable consequence. **Evidence** is what is collected. An **argument** explains why that evidence supports or challenges the hypothesis.

Example chain:

```text
Topic: CPU-cache-aware data structures
Question: Can an array-based structure improve a sorting method?
Hypothesis: Better locality outweighs the extra computation for large inputs.
Prediction: As input size grows, the tree version's cache-miss rate rises faster.
Evidence: Cache misses and execution time across controlled input sizes.
Argument: Higher miss rates explain the measured latency difference.
```

Ideas may begin with subjective intuition. The final paper must make an objective case with explicit claims, measurements, and reasoning.

### 2.2 Properties of a strong hypothesis

**Must memorize: PSUL.** A strong hypothesis is precise, specific, unambiguous, and limited in scope.

It should also be:

- **testable:** an observation, derivation, proof, or experiment can evaluate the claim;
- **falsifiable:** at least one possible observation could show it is wrong;
- **operationalized:** concepts such as quality or performance are mapped to defined measures;
- **predictive:** it says more than "the method worked on the data already seen";
- **interesting:** it teaches something beyond a single black-box result;
- **explicit about assumptions and exclusions:** readers can tell what is and is not claimed.

Limitations do not automatically weaken a result. A truthful boundary often makes a claim stronger because it prevents overgeneralization.

Compare:

```text
Too broad:
Q-lists are superior to P-lists.

Scoped and testable:
For large in-memory data sets with a skewed access pattern, Q-lists
use less space and answer searches faster than P-lists.
```

The second claim can remain valid even if P-lists win under a different access pattern.

### 2.3 Diagnose and repair a vague hypothesis

Use five questions:

1. **Compared with what?** Name the baseline.
2. **What changes?** Name the dependent metric.
3. **By how much or in which direction?** State an effect or threshold.
4. **On what?** Name the data, workload, or population.
5. **Under which conditions?** Bound the scope.

| Claim | Diagnosis | Repair |
|---|---|---|
| `Our system improves database performance.` | `improves` and `performance` are undefined; no baseline, metric, amount, workload, or conditions | Name latency/throughput, comparator, threshold, workload, and operating condition |
| `Our system reduces average query latency by at least 20% on TPC-C workloads under high contention.` | Intended good example: metric, direction, threshold, workload, and condition are explicit | For a flawless answer, explicitly add the baseline |
| `Our system improves performance in most realistic scenarios.` | `performance`, `most`, `realistic`, and `scenarios` are undefined | Define the population of scenarios and every success criterion |

TPC-C is a standard benchmark for online transaction processing (**OLTP**) systems. [IC2]

### 2.4 Falsifiability, prediction, and fair testing

A claim is scientifically useful only if some result could count against it. Repeated positive evidence can strengthen confidence, but it does not permanently prove a general empirical theory.

Important distinction:

```text
Observation after looking at the data:
  "The algorithm worked on our data."

Predictive test:
  "We predicted it would work for data of class C, then tested that
   prediction on fresh data from C."
```

The second is stronger. If the hypothesis and experiment are repeatedly tuned on the same data, that data is development evidence, not an independent confirmation. Prefer a fresh or blind test.

Zobel notes that hypotheses may need refinement after initial testing. [Z: Hypotheses] As stronger confirmatory practice, disclose the refinement and test the revised claim on fresh evidence. Do not present hindsight as an advance prediction.

### 2.5 Occam's razor and the equal-fit condition

**Expected blank:** **Occam's razor** or **principle of parsimony**. [IC2]

Correct application:

```text
H1 and H2 fit the observations equally well.
H1 is clearly simpler.
Therefore prefer H1.
```

Incorrect application:

```text
H1 is simpler, but H2 explains substantially more evidence.
Choose H1 anyway.
```

Occam's razor does not override evidence.

### 2.6 Defending a hypothesis

A paper needs three distinct elements:

```text
hypothesis + evidence + connecting argument
```

Evidence without a connecting argument is just an observation. The argument must explain why the measured outcome bears on the claim and why plausible alternatives are less convincing.

Defend the claim as a skeptical reader would:

- What phenomenon or property is being investigated, and why is it interesting?
- What is the research aim, and are the aim, hypothesis, and question convincingly connected?
- Do the stated claims accurately reflect the actual innovation?
- What result would disprove it?
- Which assumptions does it rely on, and are they plausible?
- Could another mechanism explain the same observation?
- Does the claim have improbable consequences?
- Does it cover the observations explained by the current theory?
- Is the contribution really new, or merely renamed existing work?
- Were counterexamples and extreme conditions actively sought?
- Are the data representative and sufficient?
- As a cross-module reproducibility extension: is the code/artifact quality good enough for inspection?
- Which objections cannot be rebutted and must instead be conceded as limitations?

The stronger your personal attachment to a hypothesis, the more aggressively you should try to break it. Do not twist results to preserve a favored idea. [Z: Defending Hypotheses]

### 2.7 Black-box and renaming traps

A black-box system beating one baseline on one dataset may be an observation without a useful general explanation. Ask whether the study reveals anything about:

- why the method works;
- when it stops working;
- whether the behavior predicts performance on new data;
- which properties of the data or method cause the result.

Changing terminology does not create novelty. Calling an ordinary cache a fashionable new kind of agent does not change its behavior. Inflated labels such as `intelligent`, `aware`, or `semantic` require operational definitions rather than rhetorical force.

---

## 3. Evidence and measurement

### 3.1 The four forms of evidence in depth

Zobel distinguishes proof, model, simulation, and experiment. [Z: Forms of Evidence]

#### Proof

A proof formally establishes a proposition; a disproof or counterexample establishes that a proposition is false.

- Strong for mathematical claims.
- Can generalize beyond individual test cases.
- May still contain a mistake.
- May not capture human behavior, complex systems, hardware effects, or other real-world factors.
- Asymptotic analysis alone may omit constants, locality, or actual workloads.

#### Model

A model is a mathematical description of a system, hypothesis, or component.

- Makes assumptions explicit and supports reasoning or prediction.
- Can explore behavior beyond a few measured cases.
- Needs an argument that the model corresponds to the real object.
- Too many estimated parameters or simplifying assumptions can destroy realism.

#### Simulation

A simulation implements a simplified or partial version of the hypothesis, often with artificial data.

- Parameters can be controlled smoothly across a wide range.
- Extreme and failure conditions can be explored safely.
- Artificial data may make causal factors easier to isolate than real data.
- The result may be an artifact of unrealistic simplifications.
- Practical claims eventually need comparison with reality.

#### Experiment

An experiment tests an implemented proposal on real or highly realistic data.

- Offers strong practical evidence.
- Should be driven by predictions rather than merely used to find a favorable story.
- Should include severe tests and conditions likely to reveal failure.
- Directly demonstrates behavior only for the tested data and context.
- Models or simulations may help explain or generalize the observation.

### 3.2 Combine evidence, but do not confuse it

Different evidence types can support one another. For example, an experiment may confirm a trend predicted by a model, while a simulation explores boundary cases that are difficult to create physically.

However:

```text
Implementing a mathematical performance model and printing its predicted
values tests the implementation/model calculations. It is not automatically
an experiment on the real algorithm or system.
```

Choose evidence for how convincingly it addresses the claim, not merely because it is easiest to produce. [Z: Use of Evidence]

### 3.3 Measurement: phenomenon versus proxy

The phenomenon is the underlying property of interest. A measurement is a context-dependent observation used as evidence for it.

Research aims are often qualitative:

- improve an interface;
- accelerate an algorithm;
- improve translations;
- make a network service better.

Evaluation usually needs quantitative proxies:

- task completion time;
- execution latency;
- textual-overlap score;
- packet delay.

The critical question is whether the proxy is logically connected to the aim. Text overlap, for example, can be high even when a translation is incoherent. Lower average packet delay may ignore video smoothness or service to remote users.

Measurement checklist:

1. What underlying phenomenon matters?
2. What exactly will be measured?
3. How will it be measured?
4. Is the measure objective, appropriate, and reasonable?
5. What simplifications or biases does it introduce?
6. Is one metric enough, or are several complementary metrics needed?
7. Are the data/workloads representative?
8. Could optimizing the score make the real outcome worse?

Beware of tuning a method repeatedly to one static benchmark. Performance on the benchmark can become the goal even when it no longer represents the broader problem. [Z: Approaches to Measurement]

### 3.4 Confirmation, falsification, and experimental failure

| Concept | Correct interpretation |
|---|---|
| **Falsification** | A counterexample can refute a universal claim; therefore search seriously for counterevidence |
| **Confirmation** | Evidence increases confidence; it does not mean final proof of an empirical theory |
| **Failed experiment** | May challenge the hypothesis, but may also expose a faulty auxiliary assumption, insensitive instrument, bad implementation, or poor measurement |

Do not automatically protect a hypothesis after every failure, but do not automatically discard it before checking the experiment. Theory and evidence refine one another iteratively. [Z: Reflections on Research]

### 3.5 Warning signs of weak science

- Vague or inflated terminology substitutes for a definition.
- A proposal has no serious evaluation or measurable consequence.
- The problem, solution, and success measure are all invented together without external justification.
- Only favorable results are reported.
- Implausible claims are accepted without checking quantitative limits.
- The work ignores relevant prior results or merely renames an existing idea.
- Results are internally inconsistent or not predictive.
- Authors argue for belief instead of seeking critical evidence.
- The system is always almost ready for demonstration but never testable.

Good reporting includes failures, limitations, uncertainty, and unresolved objections. [Z: Good and Bad Science]

---

## 4. Presenting experiments: setup, result, discussion

[IC2-3]

### 4.1 What belongs in each part

#### Setup

- research question/hypothesis;
- datasets and collection method;
- workload and input selection;
- baselines/comparators;
- independent and dependent variables;
- metrics;
- hardware/software/environment;
- procedure, repetitions, seeds, and controls.

#### Results

- observed measurements;
- direct comparisons;
- tables and figures;
- uncertainty/variability;
- positive, null, and negative outcomes.

#### Discussion

- interpretation and possible mechanisms;
- implications for the hypothesis;
- alternative explanations;
- limitations and threats to validity;
- why the result matters;
- what should be tested next.

Do not hide an inference inside a results sentence as if it were an observation. Also do not leave a figure unexplained: state what pattern it shows and why that pattern matters.

### 4.2 Coffee-recommender classification

| Sentence summary | Part | Reason |
|---|---|---|
| Data from five cafes; comparison against two baselines | **Setup** | Defines data and comparators |
| Search time fell by 23% versus popularity baseline | **Result** | Reports a measurement |
| Personalization seems especially useful for strong dietary preferences | **Discussion** | Interprets the result |
| Quality measured with click-through rate and normalized discounted cumulative gain (NDCG) | **Setup** | Defines metrics |
| Gains are smaller late in the day, possibly because availability drops | **Discussion** | Offers a possible explanation |
| Figure 3 shows the method stays faster as user count grows | **Result** | Reports the pattern shown by a figure |

### 4.3 True/false answers about experiment sections

| Statement | Answer |
|---|---|
| Separate setup, results, and interpretation | **True** |
| Setup should explain datasets, baselines, and metrics | **True** |
| Explain what a figure shows and why it matters | **True** |
| State limitations clearly | **True** |
| Present only positive outcomes | **False** |

---

## 5. Levels of equivalence

[IC3-4]

### 5.1 Definitions and boundaries

| Level | Applies mainly to | Required sameness | What may differ |
|---|---|---|---|
| **Bitwise identity** | Files/data/output | Exact byte representation | Nothing at the byte level |
| **Structural equivalence** | Files/data/output | Logical content/structure | Ordering or formatting, where those are semantically irrelevant |
| **Functional equivalence** | Programs/functions | Output for each input in the stated domain | Language, implementation, speed, I/O pattern, side effects |
| **Behavioral equivalence** | Programs/systems | All behavior visible under the chosen observation model | Only behavior excluded by that model |

Behavioral equivalence is meaningful only after the observation model is stated. If the model observes outputs, timing, I/O, and side effects, it demands more than functional equivalence.

### 5.2 Expected worksheet classifications

The worksheet asks for the **strongest** level justified by the stated evidence.

| Scenario | Expected answer | Why |
|---|---|---|
| Two JPEG files have identical MD5 hashes | **Bitwise identity** | This is the explicit worksheet convention |
| Two JSON files have the same properties in a different order | **Structural equivalence** | Same logical object; representation order differs |
| Two XML files have the same entities in a different order | **Structural equivalence** | Intended under the sheet's simplified definition |
| Java and Python programs produce identical output for all tested inputs | **Functional equivalence** | Tick this printed option; the evidence establishes it only over the tested set, while timing/side effects were not established |

### 5.3 Real-world nuances without losing exam marks

**Recognition only:** preserve the worksheet answer first; use these caveats only to qualify it.

- Equal MD5 hashes do not mathematically prove byte identity because collisions exist. **For this sheet, still select bitwise identity**, because the sheet explicitly uses the same MD5 hash as its example.
- JSON object-property order is normally irrelevant.
- XML sibling order can be semantically meaningful under some schemas/applications. **For this sheet, select structural equivalence** under its stated simplified rule.
- Passing every test used by the researcher is evidence of functional equivalence only on that tested set. It is not a proof over an unbounded input domain.

### 5.4 Function case study

Given:

```text
f(x) = x * 2
g(x) = x + x
```

They are functionally equivalent over ordinary numeric arithmetic because both produce `2x` for every input in that domain.

Do not overclaim behavioral equivalence. Implementations may differ in timing, instruction count, overflow semantics, overloaded operators, logging, or side effects. State the domain/semantics if the question is about actual programs rather than mathematical functions.

---

## 6. Runtime evidence and fair comparison

[IC4]

### 6.1 The worksheet data

| Run | Algorithm A (ms) | Algorithm B (ms) |
|---:|---:|---:|
| 1 | 100 | 90 |
| 2 | 105 | 200 |
| 3 | 98 | 95 |

Calculated summaries:

| Statistic | A | B |
|---|---:|---:|
| Mean | `101` ms | `128.33` ms |
| Median | `100` ms | `95` ms |
| Range | `7` ms | `110` ms |

B wins two individual runs and has the lower median, but A has the lower mean because B's second run is extremely slow.

### 6.2 Can we conclude B is faster?

**No.** A full-mark answer should say why:

- only three runs were observed;
- B is highly variable and contains one unusually high 200 ms observation;
- mean and median support different impressions;
- uncertainty is not reported;
- warm-up, run order, system load, hardware state, and controls are unknown.

Do not silently delete the 200 ms observation. Investigate it and report any justified exclusion rule transparently.

### 6.3 Better runtime experiment

1. Define the target statistic and hypothesis before running the test.
2. Warm up runtimes/caches/JITs where appropriate.
3. Use many controlled, paired repetitions on the same machine and inputs.
4. Randomize or interleave A/B order to reduce drift bias.
5. Record the environment and background load.
6. Report the distribution, mean/median, variability such as SD/IQR, and confidence intervals.
7. Investigate unusually high observations rather than cherry-picking them away.
8. Use a suitable paired statistical test if inferential evidence is required.

Exam-ready answer:

> No. Three observations are insufficient, and B has very high variability: its median is lower but its mean is higher because of the 200 ms run. Perform many controlled, paired and preferably interleaved repetitions, then report the distribution, a preselected summary statistic, variability, and uncertainty while investigating the unusually high observation.

---

## 7. Lab 3: from repeatability to a gold-standard package

### 7.1 Goal and dispatcher interface

Sheet 2 made the random experiment repeatable. Sheet 3 moves toward **Gold reproducibility**: the complete analysis should execute with one command. [L1]

Update the supplied repository with:

```bash
git pull
```

The dispatcher accepts exactly four positional arguments:

```bash
./run_experiment.sh recipe.txt 10 42 exp1
```

| Position | Shell variable | Meaning | Example |
|---:|---|---|---|
| 1 | `$1` | Input file | `recipe.txt` |
| 2 | `$2` | Number of runs | `10` |
| 3 | `$3` | Random seed | `42` |
| 4 | `$4` | Experiment label | `exp1` |

### 7.2 Usage block

Assuming `run_experiment.sh` uses Bash:

```bash
if [[ $# -ne 4 ]]; then
    printf 'Usage: %s <input-file> <runs> <seed> <label>\n' "$0" >&2
    exit 2
fi

input_file=$1
runs=$2
seed=$3
label=$4
```

High-quality scripts also check that the input exists, `runs` is positive, `seed` is an integer, and `label` is safe for a path. The sheet's required usage check focuses on the correct argument count.

### 7.3 Deterministic randomness

Pass the same seed to `pplease.py` on every run. The exact CLI syntax can vary with the supplied skeleton; this valid pattern treats the seed as a positional argument:

```bash
python3 pplease.py "$seed" < "$input_file" > "$output_file"
```

Conceptual Python pattern:

```python
rng = random.Random(seed)

for sentence in sentences:
    if rng.random() < 0.5:
        # Insert ", please" before the sentence punctuation.
        ...
```

Seed once per program invocation, not before every sentence. Re-seeding every sentence can make every sentence reuse the same first random decision.

A seed is sufficient only while these remain fixed:

- input and input order;
- code;
- PRNG implementation/version;
- number and order of random draws;
- relevant dependency/runtime behavior.

One hundred runs with the **same** seed are a repeatability check, not 100 independent Monte Carlo samples.

### 7.4 Exact persistent result path

[L1-2]

For `recipe.txt`, 10 runs, seed 42, and label `exp1`, the required directory is:

```text
results/recipe_runs_10_seed_42_exp1/
```

The `.txt` extension is removed. Core shell pattern:

```bash
input_name=$(basename -- "$input_file")
input_stem=${input_name%.*}
result_dir="results/${input_stem}_runs_${runs}_seed_${seed}_${label}"
mkdir -p "$result_dir"
```

Illustrative directory tree:

```text
results/recipe_runs_10_seed_42_exp1/
|-- polite_1.txt
|-- polite_2.txt
|-- ...
|-- polite_10.txt
|-- results.csv
|-- stats_1.txt
|-- ...
`-- stats_10.txt
```

The sheet requires one `polite_N.txt` per run and statistics in the result directory. Exact statistics filenames are an implementation choice.

Required dispatcher flow:

```text
initialize one results.csv
for every run:
    create polite_N.txt
    append one CSV row per sentence
    analyze that run from results.csv
    store statistics in the same result directory
```

### 7.5 CSV requirements

[L2]

The required CSV path is `"$result_dir/results.csv"`. Its header is:

```csv
run,original,polite
```

There is one data row per run **and** per sentence:

```text
data rows = number of runs * number of input sentences
```

Required example form:

```csv
2,"400g white sugar.","400g white sugar, please."
```

Use Python's `csv` module. Naive manual string concatenation is unsafe because commas, quotes, and embedded newlines require correct CSV escaping.

The following is an illustrative fragment only. CSV creation may live in `pplease.py`, the dispatcher, or a helper, depending on the supplied skeleton. Generate the text output and CSV record from the same transformation pass or shared sentence representation.

```python
writer = csv.writer(
    stream,
    quoting=csv.QUOTE_NONNUMERIC,
    lineterminator="\n",
)
writer.writerow([run_number, original, polite])
```

Open CSV files with `newline=""`. Recreate or truncate `results.csv` at the beginning of a fresh experiment; otherwise repeating the same labeled command can duplicate old rows.

Character-count reminder:

```text
"400g white sugar."          -> 17 characters
"400g white sugar, please."  -> 25 characters
```

The inserted text `, please` adds 8 characters.

### 7.6 Updated analysis

[L2]

Invocation:

```bash
python3 pplease_stats.py results.csv 1
```

The script must:

1. read the CSV;
2. retain only rows for the requested run;
3. calculate character lengths for `original` and `polite`;
4. print minimum, maximum, and median for both columns.

Core implementation:

```python
import csv
import statistics
import sys

if len(sys.argv) != 3:
    raise SystemExit(f"Usage: {sys.argv[0]} <results.csv> <run>")

run_number = int(sys.argv[2])

with open(sys.argv[1], encoding="utf-8", newline="") as stream:
    rows = [
        row for row in csv.DictReader(stream)
        if int(row["run"]) == run_number
    ]

if not rows:
    raise SystemExit(f"No rows for run {run_number}")

original_lengths = [len(row["original"]) for row in rows]
polite_lengths = [len(row["polite"]) for row in rows]

print("Metric Original Sentences Polite Sentences")
print("Min Length", min(original_lengths), min(polite_lengths))
print("Max Length", max(original_lengths), max(polite_lengths))
print(
    "Median Length",
    statistics.median(original_lengths),
    statistics.median(polite_lengths),
)
```

Median:

- odd count: middle sorted value;
- even count: mean of the two middle sorted values.

Count characters, including spaces and punctuation, not words. The component that creates `results.csv` must use the same sentence segmentation as the generator. `pplease_stats.py` should treat each selected CSV row as one sentence and only count its `original` and `polite` fields.

Rows for different runs within the same `results.csv` are not byte-identical because their `run` fields differ. Compare the selected `original`/`polite` values, generated files, or statistics.

### 7.7 Dockerfile

[L3]

Required default container experiment:

```text
input = recipe.txt
runs  = 10
seed  = 42
label = docker
```

Representative Dockerfile:

```Dockerfile
# Builds a reproducible polite-text experiment package
# Copyright 2026, Your Name
# SPDX-License-Identifier: MIT
FROM ubuntu:24.04

LABEL org.opencontainers.image.authors="you@example.com"

RUN apt-get update && apt-get install -y \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY recipe.txt pplease.py pplease_stats.py run_experiment.sh doAll.sh /app/

RUN chmod +x /app/run_experiment.sh /app/doAll.sh && \
    sed -i 's/\r$//' /app/run_experiment.sh /app/doAll.sh

CMD ["/app/run_experiment.sh", "recipe.txt", "10", "42", "docker"]
```

Do not accidentally change the required Docker default to the 100-run `doAll` experiment.

Running the container must create:

```text
results/recipe_runs_10_seed_42_docker/
```

and print the experiment output.

### 7.8 `doAll.sh`

[L3]

Required fixed values:

```text
input = recipe.txt
runs  = 100
seed  = 42
label = doAll
```

```bash
#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")"
exec ./run_experiment.sh recipe.txt 100 42 doAll
```

It must be copied into the image, have Linux line endings, and be executable.

### 7.9 Container-local results and persistence

With:

```bash
docker run --rm image
```

the result directory exists in the container's writable layer. `--rm` removes the stopped container, so those files disappear unless copied or mounted elsewhere. Printed terminal output remains visible.

Persist results on the host with a bind mount:

```bash
docker run --rm \
  -v "$PWD/results:/app/results" \
  image
```

`--rm` removes the stopped container, not the image.

### 7.10 Source versus binary containers

[L3]

| Workflow | What happens later | What is frozen | Main remaining risks |
|---|---|---|---|
| **Source** | Rebuild an image from the Dockerfile | Recipe text, but not necessarily what mutable references resolve to | Base tags, repositories, package availability, network, changed build context |
| **Binary** | Load and run an already-built saved image | Image layers, configuration, packaged dependencies | Architecture/kernel compatibility, external services, hardware, network, mounted inputs |

Commands with concrete example IDs:

```bash
docker build -t lab3_12345678 .
docker save -o lab3_12345678.tar lab3_12345678
docker load -i lab3_87654321.tar
docker run --rm lab3_87654321
```

Meanings:

- `docker build`: resolve the recipe and create an image.
- `docker save`: archive image layers, configuration, and tags.
- `docker load`: restore a saved image archive.
- `docker run --rm`: create/run a container and remove it when stopped.

Do not confuse `docker save/load` with `docker export/import`. `export` works from a container filesystem and does not preserve the normal image metadata/history in the same way.

After saving, exchange the tar archive with a fellow student, load and run their image, compare its output with yours, provide feedback, and receive their feedback gracefully.

### 7.11 Exact dependency-management answers

[L4-5]

The Dockerfile uses:

```Dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    python3=3.14.3-0ubuntu2 \
    python3-certifi=2026.1.4+ds-1 \
    python3-jsonschema=4.19.2-6ubuntu2 \
    python3-requests=2.32.5+dfsg-1ubuntu1
```

The Python program calls a live UTC-time API.

| Change after two months | Correct option | Reason |
|---|---|---|
| Ubuntu has a new release | **Only the source container may fail** | `ubuntu:latest` may resolve differently; the binary already has its old layers |
| A new Python version is released | **Only the source container may fail** | A later repository may no longer provide the exact pinned package; the binary already contains it |
| External time service is offline | **Binary and source may fail** | Both call the same unbundled service at runtime |

The wording is **may fail**, not **must fail**. The old package might remain available, but the source build is exposed to that change.

The program catches only JSON-schema `ValidationError`. A network failure occurs before that validation and is not handled. It also lacks a timeout and explicit HTTP status handling.

Even when online, a current-time API supplies changing external input. Better reproducibility requires recording/versioning the response, using a controlled fixture/service, or otherwise making the dependency stable.

### 7.12 Likely lab variants

**Recognition only:** these transfer the source/binary distinction to new scenarios.

| Changed condition | Saved binary image | Later source rebuild |
|---|---|---|
| Mutable base tag changes | Usually unaffected | May change/fail |
| Package repository is offline | Existing image may run | Build may fail |
| Pinned version is removed | Existing image may run | Build may fail |
| Runtime API is offline or changes schema | May fail | May fail |
| Host architecture is incompatible | May fail to run | Might rebuild natively |
| File copied in build context changes | Old image retains old copy | New build receives changed file |
| Host-mounted input changes | Sees changed input | Sees changed input |

`ubuntu:24.04` is better specified than `latest`, but a tag can still receive updates. A digest such as `FROM ...@sha256:...` identifies exact base content. Exact package pins improve specification but do not guarantee future rebuildability if no archive preserves the package.

---

## 8. Complete In-Class Exercise Sheet 3 answer key

### Questions 1-4

1. Good hypothesis words: **PRECISE, SPECIFIC, UNAMBIGUOUS**, and explicit **LIMITATIONS**. Not good: **LOOSE, CONTRADICTORY**.
2. True/false:
   - (a) Loose concepts are easier to validate: **False**.
   - (b) Two readers should interpret a precise hypothesis the same way: **True**.
   - (c) A good hypothesis should clarify what is not claimed: **True**.
3. Case studies:
   - A: **violates** the guidance; vague and missing B-MEDS.
   - B: **intended good example**; for maximum precision, add an explicit comparator.
   - C: **violates** the guidance; key terms and scope are undefined.
4. Equal fit plus greater simplicity: **Occam's razor**.

### Questions 5-6

5. **True, True, True, True, False**.
6. **Setup, Result, Discussion, Setup, Discussion, Result**.

### Questions 7-9

7. Definitions: bitwise identity, structural equivalence, functional equivalence, behavioral equivalence - see Section 5.
8. Scenarios:
   - (a) JPEG/same MD5: **Bitwise identity**.
   - (b) JSON/same properties, different order: **Structural equivalence**.
   - (c) XML/same entities, different order: **Structural equivalence** under the sheet's convention.
   - (d) Java/Python/same outputs for tested inputs: tick **Functional equivalence**; in an explanation, qualify this as evidence over only the tested set.
9. `x * 2` and `x + x`: **functionally equivalent** over ordinary numeric arithmetic.

### Question 10

10(a). **No**, B cannot yet be called generally faster: only three runs, extreme variability, conflicting mean and median, and no uncertainty/control information.

10(b). Run many controlled, paired/interleaved repetitions; report distributions, selected summary statistics, variability, and confidence intervals; investigate the 200 ms observation.

### Question 11 model comparison

> Both methods lasted four months, but Method B had **more** participants (421 versus 375). Method B produced **fewer** actively usable words (456 versus 500), while Method A enabled learners to understand **many more** words (3,000 versus 1,500) and therefore developed vocabulary more **efficiently**. Method B taught more tenses (8 versus 5), although its learners spoke **less fluently**. Conversely, Method B had a **much** lower speaking-error rate (15% versus 35%), **better** writing ability, and greater radio-news comprehension (20% versus 10%). Overall, A was better for vocabulary and fluency, whereas B performed better in grammar coverage, accuracy, writing, and listening.

Requirements satisfied:

- irregular comparative: `better`;
- all required words: `less`, `fewer`, `more`, `much`, `many`;
- adverbs: `efficiently`, `fluently`.

The worksheet confusingly gives `worst` and `fewest` as examples of comparative forms; they are superlatives, and `fewest` is regular. Use an unequivocal irregular comparative such as **better** or **worse**.

Language traps:

- `fewer` with plural count nouns: fewer words/errors;
- `less` with uncountable quantities or degree: less time, less fluently;
- `much` intensifies a comparison: much lower;
- `many` modifies plural count nouns: many words;
- standard English is `not as many ... as`, not `not as many ... than`;
- `respectively` maps values in the order the items were named.

Percentage traps:

- 35% to 15% is a fall of **20 percentage points**.
- Relative to 35%, it is a reduction of about **57.1%**.
- 20% versus 10% is **10 percentage points higher** and twice as large.
- Conflicting dimensions mean neither method is universally best.

---

## 9. Complete Lab Exercise Sheet 3 answer key

### Required facts

```text
Pull: git pull
Call: ./run_experiment.sh recipe.txt 10 42 exp1
Args: input, runs, seed, label
Usage check: exactly four dispatcher arguments
Path: results/recipe_runs_10_seed_42_exp1/
Per-run output: polite_1.txt, polite_2.txt, ...
Outputs: polite_N.txt and statistics inside the experiment directory
CSV: one results.csv with run,original,polite
CSV rows: one row for every (run, sentence) pair
Stats call: python3 pplease_stats.py results.csv 1
Stats behavior: filter one run; min/max/median for original and polite
Dispatcher stats call: python3 pplease_stats.py "$result_dir/results.csv" "$run"
Docker CMD: recipe.txt 10 42 docker; create ..._docker/ and print output
doAll.sh: recipe.txt 100 42 doAll; copied in and executable
```

### Binary image exchange

```text
build -> save -> exchange -> load -> run -> compare
-> give feedback -> receive feedback gracefully
```

Commands:

```bash
docker build -t lab3_12345678 .
docker save -o lab3_12345678.tar lab3_12345678
docker load -i lab3_87654321.tar
docker run --rm lab3_87654321
```

### Multiple choice

```text
(a) New Ubuntu release: only the source container
(b) New Python release: only the source container
(c) External service offline: the binary and the source container
```

Mnemonic: **U/P -> Source; API -> Both.**

---

## 10. Common exam traps

- A hypothesis is not strong merely because it sounds confident.
- `Performance`, `better`, `most`, and `realistic` are not metrics.
- A percentage threshold still needs a named baseline.
- Limitations can strengthen a claim by defining its valid scope.
- Positive evidence confirms in the weak scientific sense; it does not prove a general empirical theory forever.
- A failed experiment may reveal a false hypothesis or a bad auxiliary assumption/instrument/measurement.
- Occam's razor applies only when evidential fit is equal.
- Evidence and an argument connecting it to the hypothesis are different things.
- A model implemented as code is not automatically an experiment on a real system.
- Optimizing one proxy can move research away from its qualitative goal.
- `Figure shows` normally reports a result; `suggests` normally begins interpretation.
- Reporting only positive outcomes is not acceptable.
- Same logical content does not require identical bytes.
- Same outputs do not prove identical timing, I/O, or side effects.
- Tests show equivalence only over the tested set unless a proof/general argument extends it.
- For the exam, follow the sheet's MD5 and XML conventions, then add a short real-world caveat if useful.
- B being faster in two of three runs is not enough when its variance is huge.
- Do not choose whichever summary statistic supports the desired conclusion after seeing the data.
- The dispatcher now has four arguments, not two.
- The result directory is persistent `results/`, not a temporary directory.
- Remove the input filename's extension when constructing the result-directory stem: `recipe.txt` becomes `recipe`.
- Encode runs, seed, and label in the path.
- Pass the seed into `pplease.py`; merely accepting it in the shell script changes nothing.
- Do not reseed before every sentence.
- Initialize `results.csv` once, not once per run, and avoid appending duplicate old experiments.
- Use a CSV library; sentences may contain commas and quotes.
- There is one combined `results.csv`, not one CSV per run.
- `results.csv` needs one row for every run-and-sentence pair.
- Each run still creates its own `polite_N.txt`; the CSV does not replace text output.
- Filter the CSV to the requested run before calculating statistics.
- Statistics output also belongs in the persistent experiment directory.
- Count characters, including spaces and punctuation, not words.
- `doAll.sh` uses 100/42/doAll, but Docker's default uses 10/42/docker.
- Docker's default run must create the `..._seed_42_docker/` directory and print experiment output.
- `docker save` preserves an image; do not substitute `docker export` without understanding the difference.
- A binary image freezes packaged dependencies, not external APIs, host architecture, kernel, or mounted data.
- Version pinning improves specification but does not guarantee that a future repository still hosts the package.
- `--rm` removes the stopped container, not the image, and container-local outputs disappear with it.

---

## 11. Final two-minute recall sheet

```text
GOOD HYPOTHESIS
  PSUL = precise, specific, unambiguous, limited in scope
  B-MEDS = baseline, metric, effect, data/workload, scope/conditions
  must be testable, falsifiable, predictive, and explicit about assumptions

RESEARCH LOGIC
  tentative hypothesis <-> question -> prediction -> evidence -> argument
  positive evidence strengthens; it does not permanently prove
  revised-after-data hypothesis needs a fresh test
  equal evidential fit + simpler explanation = Occam's razor

EVIDENCE
  PMSE = proof, model, simulation, experiment
  model: mathematical + assumptions
  simulation: controlled/artificial + realism risk
  experiment: real/highly realistic + only tested cases directly covered

PAPER STRUCTURE
  setup = what/how
  result = observed
  discussion = meaning/why/limitations

EQUIVALENCE
  bitwise = same bytes
  structural = same content, representation may differ
  functional = same outputs for same inputs
  behavioral = same observations under stated model

RUNTIME TABLE
  A mean/median/range = 101 / 100 / 7 ms
  B mean/median/range = 128.33 / 95 / 110 ms
  cannot conclude B is faster from 3 noisy runs

LAB
  ./run_experiment.sh recipe.txt 10 42 exp1
  results/recipe_runs_10_seed_42_exp1/
  results.csv = run,original,polite; one row per run * sentence
  stats = CSV path + run number; filter, then min/max/median
  Docker = recipe.txt, 10 runs, seed 42, label docker
  doAll = recipe.txt, 100 runs, seed 42, label doAll
  binary = build -> save -> exchange -> load -> run -> compare
           -> give feedback -> receive feedback gracefully
  Ubuntu/Python change -> source may fail
  external API offline -> binary and source may fail
```

---

## 12. Closed-book self-test

Try these before reading the answers.

1. Expand PSUL.
2. Which five elements are captured by B-MEDS?
3. Rewrite `Our model is better` as a testable hypothesis.
4. Why can an explicit limitation strengthen a hypothesis?
5. What is the difference between a research question and a hypothesis?
6. What must connect evidence to a hypothesis?
7. State the exact condition for applying Occam's razor.
8. Name the four forms of evidence.
9. Why is executing a mathematical model not necessarily an experiment on the real system?
10. Give one advantage and one risk of simulation.
11. Classify: `We used three datasets and two baselines.`
12. Classify: `Latency fell by 18%.`
13. Classify: `This may be caused by cache locality.`
14. Distinguish bitwise and structural equivalence.
15. Can two programs be functionally equivalent but not behaviorally equivalent? Give an example.
16. What is the worksheet answer for two JSON objects with reordered properties?
17. Why is the three-run A/B table inconclusive?
18. Give two improvements to that runtime experiment.
19. List the four arguments to `run_experiment.sh` in order.
20. Write the exact result path for `recipe.txt 10 42 exp1`.
21. What are the three CSV columns?
22. Why should a CSV library be used?
23. What fixed parameters does `doAll.sh` use?
24. What fixed parameters must Docker run by default?
25. What does `docker save` preserve that a Dockerfile alone does not freeze?
26. Which container may fail after a new Ubuntu release?
27. Which containers may fail if the runtime UTC-time API is offline?
28. Does a fixed seed alone guarantee identical output after code/runtime changes?
29. Does `docker run --rm` delete the image?
30. Does a saved image make a live external API reproducible?
31. What exactly must the dispatcher's required usage block check?
32. What is the required text-output filename for run `N`?
33. With `r` runs and `s` input sentences, how many CSV data rows are required?
34. What two arguments does `pplease_stats.py` accept?
35. Which rows and metrics must `pplease_stats.py` analyze?
36. Where must the statistics output be stored?
37. Write the four binary-image build/save/load/run commands.
38. What human steps follow running a fellow student's image?
39. Which container may fail after a new Python release?
40. What directory and terminal behavior are required from Docker's default run?

### Answers

1. Precise, specific, unambiguous, limited in scope.
2. Baseline, metric, expected effect/direction, data/workload, scope/conditions.
3. Example: `On dataset D under condition C, model A will improve metric M by at least X relative to baseline B.`
4. It defines where the claim applies, prevents overgeneralization, and makes testing/falsification clearer.
5. A question asks what will be determined; a hypothesis asserts/predicts an answer.
6. An explicit argument explaining why the evidence bears on the claim.
7. The hypotheses fit the observations equally well; then prefer the simpler.
8. Proof, model, simulation, experiment.
9. It may test only the model's calculations, not whether the model describes the real algorithm/system.
10. Advantage: controlled parameter sweeps/extremes. Risk: unrealistic simplification that fails to transfer.
11. Setup.
12. Result.
13. Discussion.
14. Bitwise means identical bytes; structural means equivalent logical content despite allowed representation differences.
15. Yes. They can return the same values while differing in timing, logging, file I/O, or side effects.
16. Structural equivalence.
17. Only three runs, B is extremely variable, mean and median conflict, and controls/uncertainty are absent.
18. Any two of: more paired runs, warm-up, randomized/interleaved order, controlled load, distributions, variability, confidence intervals, justified investigation of extreme observations.
19. Input, number of runs, seed, label.
20. `results/recipe_runs_10_seed_42_exp1/`.
21. `run,original,polite`.
22. Correct escaping/quoting of commas, quotes, and newlines.
23. `recipe.txt`, 100 runs, seed 42, label `doAll`.
24. `recipe.txt`, 10 runs, seed 42, label `docker`.
25. Resolved image layers/configuration and packaged dependencies as built at that time.
26. Only the later source rebuild may fail; the saved binary has its old layers.
27. Both binary and source.
28. No. Input, code, runtime/PRNG, dependencies, and random-call order also matter.
29. No. It removes the stopped container.
30. No. The external service is outside the image.
31. It checks that exactly four positional arguments were supplied; otherwise it prints the correct syntax and exits.
32. `polite_N.txt`, for example `polite_1.txt` for run 1.
33. `r * s` data rows, plus one header row.
34. The path to `results.csv` and the run number to analyze.
35. Filter to the requested run, then compute minimum, maximum, and median character length separately for `original` and `polite`.
36. Inside the persistent experiment result directory.
37. `docker build -t lab3_12345678 .`; `docker save -o lab3_12345678.tar lab3_12345678`; `docker load -i lab3_87654321.tar`; `docker run --rm lab3_87654321`.
38. Compare their output with yours, provide feedback, and receive their feedback gracefully.
39. Only the later source rebuild may fail; the binary already contains its installed Python.
40. It must create `results/recipe_runs_10_seed_42_docker/` and print the experiment output.

---

## 13. Revision plan for the July 29 exam

### First focused pass

1. Read Section 1 once, then reproduce **PSUL**, **B-MEDS**, **PMSE**, the experiment-section classifier, and the dependency rule from memory.
2. Work Questions 1-10 of the in-class sheet using only Sections 2-6 to check yourself.
3. Read the Lab 3 facts and say the four arguments, exact result path, `polite_N.txt` naming, CSV cardinality, statistics filtering, Docker values, and `doAll` values aloud without looking.

### Second focused pass

1. Write the full In-Class answer key from memory.
2. Recalculate the A/B means, medians, and ranges; practice the one-paragraph conclusion.
3. Draw the source-versus-binary table, write the four binary-image commands, recite the compare/feedback steps, and explain each dependency multiple-choice answer in one sentence.
4. Complete the 40-question self-test. Mark every hesitant answer as wrong, even if guessed correctly.
5. Re-read only the marked topics and repeat the test orally.

### Immediately before the exam

Read only Section 11, then check these high-risk details:

```text
B-MEDS includes a baseline.
Occam applies only under equal fit.
Same outputs do not prove same behavior.
results/recipe_runs_10_seed_42_exp1/
One CSV row per run * sentence; filter one run before statistics.
Docker = recipe/10/42/docker; doAll = recipe/100/42/doAll.
Ubuntu/Python -> source; external API -> both.
```

Stop adding new material at that point; use the remaining time for recall.

---

## Source key and coverage

- **Z** - Justin Zobel, *Writing for Computer Science*, 3rd ed., Chapter 4, "Hypotheses, Questions, and Evidence," pp. 35-49. [Official Springer Chapter 4 record](https://link.springer.com/chapter/10.1007/978-1-4471-6639-9_4).
- **IC** - [In-Class Exercise Sheet 3](3-Hypotheses/SoSe_2026_RepEng_IC_3___Hypotheses.pdf), cited by PDF page.
- **L** - [Lab Exercise Sheet 3](Lab_Session_3/Sheet_3.pdf), cited by PDF page.

Coverage check:

- Sourced Zobel chapter themes: hypotheses, defending hypotheses, forms/use of evidence, measurement, good/bad science, falsification/confirmation, and the chapter checklist.
- Every visible question and table on all four in-class pages.
- Every task and multiple-choice scenario on all five lab pages.
- Page 4 of the in-class PDF contains duplicated stray text in its extraction layer; the rendered page contains only one visible Question 11 and table. The guide follows the rendered source.

This guide intentionally preserves the worksheet's expected MD5/XML classifications while labeling real-world caveats separately.

Access note: the local [Stud.IP shortcut](3-Hypotheses/Zobels_chapter_4_available_via_institution_login_as_Uni_Passau.url) requires institutional authentication and was not directly accessible here. The assigned chapter was identified and checked against the official Springer record, indexed chapter content/structure, and the instructor sheet; this is not a claim that the authenticated file was verified line by line or byte for byte.
