# Reproducibility Engineering - Module 4 Exam Guide

> A self-contained, exam-focused guide to every supplied Module 4 item: Git and version-control reasoning, diffs and patches, commit provenance and the DCO, merging/rebasing/history cleanup, XPath equality, frozen LaTeX dependencies, automated reporting, and Lab Sheet 4.

## How to use this guide

If time is short, study in this order:

1. Memorize the four XPath equality operators and the `git diff` state table.
2. Learn the solved In-Class Sheet 4 answers: Norman, `saucy.md`, patch labels, packaging trade-offs, and cleaned history.
3. Learn merge versus rebase and `git apply` versus `git am`.
4. Learn TinyTeX/TeX Live, the reporting pipeline, and the three lab multiple-choice answers.
5. Finish with the two-minute recall sheet and self-test.

### Two-day cram plan for the 29 July exam

- **27 July:** Sections 1-10. Redraw the Git state model, diff anatomy, merge/rebase graphs, and DCO trail from memory.
- **28 July:** Sections 11-15. Work every supplied question without looking, then check the solutions.
- **Exam morning:** Read Sections 16-18 only. Do not start a new source.

---

## 1. The whole module in one page

### Four memory blocks

```text
GIT STATE
  working tree --git add--> index --git commit--> repository

GOOD CHANGE
  one logical purpose + clear diff + meaningful message
  + responsibility trailers where project policy requires them

INTEGRATION
  merge preserves topology; rebase replays commits and rewrites identities

XPATH E-D-I-G
  eq = one value; deep-equal = structure; is = node identity; = = any matching pair
```

### The highest-yield tables

| Command | Comparison performed |
|---|---|
| `git diff` | Working tree versus index: unstaged tracked changes |
| `git diff --staged` | Index versus `HEAD`: what the next commit would contain |
| `git diff HEAD` | Working tree plus index versus `HEAD`: all tracked uncommitted changes |
| `git diff A B` | Snapshot/tree at `A` versus snapshot/tree at `B` |
| `git show C` | Commit `C`, its metadata, and normally its patch |
| `git log -p` | Commit history plus the patch introduced by each commit |

| XPath form | Operands | Meaning | Key trap |
|---|---|---|---|
| `A eq B` | Singleton atomic values | Exact value comparison | More than one item causes `XPTY0004` |
| `deep-equal(A,B)` | Any two sequences | Same ordered recursive structure/content | Same identity is unnecessary; whitespace can matter |
| `A is B` | Single nodes | Same node identity in the same XDM tree | Identical-looking nodes are still different nodes |
| `A = B` | Sequences of any length | True if any cross-pair has equal values | It is existential, not whole-sequence equality |

### The central lesson

Version control records the exact change, its base, its rationale, and a trail of responsibility. This turns development history into research provenance.

Output equality is always relative to a chosen criterion. Two PDFs may contain the same scientific result but have different bytes; two XML nodes may contain the same text but differ in attributes or identity. Always state the **equivalence relation appropriate to the claim**.

---

## 2. Git's mental model

### Working tree, index, and repository

1. **Working tree:** files currently checked out and edited on disk.
2. **Index / staging area:** the exact candidate snapshot for the next commit.
3. **Repository:** committed snapshots and their history under `.git`.

```text
edit files             select content                 record snapshot
working tree  --------------------------> index --------------------------> repository
                              git add                         git commit
```

The index is why one commit need not contain every edit in the working tree.

```bash
git status
git diff
git add -p
git diff --staged
git commit
```

`git add -p` interactively stages selected hunks, helping separate logical changes.

### Commits, branches, and `HEAD`

A commit records:

- a tree representing the project snapshot;
- parent commit(s);
- author and committer identities/timestamps;
- a commit message.

A normal commit has one parent, the root has none, and a merge commit normally has two or more. Git derives a commit's patch by comparing its tree with its parent. A commit is fundamentally a snapshot plus history metadata, not merely a stored diff.

A commit ID changes if relevant commit content changes, including its tree, parent, metadata, or message. Rewriting one commit therefore gives it a new ID and normally changes all descendant IDs.

A **branch** is a movable reference to a commit. `HEAD` normally points to the checked-out branch.

```text
A <- B <- C        main -> C
                   HEAD -> main
```

### Remote operations

| Command | Exam meaning |
|---|---|
| `git init` | Create a repository in the current directory |
| `git clone URL` | Copy a repository and its reachable history; configure a remote |
| `git fetch` | Download remote objects/refs without integrating them |
| `git pull` | Fetch and then integrate by configured merge/rebase/fast-forward behavior |
| `git push` | Update remote refs using local commits |
| `git remote -v` | Show remote names and URLs |

Trap: `git pull` is not simply “download files”; it also integrates.

### Essential command map

