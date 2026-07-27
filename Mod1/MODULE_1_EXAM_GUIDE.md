# Reproducibility Engineering - Module 1 Exam Guide

> A compact, exam-focused guide to the material supplied for Module 1: the reproducibility crisis, ACM terminology and badges, research artifacts, Docker fundamentals, and the first lab.

## How to use this guide

1. Learn the **three ACM definitions** and the decision rule first.
2. Memorize the **Nature survey numbers** and what they do - and do not - prove.
3. Understand the Docker mental model before memorizing commands.
4. Finish with the solved sheet questions and the rapid-recall checklist.

The terminology below follows **ACM Artifact Review and Badging v1.1**, which is the convention used by the course. Terminology has not been uniform: after NISO guidance, ACM itself swapped *reproducibility* and *replicability* in 2020. In an exam answer, use the current v1.1 mapping, not older ACM material, and state the convention consistently.

---

## 1. The module in one page

### The three R's

| Concept | Team | Experimental setup/artifacts | Computational interpretation |
|---|---|---|---|
| **Repeatability** | Same team | Same setup | The original researcher can rerun the computation reliably. |
| **Reproducibility** | Different team | Same setup; author-supplied artifacts | An independent group gets an agreeing result using the author's artifacts. |
| **Replicability** | Different team | Different, independently created setup/artifacts | An independent group rebuilds the experiment and still gets an agreeing result. |

Fast decision rule:

1. **Same team and same setup?** -> repeatability.
2. **Different team?** Ask whether it reuses the original setup/artifacts.
   - Reuses them -> reproducibility.
   - Rebuilds independently -> replicability.
3. **Same team but different setup?** -> not separately classified by this three-term ACM scheme; explain the facts rather than forcing a label.

Mnemonic: **1S, 2S, 2D** = same team/same setup, different team/same setup, different team/different setup.

### Nature survey numbers

Of 1,576 surveyed researchers:

- **52%**: yes, a significant crisis
- **38%**: yes, a slight crisis
- **3%**: no crisis
- **7%**: do not know

Therefore, **90% perceived at least some crisis**, but the survey measured researchers' perceptions, not the true fraction of invalid scientific results.

### Docker in one sentence

A **Dockerfile** describes the environment; `docker build` reads it to create a read-only **image**; `docker run` creates a **container**, an isolated instance with its own file system that shares the host's operating-system kernel.

### Exact identity versus similarity

- **SHA-256** answers: "Are these files byte-for-byte the same?"
- **Pearson correlation** answers: "How strongly do these aligned pixel values vary together?"
- A correlation close to `1` does **not** prove that two files or images are identical.

---

## 2. Why reproducibility matters

Science depends on claims surviving checks beyond the original analysis. Repeating, reproducing, or replicating an experiment can:

- confirm and verify a reported result;
- reveal hidden assumptions, undocumented steps, or environment dependencies;
- distinguish a robust effect from a chance result or false lead;
- make errors easier to detect and correct;
- increase confidence and allow later researchers to build on the work.

Important distinction: a failure to reproduce is **evidence that needs investigation**, not automatic proof that the original claim is false. Differences can arise from procedures, data, materials, software, hardware, statistical power, or tacit knowledge.

### What the Nature survey found

The assigned Nature material reports that:

- more than **70%** had tried and failed to reproduce another scientist's experiment;
- more than **half** had failed to reproduce one of their own experiments;
- fewer than **31%** thought a failed reproduction means the original result is probably wrong;
- **73%** still believed that at least half of the papers in their field could be trusted;
- only a minority had tried to publish a reproduction attempt;
- successful and failed reproduction attempts both faced weak publication incentives.

This apparent tension is exam-worthy: many scientists perceived a crisis and had experienced failures, yet most still trusted much of the literature. Reproducibility is not a binary synonym for truth.

Lower-priority article numbers to recognize:

- failed attempts to reproduce someone else's work were reported by about **87% in chemistry, 77% in biology, 69% in physics/engineering, 67% in medicine, 64% in earth/environment, and 62% in other fields**;
- empirical estimates cited in the article were roughly **40% reproducibility in psychology** and **10% in cancer biology**;
- **24%** reported publishing a successful reproduction and **13%** an unsuccessful one; **12%** and **10%**, respectively, reported being unable to publish those attempts;
- regarding lab procedures, **26%** said procedures existed when they joined, **33%** introduced them in the previous five years, **7%** had introduced them earlier, and **34%** reported none.

