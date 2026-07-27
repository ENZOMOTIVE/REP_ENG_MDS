# Reproducibility Engineering - Module 5 Exam Guide

> An exam-first guide to every item in the Module 5 folder: reproducible and deterministic builds, the C build pipeline, headers and multiple source files, Makefiles, the C preprocessor, predefined macros, the `assert`/`NDEBUG` heisenbug, and every task on Lab Sheet 5.

---

## How to use this guide before the exam on the 29th

If time is short, study in this order:

1. Memorize the **six rules** in the next section.
2. Work through the solved In-Class Sheet 5 answers in Section 6 without looking at the answer first.
3. Learn the Makefile syntax, automatic variables, and timestamp questions in Section 4.
4. Learn the preprocessor and heisenbug answers in Section 5.
5. Review the Git lab answer key in Section 7.
6. Finish with the traps, self-test, and two-minute recall sheet.

Source references use the key at the end. Page numbers are **PDF page numbers**, not the printed book page numbers.

---

## 1. The whole module in one page

### Six rules to memorize

1. **Definition:** A build is reproducible when the same source code, declared build environment, and build instructions let any party recreate **bit-for-bit identical specified artifacts**. Identity is normally checked with a cryptographic hash. [RB-DEF]
2. **Build pipeline:** `source -> preprocess -> compile -> assemble -> object files -> link -> executable`. [C4, pp. 22-23]
3. **Make rule:** `target: prerequisites`, followed by a **literal tab** and the recipe. A target is rebuilt if it is missing or a prerequisite is newer. [C4, pp. 34-37]
4. **Determinism rule:** ensure stable inputs, stable outputs, and capture as little uncontrolled environment state as possible. [RB-DET]
5. **Preprocessor warning:** `__DATE__` and `__TIME__` leak build time; `__FILE__` can leak a build path. These can make otherwise unchanged binaries differ. [IC5, p. 7; GCC-MACROS]
6. **Assertion warning:** never put a required side effect inside `assert(...)`; `-DNDEBUG` removes the assertion **and does not evaluate its argument**. [IC5, p. 8; HEISENBUG]

Mnemonic:

```text
SBI + SOS

Same Source + Build instructions + declared environment -> Identical bits
Stable inputs + Stable outputs + Small environmental capture
```

### The C pipeline and the commands

```text
file.c + included headers
          |
          | preprocessor: #include, #define, #if/#ifdef
          v
expanded translation unit
          |
          | compiler
          v
assembly
          |
          | assembler
          v
file.o object code ----+
other.o object code ---+-- linker + libraries --> executable
```

```bash
gcc -E file.c                  # preprocess only
gcc -S file.c                  # stop after producing assembly
gcc -c file.c -o file.o       # produce object code; do not link
gcc main.o helper.o -o tool   # link object files
gcc main.c helper.c -o tool   # let gcc drive every stage
./tool                         # run on Unix-like systems
```

The stage-control flags are documented by GCC's overall invocation options. [GCC-STAGES]

Strictly, GCC is a **compiler driver**: it coordinates preprocessing, compilation, assembly, and linking. In casual speech, the whole operation is often called compilation. [C4, pp. 18, 22-25]

### Make in a few lines

```make
tool: main.o helper.o
	$(CC) -o $@ $^

main.o: main.c main.h helper.h
	$(CC) -c main.c

helper.o: helper.c helper.h
	$(CC) -c helper.c
```

- `tool`, `main.o`, and `helper.o` are targets. Because `tool` is first, it is the default goal for plain `make`.
- The names after `:` are prerequisites/dependencies.
- The indented shell line is a recipe; the indentation must be a real tab.
- `$@` = current target; `$^` = all normal prerequisites in order, with duplicates removed; `$<` = first normal prerequisite. Order-only prerequisites are available through `$|`.

### The five most likely sources of different binaries

| Variation | Typical leak | Core fix |
|---|---|---|
| Time | `__DATE__`, `__TIME__`, archive timestamps | Remove it or use a deterministic reference such as `SOURCE_DATE_EPOCH` when supported. |
| Input order | directory traversal, locale-sensitive wildcard sorting | List inputs explicitly or sort them in a locale-independent way. |
| Build path | `__FILE__`, debug info, generated paths | Use a fixed path or compiler path-remapping support. |
| Environment/toolchain | compiler/dependency versions, flags, locale, timezone | Declare, pin, minimize, and recreate the build environment. |
| Random/undefined state | random seeds, uninitialized memory, races | Remove randomness from outputs, seed it when legitimate, initialize values, and avoid race-dependent output. |

### If the exam asks this, answer this

| Prompt | High-scoring first sentence |
|---|---|
| Define a reproducible build | "The same source, declared environment, and instructions must let any party recreate all specified artifacts bit for bit." |
| Why is the wildcard Makefile bad? | "`$(wildcard *.c)` can be ordered by the current locale, and that order reaches the linker through `$^`." |
| How does Make decide to rebuild? | "A missing target or a prerequisite newer than its target makes the target out of date; rebuilding propagates through the dependency graph." |
| Why do time macros matter? | "They substitute the current translation date/time into the source, so builds at different times contain different bytes." |
| What does `-DNDEBUG` do? | "It defines `NDEBUG`, so `assert` becomes a no-op and its expression is not evaluated." |
| Declaration versus definition | "A declaration tells the compiler a function's type signature; a definition also supplies its body." |
| Merge versus rebase | "Merge preserves both ancestry lines, normally with a merge commit; rebase replays commits onto a new base and rewrites their identities." |

---

## 2. Reproducible builds

### Exact definition and necessary ingredients

The Reproducible Builds project defines a build as reproducible if, given the same:

- **source code**, normally an exact VCS revision or source archive;
- **build environment**, including relevant tools, versions, flags, dependencies, locale, and environment variables; and
- **build instructions**;

any party can recreate **bit-by-bit identical copies of every specified primary artifact**, such as an executable, package, or filesystem image. Build logs are usually ancillary rather than the artifact being compared. [RB-DEF]

This is stronger and more specific than merely saying "the program works again." The central claim is an independently verifiable path:

```text
declared source + declared environment + declared build procedure
                              |
                              v
                  identical artifact bytes
                              |
                              v
                  identical cryptographic hash
```

### Deterministic is necessary but not sufficient

- A **deterministic build system** gives the same output whenever its defined inputs and environment are the same.
- A **reproducible build** adds independent recreation: another party must be able to reconstruct a sufficiently matching environment, run the build, and verify identical artifacts.
- A build that is deterministic only on one undocumented laptop is not independently reproducible.
- Two identical hashes show byte identity of the compared artifacts; they do not, by themselves, prove that the source is safe or correct.

The official three-step model is:

1. Make the build process deterministic.
2. Record or define the tools and relevant environment.
3. Give others a way to recreate that environment, rebuild, and compare. [RB-HOME]

### Why reproducible builds matter

