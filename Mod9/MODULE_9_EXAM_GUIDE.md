# Reproducibility Engineering - Module 9 Exam Guide

> An exam-first guide to every supplied Module 9 item: local and remote LLM reproducibility, decoding controls, prompt engineering, reasoning patterns, output verification, JSON and JSON Schema, constrained decoding, provider limitations, OpenAI API code, and the lab.

## How to use this guide before the exam

If time is short, study in this order:

1. Memorize the **one-page map** and the **provider support table**.
2. Learn the solved answers to **In-Class Sheet 9, Questions 1-12**.
3. Be able to explain the boundary **valid JSON -> schema-valid JSON -> factually correct answer**.
4. Practice the JSON Schema multiple-choice questions and the four `jq` patterns.
5. Finish with the prompt/reasoning comparison table and the final two-minute recall sheet.

The online provider features are time-sensitive. The comparison below is a **27 July 2026 snapshot**, matching the material linked by this Summer 2026 module. For the exam, learn the stated feature qualifications, not just a bare yes/no.

---

## 1. The whole module in one page

### Five memory blocks

```text
LOCAL vs REMOTE
  Local model = large, hardware-hungry, more self-contained and controllable
  Remote API  = small package, easy local hardware, but provider/network/cost dependency

REPEATABLE LLM CALL
  exact request + pinned model/version + temperature 0 + fixed seed
  + code/dependencies + raw response/metadata
  -> best effort, never a promise of bitwise identity

PICFAT-D PROMPT
  Persona, Instruction, Context, Format, Audience, Tone, Data

OUTPUT CONTROL: ESGV
  Examples -> Scaffolding -> Grammar/constrained decoding -> Validate/retry

JSON TRUST LADDER
  parses as JSON < conforms to schema < satisfies semantics < is factually correct
```

### The most important distinction

| Level | What it guarantees | What it does **not** guarantee |
|---|---|---|
| Prompt says "return JSON" | Nothing formally; it merely guides the model | Valid JSON, schema adherence, truth |
| JSON mode / JSON grammar | Parseable JSON syntax, subject to documented edge cases | A particular schema, truth |
| Strict Structured Outputs | Conformance to the **supported subset** of the supplied schema | Truth, absence of hallucinations, cross-field meaning not encoded by the schema |
| Application validation | Whatever syntactic and semantic checks the program explicitly performs | Unchecked facts or assumptions |

**Exam sentence:** Constrained decoding controls which tokens may be emitted; it does not make the selected values true.

### Provider table to memorize

This is the course-relevant comparison for strict/constrained JSON generation. "Partial" means the qualification is part of the answer. [IC7; O; A; C]

| JSON Schema feature | OpenAI | Anthropic | llama.cpp converter |
|---|---|---|---|
| `additionalProperties` | Must be `false` for objects in strict mode | Must be `false` | Supports `false`, `true`, and a schema for extra values |
| Truly optional properties | No; every declared property must be required. Simulate an optional value with a nullable union | Yes, within complexity limits | Yes; properties absent from `required` are optional |
| `minimum`, `maximum` | Yes for numeric properties; not supported by fine-tuned models | No; SDKs may strip them and validate afterward | Partial: supported for **integers**, not general numbers |
| `pattern`, `format` | Yes on current base models (not fine-tuned models); `format` supports a documented set | Partial: regex subset and a documented format set | Partial: regex subset; formats include date, time, date-time, and UUID variants |
| `anyOf` | Yes, but the root must still be an object rather than `anyOf` | Yes | Yes |
| `oneOf` | No | No | Accepted, but converted like `anyOf`; exclusive-one semantics are not enforced |

Fast comparison: **OpenAI requires all keys; Anthropic permits omitted keys; llama.cpp is broad but sometimes approximates the keyword's semantics.**

---

## 2. Reproducibility architecture: local model or remote API?

Assume that a "local model inside the container" includes the exact weights and inference software. If weights are downloaded at run time from a mutable URL, it is no longer fully self-contained. [IC1]

| Criterion | Local open-weight model in/with container | Remote provider API |
|---|---|---|
| Self-contained? | Largely yes if weights, tokenizer, runtime, configuration, and code are archived | No; depends on network, authentication, provider infrastructure, and a remotely hosted model |
| Artifact size | Very large - often gigabytes for weights plus runtime | Small - client code, prompts, schemas, and dependency metadata |
| Local hardware | High CPU/RAM and often GPU/VRAM requirements | Low; ordinary client hardware is enough |
| Long-term availability | Better under the experimenter's control if artifacts and licenses permit archiving | Provider may rename, update, restrict, or retire the model/API |
| Cost to rerun | Hardware, electricity, storage, and setup time; low marginal fee if hardware already exists | Per-token/request fees, quota, account, and possibly changing prices |
| Transparency | Weights and inference stack can be inspected and pinned; "open weights" still need not expose training data or training code | Usually a black box; backend implementation and updates are controlled by provider |
| Exact environment control | Stronger: runtime, model file, quantization, tokenizer, and decoding implementation can be pinned | Weaker: the caller controls request fields but not the serving stack |
| Convenience/portability | Heavy artifacts and hardware can make reproduction difficult | Easy to call from many environments while the service exists |

### The trade-off in one answer

A local package improves **control, inspectability, and long-term independence**, but costs storage and compute and may fail on unavailable hardware. A remote API produces a light, easy-to-run package, but externalizes critical experimental state to a changing service. Neither architecture is automatically reproducible.

### Making a remote LLM experiment as reproducible as possible

Archive all state you control: [IC1-3]