| Goal | Command | Key effect/trap |
|---|---|---|
| Set identity | `git config --global user.name "Name"` and `git config --global user.email "mail"` | This is recorded as metadata; it is not authentication |
| Inspect | `git status`, `git log --oneline --graph --decorate --all` | Read state/history before changing it |
| Create/switch branch | `git switch -c feature`, `git switch main` | Older material may use `git checkout -b feature` |
| Mark a release | `git tag -a v1.0 -m "Release v1.0"` | Record/archive the tagged commit; a tag name alone can still be moved |
| Unstage | `git restore --staged FILE` | Keeps the working-tree edit |
| Discard unstaged edit | `git restore FILE` | Destructive to that uncommitted edit; inspect first |
| Correct last private commit | `git commit --amend` | Replaces it with a new commit ID |
| Undo a shared commit | `git revert COMMIT` | Adds a new inverse commit; preserves published history |
| Move branch/history | `git reset` variants | `--hard` can discard index/working-tree work; do not use casually |

For exam answers, prefer `revert` for already shared history and reserve amend/rebase/reset for private or explicitly coordinated rewriting.

---

## 3. Reading `git diff` and `git log -p`

### Which diff?

```text
HEAD snapshot ---- staged changes ---- unstaged changes
                  index               working tree
```

- `git diff`: working tree versus index, so unstaged tracked changes.
- `git diff --cached` / `--staged`: index versus `HEAD`, so staged changes.
- `git diff HEAD`: working tree versus `HEAD`, so staged plus unstaged tracked changes.
- Untracked files do not appear as normal content changes until Git is told about them.

Revision comparisons:

```bash
git diff A B
git diff A..B
git diff A...B
```

- `A B` and `A..B` compare the endpoint trees.
- `A...B` compares the merge base of `A` and `B` with `B`; it asks what `B` introduced since divergence and is asymmetric.

### Unified diff anatomy

```diff
diff --git a/sec/hash.c b/sec/hash.c
index 1234567..89abcde 100644
--- a/sec/hash.c
+++ b/sec/hash.c
@@ -1,7 +1,7 @@
 doSomething();
-hash = getHash(val);
+hash = getSaltedHash(val, salt());
```

| Part | Meaning |
|---|---|
| `diff --git a/... b/...` | Old and new paths in Git diff notation |
| `index old..new 100644` | Abbreviated old/new blob IDs and file mode |
| `--- a/...` | Old file |
| `+++ b/...` | New file |
| `@@ -1,7 +1,7 @@` | Hunk location: old range then new range |
| leading space | Unchanged context |
| `-` | Line removed from old version |
| `+` | Line added in new version |

`100644` is a regular non-executable file. For creation/deletion, one side may be `/dev/null`. The `+` in `+++ b/file` is a header marker, not a code addition.

### History direction

Default `git log` is newest first. To reconstruct current content from `git log -p`, begin at the oldest relevant commit at the bottom and apply each patch forward. A direct check in a real repository is:

```bash
git show HEAD:path/to/file
```

---

## 4. A high-quality commit

### Atomicity

An **atomic commit** represents one complete, coherent logical change. Ideally it:

- has one purpose;
- excludes unrelated work in progress;
- builds and passes relevant tests;
- is independently reviewable and, where reasonable, revertible;
- has a message that explains intent.

Atomic does not mean “one file” or “very few lines.” A coherent change can require code, tests, docs, and configuration together.

### Message structure

```text
Use salted hashes

Function getHash() stores password hashes without a salt. Add the salting
step required by the referenced security design.

Signed-off-by: Jane Doe <jane@doe.com>
Reviewed-by: Jean Doe <jean@doe.com>
Tested-by: Judy Doe <judy@doe.com>
```

1. Concise imperative subject.
2. Blank line.
3. Body explaining motivation, context, design, consequences, or references. Explain **why**; the diff shows the technical **what**.
4. Structured responsibility trailers.

### Author versus committer

- **Author:** originally created the change.
- **Committer:** integrated/recorded that change in this repository history.

They may differ when a maintainer applies a patch or a commit is rebased/cherry-picked.

---

## 5. DCO and responsibility trailers

### Developer Certificate of Origin

The DCO is a contributor certification. In exam language, a signatory states that one route applies:

- they created the contribution and may submit it under the indicated open-source license;
- it derives from appropriately licensed work and they may submit the modification;
- another person supplied it after making the same certification and it was passed on unchanged;
- they understand the contribution and identifying sign-off are public, retained, and redistributable under the project/license.

```bash
git commit -s
```

adds:

```text
Signed-off-by: Name <email>
```

### What sign-off is not

- not automatically a cryptographic signature;
- not the same as `git commit -S`, which cryptographically signs;
- not merely a claim of authorship;
- not proof that code is correct, reviewed, or tested;
- not the same instrument as a Contributor License Agreement.

It is a legal/provenance certification about the contribution's allowed origin and route of submission. Multiple sign-offs can document a chain.

| Trailer | Course-figure meaning |
|---|---|
| `Signed-off-by` | DCO/provenance certification |
| `Reviewed-by` | Named person reports review and an acceptable result under project policy |
| `Tested-by` | Named person reports testing |

Git does not magically verify arbitrary trailers. Never add another person's trailer without the required action/permission.

---

## 6. Interruptions, branches, stashes, and Norman's mistake

### Why Norman's history is unsafe

Norman was halfway through new functionality when an urgent production bug arrived. He committed the incomplete feature, then fixed the bug on top and committed again.