The main security purpose is to detect a compromised build path: an independent clean build can reveal that a distributed binary contains changes absent from the published source. Other benefits include:

- finding race, timing, locale, encoding, and dependency problems;
- proving that a build-system change did not alter the produced binary;
- recreating matching debug symbols for production artifacts;
- making binary differences smaller and more meaningful;
- improving dependency awareness and software-supply-chain auditing;
- avoiding unnecessary downstream rebuilds when output is unchanged. [RB-WHY]

Exam nuance: reproducibility makes tampering **detectable through comparison**. It does not prevent every attack, guarantee the correctness of the source, or solve the "trusting trust" problem by itself.

### The deterministic-build checklist

The shortest official summary is:

```text
stable inputs + stable outputs + minimal environment capture
```

Use this expanded checklist in a design question:

| Problem source | Why output can change | What to do |
|---|---|---|
| Current time/date | A different value is embedded on every build | Omit it; otherwise derive a reference time from source history and use `SOURCE_DATE_EPOCH` where supported. |
| Timezone | The same timestamp formats differently | Normalize timezone, commonly UTC. |
| Locale | Filename collation, messages, decimal formats, and generated text vary | Fix the locale or use a locale-independent operation. |
| Filesystem enumeration | Directory order is not a reliable API contract | Explicitly list or deterministically sort inputs. |
| Output order | Hash maps, parallel tasks, or traversal order change serialization | Sort/canonicalize output before writing it. |
| Randomness | Random identifiers, seeds, or layout change bytes | Eliminate it from the artifact or use a controlled deterministic seed. |
| Uninitialized memory | Arbitrary memory contents leak into output | Initialize every output-affecting value. |
| Absolute build path | Paths enter `__FILE__`, debug data, archives, or generated files | Use a fixed build root or path-prefix mapping. |
| User/host information | Username, hostname, home path, or environment enters output | Do not embed it; sanitize relevant variables. |
| Tool/dependency drift | Different compiler/library versions legitimately emit different bytes | Pin and make the toolchain/environment recreatable. |
| Network downloads | Mutable or unavailable resources change/disappear | Vendor, archive, checksum, or otherwise lock every dependency. |
| Archive metadata | Member order, timestamps, owner, group, or permissions differ | Normalize metadata and order. |
| Concurrency | Races change ordering or content | Make output independent of scheduling or serialize the affected step. |

### `SOURCE_DATE_EPOCH`

`SOURCE_DATE_EPOCH` is a distribution-independent convention for passing one deterministic timestamp through the build environment. Its value is an ASCII integer containing seconds since `1970-01-01 00:00:00 UTC`, usually derived from the latest source modification. Supporting tools use it instead of the current time for embedded timestamps. [SDE]

```bash
export SOURCE_DATE_EPOCH=1710000000
make
```

Important limits:

- It works only when the involved tool honors it.
- It fixes time-dependent output, not locale, path, ordering, random, tool-version, or all archive-metadata problems.
- A fixed arbitrary timestamp can make output deterministic, but a source-derived value preserves useful provenance.

### How to verify a reproducible build

A sound verification procedure is:

1. Select the exact source revision.
2. Recreate the declared build environment and dependencies.
3. Run the documented build without reusing undeclared local products.
4. Hash every specified artifact, for example with `sha256sum`.
5. If hashes differ, inspect the artifact difference and vary one environmental dimension at a time: time, timezone, locale, path, file order, user, toolchain, and parallelism.

```bash
sha256sum build-a/tool build-b/tool
cmp build-a/tool build-b/tool
```

`cmp` or hashes tell you **that** bytes differ. A structural comparison tool such as `diffoscope` can help explain **where and why** they differ.

---

## 3. C essentials used by this module

### Anatomy of a small C program

```c
#include <stdio.h>

int main()
{
    puts("C rocks!");
    return 0;
}
```

- A `.c` file contains human-readable source.
- `#include <stdio.h>` asks the preprocessor to include declarations for standard input/output functions.
- Execution begins at `main` in a hosted C program.
- `main` returns an `int`; `0` conventionally signals successful termination.
- `gcc source.c -o program` builds an executable; `./program` runs it on Unix-like systems.
- `gcc source.c -o program && ./program` runs only if the build succeeded. [C1, pp. 3, 5-9]
- `echo $?` on a Unix-like shell displays the previous command's exit status. [C1, p. 6]

### Solved card-value reconstruction

The first in-class puzzle becomes the following. Its magnets use `int main()` exactly; in a modern no-argument definition, `int main(void)` states the intent more explicitly. [IC5, p. 1; C1, p. 7]

```c
#include <stdio.h>
#include <stdlib.h>

int main()
{
    char card_name[3];
    puts("Enter the card_name: ");
    scanf("%2s", card_name);

    int val = 0;
    if (card_name[0] == 'K') {
        val = 10;
    } else if (card_name[0] == 'Q') {
        val = 10;
    } else if (card_name[0] == 'J') {
        val = 10;
    } else if (card_name[0] == 'A') {
        val = 11;
    } else {
        val = atoi(card_name);
    }

    printf("The card value is: %i\n", val);
    return 0;
}
```

Why each detail matters:

- `<stdio.h>` declares `puts`, `scanf`, and `printf`.
- `<stdlib.h>` declares `atoi`.
- The array needs two input characters plus the terminating null byte.
- `%2s` limits the input to two characters; plain `%s` could overflow the three-byte array.
- Character literals use single quotes, while strings use double quotes.
- `atoi` is enough for this exercise, although real code often prefers `strtol` because `atoi` cannot report conversion errors reliably.

### Data types and conversions - lower priority, but assigned

| Type | Course-level meaning | Portability warning |
|---|---|---|
| `char` | stores a small integer/character code | Signedness is implementation-dependent unless written `signed char` or `unsigned char`. |
| `short` | integer type no wider than `int` | Do not assume an exact byte count. |
| `int` | usual whole-number type, at least 16 bits | Range varies by implementation. |
| `long` | integer type at least as wide as `int`, at least 32 bits | It is not necessarily wider than `int`. |
| `float` | basic floating-point type | Precision and representation are finite. |
| `double` | at least as precise as `float` | Floating-point calculations are not exact real arithmetic. |

Use the implementation rather than guessing its sizes:

```c
#include <limits.h>  /* INT_MIN, INT_MAX, ... */
#include <float.h>   /* FLT_MIN, FLT_MAX, ... */

printf("%zu\n", sizeof(int));
```

The book excerpt prints `%z`, but the standard conversion for a `sizeof` result (`size_t`) is `%zu`. Data-model differences are another reason to define the build environment rather than assuming that all targets have identical C types. [C4, pp. 3-8]

Key conversion rules:

```c
int x = 7;
int y = 2;
float a = x / y;          /* integer division first: 3, then 3.0 */
float b = (float)x / y;   /* floating division: 3.5 */
```