1. The exact ordered request: every developer/system/user/assistant message and every input file after preprocessing.
2. Exact model identifier and, where offered, a dated snapshot rather than a moving alias.
3. Every parameter: temperature, `top_p`, seed, reasoning effort, token limits, stop rules, tools, schemas, and response format.
4. Provider, endpoint/API version, SDK and dependency versions, request date/time, and region/service tier if relevant.
5. Complete program, lockfile/container, preprocessing, postprocessing, validation, and evaluation code.
6. Raw response before parsing plus response ID, finish/stop reason, usage, and backend fingerprint/version metadata when supplied.
7. The exact outputs used in the paper. This preserves the historical evidence even if a future rerun differs or becomes impossible.
8. Expected tolerances or evaluation criteria. Do not define success as byte identity if the scientific claim only needs semantic/statistical agreement.
9. An availability plan: budget/quota instructions, a clear error if the model is retired, and - if scientifically acceptable - a documented fallback. A fallback is a changed experiment and must be reported as such.

Do **not** archive or publish an API key. The reproducer supplies a separate credential and pays for their own calls.

---

## 3. Sampling, randomness, and repeatability

### How text generation works

At every step, the model assigns probabilities to candidate next tokens. A decoder then chooses one, appends it, and repeats. For a prefix such as `I am driving a`, likely continuations such as `car` usually outrank an implausible one such as `elephant`. [H5]

### Greedy decoding and the three sampling controls

| Control | Mechanism | Lower setting | Higher setting |
|---|---|---|---|
| `do_sample` | Switches between greedy choice and sampling in the book's Transformers example | `False`: choose highest-probability token | `True`: sample from candidates |
| `temperature` | Reshapes probability distribution | Sharper, more predictable | Flatter, more diverse/random |
| `top_p` | Keeps the smallest token set whose cumulative probability reaches `p` | Smaller variable-size nucleus | Larger candidate pool; `1` permits all |
| `top_k` | Keeps exactly the `k` most probable candidates | Fewer candidates | More candidates |

Key distinctions: [H5-7]

- In the book's local pipeline, `do_sample=False` is the executable greedy setting.
- `temperature=0` is the course/API shorthand for the most deterministic available decoding.
- `top_p` selects a **variable-size probability mass**; `top_k` selects a **fixed number**.
- Prefer changing temperature or `top_p`, rather than casually changing both, because their effects interact.

### Use-case combinations from the assigned chapter

| Use case | Temperature | `top_p` | Intended behavior |
|---|---:|---:|---|
| Brainstorming | High | High | Very diverse and unexpected |
| Email generation | Low | Low | Focused and conservative |
| Creative writing | High | Low | Creative within a smaller coherent pool |
| Translation | Low | High | Stable answer with broader vocabulary |

### Temperature and seed blanks

The In-Class Sheet expects: [IC2]

> Set **temperature** to `0` for the most near-deterministic sampling; higher temperature increases randomness. Pass a fixed **seed** so identical requests make the same pseudo-random choices where the API/model supports it.

### Why a fixed seed and temperature 0 still do not guarantee identical bytes

- `seed` is documented as a **best effort**, not a determinism contract.
- The provider may update model weights, tokenizer, safety system, routing, quantization, kernels, batching, or inference code.
- Floating-point parallelism and accelerator kernels can be nondeterministic.
- A tiny numeric difference can change a token choice and then the whole remaining sequence.
- Load balancing can route calls to different hardware or backend revisions.
- Ties and near-ties can be resolved differently.
- Some reasoning models do not support temperature/seed controls in the same way. The sheet specifically warns that reasoning models such as its GPT-5.5 example usually require reasoning-specific controls instead.
- A changed backend fingerprint is evidence that the serving configuration changed; an unchanged fingerprint still is not proof of identical output.

Therefore, the package must contain both the **recipe for rerunning** and the **raw result originally observed**. [IC2-3]

### Reproducibility target

Choose the right claim:

- **Bitwise repeatability:** exact bytes match. Often unrealistic for a remote LLM.
- **Structural repeatability:** output always satisfies the required schema.
- **Semantic repeatability:** answers convey the same meaning or classification.
- **Statistical repeatability:** aggregate performance over repeated calls stays within a stated tolerance.

A rigorous experiment states which level it tests and how agreement is measured.

---

## 4. API keys and secret handling

### Correct pattern

Read the key from an environment variable at run time: [IC2; IC8]

```python
import os
from openai import OpenAI

client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])
```

Supply it when starting the container:

```bash
docker run --rm -e OPENAI_API_KEY lab9
```

If it is already exported on the host, Docker forwards its value. An environment file can also be used locally:

```bash
docker run --rm --env-file .env lab9
```

Protect `.env` with permissions and `.gitignore` it.

### Never do this

- Hard-code a key in Python, a notebook, a Dockerfile, or a command committed to Git.
- use `ARG`/`ENV` in a Dockerfile to bake the key into an image layer.
- `COPY` a credential file into the image or reproduction archive.
- print the key in logs, error messages, screenshots, or CI output.
- publish your personal key so others can reproduce the work.

Environment variables reduce accidental inclusion in artifacts, but any process with suitable access may still inspect them. For deployed systems, use a proper secret manager or container secret mechanism.

---

## 5. Prompt engineering fundamentals

Prompt engineering is the iterative design of model input to elicit useful output. It includes instructions, context, examples, output cues, evaluation, and safeguards. There is no universal perfect prompt: behavior depends on model, data, ordering, and use case. [H8]

### From completion to instruction

A bare prompt such as `The sky is` merely invites continuation. A task prompt normally has at least: [H8-10]

1. **Instruction:** what operation to perform.
2. **Data:** what the operation applies to.

An output indicator such as `Sentiment:` can encourage a short label rather than an essay, but it remains soft guidance.

### Seven prompt components: PICFAT-D

| Component | Question answered | Sheet 9 example |
|---|---|---|
| **Persona** | Who should the model act as? | "You are an expert research software engineer." |
| **Instruction** | What must it do? | "Extract the software, datasets, and hardware..." |
| **Context** | Why/what should it focus on? | "Focus on the points needed to reproduce..." |
| **Format** | What shape should the answer have? | "Answer with a JSON object..." |
| **Audience** | Who will consume it? | "The output is for reviewers..." |
| **Tone** | What style/voice? | "Keep the JSON values concise and factual." |
| **Data** | What source material is processed? | `Paper: <text ...>` |