Do not confuse any of these percentages with the 52/38/3/7 crisis-perception chart.

Vocabulary warning: the 2016 Nature article uses *reproduce* and *replication* informally and notes that no consensus existed. Its "failed to reproduce" percentages do not by themselves specify current-ACM reproducibility (different team using author artifacts).

### Main causes identified

Group the causes into three levels:

| Level | Examples |
|---|---|
| **Research design and analysis** | Poor experimental design, low statistical power, weak analysis, selective reporting, insufficient repetition in the original lab |
| **Artifacts and communication** | Missing methods or code, unavailable raw data, incomplete documentation, specialized techniques, variable materials/reagents |
| **Research culture** | Pressure to publish, insufficient mentoring or oversight, insufficient peer review, competition for grants and jobs |

More than 60% of respondents said that **pressure to publish** and **selective reporting** often or always contributed. More than half also pointed to insufficient replication, poor oversight, or low statistical power.

### Proposed improvements

The strongest survey support was for:

- more robust experimental design;
- better statistics;
- better mentorship;
- redoing important work within the lab;
- clearer, standardized methods and documentation;
- making code, data, and workflows available;
- preregistering hypotheses and analysis plans when appropriate;
- stronger action and incentives from journals, funders, and institutions.

Nearly 90% endorsed robust design, better statistics, and better mentorship. Around 80% thought funders and publishers should do more.

### Survey caveat

The questionnaire was advertised to Nature readers and through related websites/social media as a survey about reproducibility. This can create **self-selection bias**: people already interested in the issue may be more likely to respond. Treat the results as evidence about the experiences and views of respondents, not a precise estimate for all scientists or all published work.

---

## 3. Repeatability, reproducibility, and replicability

### How to justify a classification

Use the matrix in Section 1. A full-mark definition identifies **who performed the new run**, **whether the setup/artifacts were reused or rebuilt**, and **whether the result agreed within the stated precision**.

- Repeatability example: you rerun your own computation with the same code, inputs, environment, parameters, and procedure.
- Reproducibility example: an independent evaluator uses the paper's code, data, container, and instructions to regenerate its main tables.
- Replicability example: another group independently implements the published method and reaches a result supporting the same main claim.

### "Same result" does not mean identical digits

ACM requires agreement within a tolerance appropriate for the experiment. Exact equality may be impossible because of randomness, floating-point arithmetic, hardware, sampling, or measurement noise. The decisive question is whether differences invalidate or materially change the paper's main claims.

### Solved classification questions from In-Class Sheet 1

| Scenario | Answer | Reason |
|---|---|---|
| Scientists perform others' experiments | **To confirm and verify results** | Independent checking is a foundation of reliable science. |
| Alice reconstructs another scientist's physics experiment from the article | **Replication** | Different researcher and independently reconstructed setup/artifacts. |
| Bob repeatedly samples the river over four weeks | **Repetition / repeatability** | The same researcher repeats the measurement procedure. |
| An environmental group obtains Nina's software, input data, and equipment | **Reproduction** | Different team using the original artifacts/setup. |
| Alice visits Charlie's lab and follows his exact procedure there | **Reproduction** | Different person using the original setup and procedure. |
| Eve follows Dave's directions in her own kitchen | **Replication** | Different person and independently realized setup/equipment. |
| Fay runs her hamster under each condition ten times | **Repetition / repeatability** | Multiple trials by the same experimenter within one setup. |
| George drops each golf ball ten times | **Repetition / repeatability** | Repeated measurements by the same experimenter. |
| Joy repeats Harry's density experiment using Harry's equipment | **Reproduction** | Different person using the original equipment/setup. |

Exam technique: do not classify from the word "same" alone. Explicitly identify **team**, **procedure**, **equipment/environment**, and **artifact ownership**.

---

## 4. Research artifacts and ACM badges

### What is an artifact?

In ACM's badging policy, an artifact is a digital object created for a study or generated by it. Examples include:

- source code and executable software;
- experiment, build, and analysis scripts;
- input datasets, collected raw data, and processed data;
- configuration files, parameters, and random seeds;
- notebooks, queries, schemas, and workload definitions;
- environment descriptions, lockfiles, Dockerfiles, and container recipes;
- logs, intermediate results, tables, plots, and scripts that generate them;
- documentation, licenses, checksums, and provenance metadata.

The course exercises sometimes use *artifact* more broadly, including physical equipment. For an ACM badge, the formal focus is the associated digital objects.

### The three independent badge families

The badges are independent: a paper may earn one, several, or all of them.

#### 1. Artifacts Evaluated

The artifacts passed an independent audit. Public availability is not required, but reviewers must receive them.

- **Functional**: documented, consistent with the paper, complete as far as possible, exercisable, and supported by verification/validation evidence.
- **Reusable**: satisfies Functional and is additionally well structured, carefully documented, and prepared for reuse according to community standards.

Functional and Reusable are alternative levels within this badge family. Reusable subsumes Functional, so only one of the two is applied in an instance.

#### 2. Artifacts Available

Relevant author-created artifacts are in a **publicly accessible archival repository**, with a DOI or link and a unique identifier.

Key consequences:

- use a repository with a plan for long-term access;
- an institutional repository, publisher repository, Zenodo, Figshare, or Dryad can qualify;
- a personal web page is not sufficient;
- availability does not imply that the artifacts were evaluated, complete, or reusable.

#### 3. Results Validated

Another person or team successfully obtained the paper's main results.

- **Results Reproduced**: the independent team used at least some author-supplied artifacts.
- **Results Replicated**: the independent team did not use author-supplied artifacts.

These result badges may be awarded after publication; ACM requires a peer-reviewed reproduction or replication report as evidence.

### Model answer: ensuring artifact availability for a thesis

A minimal answer for the formal **Artifacts Available** badge must state:

1. Deposit relevant author-created artifacts in a publicly accessible archival repository with a long-term access plan.
2. Provide the repository DOI or link and a unique object/version identifier.

A stronger thesis-release plan should additionally:

1. Create a complete inventory of code, data, configurations, seeds, scripts, and generated outputs.
2. Clean secrets and personal data; document any access restrictions or provide a legal synthetic/proxy dataset where necessary.
3. Tag an immutable release and record exact software, package, OS, and relevant hardware versions.
4. Add a README with setup, execution, expected outputs, runtime, and the exact commands that regenerate every table and figure.
5. Add a license and citation metadata.
6. Link the permanent archived release from the thesis and test it on a clean machine or container before submission.

Git is excellent for development history, but a mutable repository URL by itself is weaker than an archived, immutable release with a persistent identifier.

### Thesis-reflection answer template

- **Hypothesis:** write a declarative, testable, falsifiable prediction with a direction or threshold: "Under [conditions], [method A] will reduce/increase [metric] by [amount] compared with [baseline B]."
- **Validation:** name the independent variable, baseline, dependent metric, datasets, number of trials, controls, and analysis used to support or not support the hypothesis. Evidence does not permanently "prove" a scientific hypothesis.
- **Artifacts:** list code, exact data versions, scripts, parameters, seeds, environments, raw/intermediate/final results, and documentation.
- **24-hour pass criterion:** retrieve the exact revision, recreate its environment, rerun the experiments, and regenerate **every reported table and chart within 24 hours**.
- **Why that audit might fail:** lost data, missing package versions, broken dependencies, dead URLs, undocumented manual steps, unrecorded seeds, unavailable hardware/services, absolute paths, credentials, or no script connecting raw data to final figures.
- **What should have been done:** version control, immutable release, archival DOI, dependency locking/containerization, workflow automation, checksums, complete README, tests, and a clean-environment rerun before submission.

---

## 5. Docker mental model

### Core objects

| Object | Meaning |
|---|---|
| **Dockerfile** | Text instructions that describe how to build an image. |
| **Image** | Read-only template containing the application environment; a blueprint. |
| **Container** | A created/running instance of an image with isolation and a writable container layer. |
| **Host** | The machine on which the Docker engine and containers run. |

### Layered architecture

From top to bottom:

1. application inside the container's isolated file system;
2. Docker/container engine managing the container;
3. host file system;
4. physical or remote host machine.

Containers share the host's **operating-system kernel**, even though their file systems and processes are isolated. This is why containers are more lightweight than virtual machines that normally include a separate guest operating system/kernel.