- When both operands are integers, `/` performs integer division and discards the fractional part.
- Casting either operand to `float` makes the other participate in floating-point arithmetic.
- Converting `58.65f` to `int` truncates toward zero to `58`.
- Conversion to an unsigned integer is defined modulo one more than that type's maximum. An out-of-range conversion to a signed integer is implementation-defined or can raise an implementation-defined signal, so do not rely on the book's particular wraparound example.
- Useful warning flags include `-Wall -Wextra -Wconversion -pedantic`.

### Declaration, prototype, and definition

```c
float add_with_tax(float price);       /* declaration/prototype */

float add_with_tax(float price)        /* definition */
{
    return price * 1.06f;
}
```

- A **declaration** tells the compiler the name and type of a function before it is called.
- A **prototype** is a declaration that specifies parameter types, enabling argument checking.
- A **definition** supplies the body and creates the function.
- In modern C, do not call a function without a prior declaration. The legacy behavior described in the book assumed an undeclared function returned `int`; that behavior is invalid in C99 and later. [C4, pp. 10-19]
- In the worksheet's historical syntax, `float f();` is a declaration with an **unspecified** parameter list, not a prototype through C17. Write `float f(void);` for a no-argument prototype.

The assigned tax-program blanks are approximately:

```c
float total = 0.0f;
short count = 0;
short tax_percent = 6;

float add_with_tax(float f)
{
    float tax_rate = 1 + tax_percent / 100.0f;
    total = total + f * tax_rate;
    count = count + 1;
    return total;
}
```

Using `100.0f`, rather than `100`, prevents unintended integer division.

### Solved four-candidate compiler exercise

The two later function definitions return `58.65` Earth days and `24` hours respectively. The expected, course-era answer is: [IC5, pp. 2-3]

| Candidate | Builds? | Warning? | Correct result? | Why |
|---|:---:|:---:|:---:|---|
| Both declarations; `length_of_day` is `float` | Yes | No | Yes | Calls are known and types match. |
| Only the `float` function is declared | Yes in the legacy model | Yes | Yes in that model | The missing hours declaration is implicitly assumed to return `int`, which happens to match. |
| Neither function is declared | No | Diagnostics | No | Mercury is assumed to return `int`, then its `float` definition conflicts. |
| Both declared; `length_of_day` is `int` | Yes | Normally no warning in the exercise | No | `58.65` becomes `58`; output is `58 * 24 = 1392`, not about `1407.6`. |

Modern-C qualification that earns marks if stated briefly:

- C99 and later do not permit implicit function declarations, so a strict modern compiler can reject candidate 2 too.
- Stronger optional flags such as `-Wconversion` can warn on candidate 4.
- The worksheet asks for the intended legacy behavior, so give its table first and then state the modern qualification.

### Headers and multiple source files

Use a header for the interface and a `.c` file for its implementation:

```c
/* encrypt.h */
void encrypt(char *message);
```

```c
/* encrypt.c */
#include "encrypt.h"

void encrypt(char *message)
{
    /* implementation */
}
```

```c
/* main.c */
#include "encrypt.h"

int main(void)
{
    /* call encrypt(...) */
    return 0;
}
```

```bash
gcc main.c encrypt.c -o message_hider
```

Important distinctions:

- `#include <stdio.h>` normally searches the compiler's system include path.
- `#include "encrypt.h"` first denotes a local/project header according to the compiler's search rules.
- `#include` conceptually inserts the header contents during preprocessing; it does **not** separately compile the header.
- Put declarations in `.h`; put each ordinary definition in one `.c` file.
- Include the same header in the implementation and every caller so incompatible types are diagnosed.
- To share a variable deliberately, a header can contain an `extern` declaration while exactly one source file contains its definition. Prefer functions and limited state over global variables when possible. [C4, pp. 13-25]

Correction to an assigned-book typo: C4 PDF page 24 says linking reaches the actual function in `encrypt.h`. The header only **declares** it; the linker resolves the call to the definition compiled from `encrypt.c`. A valid declaration can make compilation succeed while an omitted implementation object still causes an undefined-reference linker error.

### Why object files and incremental builds exist

This command repeats preprocessing, compilation, and assembly for every source:

```bash
gcc main.c a.c b.c c.c -o tool
```

For a large program, preserve unchanged object files:

```bash
gcc -c main.c
gcc -c a.c
gcc -c b.c
gcc -c c.c
gcc main.o a.o b.o c.o -o tool
```

After only `b.c` changes:

```bash
gcc -c b.c
gcc main.o a.o b.o c.o -o tool
```

Only `b.o` must be regenerated, but the executable must be relinked. Make automates this dependency decision. [C4, pp. 27-35]

---

## 4. Makefiles and dependency reasoning

### Vocabulary and syntax

```make
target: prerequisite1 prerequisite2
	recipe command
```

| Term | Meaning |
|---|---|
| Target | The file or named action the rule is meant to create/update. |
| Prerequisite/dependency | An input that must be current before the target. |
| Recipe | Shell command(s) used to create the target. |
| Rule | Target, prerequisites, and optional recipe together. |

A recipe line starts with a **literal tab**, not spaces. This historical syntax is exam bait. [C4, pp. 34-38]

### Make's update algorithm

When asked to build a target, Make reasons recursively:

1. Find the target's rule.
2. First bring every prerequisite target up to date.
3. Run the recipe if the target is missing or any prerequisite is newer.
4. If a prerequisite was rebuilt, its new timestamp can make every target above it stale.

Make usually reasons from modification timestamps, not file contents. Consequently:

- wrong or future-dated clocks can fool it;
- omitted header dependencies can leave stale object files;
- a target that initially looks current may need rebuilding after one of its prerequisites is regenerated;
- `make clean` followed by a full build can hide a defective dependency graph rather than fix it.

By course convention, rules live in `Makefile` or `makefile`, which Make discovers automatically. The dependency language is portable in principle, but recipes invoke underlying commands, so shell/tool differences can make a Makefile operating-system dependent. [C4, pp. 36, 38]

### A correct multi-file Makefile

```make
CC = gcc
CFLAGS = -Wall -Wextra -pedantic

launch: launch.o thruster.o
	$(CC) launch.o thruster.o -o launch

launch.o: launch.c launch.h thruster.h
	$(CC) $(CFLAGS) -c launch.c

thruster.o: thruster.c thruster.h
	$(CC) $(CFLAGS) -c thruster.c
```

If `thruster.h` changes, **both** objects must rebuild because both source files use that interface. Then `launch` must be relinked. A dependency graph is only correct when it names every input that can affect the target.

### Automatic variables and Make expressions

| Expression | Meaning in the current rule |
|---|---|
| `$@` | target name |
| `$^` | all normal prerequisites, with duplicate names removed, in their resulting order; order-only prerequisites are excluded |
| `$<` | first prerequisite |
| `$(CC)` | value of Make variable `CC` |
| `$(wildcard *.c)` | matching `.c` filenames |
| `$(SRCS:.c=.o)` | suffix substitution from `.c` to `.o` |
| `$(sort LIST)` | sorted, duplicate-free list using Make's locale-independent ordering for this exercise |