[IC4; H12-15]

### Three high-value prompt rules

1. **Be specific:** state task, scope, length, allowed labels, and format.
2. **Handle uncertainty:** permit an explicit `unknown`/`I don't know` outcome. This reduces pressure to invent an answer but cannot guarantee honesty.
3. **Place crucial instructions near an edge:** models often weight the beginning (**primacy**) and end (**recency**) more than information "lost in the middle." [H11-12]

### Prompt iteration is an experiment

Build prompts modularly:

1. Start with instruction and data.
2. Add only components that have a purpose.
3. Change one component/order at a time.
4. Evaluate on representative cases and record the model/version/parameters.
5. Keep the measured improvement; remove needless text.

This is also a reproducibility issue: the exact prompt is an experimental artifact and must be versioned.

### Chat roles and templates

Messages such as `user` and `assistant` are converted into the model-specific training template. The Phi-3 example becomes: [H3-5]

```text
<s><|user|>
Create a funny joke about chickens.<|end|>
<|assistant|>
```

- Roles distinguish instructions/examples from expected answers.
- Special tokens mark sequence, speaker, and stopping boundaries.
- A template appropriate for one model need not be correct for another.
- In OpenAI's API terminology, a `developer` message provides application rules and outranks a `user` message; generated messages have the `assistant` role. [O]

---

## 6. In-context learning, chaining, and reasoning patterns

### Zero-shot, one-shot, and few-shot

**In-context learning** supplies task demonstrations in the current prompt without updating model weights. In the assigned chapter: [H15-17]

- zero-shot = no examples;
- one-shot = one example;
- few-shot = two or more examples.

Examples can demonstrate content, labels, tone, or output structure. They increase the chance of compliance but do **not** constrain the token stream; the model can still ignore them.

### Modular prompting versus chain prompting

- **Modular prompt:** persona, instruction, context, format, audience, tone, and data are pieces of one call.
- **Chain prompting:** one call's output becomes a later call's input.

Product example: features -> product name -> slogan -> sales pitch. Chaining gives each step a narrower task and its own parameters/token budget. Costs are extra calls, latency, and **error propagation** from an early stage. [H17-19]

Other chain patterns:

- generate -> validate;
- several parallel answers -> merge;
- outline -> characters -> story beats -> dialogue.

### System 1/System 2 analogy

- **System 1:** fast, automatic, intuitive; analogous to immediate token generation.
- **System 2:** slow, deliberate, logical/self-reflective; reasoning prompts try to mimic this process.

The chapter carefully says LLM behavior **resembles** reasoning; the analogy does not prove human-like understanding. [H20]

### Compare the four multi-step techniques

| Technique | Core mechanism | Evaluation | Main cost/trap |
|---|---|---|---|
| Chain prompting | Output of stage A becomes input to B | Per workflow design | Upstream error propagates |
| Chain-of-thought (CoT) | Generate intermediate reasoning before answer | Usually one path | More tokens; reasoning can still be wrong |
| Self-consistency | Sample several diverse complete reasoning paths | Majority vote over final answers | About `n` calls for `n` samples |
| Tree-of-thought (ToT) | Generate, rate, keep, and prune intermediate branches | At intermediate steps | Many generation/evaluation calls |

#### Chain-of-thought

- Standard CoT shows a worked reasoning example.
- Zero-shot CoT gives a cue such as `Let's think step-by-step` without a worked example.
- In the book's apple example: `23 - 20 = 3`, then `3 + 6 = 9`. [H20-23]

#### Self-consistency

1. ask the same question multiple times;
2. allow diverse sampling paths;
3. optionally use CoT for each;
4. extract final answers;
5. return the majority answer.

Repeating deterministic greedy decoding is not useful self-consistency; diversity is the point. A majority can still be systematically wrong. [H23-24]

#### Tree-of-thought

At each step, generate several candidate thoughts, rate/vote, prune weak branches, and expand promising branches. A simpler prompt can imitate a discussion among several experts, but one model role-playing experts is not the same as truly independent evidence. [H24-26]

---

## 7. Output verification and control

### Four different reasons to validate

| Goal | Example | Appropriate check |
|---|---|---|
| Structure | Must parse as JSON | JSON parser / constrained grammar |
| Allowed content | Label must be one of three values | `enum`, set membership |
| Ethics/safety | No PII, profanity, or prohibited content | Dedicated policies/classifiers/review |
| Accuracy | Claim must be factual and supported | Grounding, tools, source checks, domain validation |

[H26-27]

Passing one row does not imply passing the others.

### Four practical techniques from Sheet 9

| Technique | How it works | Strength | Limitation |
|---|---|---|---|
| **Examples / few-shot formatting** | Show correctly formatted answers | Easy; helps both content and layout | Model may ignore them |
| **Scaffolding / slot filling** | Program emits known braces/keys; model emits only unknown values | Fixed scaffolding cannot be malformed by model | Values can still be invalid or false |
| **Grammar/schema constrained decoding** | Mask every next token that would violate the supported grammar | Valid structure by construction | Provider supports only a subset; semantics/truth remain |
| **Validate, retry, or repair** | Parse/validate after generation; feed error back or use repair tool | Works with ordinary models and rich validators | More latency/cost; retries need a cap and may never succeed |

[IC4-6; H27-31]

The book also names **fine-tuning** as a third general output-control family alongside examples and grammar, but does not cover it in this extract. [H27]

### Evaluation-retry loop answer

The two hidden labels in Figure 6-19 are: [IC5; H29]

1. evaluator instruction: **"Check whether the following text adheres to the JSON format:"**
2. lower box in the loop: another **LLM** acting as evaluator/repair component.