Local versus course server:

- Local Docker: your own PC is the **host**.
- Remote Docker server: the server is the **host**; your PC is a client connected through SSH.

### Why Docker helps reproducibility

An image can package the application with its libraries, tools, and configuration, reducing "works on my machine" variation. Docker does not guarantee reproducibility by itself. Results can still depend on unpinned packages or base images, input data, random seeds, CPU/GPU architecture, host kernel behavior, network services, clock/time, or undocumented commands.

For stronger reproducibility, pin versions or image digests, archive inputs, record seeds and hardware, automate the full workflow, and document expected outputs.

---

## 6. Docker commands you should recognize

The sheet prefixes indicate **where** to run a command; they are not typed:

- `user@host$`: execute on the host.
- `user@container$`: execute inside the container.

### Build, create, and enter

```bash
# Build image "lab1" from the Dockerfile in the current build context.
docker build -t lab1 .

# List images.
docker image ls

# Create and start an interactive container named lab1-cont.
docker run -it --name lab1-cont lab1

# Show running containers.
docker ps

# Show running and stopped containers.
docker ps -a

# Start an existing stopped container.
docker start lab1-cont

# Run an interactive Bash shell in an existing running container.
docker exec -it lab1-cont bash
```

`docker run` creates a new container; `docker start` starts an existing stopped one; `docker exec` runs another process inside an existing running one.

Because `docker build -t lab1 .` supplies a name but no explicit `:tag`, Docker displays the image as `lab1:latest`.

In the sheet's interactive example, `exit` leaves the shell and normally stops the container because that shell is its main foreground process. The named container still exists and can be restarted.

### Important flags

| Flag | Meaning |
|---|---|
| `docker build -t lab1 .` | Here `-t` assigns the image tag/name; `.` is the build context. |
| `docker run -i` | Keep standard input open. |
| `docker run -t` | Allocate a pseudo-terminal. |
| `docker run -it` | Interactive terminal (`-i` plus `-t`). |
| `docker run -d` | Run detached/in the background. |
| `--name NAME` | Give the container a stable human-readable name. |
| `-v HOST:CONTAINER` | Bind-mount a host path at a container path. |

Trap: `-t` means **tag** for `docker build`, but **pseudo-terminal** for `docker run`.

### Reading a container prompt

For `repro@48e05f93af51:~$`:

- `repro` is the user;
- `48e05f93af51` is the container hostname, commonly derived from its ID;
- `~` is the user's home directory;
- `$` indicates a non-root shell (`#` commonly indicates root).

The exact `ls -l` contents asked for by the sheet depend on the course repository's Dockerfile and copied assets. Those files are not in the supplied module, so the listing should not be invented; the examinable point is that `ls` runs in the container's current directory.

### Copying files

```bash
# Container -> host
docker cp lab1-cont:/home/repro/correlation.py ~/

# Host -> container
docker cp ~/correlation.py lab1-cont:/home/repro/correlation.py
```

The colon in `CONTAINER:PATH` identifies a container-side path. Without it, the path is on the host.

`docker cp` is a one-time transfer. It does not keep the two copies synchronized.

### Bind mounts

```bash
docker run -it --name lab1-cont-mount \
  -v /absolute/host/path:/home/repro/mount lab1
```

A bind mount maps the host directory directly into the container. Edits made through either path are visible on the other side. The mount must be configured when the container is created. Use an absolute host path. When Docker runs on the university server, the left-hand host path is on that remote server, not on your laptop.

For the sheet's mounted `test.sh`, `sudo chmod +x mount/test.sh` grants execute permission and `./mount/test.sh` runs it, printing `Test passed!`.

### The sample Dockerfile

```dockerfile
FROM ubuntu:24.04
RUN apt update && apt install -y bash coreutils lsb-release
COPY experiment.sh /usr/local/bin/experiment.sh
RUN chmod +x /usr/local/bin/experiment.sh
```

- `FROM` selects the base image/environment.
- `RUN` executes commands while building the image.
- `COPY` copies from the host build context into the image.
- the final `RUN` makes the script executable in the image.

The sheet then uses:

```bash
docker build -t experiment-app .
docker run -itd --name exp-cont experiment-app
docker exec exp-cont /usr/local/bin/experiment.sh
```