Even though the changes are in separate commits, the bug-fix tip includes all ancestor snapshots. Deploying the tip therefore deploys the unfinished feature too. The problem is mixing purposes in one releasable line and basing the hotfix on an unsuitable snapshot.

### Clean hotfix workflow

If the feature is safely committed on a private feature branch:

```bash
git switch main
git switch -c hotfix-production-bug
# edit and test
git add -p
git commit -s -m "Fix production bug"
git switch main
git merge hotfix-production-bug
git switch feature-work
```

If the feature is uncommitted:

```bash
git status
git stash push -m "WIP feature"
# now at the clean HEAD: fix and test the production bug
git add -p
git commit -s -m "Fix production bug"
git stash pop
```

Stash details:

- tracked working-tree/index changes are stashed by default;
- add `-u` only when relevant untracked files belong to the WIP; `-a` also includes ignored files;
- `apply` restores but retains the stash;
- `pop` restores and drops it on success;
- restoration can conflict if the hotfix touched the same lines;
- a stash is repository-wide, not permanently attached to one branch, so name it.

Alternatives include a private WIP commit later cleaned with rebase, selective `git add -p`, or creating the fix on the clean base and `cherry-pick`ing it elsewhere.

Best exam sentence:

> Isolate the WIP on a feature branch or stash, start the bug-fix branch from the clean production base, and commit only the tested, atomic fix.

---

## 7. Merge versus rebase

Assume branches diverged:

```text
          F1 <- F2   feature
         /
A <- B <- C <- D     main
```

### Merge

On `main`:

```bash
git merge feature
```

With divergence, Git performs a three-way merge using both tips and their common ancestor, then normally makes a two-parent commit:

```text
          F1 <- F2
         /         \
A <- B <- C <- D ---- M   main
```

Properties:

- preserves existing commits and branch topology;
- records when lines of development joined;
- normally preserves existing commit IDs;
- may add a non-linear merge commit.

If the current tip is an ancestor of the other tip, Git can **fast-forward** by moving the branch reference. No two-parent merge commit is needed.

### Rebase

On `feature`:

```bash
git rebase main
```

Git finds the common base and replays feature changes on top of `main`:

```text
A <- B <- C <- D <- F1' <- F2'   feature
```

Properties:

- creates new commits with new IDs;
- gives a linear presentation;
- makes the work appear based on the new tip;
- does not preserve the original feature topology;
- may require conflict resolution for several replayed commits.

### Conflicts

```bash
# resolve marked files, then:
git add <resolved-files>
git rebase --continue

# abandon:
git rebase --abort
```

For a merge, resolve, stage, and commit; use `git merge --abort` to abandon when available.

### Golden rule

Do not casually rebase commits collaborators already use. Rebase abandons old identities and replaces them. Safe default:

- clean/rebase your own private branch before sharing;
- merge shared/public history;
- rewrite shared history only with explicit coordination.

---

## 8. Interactive rebase and presentation history

```bash
git rebase -i --root
# or only the latest five commits
git rebase -i HEAD~5
```

| Action | Effect |
|---|---|
| `pick` | Keep commit |
| `reword` | Keep change, edit message |
| `edit` | Stop so content/metadata can be amended |
| `squash` | Combine into previous commit and combine/edit messages |
| `fixup` | Combine into previous commit and normally discard this message |
| `drop` | Remove commit |
| reorder lines | Replay commits in a new order |

New fixups can be prepared with:

```bash
git commit --fixup=<target-commit>
git rebase -i --autosquash <base>
```

Important nuance for the supplied history: its messages use `fixup:` with a colon, not Git's recognized `fixup! <target subject>` form. Autosquash will not auto-place them; reorder and label them manually.

Development history can preserve experiments and dead ends, while presentation history optimizes review and reuse. A strong answer acknowledges the trade-off: keep an archival/raw reference if needed, publish a clean logical series, and never claim rewritten history is untouched chronology.

---

## 9. Creating and applying patches

### Plain diff patch

Create:

```bash
git diff BASE..TIP > change.patch
```

Check and apply:

```bash
git apply --check change.patch
git apply change.patch
git diff
git add <files>
git commit
```

Key properties:

- `git apply` changes the working tree and normally creates no commit;
- a plain diff does not preserve original author/date/message as a new commit;
- `--check` tests applicability without changing files;
- `--index` applies to the index and working tree;
- `--3way` can help when blob information/objects are available;
- `-R` applies the patch in reverse;
- use `git diff --binary` when a raw patch must include suitable binary changes.

### Commit-aware series

```bash
git format-patch BASE..TIP
git format-patch -1 COMMIT
git am --3way 0001-description.patch
```

If application conflicts:

```bash
# resolve and stage
git am --continue
# or
git am --abort
```

`format-patch` normally emits one mail-formatted patch per non-merge commit, including author identity/date, message, and technical diff. `git am` creates new commits that preserve those author/message fields and boundaries, but their parent, committer metadata/date, and commit IDs can differ.

```text
git diff / git apply      -> file changes; receiver stages/commits
git format-patch / git am -> commit-aware patches become commits
```