Conceptual flow:

```text
prompt -> generator LLM -> draft
                           |
                           v
              evaluator prompt + evaluator LLM
                    | valid             | invalid/feedback
                    v                   +------> retry draft
                  output
```

Use a deterministic parser/schema validator before an LLM evaluator when the rule is mechanically decidable.

### Prompting with a schema versus constrained decoding

| | Schema pasted into prompt | Proper constrained decoding |
|---|---|---|
| Enforcement time | Model sees it as text | Decoder checks before every token |
| Illegal token | Still possible | Masked/unavailable |
| Guarantee | Best-effort instruction following | Schema adherence within supported subset |
| Failure handling | Parser + validator + retry/repair | Schema can be rejected; refusals/truncation still need handling |
| Cost | Schema consumes context; retries may add calls | Grammar compilation/first-call latency and restricted decoding |
| Truth | Not guaranteed | Not guaranteed |

### Constrained sampling algorithm

1. Compile the supported schema/grammar.
2. At the current prefix, compute tokens that can still lead to a valid completion.
3. Mask all invalid tokens.
4. Apply temperature/`top_p` among the remaining legal candidates.
5. Sample/choose a token and repeat.

Grammar controls **admissibility**. Sampling parameters still control **which admissible value** is selected. [H30]

### Book's llama-cpp-python example

```python
output = llm.create_chat_completion(
    messages=[
        {"role": "user", "content": "Create a warrior for an RPG in JSON format."}
    ],
    response_format={"type": "json_object"},
    temperature=0,
)["choices"][0]["message"]["content"]

parsed = json.loads(output)
```

Successful `json.loads` proves parseable JSON syntax. It does not prove a particular schema or a correct character description. [H31-32]

---

## 8. JSON essentials and `jq`

### Lab setup and dataset

The lab first updates the separately cloned course repository and builds its supplied environment: [L1]

```bash
git pull
cd LabSession9
docker build -t lab9-json .
docker run -it lab9-json
```

`births.json` is an array with six monthly observations: January-March 2018 and July-September 2019. Each object has `year`, `month`, `male`, `female`, and `total`. The data shape motivates the array/item/object schema below.

### JSON mental model

JSON values are:

- object: key/value mappings in `{}`;
- array: ordered values in `[]`;
- string;
- number;
- boolean: `true` or `false`;
- `null`.

Important semantics:

- Whitespace outside strings is insignificant.
- Object key order is not semantically significant.
- Array element order **is** significant.
- `95` is a number; `"95"` is a string.
- JSON syntax alone says nothing about which keys should exist or what values mean.

### Pretty versus compact

```bash
# Human-readable, indented form
jq . births.json > births_pretty.json

# Compact single-line form
jq -c . births_pretty.json
```

Pretty JSON is easier to read, review, and line-diff. Compact JSON saves whitespace and is useful for transfer/storage or JSON-lines pipelines. Both represent the same data. [L1-2]

### Query patterns

The exam says you do not need to memorize `jq`, but you may need to apply a documented pattern. [L3]

```bash
# Every month
jq '.[].month' births.json

# Number of array records
jq 'length' births.json
# Output: 6

# 2019 records projected to month and total
jq '.[] | select(.year == 2019) | {month, total}' births.json

# Lab 2.3(a): every year
jq '.[].year' births.json

# Lab 2.3(b): August total
jq '.[] | select(.month == "August") | .total' births.json
# Output: 10200
```

Read left to right:

- `.[]` iterates array elements;
- `.field` reads one property;
- `select(condition)` filters;
- `{month, total}` constructs a smaller object;
- `|` passes each result to the next filter.

### Comparing JSON documents semantically

Plain `diff` compares bytes/lines, so indentation, whitespace, and object-key order create noise. Canonicalize both documents first: [L3]

```bash
jq -S -c . births.json > births.normalized.json
jq -S -c . births_reordered.json > births_reordered.normalized.json
diff births.normalized.json births_reordered.normalized.json
```

`-S` sorts object keys; `-c` normalizes whitespace. An empty `diff` means these normalized representations agree. This does not make arrays order-insensitive.

---

## 9. JSON Schema

JSON Schema describes permitted document structure. A JSON instance is valid for a schema if it violates none of the applicable constraints. [L4]

### Keywords to recognize

| Keyword | Meaning |
|---|---|
| `type` | Required JSON type, e.g. `object`, `array`, `integer` |
| `properties` | Schemas for named object properties |
| `required` | Keys that must appear |
| `additionalProperties: false` | Reject undeclared object keys |
| `items` | Schema for array elements |
| `minimum`, `maximum` | Inclusive numeric bounds |
| `enum` | Value must be one listed choice |
| `pattern` | String must match a regular expression |
| `format` | Named string format when supported/enforced |
| `anyOf` | Valid against at least one listed subschema |
| `oneOf` | Valid against **exactly one** listed subschema |

Do not confuse `properties` with `required`: declaring a property schema does not automatically require the key in ordinary JSON Schema.