The script computes 7 + 5 and prints separate lines including `Input values: a=7, b=5` and `Sum: 12`. It reports the distribution **inside the container** (Ubuntu 24.04 from its image), not Alice's Debian host or Bob's Ubuntu host.

Shell syntax worth recognizing from the script:

- `a=7` assigns a variable; Bash assignments have no spaces around `=`;
- `$a` expands a variable;
- `$((a + b))` performs arithmetic expansion;
- `$(lsb_release -ds)` substitutes a command's output;
- `#` begins a comment, while `#!/bin/bash` selects the interpreter.

---

## 7. Comparing the two images

### Method 1: visual inspection and metadata

Visual appearance, file size, and timestamps are quick clues, but none proves content identity.

- Same size does not imply same bytes.
- Different size does prove the files are not byte-identical.
- Timestamps describe metadata/history, not content.
- A hidden or subtle pixel change can be invisible to a person.

### Method 2: SHA-256

```bash
sha256sum res/fox.jpg
sha256sum res/fox_secret.jpg
```

- Different hashes -> the byte sequences are definitely different.
- Equal SHA-256 hashes -> treat the files as byte-identical in normal engineering practice; a deliberate hash collision is theoretically possible but negligible here.

Checksums are appropriate for integrity and exact artifact verification.

### Method 3: Pearson correlation of pixels

For paired values `(x_i, y_i)`, Pearson's `r` measures linear association:

- `r = 1`: perfect positive linear relationship;
- `r = 0`: no linear correlation (a nonlinear relationship can still exist);
- `r = -1`: perfect negative linear relationship.

Minimal implementation:

```python
from PIL import Image
import numpy as np

def grayscale_array(path):
    image = Image.open(path).convert("L")
    return np.asarray(image, dtype=float)

x = grayscale_array("res/fox.jpg")
y = grayscale_array("res/fox_secret.jpg")

if x.shape != y.shape:
    raise ValueError("Images have different dimensions")

r = np.corrcoef(x.flatten(), y.flatten())[0, 1]
print(r)
```

The lab installs the required packages with `pip3 install --user numpy pillow` and runs the script with `python3 correlation.py` inside the container. `np.corrcoef(x.flatten(), y.flatten())` returns a 2-by-2 matrix; the desired cross-correlation is the off-diagonal value `[0, 1]`.

A value near `1` means the overall aligned grayscale patterns are extremely similar. It does **not** mean the images or files are identical: a small embedded message can alter bytes and pixels while barely changing the global correlation. Converting to grayscale can also discard color differences.

The actual `fox.jpg` assets are not among the supplied Module 1 files, and the linked FIMGit repository requires authentication. Therefore, no exact checksum or correlation value should be fabricated or memorized from this guide; learn what each result means.

Exam comparison:

| Question | Best method |
|---|---|
| Are the files byte-for-byte identical? | SHA-256/checksum |
| Do the images look similar overall? | Visual/perceptual or statistical comparison |
| Are aligned pixel intensities linearly similar? | Pearson correlation |

---

## 8. Solved lab multiple choice

### 5(a): Alice versus Bob

**Correct:** They will get the same output because the script is deterministic and the container provides the same environment.

Reason: both build from `ubuntu:24.04`, execute the same script inside the container, and compute deterministic integer arithmetic. The host distributions do not become the distribution inside the container.

Real-world nuance: architecture-specific behavior, floating-point calculations, unpinned downloads, external services, and nondeterminism can still create differences. For the simplified sheet scenario, the stated answer is the intended one.

### 5(b): prove the file exists inside the container

**Correct:**

```bash
docker exec exp-cont ls /usr/local/bin/experiment.sh
```

Reason: the command is issued on the host, but `docker exec` runs `ls` inside `exp-cont`. A plain host-side `ls /usr/local/bin/...` checks the host instead.

### 5(c): find the copied file

After:

```bash
docker cp exp-cont:/usr/local/bin/experiment.sh experiment_copy.sh
```

**Correct:**

```bash
ls experiment_copy.sh
```

Reason: the destination has no `CONTAINER:` prefix, so the copied file is in the host's current directory.

---

## 9. Common exam traps