These automatic-variable semantics are specified by the GNU Make manual. [MAKE-AUTO]

Do not confuse Make's `$@` with shell positional parameters or `$(...)` with shell command substitution. They are expanded by Make in this context.

### Exact reproducibility problem from the sheet

Problematic version: [IC5, p. 6; RB-STABLE]

```make
SRCS = $(wildcard *.c)

tool: $(SRCS:.c=.o)
	$(CC) -o $@ $^
```

Cause, step by step:

```text
different locale
-> wildcard gives filenames in a different collation order
-> .o prerequisites inherit that order
-> $^ passes a different order to the linker
-> link layout/archive selection can differ
-> executable bytes/hash can differ
```

Expected fixes:

```make
# Best when membership and order are known:
SRCS = util.c helper.c main.c
```

or:

```make
# GNU Make's sort is locale-independent:
SRCS = $(sort $(wildcard *.c))
```

High-scoring nuance:

- The wildcard is not simply "random"; its ordering can depend on the current locale.
- `LC_ALL=C make` can normalize the process locale, but an explicit list or `$(sort ...)` is the expected source-level repair.
- Explicit membership also stops a stray `.c` file from silently entering the build.
- Link order can affect more than bytes: static-library symbol resolution and initialization order can make order semantically important.

### Solved timestamp graphs

#### Engine-management system

```text
thruster.c  11:43 -> thruster.o  11:48 \
turbo.c     12:15 -> turbo.o     12:22  \
graticule.c 14:52 -> graticule.o 14:25   -> ems 14:26
servo.c     13:47 -> servo.o     13:46  /
```

Rebuild:

- `graticule.o`, because `graticule.c` is newer;
- `servo.o`, because `servo.c` is newer;
- `ems`, because the regenerated objects make the executable stale.

Do not rebuild `thruster.o` or `turbo.o`. [IC5, p. 4]

#### Galley program

```text
microwave.c 15:42 -> microwave.o 18:02 \
popcorn.c   17:05 -> popcorn.o   17:07  -> galley 17:09
juicer.c    16:41 -> juicer.o    16:43 /
```

Rebuild only `galley`: every object is newer than its own source, but `microwave.o` is newer than the final executable. [IC5, p. 4]

### Solved `oggswing` Makefile

```make
oggswing: oggswing.c oggswing.h
	gcc oggswing.c -o oggswing

swing.ogg: whitennerdy.ogg oggswing
	oggswing whitennerdy.ogg swing.ogg
```

This is the exact magnet solution. On many Unix shells, `./oggswing ...` is operationally safer because the current directory is normally absent from `PATH`. [IC5, p. 5; C1, p. 9]

Dependency logic:

- Editing `oggswing.c` or `oggswing.h` rebuilds `oggswing`.
- Editing `whitennerdy.ogg`, or rebuilding `oggswing`, regenerates `swing.ogg`.
- Since `oggswing` is the first target, plain `make` builds only it. Use `make swing.ogg`, or add `all: swing.ogg`, when the audio file is the desired default.

---

## 5. The C preprocessor

### What it does

Preprocessing occurs before proper compilation. It transforms tokens and selects source text using directives where `#` is the first non-whitespace preprocessing token on the line:

```c
#include <stdio.h>
#define DAYS 7

#ifdef SPANISH
char *greeting = "Hola";
#else
char *greeting = "Hello";
#endif
```

- `#include` makes declarations/text from a header available in the translation unit.
- `#define` creates an object-like or function-like macro.
- `#if`, `#ifdef`, `#ifndef`, `#else`, and `#endif` control conditional compilation.
- `#ifdef NAME` tests whether `NAME` is defined, not whether its replacement value is true; even `#define NAME 0` makes `#ifdef NAME` succeed.
- Macros are not runtime variables. They are token replacements performed before the compiler type-checks the result. [CPP]
- The stages are normally connected internally rather than saving a permanent preprocessed file; `gcc -E` asks the driver to expose that intermediate result. [C4, p. 18]

Inspect it with:

```bash
gcc -E test.c       # preprocessed output, normally with line markers
gcc -E -P test.c    # easier-to-read output without line markers
```

### Object-like macro exercise

```c
#define BUFFSIZE 1024
int buf[BUFFSIZE + 1];
```

Preprocessor result:

```c
int buf[1024 + 1];
```

The preprocessor substitutes `1024`; it does not calculate `1024 + 1`. The compiler later evaluates the integer constant expression and allocates 1025 elements. [IC5, p. 7]

### Function-like macro and parentheses trap

```c
#define a(b) b + 1
int x = a(1) + 1;
```

Expansion:

```c
int x = 1 + 1 + 1;
```

Therefore `x == 3`. But the macro is unsafe:

```c
2 * a(3)       /* expands to 2 * 3 + 1, so 7 rather than 8 */
```

Safer form:

```c
#define ADD_ONE(b) ((b) + 1)
```

Parenthesize every parameter occurrence and the complete replacement expression. Also avoid arguments with side effects when a macro may evaluate them more than once.

### Standard predefined macros

| Macro | Replacement | Example/format | Reproducibility risk |
|---|---|---|---|
| `__LINE__` | current presumed source line as an integer | `3` | Stable for unchanged line structure, but changes with edits. |
| `__FILE__` | current input filename/path as a string | `"testCPP.c"` or an absolute path | Can embed a checkout/build path. |
| `__DATE__` | translation date string | `"Jul 27 2026"`; one-digit day is space-padded | Direct time-dependent bytes. |
| `__TIME__` | translation time string | `"14:05:09"` | Direct time-dependent bytes. |
| `__STDC__` | normally `1` for standard-conforming preprocessing | `1` | Usually informational. |
| `__STDC_VERSION__` | selected C standard version | e.g. `201112L` for C11 | Captures/channels language-mode differences. |

For the sheet's `testCPP.c`, the relevant runtime output has this shape: [IC5, p. 7; GCC-MACROS]

```text
__LINE__ = 3
__FILE__ = testCPP.c
__TIME__ = HH:MM:SS
__DATE__ = Mmm dd yyyy
```

The exact `__FILE__` string depends on how the file was passed/opened, and time/date are the translation values. `__LINE__` and `__FILE__` can also be influenced by `#line`.

Exam answer for reproducibility:

> Avoid uncontrolled `__DATE__` and `__TIME__` in artifacts, warn on them with GCC's `-Wdate-time`, and normalize supported tools with a source-derived `SOURCE_DATE_EPOCH`. Control or remap paths if `__FILE__` reaches the artifact. [GCC-WARN]

### `assert`, `NDEBUG`, and conditional removal

An assertion is intended to check a programmer invariant during development:

```c
assert(index < length);
```

If `NDEBUG` is defined before `<assert.h>` is processed, assertion calls become disabled. The argument is not evaluated:

```bash
gcc program.c -o debug-style
gcc -DNDEBUG program.c -o release-style
```