### A defensible `births.json` schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "year": { "type": "integer" },
      "month": {
        "type": "string",
        "enum": [
          "January", "February", "March", "April",
          "May", "June", "July", "August",
          "September", "October", "November", "December"
        ]
      },
      "male": { "type": "integer", "minimum": 0 },
      "female": { "type": "integer", "minimum": 0 },
      "total": { "type": "integer", "minimum": 0 }
    },
    "required": ["year", "month", "male", "female", "total"],
    "additionalProperties": false
  }
}
```

This enforces the observed structure, valid month names, and nonnegative integer counts. It does **not** enforce `total = male + female`; that is a cross-field semantic rule requiring application logic or a more specialized mechanism. The two `births_broken_*.json` files referenced by the sheet are not supplied in this repository, so their exact corrupt fields and exact validator messages must not be invented. [L4]

### Validation command

```bash
check-jsonschema --schemafile births_schema.json births.json
```

- A valid instance reports `ok`.
- An invalid instance produces a non-success verdict with a path/location and the failed rule, such as missing required property, wrong type, or unexpected property.
- Refine the schema so the good file remains valid while each broken file is rejected for the intended reason. [L4]

### `anyOf` versus `oneOf`

For subschemas A and B:

| Instance matches | `anyOf` | `oneOf` |
|---|---:|---:|
| neither | invalid | invalid |
| only A | valid | valid |
| only B | valid | valid |
| both A and B | valid | **invalid** |

This exactly-one rule explains the hero/gadget/mutation questions below.

---

## 10. Solved lab multiple choice

### 3(a): `id`, optional `name`, bounded `score`, no extra keys

Schema requires `id >= 1`, numeric `score` from 0 through 100, and rejects undeclared properties.

1. `{"id":1,"name":"Ada","score":90}` -> valid.
2. `{"id":0,"name":"Bob","score":50}` -> invalid: `id < 1`.
3. `{"id":3,"name":"Cy","score":80,"x":1}` -> invalid: extra `x`.
4. `{"id":4,"score":100}` -> valid: `name` is optional and 100 is allowed.

**Answer: 2 valid instances.** [L6]

### 3(b): same schema, type trap

1. `{"id":5,"score":95}` -> valid.
2. `{"id":6,"name":"Finn","score":"95"}` -> invalid: string, not number.
3. `{"id":7,"name":"Gus","score":60.5}` -> valid: `number` includes non-integer values.
4. `{"id":8,"name":"Hank","score":0}` -> valid: minimum is inclusive.

**Answer: 3 valid instances.** [L6]

### 3(c): exactly one of `gadget` or `mutation`

1. Volt: gadget only, valid level -> valid.
2. Blaze: mutation only, valid level -> valid.
3. Rex: both -> matches both branches, so `oneOf` fails.
4. Zed: gadget only, but level 0 violates minimum 1.

**Answer: 2 valid instances.** [L7]

### 3(d): extra properties are allowed here

This schema does **not** say `additionalProperties: false`.

1. Nova: mutation only, level 100 -> valid.
2. Gale: gadget only; extra `city` is allowed -> valid.
3. Ping: neither gadget nor mutation -> invalid.
4. Ace: mutation only -> valid.

**Answer: 3 valid instances.** [L7]

---

## 11. Bowtie and reproducible validation

Different JSON Schema validators can disagree because they have different versions, draft support, bugs, or subsets. Therefore, "the file is valid" is incomplete provenance. State **which validator, which version/image, and which schema draft** produced the verdict. [L5]

### What Bowtie is

Bowtie is a **meta-validator/orchestrator**. It does not supply just one validation algorithm; it runs selected validator implementations in their own container images and collects/compares the results.

The sheet notes that the then-latest Bowtie requires at least Python 3.13; with `uv`, its example installation selects that version explicitly:

```bash
uv tool install bowtie-json-schema --python 3.13
```

```bash
# Run on host, not inside the lab9-json container
bowtie filter-implementations

bowtie validate -i python-jsonschema \
  births_schema.json births.json | bowtie summary

bowtie validate -i python-jsonschema -i js-ajv \
  births_schema.json births.json | bowtie summary
```

Why pinned images help:

- freeze validator implementation and dependencies together;
- avoid accidental dependence on host language/package versions;
- identify exactly which implementation produced each verdict;
- make cross-language disagreements visible;
- improve later reruns if the exact image remains archived.

Limits:

- A container tag can be mutable; prefer immutable digests for strong identity.
- Container availability, host architecture, and Docker itself remain dependencies.
- Agreement among validators does not prove the data's scientific meaning is correct.

---

## 12. Structured Outputs in depth

### JSON mode is not Structured Outputs

| Mode | Valid JSON? | Matches specific schema? |
|---|---:|---:|
| Prompt only | Not guaranteed | No |
| JSON mode | Yes, barring documented edge cases/truncation | No |
| Structured Outputs with strict supported schema | Yes | Yes, for supported structural constraints |

### OpenAI strict-schema rules

- Set `strict: true`.
- Use response-format Structured Outputs when the model should answer the user in a schema; use strict function/tool schemas when the model must call application code with validated arguments.
- Every object must use `additionalProperties: false`.
- Every property must be named in `required`.
- To model a conceptually optional value, require the key but allow `null`, for example `"type": ["string", "null"]`.
- The root must be an object, not a root-level `anyOf`.
- Nested `anyOf` is supported; `oneOf` is not.
- Keywords such as `allOf`, `not`, conditional `if`/`then`/`else`, and dependency keywords are outside the documented strict subset.
- Current general models support numeric `minimum`/`maximum`, string `pattern`/selected `format`, and array bounds; fine-tuned models have narrower constraint support. [O]

### Anthropic qualifications

- Objects require `additionalProperties: false`.
- Properties not named in `required` can truly be omitted.
- `anyOf` is supported; `oneOf` is not listed as supported.
- Numerical bounds such as `minimum`/`maximum` are not enforced by constrained decoding.
- Simple regex patterns and selected string formats are supported.
- Some SDK helpers remove unsupported constraints, put the intent into descriptions, and validate the final result against the original client-side schema. That can make the request's effective schema different from the one written in application code.
- Refusal, token-limit truncation, and documented enum-casing behavior require explicit handling. [A]

### llama.cpp qualifications

The official converter turns a JSON Schema subset into a GBNF grammar: [C]

- optional properties and additional properties are supported;
- if `additionalProperties` is omitted, the examined converter effectively emits only declared keys, which differs from ordinary JSON Schema's default of allowing extras;
- `minimum`/`maximum` are implemented for integers, not arbitrary `number` values;
- regex is supported only by the converter's subset;
- supported formats include date, time, date-time, and UUID variants, while formats such as email/URI are not fully implemented in the examined converter;
- both `oneOf` and `anyOf` enter the same union-generation branch. This admits alternatives but loses `oneOf`'s "not both" semantics when branches overlap.

### What a successful strict call proves

For Sheet 9 Question 10: [IC7]

| Statement | True? | Reason |
|---|:---:|---|
| Output is syntactically correct JSON | **True** | Grammar admits a JSON structure |
| Output conforms to declared types and required properties | **True** | These are enforced supported constraints |
| Numbers and strings are guaranteed factually correct | **False** | Schema checks shape/ranges, not world truth |
| Output is guaranteed hallucination-free | **False** | A hallucination can fit the schema perfectly |
| Unexpressed semantics such as `end_date > start_date` need a separate check | **True** | Decoder cannot enforce a rule not represented in its grammar |
| A schema may be rejected or altered because only a subset is supported | **True** | Raw APIs can reject; some SDKs transform/strip unsupported keywords |

Also handle exceptional response paths: refusal, incomplete/max-token output, API errors, and a model that cannot satisfy the requested task.

---

## 13. Filled OpenAI API code from Sheet 9

These snippets use the model and API surfaces printed on the exercise sheet. The model name is part of the course question; preserve it when filling the blanks. [IC8-9]

### Question 11: Chat Completions text generation

```python
import os
from openai import OpenAI