For a reproducible patch stack, record exact upstream URL/base commit, patch order and hashes, tools/commands, submodules/assets, license/provenance, tests, and expected final tree/commit.

---

## 10. Snapshot versus clone plus patches versus fork

| Strategy | Advantages | Risks/disadvantages |
|---|---|---|
| Final source snapshot | Simple, offline/self-contained if complete, easy to checksum/archive | Often loses Git history, exact upstream base, responsibility trail, and separation of changes; harder to review/update; license/notices still required |
| Exact upstream plus patch stack | Compact, separates upstream/research work, reviewable/replayable; `format-patch` can retain authors/messages | Must pin/preserve base and order; network/upstream can disappear; patches can conflict; raw diffs may lose metadata/binary detail |
| Hosted fork | Full reachable history, exact commits, natural branches/tags/PRs, easy collaboration/upstream syncing | Platform/account/network dependent; refs can move or be force-pushed; fork can disappear/diverge; not archival by itself |

Best reproducibility answer:

1. Record upstream URL, license, and exact base commit.
2. Preserve research commits in a full repository/fork or ordered commit-aware series.
3. Identify the exact final commit/tag.
4. Archive the needed repository and patches in the package or a long-term repository; a `git bundle` can preserve full Git data.
5. Provide one tested reconstruction/build command and expected checksums.

The word **latest** is a warning. Reproduction needs an exact immutable revision.

---

## 11. Solved In-Class Exercise Sheet 4

### Q1: what should Norman have done? [IC4 pp. 1-2]

Isolate unfinished work with a feature branch or stash, create the hotfix from clean production, stage only the fix, test it, and make one atomic commit. A separate WIP commit on the same ancestry is still unsafe because the bug-fix tip includes that ancestor.

### Q2: exact current `saucy.md` [IC4 p. 3]

Apply `git log -p` oldest to newest:

```markdown
# Spicy Green Mean Machine

## Ingredients
1/2 cup - Plain yogurt
3-4 cloves - Garlic
2 cups - Chopped cilantro
1/4 cup - Olive oil
1/4 cup - Lime juice
2 pinches - Salt
2 - Jalapenos, deseeded

## Instructions
Add all ingredients to a blender. Mix until desired consistency.
```

Derivation:

1. `first attempt` creates the original.
2. `make it spicy` adds one jalapeno.
3. `update recipe name` changes the title.
4. `add punch` makes salt/jalapenos two and changes “smooth” to “desired consistency.”

### Q3: patch and responsibility labels [IC4 p. 4]

| Arrow | Full-mark label |
|---|---|
| `commit: aa09...` | Commit object ID/hash for this exact history object |
| `Author: Jane...` | Original creator of the change |
| `Committer: John...` | Person who integrated/recorded it |
| `Use salted hashes` | Concise commit subject |
| Explanatory paragraph | Commit body: motivation/context/rationale/reference |
| `Signed-off-by` | DCO/provenance certification |
| `Reviewed-by` | Named reviewer reports review |
| `Tested-by` | Named tester reports testing |
| `diff --git a/... b/...` | Diff file header with old/new paths |
| `@@ -1,7 +1,7 @@` | Old/new hunk ranges |
| `doSomething();` | Unchanged context |
| `-hash...` / `+hash...` | Removed old line / added replacement |

The PDF typography shows an en dash in one `diff –git`; real Git output uses ASCII `diff --git`.

### Q4: package strategies [IC4 p. 4]

Use Section 10. Time-pressure answer:

> A snapshot is simplest but hides history and the upstream/local boundary. An exact upstream revision plus ordered commit-aware patches is compact and auditable but depends on preserving the base/order. A fork preserves full history and supports collaboration, but a live hosting URL is not archival. I would archive the exact upstream and final commits, license, history/patches, dependencies, and tested commands.

### Q5: clean the hello-world history [IC4 p. 5]

Current logical targets:

- `ab1f4d7...` fixes `d7fc97a...` (“Add code proper”).
- `009230f...` fixes `8cdb592...` (“Add build infrastructure”).

Create a safety branch for real work, then:

```bash
git branch backup/before-history-cleanup
git rebase -i --root
```

Todo, oldest first:

```text
pick  9cba6f7  Kick-Off a new project: The ultimate hello world tool
pick  d7fc97a  Add code proper
fixup ab1f4d7  fixup: Actually improve code quality
pick  8cdb592  Add build infrastructure
fixup 009230f  fixup: Ensure that build system sets highest standards
```

Desired three logical commits:

1. Kick off project and README.
2. Add already-correct C program (`int main`, `return 0`).
3. Add build infrastructure already using `-Wall -Werror -pedantic`.

Each correction must immediately follow its target. `fixup` absorbs the change and drops the fixup message; `squash` would combine/edit messages.

Verify:

```bash
git log --graph --oneline --decorate
make
git diff backup/before-history-cleanup HEAD --
```

The last diff should be empty: cleaner history, same final tree. Preserve meaningful authorship/sign-offs, expect new hashes, and avoid rewriting public history. If an authorized rewritten branch must be pushed, `--force-with-lease` is safer than blind `--force`.