`-DNDEBUG` is the command-line equivalent of defining `NDEBUG` for preprocessing.

Never do this:

```c
assert(someinitialization() == 0);  /* required work hidden in a check */
```

Do this instead:

```c
int result = someinitialization();  /* always runs */
assert(result == 0);                /* optional invariant check */
if (result != 0) {
    return 1;                       /* real production handling */
}
```

Assertions are not replacements for validation or recoverable error handling.

### Solved heisenbug

The sheet initializes an invalid pointer and changes it only inside the asserted call: [IC5, p. 8]

```c
char *p = (char *)5;

int someinitialization(void)
{
    p = "abc";
    return FALSE;
}

assert(someinitialization() == FALSE);
printf("%s\n", p);
```

Normal build:

```text
assert enabled
-> someinitialization() executes
-> p becomes "abc"
-> assertion succeeds
-> prints abc
```

Build with `-DNDEBUG`:

```text
assert disabled
-> expression is not evaluated
-> p remains address 5
-> printf dereferences it as a string
-> undefined behavior, usually a segmentation fault
```

The worksheet blank likely expects **`abc`** and **segmentation fault**. The standards-precise phrase for the second is **undefined behavior, commonly observed as a segmentation fault**.

A **heisenbug** is a bug whose behavior changes or disappears when one tries to observe or debug it. Debugging can alter timing, memory layout, optimization, or - as here - which code is compiled/evaluated. The root cause is not mystical observation; it is a program whose behavior depends on those changed conditions. [HEISENBUG]

Golden rule:

```text
Assert conditions must be side-effect free.
```

---

## 6. Fast answer key - In-Class Exercise Sheet 5

Use this section to test yourself. Each item gives the minimum complete exam answer.

### Exercise 1: reconstruct the card program

Order the pieces as follows:

```text
#include <stdio.h>
#include <stdlib.h>
int main() {
    char card_name[3];
    puts(...);
    scanf("%2s", card_name);
    int val = 0;
    if K -> 10
    else if Q -> 10
    else if J -> 10
    else if A -> 11
    else -> atoi(card_name)
    printf(...);
    return 0;
}
```

The decisive details are the two headers, single-quoted character tests, `%2s`, and final `return 0`. [IC5, p. 1]

### Exercise 2: be the compiler

1. Both declarations and correct `float`: **builds, no warning, works**.
2. Only the Mercury declaration: **legacy answer: builds, warning, works**, because the missing function really returns the implicitly assumed `int`.
3. No declarations: **does not compile**, because an assumed `int` conflicts with Mercury's later `float` definition.
4. Both declarations but `int length_of_day`: **builds, normally no warning in the exercise, wrong result `1392.000000`**, due to truncation from `58.65` to `58`.

Then add: modern C99+ rejects implicit function declarations. [IC5, pp. 2-3]

### Exercise 3: file updates

- Engine graph: rebuild **`graticule.o`, `servo.o`, and `ems`**.
- Galley graph: rebuild **only `galley`**.

Always propagate a rebuilt dependency upward to the final target. [IC5, p. 4]

### Exercise 4: Make magnets

```make
oggswing: oggswing.c oggswing.h
	gcc oggswing.c -o oggswing

swing.ogg: whitennerdy.ogg oggswing
	oggswing whitennerdy.ogg swing.ogg
```

The spaces separate prerequisites; the two recipes begin with tabs. [IC5, p. 5]

### Exercise 5: unreproducible Makefile

Cause:

> `$(wildcard *.c)` can sort under the active locale, so `$^` can pass object files to the linker in different orders and produce different binaries.

Fix either by listing inputs explicitly:

```make
SRCS = util.c helper.c main.c
```

or sorting with Make:

```make
SRCS = $(sort $(wildcard *.c))
```

[IC5, p. 6; RB-STABLE]

### Exercise 6: macro outputs

Part (a):

```c
int buf[1024 + 1];  /* preprocessor output; compiler later gets 1025 */
```

Part (b):

```c
int x = 1 + 1 + 1; /* x is 3 */
```

Part (c):

```text
__LINE__ = 3
__FILE__ = testCPP.c        # possibly with a path
__TIME__ = compile time in HH:MM:SS
__DATE__ = compile date in Mmm dd yyyy
```

`__TIME__` and `__DATE__` are direct reproducibility hazards; `__FILE__` can be path-dependent. [IC5, p. 7]

### Exercise 7: heisenbug

- Without `-DNDEBUG`: the assertion evaluates `someinitialization()`, sets `p = "abc"`, and prints **`abc`**.
- With `-DNDEBUG`: the assertion and its evaluation disappear; `p` stays at invalid address 5, so behavior is **undefined, usually a segmentation fault**.
- Cause: essential initialization is hidden as a side effect inside `assert`.
- Fix: call initialization unconditionally, store its result, then assert/check that result separately. [IC5, p. 8]

---

## 7. Lab Sheet 5 - complete answer guide

The lab is intentionally Git-heavy even though the in-class sheet centers on builds. It is still part of the Module 5 folder, so it is covered here in full.

### Preparation and basic repository workflow

```bash
git status
git pull

cp -r RepEng/LabSession5 MyLabSession5
cd MyLabSession5

git init
git add .
git commit -m "Initial commit"
git tag LabSession5-v1
git switch -c MyLabSession5
# Older equivalent: git checkout -b MyLabSession5
```

After changing `hello.sh` to print `Hello from Lab Session 5`:

```bash
git status              # modified, not staged
git diff
git add hello.sh
git status              # modified and staged
git diff --cached
git commit -m "Change greeting for Lab Session 5"

touch todos.txt
printf '%s\n' 'todos.txt' > .gitignore
git status
git status --short --ignored
git check-ignore -v todos.txt
```

Expected short-status forms:

```text
 M hello.sh       modified only in working tree
M  hello.sh       staged modification
?? .gitignore     untracked
!! todos.txt      ignored; shown only with --ignored
```

Mental model:

```text
working tree --git add--> staging index --git commit--> HEAD commit
```

- `git diff` compares working tree with index.
- `git diff --cached` compares index with `HEAD`.
- `git add` stages the file's current snapshot.
- A tag remains attached to the original commit while a branch name normally advances.
- `.gitignore` normally affects untracked files only. Ignoring a name does not untrack a file already in Git.
- `.gitignore` is itself an ordinary file and must be staged/committed if it is to be shared. [L5, pp. 1-2]

### Tracking contributions with `git blame`

```bash
git clone https://github.com/looselytyped/gitanjali-aref-wedding-plans.git
cd gitanjali-aref-wedding-plans

git blame drinks.md
git blame appetizers.md
git blame -L 5,5 appetizers.md
git blame --line-porcelain appetizers.md
```

A normal blame line gives roughly:

```text
commit (author date/time timezone final-line-number) current line text
```

Verified sheet answers for `appetizers.md`:

1. **2 authors:** Trinity and Armstrong.
2. **Last edit:** July 27, 2021.
3. **Line 5:** last edited by Armstrong; it is the mini grilled-cheese line.

Blame traps:

- It attributes the **current surviving form of each line**, not necessarily the original idea.
- Deleted/fully replaced lines do not appear in ordinary blame output.
- Use `git log -- FILE` to study every historical commit to a file.
- `git blame -w` can ignore whitespace; `-M` and `-C` help follow moved/copied lines. [L5, p. 2]

### Rewriting the supplied history

First inspect safely:

```bash
git clone https://github.com/ReproEng/LabSession2
cd LabSession2
git log --oneline --graph --decorate --all
git switch -c rewrite-experiment master
```

The supplied `master` history is:

```text
9cba6f7  project/README
d7fc97a  adds hello.c, initially with void main()
8cdb592  adds .gitignore and Makefile, initially suppressing warnings
ab1f4d7  fixes hello.c to int main() plus return 0
009230f  replaces suppressed warnings with strict compiler flags
```

The two `fixup` commits correct honest mistakes and are more useful folded into the logical commits they repair. Run:

```bash
git rebase -i 9cba6f7
```

Reorder/edit the todo list to:

```text
pick  d7fc97a Add code proper
fixup ab1f4d7 fixup: Actually improve code quality
pick  8cdb592 Add build infrastructure
fixup 009230f fixup: Ensure that build system sets highest standards
```

Result: three logical commits including the unchanged root - project description, standards-compliant code, and strict build infrastructure.

Interactive-rebase commands:

| Command | Effect |
|---|---|
| `pick` | retain commit |
| `reword` | retain changes, edit message |
| `edit` | pause to amend/split |
| `squash` | combine with previous commit and edit combined message |
| `fixup` | combine with previous commit and discard this message |
| `drop` | omit commit |

A fixup must immediately follow the commit it fixes. Rebase replays changes and produces new commit IDs because the parent/content/metadata relationship changes.

### Merge result versus linear result

The `i18n` branch adds a greeting selected using `LANG` and diverges from an older commit.

Merge-preserving version:

```bash
git switch -c merged-result rewrite-experiment
git merge origin/i18n
# Resolve hello.c, retaining localization AND int main()/return 0.
git add hello.c
git commit
git log --oneline --graph --decorate --all
```

Linear version:

```bash
git switch -c linear-result rewrite-experiment
git cherry-pick dcb12f0
# Resolve the same semantic conflict.
git add hello.c
git cherry-pick --continue

git log --oneline --graph --decorate linear-result
git rev-list --merges linear-result   # should print nothing
```

- Merge normally preserves both ancestry lines and creates a two-parent merge commit.
- Cherry-pick/rebase reapplies changes as new commits and can give a linear history.
- Conflict resolution must preserve the intent of **both** lines of development, not merely delete marker lines.

Review and repair messages:

```bash
git log --stat
git log -p
git rebase -i --root
```

Mark inaccurate messages as `reword`. Suitable final subjects are:

```text
Document project goal
Add standards-compliant hello-world program
Add strict Make-based build infrastructure
Add German greeting selected by LANG
```

### Rebase recovery

```bash
git rebase --continue     # after resolving and staging
git rebase --abort        # restore pre-rebase state
git reflog                # find recent HEAD positions
git branch rescue HEAD@{N}
```

`git reset --hard <commit>` can restore an exact known state but discards tracked working-tree/index changes; use a safety branch and an exact commit. Do not casually rebase shared published history. If a rewritten private branch must replace its remote branch, `--force-with-lease` is safer than plain `--force`. [L5, p. 3]

### Transparent changes with a patch

```bash
cd RepEng/LabSession5
cp hello.c hello_new.c
# Edit hello_new.c so it prints: Hello World
diff -u hello.c hello_new.c > hello.patch
```

Unified-diff anatomy:

- `---` identifies the old file.
- `+++` identifies the new file.
- `@@ -old_start,old_count +new_start,new_count @@` identifies a hunk's old and new line ranges; for example, `@@ -5,7 +5,7 @@` means seven lines beginning at line 5 in both versions.
- `-` is removed text, `+` is added text, and a leading space is context.

`diff` exit statuses are exam-worthy: `0` means identical, `1` means differences were successfully found, and values greater than `1` indicate an error. Therefore, exit status 1 while creating a non-empty patch is expected.

Representative Dockerfile:

```dockerfile
FROM gcc:latest

WORKDIR /work
COPY hello.c hello.patch ./
RUN patch hello.c hello.patch
RUN gcc -Wall -Wextra -pedantic -o hello hello.c
CMD ["./hello"]
```

If the base image lacks the `patch` utility, install it in an earlier layer. The usual equivalent syntax is:

```bash
patch hello.c < hello.patch
```

Then:

```bash
docker build -t lab5-patched .
docker run --rm lab5-patched
```

Expected output: `Hello World`.

`gcc:latest` mirrors a simple lab demonstration but is a mutable tag, so it does not define a reproducible environment. For a genuinely reproducible image build, pin an exact base-image version and preferably its immutable digest, and pin the installed packages/toolchain too.

The provenance idea is more important than the container syntax: keep the upstream/original file unchanged, preserve the explicit patch, apply it automatically, and compile the result. Copying only an undocumented `hello_new.c` loses that transparent derivation. [L5, p. 4]

### Lab multiple-choice answer key

| Question | Answer | Reason |
|---|---|---|
| 6(a) Latest code author | **Alice Miller** | Alice is `Author`; Chris Admin is `Committer`. |
| 6(b) Number of authors | **3** | Alice, Ben, and Dana. |
| 6(c) Commits deleting a file | **0** | Some delete lines; none deletes an entire file. |
| 6(d) Most changed file | **`src/register.js`** | `24 + 18 = 42` touched lines. |
| 6(e) Listed lines in latest `resume.md` | **3** | Languages, English, Klingon remain; Romulan was removed. |
| 6(f) Listed lines after checkout of `other-branch` | **2** | Initial experience line and old "Routed incoming" line. |

Churn totals for 6(d):

```text
README.md          20 + 4  = 24
index.html         18
app.js              7
src/profile.html   36
src/register.js    24 + 18 = 42
```

Traps:

- **Author** wrote the change; **committer** recorded/integrated that commit.
- Lines deleted inside a file do not mean the file was deleted.
- `--stat` measures touched lines, not current file size or just net growth.
- `-` belongs to the old version and `+` to the new version.
- `\ No newline at end of file` is diff metadata, not a file line.
- Checking out `other-branch` moves `HEAD` and restores that branch's snapshot; the newer commit remains on `main`. [L5, pp. 5-7]

---

## 8. Exam traps and model answers

### Frequent traps