# (1) Read the secret at runtime.
client = OpenAI(api_key=os.environ["OPENAI_API_KEY"])

response = client.chat.completions.create(
    model="gpt-5.5",
    # Turn off reasoning to enable temperature on this sheet's model.
    reasoning_effort="none",
    messages=[
        {
            "role": "developer",
            "content": "You are a helpful assistant.",
        },
        {
            "role": "user",
            "content": "Define reproducibility in one sentence.",
        },
    ],
    temperature=0.0,  # (2) most deterministic available decoding
    seed=42,          # (3) best-effort reproducible sampling
)

print(response.choices[0].message.content)  # (4)
```

Blank answers:

1. `os.environ["OPENAI_API_KEY"]`
2. `temperature`
3. `seed`
4. `choices[0].message.content`

### Question 12: Responses API with Structured Outputs

```python
schema = {
    "type": "object",
    "properties": {
        "value": {"type": "number"},
        "unit": {"type": "string"},
    },
    "required": ["value", "unit"],       # (1)
    "additionalProperties": False,        # (2)
}

response = client.responses.create(
    model="gpt-5.5",
    reasoning={"effort": "low"},
    input=[
        {
            "role": "user",
            "content": "How hot is boiling water at sea level?",
        }
    ],
    text={
        "format": {
            "type": "json_schema",
            "name": "measurement",
            "schema": schema,
            "strict": True,               # (3)
        }
    },
)