1. **Different person does not automatically mean replication.** If that person uses the original artifacts/setup, it is reproduction.
2. **Different physical location does not automatically mean a different setup.** Ask whether the measuring system/artifacts were reused or independently rebuilt.
3. **Reproducible does not mean correct.** A flawed deterministic analysis can be perfectly reproducible.
4. **A failed reproduction does not automatically falsify a claim.** Investigate procedures, conditions, data, and tolerances.
5. **Artifact Available is not Artifact Evaluated.** Public presence says nothing by itself about functionality or reusability.
6. **A Git repository is not automatically permanent archival storage.** Prefer an immutable release with a DOI or unique persistent identifier.
7. **An image is not a container.** The image is the template; the container is an instance.
8. **The host and container have different file systems.** Use `docker cp` or a bind mount deliberately.
9. **`docker run`, `start`, and `exec` are not synonyms.** Create, restart, and execute-inside are different operations.
10. **Same size or high correlation is not byte identity.** Use a checksum for exact comparison.
11. **The container shares the host kernel.** It does not contain a complete independent guest kernel like a typical VM.
12. **Survey percentages are perceptions.** They do not directly measure what percentage of all science is false.

---

## 10. Rapid-recall checklist

Before the exam, you should be able to say each answer without notes:

- 52 significant, 38 slight, 3 no, 7 do not know; 1,576 respondents.
- More than 70% failed to reproduce someone else's experiment; more than half failed to reproduce their own.
- Same team/same setup = repeatability.
- Different team/same author artifacts = reproducibility.
- Different team/independent artifacts = replicability.
- Artifact Available = public archival repository plus DOI/link and unique identifier.
- Functional = documented, consistent, complete, exercisable, and verified/validated.
- Results Reproduced uses author artifacts; Results Replicated does not.
- Dockerfile --`docker build`-> image --`docker run`-> container.
- Containers share the host kernel but have isolated file systems.
- `docker exec CONTAINER COMMAND` runs a command inside a running container.
- `docker cp CONTAINER:path hostpath` copies out; reverse the arguments to copy in.
- `-v HOST:CONTAINER` creates a bind mount.
- SHA-256 tests byte identity; correlation tests linear similarity.
- High correlation does not prove equality.

---

## 11. Short self-test

1. A new team runs the original code and data in the supplied container. What is this?
2. A new team writes its own implementation from the paper and confirms the main claim. What is this?
3. Why is 90% the useful combined Nature-survey number?
4. Why does the survey not prove that 90% of published science is irreproducible?
5. Can a paper receive Artifacts Available without Artifacts Evaluated?
6. What is the difference between Results Reproduced and Results Replicated?
7. What does `.` mean in `docker build -t lab1 .`?
8. Which machine is the host when Docker runs on the university server?
9. Why does plain `ls /usr/local/bin/experiment.sh` on your PC not inspect the container?
10. Two images have `r = 0.99999` but different SHA-256 hashes. Are they identical?

### Answers

1. Reproducibility/reproduction: different team, author-supplied artifacts.
2. Replicability/replication: different team, independently built artifacts.
3. `52% + 38% = 90%` perceived either a significant or slight crisis.
4. It is a self-selected perception survey, not a direct audit of the literature.
5. Yes. The badges are independent, and availability does not require evaluation.
6. Reproduced uses some author artifacts; replicated does not.
7. The current directory is the Docker build context.
8. The university server; your PC is the SSH client.
9. Plain `ls` runs on the host. Use `docker exec` to run it in the container.
10. No. They are highly similar by that metric but bytewise different.

---

## Sources covered

This guide was built from every item supplied under `Mod1`:

- [In-Class Exercise Sheet 1](./1-Repeat-Reproduce-Replicate/SoSe_2026_RepEng_IC_1.pdf)
- [Lab Exercise Sheet 1](./Lab_Session_1/Sheet_1.pdf)
- [Nature: "1,500 scientists lift the lid on reproducibility"](https://www.nature.com/articles/533452a) ([PDF](https://www.nature.com/news/polopoly_fs/1.19970%21/menu/main/topColumns/topLeftColumn/pdf/533452a.pdf))
- [Nature course DOI: "Is there a reproducibility crisis in science?"](https://doi.org/10.1038/d41586-019-00067-3)
- [ACM Artifact Review and Badging - Current](https://www.acm.org/publications/policies/artifact-review-and-badging-current)

The two `.url` files in the module are authenticated Stud.IP wrappers for the Nature and ACM references above.