| Tempting but wrong answer | Correct reasoning |
|---|---|
| "Reproducible means it produces approximately the same behavior." | For reproducible **builds**, the specified artifacts must be bit-for-bit identical under the declared conditions. |
| "Deterministic and reproducible are synonyms." | Determinism is the output property; reproducibility additionally needs an independently recreatable environment and verification path. |
| "Matching hashes prove the program is secure." | They prove byte identity of the compared objects, not correctness or safety of the source. |
| "The wildcard result is random." | In the assigned example it is sorted according to the active locale; locale variation changes the order. |
| "Sorting is enough in every shell command." | The sort itself must have controlled collation, such as `LC_ALL=C sort`, unless the operation is specified as locale-independent. |
| "Make rebuilds a target whenever a dependency's contents differ." | Traditional Make primarily compares existence and modification times. |
| "Only the stale `.o` file changes." | After recompiling an object, every dependent final target must be reconsidered and normally relinked. |
| "A header does not need to be a prerequisite because it is not compiled." | A header changes the translation unit, so every affected object depends on it. |
| "`gcc -c` creates an executable." | It stops before linking and normally creates an object file. |
| "`#define` creates a constant variable." | It creates a preprocessing replacement; no typed runtime object is implied. |
| "The preprocessor evaluates `1024 + 1`." | It substitutes tokens; the compiler evaluates the later constant expression. |
| "`a(1) + 1` becomes `(1 + 1) + 1` because macros understand expressions." | It is literal token substitution; parentheses appear only if the macro definition contains them. |
| "`__FILE__` is always only the basename." | It is the input name/path by which preprocessing opened the file and can contain a relative or absolute path. |
| "`__LINE__` makes repeated builds nondeterministic." | It is stable for the same preprocessed source location; time and path macros are the direct concerns here. |
| "An assertion is ordinary production error handling." | It is an optional invariant check and may be disabled completely. |
| "The `-DNDEBUG` program is guaranteed to segfault." | Dereferencing address 5 is undefined behavior; a segmentation fault is the expected common outcome, not a language guarantee. |
| "`git blame` finds the original author of every idea." | It attributes the current surviving lines to commits. |
| "Committer and author are always the same." | The author wrote the change; a different committer may have integrated it. |
| "Rebase moves the same commits." | Rebase reapplies changes on new parents and creates new commit identities. |
| "Resolving a conflict means deleting `<<<<<<<` markers." | The resulting code must preserve the intended semantics of both changes and must be tested. |
| "A diff exit status of 1 means the patch command failed." | For `diff`, 1 normally means the files differ successfully. |

### Model answer: define and verify a reproducible build

> A build is reproducible when the same source revision, declared build environment, and build instructions allow any party to recreate bit-for-bit identical copies of all specified artifacts. Pin or define relevant tools, dependencies, flags, locale, paths, and other environmental inputs; remove or normalize volatile values such as time and unstable ordering; then rebuild independently and compare cryptographic hashes. A matching hash verifies identity of the artifacts, not correctness of their source.

### Model answer: diagnose the wildcard Makefile

> `$(wildcard *.c)` produces a filename order influenced by the active locale. Suffix substitution preserves that order and `$^` passes it to the linker. Different locales can therefore link the same object set in different orders and create different bytes. List the source files explicitly or use `$(sort $(wildcard *.c))`; also make the remaining build environment reproducible.

### Model answer: explain Make's timestamp graph

> Make first updates prerequisites recursively. A target is out of date if it is missing or a prerequisite is newer. Therefore, rebuild each object whose source/header is newer, then propagate that new object timestamp upward and relink every dependent executable. Comparing the executable only with the old object timestamps would miss this transitive update.

### Model answer: explain the macro output

> The C preprocessor performs token substitution before compilation. `BUFFSIZE` expands to `1024`, leaving `1024 + 1` for the compiler to evaluate. A function-like macro without parentheses is substituted literally and can interact with surrounding operators, so macro parameters and the complete replacement expression should be parenthesized.

### Model answer: explain and fix the heisenbug

> With assertions enabled, evaluating the assertion also runs `someinitialization`, so `p` becomes `"abc"`. With `-DNDEBUG`, `assert` expands away and its argument is not evaluated; `p` remains invalid, so printing it is undefined behavior, commonly a segmentation fault. Required side effects must execute outside `assert`; store the initialization result, assert the invariant, and use normal control flow for production error handling.

### Model answer: merge versus linear history

> A merge preserves the branch topology and normally records a new two-parent commit. Rebase or cherry-pick replays changes on a new base, producing new commit identities and a linear history. Rebase improves a private history's readability but should not casually rewrite commits already shared with collaborators.

---

## 9. Final two-minute recall sheet

```text
REPRODUCIBLE BUILD
same source + declared environment + instructions
-> any party
-> all specified artifacts identical bit for bit
-> verify with cryptographic hashes

DETERMINISM
stable inputs + stable outputs + minimal environment capture

C PIPELINE
.c -> preprocess -> compile -> assemble -> .o -> link -> executable
gcc -E | gcc -S | gcc -c | gcc objects -o program

HEADER
declarations/interface in .h; definitions in .c
"local.h" versus <system.h>
every affected .o must depend on every used header

MAKE
target: prerequisites
<TAB>recipe
missing target OR newer prerequisite -> rebuild
$@ target | $^ normal prerequisites (deduplicated) | $< first normal prerequisite

TIMESTAMPS
ems: graticule.o + servo.o + ems
galley: galley only

OGGSWING
oggswing: oggswing.c oggswing.h
<TAB>gcc oggswing.c -o oggswing
swing.ogg: whitennerdy.ogg oggswing
<TAB>oggswing whitennerdy.ogg swing.ogg

WILDCARD BUG
locale -> wildcard order -> $^ link order -> different bytes
fix explicit SRCS or $(sort $(wildcard *.c))

MACROS
BUFFSIZE -> int buf[1024 + 1]
a(1)+1 -> 1+1+1 -> 3
safe macro: #define ADD_ONE(x) ((x) + 1)

PREDEFINED
__LINE__ integer line
__FILE__ file/path string
__TIME__ HH:MM:SS - volatile
__DATE__ Mmm dd yyyy - volatile

HEISENBUG
normal -> initialization runs -> abc
-DNDEBUG -> assert expression disappears -> invalid p -> UB/usually segfault
never put required side effects inside assert

GIT LAB MCQ
Alice | 3 authors | 0 deleted files | register.js | 3 lines | 2 lines

BLAME
2 authors | last edit 27 Jul 2021 | line 5 Armstrong

HISTORY
merge preserves topology; rebase/cherry-pick rewrites/replays linearly
diff exit 1 = files differ successfully
```

---

## 10. Self-test

Try these without looking below.