print(response.output_text)
```

Blank answers:

1. `"value", "unit"`
2. `False`
3. `True`

The expected content is structurally like `{"value": 100, "unit": "°C"}`, but the schema alone does not force that scientifically correct value or unit. It merely requires one number and one string.

### Chat Completions versus Responses

- Chat Completions consumes a `messages` list and returns choices; text is at `choices[0].message.content`.
- Responses consumes `input` items and can produce several typed output items; `response.output_text` is the SDK convenience accessor for final text.
- Current OpenAI guidance recommends the Responses API for new text-generation applications, especially workflows using reasoning models; keep Chat Completions here because Question 11 explicitly tests that interface.
- A `developer` message carries application instructions; a `user` message carries the end-user request.
- Reproduction code must pin the SDK version because response objects and supported parameters can evolve. [O]

---

## 14. Complete solved In-Class Sheet 9

### Q1. Architecture comparison

Use the table in Section 2. One-sentence conclusion: local favors self-containment/control but needs huge artifacts and hardware; remote favors convenience/small packages but depends on an opaque, mutable paid service.

### Q2. Long-term remote reproducibility

Pin the model/snapshot and full request; archive code/dependencies, inputs, schemas/tools, parameters, timestamps and response metadata; store the exact raw output used; define evaluation tolerances; document provider/account/cost requirements and model-retirement limitations. Never claim the provider can be frozen from the client side.

### Q3. Secure API key

Read `OPENAI_API_KEY` from the environment, inject it at container run time with `-e`/`--env-file` or a secret manager, exclude secret files from Git and build context, and never bake the key into the image.

### Q4. Reproducibility controls

- blank 1: **temperature**
- value: **0**
- blank 2: **seed**
- exact equality still not guaranteed because the remote backend and numerical execution can change or be nondeterministic
- package the complete request/configuration/metadata **and the raw observed response**

### Q5. Prompt roles

1. expert research software engineer -> **persona**
2. extract software/datasets/hardware -> **instruction**
3. focus on reproduction points -> **context**
4. JSON object, one property per item -> **format**
5. for reproducibility reviewers -> **audience**
6. concise and factual -> **tone**
7. paper text -> **data**

### Q6. Output-structure techniques

1. imitate shown outputs -> **examples / few-shot prompting**
2. program supplies skeleton; model fills values -> **scaffolding / template or slot filling**
3. decoder permits only grammar/schema tokens -> **constrained decoding / constrained sampling**
4. validate then reprompt/repair -> **validation-retry/repair loop**

### Q7. Figure labels

- evaluator text: **Check whether the following text adheres to the JSON format:**
- lower component: **LLM**

### Q8. Schema in prompt versus constrained decoding

Prompting is a best-effort instruction and may emit invalid JSON or violate the schema. Constrained decoding masks illegal next tokens and provides structural adherence to its supported schema subset. Both can produce false content; constrained decoding also introduces schema-subset and exceptional-response limitations.

### Q9. Provider limitations

Memorize the qualified table in Section 1. Especially remember:

- OpenAI: no omitted optional keys; use nullable required fields.
- Anthropic: optional keys yes, numeric bounds no.
- llama.cpp: integer bounds only; `oneOf` is treated like a union/`anyOf`.

### Q10. True statements

Check **1, 2, 5, and 6**. Do not check factual correctness or hallucination freedom.

### Q11. Text-generation code

`os.environ["OPENAI_API_KEY"]`, `temperature`, `seed`, `choices[0].message.content`.

### Q12. Structured-output code

`["value", "unit"]`, `False`, `True`.

---

## 15. Lower-priority assigned-chapter details

These are less central to Sheet 9 but are present in the assigned extract and may appear in recognition questions.

### Model choice and loading

- Earlier representation-focused models such as BERT are associated with classification/understanding tasks; generative pretrained transformers produce new text from prompts.
- A foundation model is pretrained on large text corpora; many task-specific models are fine-tuned from it.
- The chapter contrasts proprietary models (generally stronger, in its wording) with open models (more flexible and free to use).
- It recommends learning with a smaller model first. Phi-3-mini has 3.8 billion parameters and is described as suitable for devices with up to 8 GB VRAM. [H2-3]

Figure 6-1 shows model families and sizes at recognition level: Llama (7B/13B/33B/70B), StableLM (3B/7B), Falcon (7B/40B/180B), Llama 2 (7B/13B/70B), and Mistral (7B). The transferable point is that foundation-model families are released at several parameter scales.

```python
model = AutoModelForCausalLM.from_pretrained(
    "microsoft/Phi-3-mini-4k-instruct",
    device_map="cuda",
    torch_dtype="auto",
    trust_remote_code=True,
)
tokenizer = AutoTokenizer.from_pretrained(
    "microsoft/Phi-3-mini-4k-instruct"
)
pipe = pipeline(
    "text-generation",
    model=model,
    tokenizer=tokenizer,
    return_full_text=False,
    max_new_tokens=500,
    do_sample=False,
)
```

Know the meanings:

- `device_map="cuda"`: place model on GPU.
- `torch_dtype="auto"`: choose appropriate model numeric type.
- `trust_remote_code=True`: allow repository-defined code; this is also a security/reproducibility dependency.
- `return_full_text=False`: omit the prompt from returned generated text.
- `max_new_tokens=500`: cap generated tokens.
- `do_sample=False`: greedy decoding.

### GGUF and llama-cpp-python

- GGUF is used by llama.cpp and commonly stores compressed/quantized models.
- `n_gpu_layers=-1` places all layers on GPU.
- `n_ctx=2048` selects context size.
- Clearing an old model with `del`, `gc.collect()`, and `torch.cuda.empty_cache()` releases Python/GPU memory before loading another. [H30-31]

### Instruction-based applications shown

Recognize supervised classification, search, summarization, code generation, and named-entity recognition. An NER prompt can name allowed entity categories and explicitly exclude verbs/adjectives. [H10-11]

Also recognize the output-control library names **Guidance**, **Guardrails**, and **LMQL**. The chapter presents them as tools that can constrain or validate generation; knowing a name does not imply that every tool provides the same guarantee. [H29]

### Source caveats worth knowing

- The incomplete RPG JSON in the book is intentionally truncated to demonstrate that prompting for JSON does not guarantee parseability.
- Figure 6-13's printed caption appears copied from the prior figure; the figure itself correctly compares zero-, one-, and few-shot prompting.
- The book's `temperature=0` explanation is conceptual; its local deterministic code path uses `do_sample=False`.

---

## 16. Common exam traps

1. **Temperature 0 is not a mathematical guarantee of identical output.** It is the most deterministic supported setting.
2. **A seed is best effort.** Save the backend fingerprint and raw output too.
3. **Do not put an API key in the reproduction package.** Reproducers provide their own.
4. **A remote API container is not self-contained.** The important model state remains outside it.
5. **Open weights are not automatically reproducible.** You still need exact weight hash, tokenizer, inference engine, quantization, prompt template, hardware, and parameters.
6. **Few-shot examples guide; they do not enforce.**
7. **Scaffolding fixes only the scaffolding.** Generated slot values can still be wrong or malformed for their intended meaning.
8. **JSON mode is not schema mode.**
9. **Schema-valid is not factually correct.**
10. **`properties` does not mean `required` in ordinary JSON Schema.**
11. **`number` accepts values such as `60.5`; `integer` does not.**
12. **Minimum/maximum are inclusive.**
13. **`oneOf` means exactly one, not at least one.** Matching both branches is invalid.
14. **Extra keys are allowed by ordinary JSON Schema unless restricted.**
15. **Object key order and whitespace do not change JSON data; array order does.**
16. **Plain `diff` compares representation, not JSON meaning.** Normalize/sort first.
17. **Bowtie is an orchestrator/meta-validator, not a single new validator algorithm.**
18. **Pinned container images improve provenance but do not prove scientific correctness.**
19. **Provider feature tables need qualifications.** For example, llama.cpp supports integer bounds but not all numeric bounds.
20. **An SDK may silently transform a schema.** Record the effective request and validate application semantics afterward.
21. **A refusal or token-limit stop may fall outside the requested schema.** Handle status/stop fields before parsing.
22. **Self-consistency is not independence.** Several samples from one model can share the same bias.
23. **ToT is not merely a long CoT.** It evaluates/prunes branching intermediate alternatives.
24. **Prompt chaining is not prompt components.** Chaining spans multiple calls.

---

## 17. Final two-minute recall sheet

```text
ARCHITECTURE
  Local  = big + hardware + controllable + more self-contained
  Remote = small client + cheap local hardware + API/network/provider/cost dependency

REPEATABILITY
  temperature=0 + fixed seed + exact request/model/versions
  + response metadata + raw output
  still NOT guaranteed bitwise identical

SECRET
  os.environ["OPENAI_API_KEY"]
  docker run -e OPENAI_API_KEY ...
  never Dockerfile/Git/image/log