---

## 12. Structural equivalence and XPath [L4 pp. 1-3]

### Equality is a design decision

Possible output relations include byte identity, scalar equality, normalized-value equality, recursive structural equality, object identity, or scientific agreement within tolerance. The right relation depends on what the experiment promises.

### Lab XML

```xml
<experiments>
  <exp id="A"><time unit="s">42</time></exp>
  <exp id="B"><time>42</time></exp>
  <exp id="C"><time>42</time></exp>
  <exp id="D">
    <time>40</time>
    <time>42</time>
  </exp>
  <exp id="E"><time> 42 </time></exp>
</experiments>
```

### `eq`: singleton value comparison

`eq` atomizes nodes and compares one atomic value with one value.

- empty operand can yield an empty sequence;
- more than one atomized item causes dynamic error `XPTY0004`;
- untyped XML values are cast to strings for value comparison;
- spaces in `" 42 "` remain significant unless explicitly normalized.

Use it for one measurement against one expected scalar.

### `deep-equal()`: recursive structure/content

For these examples, it requires sequences with the same length/order and selected nodes with matching kinds, names, attributes, text, and recursive children.

- node identity need not match;
- parents do not matter if only child nodes are selected;
- attribute order is irrelevant, but attribute names/values matter;
- child order and significant text/whitespace matter.

Use it to regression-test XML subtrees or ordered structured results.

### `is`: node identity

`A is B` is true only when both expressions identify the exact same XDM node. Matching appearance is insufficient. Each operand must be a single node or empty; a longer sequence is an error.

Use it to test whether two paths/variables alias the same parsed node.

### `=`: general/existential comparison

General comparison accepts sequences and is true when **at least one cross-pair** has equal values:

```text
(42) = (40, 42)  -> true
```

It does not require equal lengths/order or all values equal. For sequences, `!=` is not always the logical inverse of `=`: one pair can be equal while another pair is unequal.

Use it for membership/overlap: “does any observed value match any allowed value?”

### Exact lab results

| Expression | Result | Reason |
|---|---:|---|
| `A/time eq E/time` | `false` | Atomized strings are `"42"` and `" 42 "` |
| `deep-equal(A/time,B/time)` | `false` | A alone has `unit="s"` |
| `deep-equal(A/time,E/time)` | `false` | Attribute sets and text differ |
| `B/time is C/time` | `false` | Distinct nodes |
| `B/time = D/time` | `true` | D's sequence contains `42` |
| `B/time eq C/time` | `true` | Both singleton values are `"42"` |
| `deep-equal(B/time,C/time)` | `true` | Selected `<time>` structures/content match |
| `B/time is B/time` | `true` | Same selected node |
| `D/time eq B/time` | `XPTY0004` | D selects two values |
| `normalize-space(A/time) eq normalize-space(E/time)` | `true` | Explicit normalization removes spaces |

### Xidel workflow

First update the existing lab clone:

```bash
git pull
```

Then:

```bash
cd LabSession4/2_structural_equivalence/
docker build -t xidel-env .
docker run --rm -it xidel-env
xidel experiments.xml -se "<XPath expression>"
```

- `-s`: suppress status/metadata output.
- `-e`: evaluate the expression.
- Quotes prevent the shell interpreting XPath punctuation.
- `--rm` deletes the stopped container, not the image.
- `-it` supplies an interactive terminal.

---

## 13. Freezing LaTeX dependencies [L4 pp. 3-5]

LaTeX is modular. A TeX Live bundle is convenient but large. TinyTeX is lighter, but downloading missing packages on demand makes the effective environment drift. Install the complete package set during the image build.

### TeX Live image

Build from `LabSession4/4_reporting/`. A complete minimal pattern is:

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive-fonts-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY . /work/

RUN pdflatex -interaction=nonstopmode -halt-on-error experiment.tex && \
    pdflatex -interaction=nonstopmode -halt-on-error experiment.tex

CMD ["sh", "-c", "pdflatex -interaction=nonstopmode -halt-on-error experiment.tex && pdflatex -interaction=nonstopmode -halt-on-error experiment.tex"]
```

The first run writes cross-reference data; the second resolves references such as `\ref{fig:results_plot}`.

### TinyTeX image

Bootstrap requirements:

```text
ca-certificates  perl  wget  xz-utils
```

Complete TinyTeX pattern:

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    perl \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- "https://tinytex.yihui.org/install-bin-unix.sh" | sh
ENV PATH="/root/.TinyTeX/bin/x86_64-linux:${PATH}"

# Operational TeX Live package names:
RUN tlmgr install amsmath graphics hyperref

WORKDIR /work
COPY . /work/

RUN pdflatex -interaction=nonstopmode -halt-on-error experiment.tex && \
    pdflatex -interaction=nonstopmode -halt-on-error experiment.tex

CMD ["sh", "-c", "pdflatex -interaction=nonstopmode -halt-on-error experiment.tex && pdflatex -interaction=nonstopmode -halt-on-error experiment.tex"]
```

Build and run both variants:

```bash
cd LabSession4/4_reporting/
docker build -f Dockerfile.texlive -t repeng-texlive .
docker run --rm repeng-texlive
docker build -f Dockerfile.tinytex -t repeng-tinytex .
docker run --rm repeng-tinytex
docker images
```

**Sheet wording versus operational name:** the sheet literally asks for `tlmgr install amsmath graphicx hyperref`, which is the exam phrase to recognize. [CTAN records `graphicx` as contained in TeX Live package `graphics`](https://ctan.org/pkg/graphicx), so a working `tlmgr` command normally uses `amsmath graphics hyperref`.

Add every other package used by `experiment.tex`. “At least” the listed set is not universally sufficient. The shown PATH is x86-64-specific; other architectures can differ. For strict freezing, also pin/archive the TinyTeX installer and TeX repository/package versions; an online install script plus unversioned `tlmgr` packages can still drift.

In the Dockerfile multiple-choice snippets, `--no-install-recommends` avoids optional apt packages and removing `/var/lib/apt/lists/*` reduces the final layer/stale cache. These are useful size/hygiene measures, but neither pins a dependency version.

### Image sizes

```bash
docker pull ubuntu:24.04
docker images
```

Expected qualitative order:

```text
Ubuntu base < minimal TinyTeX < TeX Live bundle
```

The supplied size table is intentionally blank. Do not memorize fabricated MB values; size varies with architecture, date, versions, and cleanup.

### Pinning hierarchy

1. `ubuntu:latest` and unversioned packages: freely drift.
2. `ubuntu:24.04`: better release selection, but still a movable tag.
3. Exact package versions: better, but repositories can later remove them.
4. Image digest plus locks/hashes and repository snapshots: much stronger.
5. Preserve/archive the built image and sources: also protects against disappearance.

Pinning selection and guaranteeing future buildability are different problems.

---

## 14. Automated reporting and repeatability [L4 pp. 5-6]

### Required paper content

1. **Hypothesis/RQ:** precise, testable, connected to a metric.
2. **Setup:** `pplease`/Python/LLM implementation, container and host, input provenance, metric, repetitions, seeds, and aggregation such as mean/median.
3. **Results:** chart generated by a Python script, aligned with the hypothesis/RQ, plus textual interpretation.
4. **Discussion:** answer the RQ, assess the hypothesis, limitations, and threats.
5. **Feedback:** peer review, revision, then tutor feedback.

### End-to-end Gold pipeline

Start with the Sheet 3 reproduction Dockerfile and add the TinyTeX bootstrap/package steps to **that same image**. Keep its Python runtime, dependencies, inputs, and scripts. The resulting container must both run the experiment and compile LaTeX.

```text
input + code + frozen environment
              |
              v
        run experiments
              |
              v
      result data + chart
              |
              v
       LaTeX paper -> PDF
```

The chart path must exactly match LaTeX:

```latex
\includegraphics{results/chart.pdf}
```

Robust dispatcher shape:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Keep the existing Sheet 3 commands that run pplease and write result data.
# Then call the Python chart script; it must write results/chart.pdf.
# Example shape (adapt filenames/arguments to your implementation):
# python3 pplease.py < input.txt > results/generated.txt
# python3 plot_results.py results/generated.txt results/chart.pdf

test -s results/chart.pdf

pdflatex -interaction=nonstopmode -halt-on-error experiment.tex
pdflatex -interaction=nonstopmode -halt-on-error experiment.tex
```

- `nonstopmode`: no wait for interactive input.
- `halt-on-error`: stop instead of silently continuing.
- `set -euo pipefail`: useful fail-fast shell behavior, though not an explicit sheet requirement.

This reaches Module 2's Gold idea because one dispatcher covers experiments, chart, and final paper.

### Hashes and repeatability

Exact test procedure:

```bash
./run_experiment.sh
# Visually inspect experiment.pdf, including the generated figure.
cp experiment.pdf /tmp/experiment-run1.pdf

# Change no code or data.
./run_experiment.sh
cp experiment.pdf /tmp/experiment-run2.pdf

md5sum /tmp/experiment-run1.pdf /tmp/experiment-run2.pdf
```

Preserve the first PDF or at least record its hash before the second run overwrites it.

- equal hashes: byte streams are identical for this test;
- unequal hashes: bytes differ;
- unequal hashes alone do not prove data, chart values, conclusions, or visible pages differ.

Non-scientific byte differences can come from timestamps, PDF IDs/metadata, generated-chart metadata, object ordering/compression, locale, timezone, paths, or tool versions. Scientific differences can come from randomness, changed inputs, floating-point/environment variation, or nondeterministic ordering.

Full-mark answer:

> Different MD5 values prove that the PDF artifacts are not bitwise identical. They do not alone show a different scientific result. Define the required equivalence and compare raw result data, chart values/content, extracted text, or canonicalized structure. If those agree, the result may be semantically repeatable even though PDF serialization is not. For byte identity, freeze tools/inputs and control randomness, timestamps, metadata, locale, and supported deterministic settings such as `SOURCE_DATE_EPOCH`.

MD5 is acceptable here as a quick equality test; SHA-256 is preferable for serious integrity/security use.

---

## 15. Solved Lab Sheet 4 multiple choice [L4 pp. 7-8]

### 5(a)

Correct:

```xpath
//exp[@id='1']/time = //exp[@id='2']/time
```

The right side is `(41,42)`, so `=` finds the matching `42`. `eq` raises a cardinality error; `deep-equal` sees different lengths; the `exp` nodes are not identical.

### 5(b)

False:

```xpath
//exp[@id='1'] is //exp[@id='2']
```

They are different nodes. Their selected `time` values are equal with `eq`/`=`, and the selected `time` elements are deep-equal.

### 5(c)

**Course-intended answer: 1, only snippet A.**

| Snippet | Course classification |
|---|---|
| A | Accept: `ubuntu:24.04` and `python3=3.12.3-0ubuntu2.1` |
| B | Reject: `python3` is unversioned |
| C | Reject: `ubuntu:latest` moves |
| D | Reject: apt packages are pinned, but `pip install pandas` is unversioned |

Real-world caveat: even A is not an eternal bitwise guarantee because `ubuntu:24.04` is not a digest and apt repositories change. In the MC abstraction, mark **1**; in an explanation, add the digest/repository-snapshot caveat.

---

## 16. Common exam traps

1. `git diff` excludes staged changes; use `git diff --staged`.
2. A commit is a snapshot with parents/metadata; a patch is change relative to a base.
3. Default `git log` is newest first.
4. Context lines begin with a space; `---`/`+++` are headers.
5. Author created; committer integrated.
6. `Signed-off-by` is DCO certification, not GPG signing or testing.
7. Atomic means one logical purpose, not one file.
8. A hotfix must start from clean production, not a WIP feature snapshot.
9. Fast-forward moves a reference; it need not create a merge commit.
10. Merge preserves topology/IDs; rebase replaces replayed commit IDs.
11. Do not rewrite shared history without coordination.
12. `git apply` normally creates no commit; `git am` applies mail patches as commits.
13. A live fork or “latest” snapshot is not an immutable archive.
14. `eq` with multiple items is an error, not `false`.
15. `=` asks whether any pair matches, not whether sequences are identical.
16. `is` asks identity, not content equality.
17. `deep-equal(B/time,C/time)` ignores their unselected parent IDs.
18. XML text whitespace can be data.
19. TinyTeX auto-download allows dependency drift.
20. Run LaTeX twice when references must resolve.
21. Different PDF hashes prove different bytes, not automatically different science.
22. Lab 5(c)'s course answer is 1, although strict immutability needs stronger pinning.

---

## 17. Likely exam prompts: answer skeletons

### Why version control for reproducibility?

It identifies exact states and changes, records ordered provenance/responsibility, supports inspection/reversion/reapplication, and lets a package cite an exact revision. Add that a mutable remote is not archival; preserve the referenced objects/environment.

### Explain a diff

Identify old/new paths, blob IDs/mode, file headers, hunk ranges, context, deletion, addition, then summarize the semantic change.

### Urgent fix during unfinished work

Isolate WIP, start hotfix from clean production, stage/test/commit only the fix, integrate, then resume WIP.

### Merge or rebase?

Draw both graphs. Merge preserves topology/IDs; rebase replays to create a linear history with new IDs. Mention conflicts and the shared-history rule.

### What does DCO sign-off establish?

A contributor certifies an allowed origin/right-to-submit path and public retention/redistribution of the record. It is not cryptographic proof, review, or testing.

### Why patches in a reproduction package?

They isolate research changes from an exact upstream base. Preserve base, order, metadata, hashes, application/tests. Distinguish `diff/apply` from `format-patch/am`.

### Which XPath relation?

Define the intended equivalence first: `eq` one scalar, `=` any sequence pair, `deep-equal` recursive content, `is` node identity. Mention cardinality/whitespace.

### Are different-hash PDFs repeatable?

Not byte-identical. Determine whether the claimed result is the serialized PDF or scientific content; compare appropriate data/structure and identify nondeterminism.

### How does the lab reach Gold?

The container captures Python/LaTeX dependencies; one dispatcher runs experiments, generates the chart at a fixed path, and compiles the documented final paper with fail-fast behavior.

---

## 18. Final two-minute recall sheet

```text
GIT STATES
  WT --add--> index --commit--> repository
  diff = WT:index
  diff --staged = index:HEAD
  diff HEAD = WT:HEAD (tracked)

DIFF
  --- old, +++ new
  @@ -old +new @@ hunk
  space=context, -=removed, +=added

COMMIT
  one coherent logical change
  author made it; committer integrated it
  subject + body + trailers
  -s DCO sign-off; -S cryptographic signature

INTEGRATION
  merge preserves graph/IDs; fast-forward may only move a ref
  rebase replays -> new IDs; do not rewrite shared history casually
  rebase -i: pick/reword/edit/squash/fixup/drop/reorder

PATCHES
  git diff -> git apply -> stage/commit yourself
  format-patch -> am -> preserve author/date/message + boundaries
                       but new committer/parents/IDs are possible

PACKAGE
  never say "latest"
  upstream URL + license + exact base + exact final revision
  archive repo/patches + tested reconstruction

XPATH E-D-I-G
  eq = singleton value; >1 item is XPTY0004
  deep-equal = ordered recursive structure/content
  is = exact same node
  = = any equal cross-pair

LAB
  A eq E false (whitespace)
  deep-equal A/B false (attribute)
  B is C false (identity)
  B = D true (D contains 42)
  MC: (a) =, (b) is is false, (c) 1/A only

REPORTING
  explicit TinyTeX packages; pdflatex twice
  experiment -> data/chart -> paper, one dispatcher
  unequal PDF hashes = unequal bytes, not automatically unequal science
```

---

## 19. Self-test

1. What does plain `git diff` compare?
2. Why can a staged change be absent from it?
3. What are the old/new ranges in a hunk header?
4. Author versus committer?
5. What does `git commit -s` add/certify?
6. Why was Norman's separate WIP commit still unsafe?
7. When is merge a fast-forward?
8. Why do rebase hashes change?
9. Which action absorbs a correction and discards its message?
10. `git apply` versus `git am`?
11. Why is “latest upstream” insufficient?
12. `eq` with a two-item operand?
13. Why can B be `deep-equal` to C but not `is` C?
14. Why is B generally equal to D?
15. Why is A not value-equal to E?
16. Why install TinyTeX packages explicitly?
17. Why compile LaTeX twice?
18. What does PDF MD5 mismatch prove?
19. Lab 5(c) answer?
20. What are the three cleaned hello-world commits?

### Answers

1. Working tree versus index: unstaged tracked changes.
2. It is already in the index; use `git diff --staged`.
3. `-oldStart,oldCount`, then `+newStart,newCount`.
4. Originator versus person who recorded/applied the commit.
5. `Signed-off-by`, certifying DCO/right-to-submit provenance.
6. The bug-fix tip includes its incomplete ancestor.
7. Current tip is an ancestor of the other tip, so only the reference moves.
8. Replayed commits have different parents and become new objects.
9. `fixup`.
10. `apply` changes files without normally committing; `am` creates commits from mail patches.
11. A moving name/remote may change or disappear; preserve an exact base.
12. Dynamic type/cardinality error `XPTY0004`.
13. Selected structures match, but they are distinct nodes.
14. D's values include the matching `42`.
15. E's text contains significant surrounding spaces.
16. On-demand downloads drift across builds.
17. First writes cross-reference data; second resolves it.
18. Only that the PDF byte streams differ.
19. One snippet: A.
20. Kickoff/README; corrected C program; corrected strict build infrastructure.

---

## Sources covered

Every file under `Mod4` was audited:

- [In-Class Exercise Sheet 4](./4-Version_Control/SoSe_2026_RepEng_IC_4___git.pdf)
- [Lab Exercise Sheet 4](./Lab_Session_4/Sheet_4.pdf)
- [`Udacity_Course_on_git.url`](./4-Version_Control/Udacity_Course_on_git.url)
- [`git_diff.url`](./4-Version_Control/git_diff.url)
- [`git_merge_and_rebase.url`](./4-Version_Control/git_merge_and_rebase.url)
- [`Create_and_apply_a_git_patch.url`](./4-Version_Control/Create_and_apply_a_git_patch.url)
- [`Developer_certificate_of_origin.url`](./4-Version_Control/Developer_certificate_of_origin.url)

PDF coverage map:

- In-Class pp. 1-2: Norman/WIP isolation; p. 3: `git log -p`; p. 4: patch responsibility and packaging; p. 5: history cleanup.
- Lab pp. 1-3: structural equivalence/XPath; pp. 3-5: TeX Live/TinyTeX; pp. 5-6: report and Gold pipeline; pp. 7-8: multiple choice.

Source keys used inline: **IC4** = In-Class Exercise Sheet 4; **L4** = Lab Exercise Sheet 4.

The duplicate Lab Sheet 4 in the combined exercises directory is byte-for-byte identical (SHA-256 `cb4694f457a6a55c0bb25f2ff0b827b29a1cf4770ba0d3e383dd6828ff59eb91`).

Authoritative equivalents used to verify the shortcut topics and lab semantics:

- [Udacity: Version Control with Git](https://www.udacity.com/course/version-control-with-git--ud123)
- [Git `diff`](https://git-scm.com/docs/git-diff)
- [Git branching/merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)
- [Git rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing)
- [Git `format-patch`](https://git-scm.com/docs/git-format-patch), [`am`](https://git-scm.com/docs/git-am), and [`apply`](https://git-scm.com/docs/git-apply)
- [DCO 1.1](https://developercertificate.org/)
- [W3C XPath comparisons](https://www.w3.org/TR/xpath-30/#id-comparisons)
- [W3C `deep-equal`](https://www.w3.org/TR/xpath-functions-30/#func-deep-equal)
- [CTAN `graphicx` package mapping](https://ctan.org/pkg/graphicx)

The five `.url` files are authenticated Stud.IP wrappers; their public target URLs are not stored locally. Their assigned topics were cross-checked against the official Git, DCO, and W3C sources above.