1. State the exact reproducible-build definition in one sentence.
2. Why is a deterministic build on one undocumented machine not necessarily reproducible?
3. What three broad properties summarize a deterministic build system?
4. Put preprocessing, linking, assembly, and compilation in order.
5. What does `gcc -c a.c` produce and omit?
6. Why must a caller see a function declaration before the call?
7. What is the difference between `#include "x.h"` and `#include <x.h>` at course level?
8. When does Make consider a target out of date?
9. Why must a header appear as an object-file prerequisite?
10. What do `$@`, `$^`, and `$<` mean?
11. Why can `$(wildcard *.c)` make the provided build unreproducible?
12. Give both expected fixes for that Makefile.
13. Which files rebuild in the engine timestamp graph?
14. Which files rebuild in the galley graph?
15. Expand `#define a(b) b + 1` in `a(1) + 1`.
16. How should that macro be repaired?
17. What does each of `__FILE__`, `__LINE__`, `__DATE__`, and `__TIME__` expand to?
18. Which of those are direct build-time hazards, and which can leak a build path?
19. What does `-DNDEBUG` do to an assertion's argument?
20. Why is the second heisenbug run undefined rather than guaranteed to crash?
21. Distinguish Git author from committer.
22. Why are there zero file-deleting commits in the MCQ even though the log reports deletions?
23. What is the conceptual difference between merge and rebase?
24. Why is `fixup` appropriate for the two supplied correction commits?
25. Why is exit status 1 from `diff` expected when creating a patch?

### Answers

1. Same source, declared build environment, and instructions must let any party recreate bit-for-bit identical specified artifacts.
2. Another party cannot recreate the undocumented inputs/environment, even if repeated local runs happen to be deterministic.
3. Stable inputs, stable outputs, and minimal capture of uncontrolled environment state.
4. Preprocess, compile to assembly, assemble to object code, link objects/libraries.
5. An object file such as `a.o`; it omits linking and therefore normally does not create a runnable program.
6. So the compiler knows and checks the return and parameter types rather than guessing or rejecting an undeclared call.
7. Quotes denote a local/project include search; angle brackets denote the compiler/system include paths.
8. If the target is missing or a recursively updated prerequisite is newer.
9. Its contents become part of the translation unit and can change the generated object code.
10. Target, all normal prerequisites with duplicates removed, and first normal prerequisite respectively; `$|` holds order-only prerequisites.
11. Wildcard collation can depend on locale; the varying order flows through `$^` to the linker.
12. Explicit ordered source list, or `$(sort $(wildcard *.c))`.
13. `graticule.o`, `servo.o`, and `ems`.
14. `galley` only.
15. `1 + 1 + 1`, so the initializer value is 3.
16. `#define ADD_ONE(b) ((b) + 1)`.
17. Input filename/path string, source-line integer, translation-date string, translation-time string.
18. `__DATE__` and `__TIME__` directly vary with build time; `__FILE__` can leak/change with the path.
19. It is not evaluated because the assertion becomes disabled.
20. C places no requirement on what happens after dereferencing the invalid pointer; a segmentation fault is only a common manifestation.
21. Author created the change; committer recorded/integrated the commit.
22. The stats show lines removed within still-existing files, not deletion of an entire path.
23. Merge preserves both ancestry lines/topology; rebase replays changes onto a new base and creates new commit identities.
24. They are honest corrections to earlier logical changes, so folding each directly after its target preserves a clean, meaningful story.
25. `diff` reserves 1 for "files differ" and values above 1 for an error.

---

## Source key and coverage audit

All nine supplied Module 5 source items were reviewed: five PDFs totaling 64 pages and four `.url` shortcuts. The shortcuts route through the university system and did not resolve without its authenticated session. Their identifiable public readings are included below; the Head First C repository is also cited directly inside the assigned PDFs.

### Local PDFs

- **IC5** - [In-Class Exercise Sheet 5 / Reproducible Builds](5-Reproducible_Builds/SoSe_2026_RepEng_IC_5___Reproducible_Builds.pdf), all 8 PDF pages. Primary exam questions and highest-priority source.
- **C1** - [Head First C, Chapter 1 excerpt](5-Reproducible_Builds/head_first_c_chapter1.pdf), all 9 PDF pages. Small-program anatomy, `main`, headers, GCC, build/run.
- **C4** - [Head First C, Chapter 4 excerpt](5-Reproducible_Builds/head_first_c_chapter4.pdf), all 39 PDF pages. Types, declarations, headers, multiple sources, the build pipeline, object files, Make.
- **CPP** - [Head First C, preprocessor appendix](5-Reproducible_Builds/head_first_c_appendix_preprocessor.pdf), complete 1-page excerpt. `#include`, `#define`, function-like macros, conditional compilation.
- **L5** - [Lab Sheet 5](Lab_Session_5/Sheet_5.pdf), all 7 PDF pages. Git workflow, blame, history rewriting, patches/Docker, and MCQs.

### Linked readings and artifact site

- **RB-HOME** - [Reproducible Builds project](https://reproducible-builds.org/) - independent path from source to binary and the three-step workflow.
- **RB-DEF** - [Official definition](https://reproducible-builds.org/docs/definition/) - same source, environment, instructions, and bit-for-bit artifacts.
- **RB-DET** - [Deterministic build systems](https://reproducible-builds.org/docs/deterministic-build-systems/) - stable inputs, stable outputs, minimal environment capture.
- **RB-STABLE** - [Stable order for inputs](https://reproducible-builds.org/docs/stable-inputs/) - the exact Makefile from IC5 and its two expected repairs.
- **RB-WHY** - [Why reproducible builds?](https://reproducible-builds.org/docs/why/) - supply-chain detection, quality, debugging, and smaller differences.
- **SDE** - [`SOURCE_DATE_EPOCH` specification](https://reproducible-builds.org/specs/source-date-epoch/) - deterministic source-derived timestamps.
- **GCC-MACROS** - [GCC standard predefined macros](https://gcc.gnu.org/onlinedocs/cpp/Standard-Predefined-Macros.html) - exact forms and meanings of `__FILE__`, `__LINE__`, `__DATE__`, `__TIME__`, and standard-version macros.
- **GCC-STAGES** - [GCC overall options](https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html) - stopping after preprocessing, compilation, or assembly.
- **GCC-WARN** - [GCC warning options](https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html#index-Wdate-time) - `-Wdate-time` diagnostics.
- **MAKE-AUTO** - [GNU Make automatic variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html) - `$@`, `$^`, `$<`, and `$|` semantics.
- **HEISENBUG** - [The assigned C heisenbug example](https://jacquesmattheij.com/a-c-heisenbug-in-the-wild/) - why assertion side effects disappear with `NDEBUG`.
- **Head First C artifacts** - [author-maintained example-code repository](https://github.com/dogriffiths/HeadFirstC), cited on IC5 page 5 - code corresponding to the assigned book excerpts. The authenticated `.url` wrapper's exact redirect could not be independently inspected.

### Final priority judgment

If only one hour remains, spend it on:

1. IC5 pages 4-8: Make timestamps, Makefile syntax, stable ordering, macros, heisenbug.
2. The reproducible-build definition and deterministic-build checklist.
3. The four-candidate compiler table and build pipeline.
4. Lab MCQs, blame answers, and merge-versus-rebase concepts.

The broad type survey and detailed Git command variations are lower priority than those four areas, but they remain included because they are assigned material.