PROMPT = PICFAT-D
  Persona Instruction Context Format Audience Tone Data

SHOTS
  zero = 0 examples; one = 1; few = 2+

REASONING
  CoT = one stepwise path
  Self-consistency = many complete paths -> majority answer
  ToT = branch -> rate -> prune -> expand

OUTPUT CONTROL
  examples = guidance
  scaffolding = fixed wrapper
  grammar = legal tokens only
  validate/retry = check after generation

TRUST LADDER
  JSON syntax < schema < semantics < truth

JSON SCHEMA
  properties declare; required requires
  additionalProperties:false rejects extras
  anyOf >= 1; oneOf exactly 1

Q9 PROVIDERS
  OpenAI: extras false, all keys required, numeric/string constraints yes, anyOf yes, oneOf no
  Anthropic: extras false, optional yes, numeric bounds no, anyOf yes, oneOf no
  llama.cpp: extras + optional yes, integer bounds only, patterns/formats partial,
             anyOf yes, oneOf accepted as anyOf-like union

LAB MC
  (a) 2, (b) 3, (c) 2, (d) 3

API BLANKS
  Q11: os.environ["OPENAI_API_KEY"], temperature, seed,
       choices[0].message.content
  Q12: ["value", "unit"], False, True

BOWTIE
  host-side meta-validator -> pinned validator containers -> comparable verdicts
```

---

## 18. Short self-test

1. Why can a local LLM be more reproducible but less portable than an API call?
2. Name six items that must be archived for a remote LLM experiment.
3. Why should the raw original response be included?
4. What do temperature, `top_p`, and `top_k` change?
5. Why does a fixed seed not guarantee identical output from a remote service?
6. What are the seven PICFAT-D prompt components?
7. What is the difference between few-shot prompting and fine-tuning?
8. Modular prompting versus prompt chaining?
9. CoT versus self-consistency versus ToT?
10. Name the four output-control techniques from Sheet 9.
11. Does constrained decoding remove temperature's effect completely?
12. What are the four separate output-validation goals?
13. Why can schema-valid JSON still be a hallucination?
14. How do you compare two JSON files while ignoring key order and whitespace?
15. What is the difference between `properties` and `required`?
16. When does an object match `oneOf`?
17. Why is `{"score":"95"}` invalid for `{"type":"number"}`?
18. Why run Bowtie validators in pinned containers?
19. Which Q10 statements are true?
20. What are all seven code blanks across Questions 11 and 12?

### Answers

1. It can freeze weights/runtime locally, but its artifact and hardware requirements are large.
2. For example: exact prompt/messages, model snapshot, all parameters, code/dependencies, input/preprocessing, schema/tools, timestamp/API version, response metadata, and raw output.
3. Future service reruns may differ or become impossible; the raw response preserves the evidence actually analyzed.
4. Temperature reshapes randomness; `top_p` selects cumulative probability mass; `top_k` selects a fixed candidate count.
5. Backend/model/hardware/routing/numeric execution can change and the seed is best effort.
6. Persona, instruction, context, format, audience, tone, data.
7. Few-shot examples live in the prompt and do not change weights; fine-tuning updates model parameters using training examples.
8. Components coexist in one prompt; chaining passes output between calls.
9. One reasoning path; many complete paths plus majority vote; branching intermediate paths with rating/pruning.
10. Examples, scaffolding, constrained decoding, and validate/retry/repair.
11. No. It restricts legal tokens; temperature can still select among legal candidates.
12. Structure, allowed content, ethics/safety, and factual accuracy.
13. A false value can have the correct key and type.
14. Canonicalize both with `jq -S -c .`, then `diff` the normalized results.
15. `properties` assigns schemas to possible keys; `required` says which keys must occur.
16. When it matches exactly one listed branch.
17. JSON string and JSON number are distinct types.
18. To freeze each implementation/dependency version and make its verdict rerunnable/comparable.
19. Syntactic JSON, declared type/required conformance, separate semantic checks, and possible schema rejection/transformation: statements 1, 2, 5, 6.
20. `os.environ["OPENAI_API_KEY"]`; `temperature`; `seed`; `choices[0].message.content`; `"value", "unit"`; `False`; `True`.

---

## Source key and coverage

Every supplied Module 9 item was included.

- **IC** - [In-Class Exercise Sheet 9](9_-_LLMs/SoSe_2026_RepEng_IC_9___LLMs.pdf), cited by PDF page.
- **H** - [Hands-On Large Language Models, Chapter 6 extract](9_-_LLMs/Hands-On_LLM_extracted_pages.pdf), cited by extracted PDF page. PDF pages 2-33 correspond to printed book pages 167-198.
- **L** - [Lab Exercise Sheet 9](Lab_Session_9/Sheet_9.pdf), cited by PDF page.
- **O** - OpenAI's [Structured Outputs introduction/cookbook](https://developers.openai.com/cookbook/examples/structured_outputs_intro), [Structured Outputs guide](https://developers.openai.com/api/docs/guides/structured-outputs), [text generation guide](https://developers.openai.com/api/docs/guides/text), and [feature announcement](https://openai.com/index/introducing-structured-outputs-in-the-api/).
- **A** - Anthropic's [Structured Outputs and JSON Schema limitations](https://platform.claude.com/docs/en/build-with-claude/structured-outputs#json-schema-limitations).
- **C** - llama.cpp's official [`json_schema_to_grammar.py`](https://github.com/ggml-org/llama.cpp/blob/master/examples/json_schema_to_grammar.py), whose accepted keywords define the converter limitations used in the comparison.

The five `.url` files in `Mod9/9_-_LLMs` are Stud.IP `sendfile.php` wrappers; anonymous access returns the login page. Their filenames identify the OpenAI, Anthropic, and llama.cpp topics represented by the authoritative public sources **O**, **A**, and **C** above.
