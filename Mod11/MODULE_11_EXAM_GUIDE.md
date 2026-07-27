# Reproducibility Engineering - Module 11 Exam Guide

> A self-contained, exam-focused guide to every supplied Module 11 source: FAIR data stewardship, legal protection and storage of research data, the EU sui generis database right, multi-stage Docker builds, remote execution, provenance, and HDF5.

## How to use this guide before the exam

With two days left, study in this order:

1. Read **Section 1** once. It contains the answers most likely to earn direct marks.
2. Write the 15 FAIR principles from memory using the chain in **Section 2**.
3. Learn the legal layer test and the two cases in **Sections 3-4**.
4. Memorize the three lab MCQ counts and the HDF5 tree in **Sections 6-8**.
5. Finish with the traps, two-minute sheet, and closed-book test.

Priority:

- **A - must know:** all 15 FAIR principles; FAIR is not the same as open; machine-actionability; GDPR versus copyright versus trade secrecy versus the sui generis right; schema versus instance; create versus obtain; the BHB and Toll Collect outcomes; all in-class answers; multi-stage build logic; HDF5 groups/datasets/attributes; all three lab MCQ answers.
- **B - understand:** why rights accumulate; licenses versus statutory rights; the stakeholder diagram; the remote package/run/collect/analyze workflow; `tmux`; provenance; `h5ls` versus `h5dump`.
- **C - recognize:** FAIR repository examples; detailed license variants; lifecycle-contract edge cases; exact Docker and SSH commands.

> **The whole module in ten lines**
>
> - FAIR = **Findable, Accessible, Interoperable, Reusable**, for humans and especially machines.
> - **Accessible does not mean public:** an open protocol may still require authentication and authorization.
> - FAIR describes digital research objects, including data, algorithms, tools, and workflows; it is not itself a technical standard.
> - Legal layers accumulate: **personal data -> GDPR; original expression -> copyright; protected valuable secrecy -> trade secret; database instance with substantial investment in obtaining/verifying/presenting -> EEA sui generis right; assent -> contract/license**.
> - **Copyright rewards originality; the sui generis right rewards investment.**
> - Sui generis: investment must concern **obtaining, verifying, or presenting** content, not merely creating the underlying information.
> - Multi-stage Docker: build with the toolchain, then copy only a **static binary** into `scratch`.
> - Remote workflow: **Build, Package, Ship, Run, Collect, Analyze**; return raw data together with target provenance.
> - HDF5 = **Groups organize, Datasets store typed arrays, Attributes describe them**.
> - Lab MCQ counts: **5(a) = 3, 5(b) = 3, 5(c) = 4 on the literal wording**; 5(c) becomes 3 only under an unstated "native image type" convention.

---

## 1. The module in one page

### 1.1 FAIR trigger-word table

| Category | Trigger words | Principle IDs |
|---|---|---|
| **Findable** | persistent unique ID; rich discovery metadata; metadata names the data ID; searchable index | F1-F4 |
| **Accessible** | retrieval by ID; standardized open protocol; authentication/authorization; metadata survives | A1, A1.1, A1.2, A2 |
| **Interoperable** | formal shared knowledge language; FAIR vocabulary; qualified links | I1-I3 |
| **Reusable** | rich relevant attributes; clear license; provenance; domain standards | R1, R1.1-R1.3 |

Fast traps:

- A license is **Reusable**, not Accessible.
- A persistent identifier is **Findable**, not Accessible.
- Metadata surviving after deletion is **Accessible**.
- A formal representation language is **Interoperable**.
- Domain-relevant community standards are **Reusable**, while commonly adopted exchange standards/formats are usually tested as **Interoperable**.

### 1.2 Legal scenario decision table

| Clue | Main framework | Test |
|---|---|---|
| Identifiable living person | **GDPR/data protection** | Processing needs consent or another lawful basis. |
| Original figure, code, schema, view, GUI, API implementation | **Copyright** | Sufficient original intellectual creation/expression. |
| Customer list or confidential know-how | **Trade secret** | Not generally known/readily accessible, commercially valuable because secret, and protected by reasonable measures. |
| Database instance funded through substantial collection/checking/presentation effort | **EU sui generis database right** | Substantial qualitative or quantitative investment in obtaining, verifying, or presenting contents. |
| User accepted click-through, NDA, README terms, or license | **Contract/license** | Binds the assenting parties according to its terms. |
| Plain public facts or measurements alone | **Normally none of the first three** | But the collection, schema, contract, or database instance may still be protected separately. |

Always identify the **layer** before naming the law:

```text
record/content -> selection/schema/view -> code/interface -> database instance -> access contract
```

Several layers can be protected at once and by different people.

### 1.3 Sui generis test in six questions

1. Is there a database: systematically/methodically arranged and individually accessible items?
2. Is the maker eligible, usually established in the European Economic Area (EEA)?
3. Was there substantial investment?
4. Was that investment in **obtaining, verifying, or presenting** contents, rather than simply creating the information?
5. Was all or a substantial part extracted/re-utilized, or were small parts taken repeatedly and systematically until equivalent?
6. Did the relevant act occur in the EEA, and is there a license or narrow exception?

Case mnemonic:

```text
BHB created race information       -> not protected
Toll Collect obtained sensor facts -> protected
```

### 1.4 Lab workflow in one picture

```text
mentos.c
   |
   v
[gcc:14 builder] --static compile--> /mentos
   |                                  |
   | COPY --from                      v
   +----------------------------> [scratch runtime image]

controlled builder
   -> experiment.tar.gz
   -> SCP to remote
   -> SSH + tmux + dispatch.sh
   -> out/measurements.csv + out/config/*
   -> results.tar.gz back to builder
   -> plot.py -> measurements.png + README
```

### 1.5 Exact answer strip

#### In-class Questions 1-6

1. FAIR artefacts: **research data, algorithms, software tools, workflows**; not physical laboratory equipment.
2. Stakeholders: **all five listed choices**, including computational agents.
3. Blanks: **machine-actionable**; **computational agents**.
4. Strategy: **adopt general-purpose, open interoperability standards**.
5. Categories: **Findable; Accessible; Interoperable; Reusable**.
6. Classifications: **Reusable; Findable; Interoperable; Accessible**.

#### In-class Questions 7-11

7. Customer list -> **trade secret**; personal spreadsheet -> **GDPR**; textbook figure -> **copyright**; public weather facts -> **none of those as content**.
8. All five listed original database artefacts -> **copyright**.
9. `firstName`/`lastName` schema -> **No**; novel 1,860-region schema -> **Yes**.
10. Right: **sui generis database right**. (a) BHB **not protected**. (b) Toll Collect **protected**. (c) **University**. (d) repeated systematic extraction and all records. (e) US maker **No**. (f) German maker copied in the US **No for that US act**. (g) French team **Yes, risk exists without permission**.
11. Memorize the label table in Section 5.

#### Lab Question 5

- 5(a): **3 true** - (i), (ii), (iv).
- 5(b): **3 true** - (i), (ii), (iii).
- 5(c): **4 true on the literal wording** - (ii), (iii), (iv), (v). JSON can represent an image as pixel arrays or encoded text. If an instructor explicitly restricts "store" to native image/binary types, the count would instead be 3; the sheet itself states no such restriction.

---

## 2. FAIR data stewardship

### 2.1 What FAIR applies to

FAIR concerns **scholarly digital research objects**, not only the final table. The supplied question therefore includes:

- research data;
- algorithms used to process/analyze it;
- software tools;
- workflows and analytical pipelines.

Physical laboratory equipment is outside that digital-object scope, although metadata describing equipment can itself be FAIR. [IC1; FAIR1,5]

The stakeholders include original researchers, researchers who want to reuse work, professional data publishers/repositories, funders, tool builders, and **computational agents**. The last group is central: modern data volume, variety, and speed make human-only discovery and integration inadequate. [IC1; FAIR1-3]

### 2.2 Machine-readable versus machine-actionable

The exact fill-in answer is:

> Digital objects should be **machine-actionable**, enabling **computational agents** to autonomously discover, interpret, assess, and reuse data.

**Machine-readable** means software can parse the syntax. **Machine-actionable** is stronger: an agent can infer enough explicit meaning, permissions, relationships, and processing information to decide what to do with a previously unseen object with little or no human help.

Ask two separate questions:

1. Metadata: **What is this object, and may I use it?**
2. Content: **How should I process or integrate it?**

A CSV is machine-readable, but columns called `x`, `y`, and `z` with no units, provenance, license, or vocabulary are not very machine-actionable.

### 2.3 The 15 principles to memorize

Memory chain:

```text
F: PID - Rich - Link - Index
A: Retrieve - Open - Auth - Metadata survives
I: Language - Vocabulary - Qualified links
R: Rich - License - Provenance - Standards
```

#### Findable

| ID | Exam-ready wording | Why it exists |
|---|---|---|
| **F1** | (Meta)data have a **globally unique, persistent identifier**. | Stable, unambiguous reference. |
| **F2** | Data have **rich metadata**. | Discovery requires description beyond a filename. |
| **F3** | Metadata clearly include the **identifier of the data** described. | Keeps description and object linked when separated/indexed. |
| **F4** | (Meta)data are **registered or indexed in a searchable resource**. | An identifier is useless if nobody can discover it. |

#### Accessible

| ID | Exam-ready wording | Why it exists |
|---|---|---|
| **A1** | (Meta)data are retrievable by identifier through a **standardized communications protocol**. | Predictable automated retrieval. |
| **A1.1** | The protocol is **open, free, and universally implementable**. | No proprietary client gate. |
| **A1.2** | The protocol supports **authentication and authorization when needed**. | FAIR accommodates controlled data. |
| **A2** | **Metadata remain accessible** even after the data disappear. | Preserves citation, provenance, and knowledge that the object existed. |

#### Interoperable

| ID | Exam-ready wording | Why it exists |
|---|---|---|
| **I1** | (Meta)data use a **formal, accessible, shared, broadly applicable knowledge-representation language**. | Machines need common syntax and semantics. |
| **I2** | (Meta)data use vocabularies that are **themselves FAIR**. | A disappearing/opaque vocabulary breaks interpretation. |
| **I3** | (Meta)data contain **qualified references** to other (meta)data. | The link states the relationship, not merely a URL. |

#### Reusable

| ID | Exam-ready wording | Why it exists |
|---|---|---|
| **R1** | (Meta)data have a plurality of **accurate, relevant descriptive attributes**. | A potential user can judge fitness for purpose. |
| **R1.1** | (Meta)data have a **clear, accessible usage license**. | Machines and people can know permitted use. |
| **R1.2** | (Meta)data have **detailed provenance**. | Users can trace source, transformations, and responsibility. |
| **R1.3** | (Meta)data follow **domain-relevant community standards**. | Reuse requires the conventions of the intended field. |

The sheet shortens R1 to rich, accurate, relevant attributes. Learn the meaning, and recognize the original phrase if it appears. [IC2; FAIR4]

### 2.4 FAIR does not mean open

This is the most important conceptual trap:

- A1.1 requires an **open protocol**, not publicly downloadable data.
- A1.2 explicitly permits authentication and authorization.
- R1.1 requires a **clear** license, not necessarily a permissive license.
- Sensitive data can have public metadata and a documented application process while the data remain restricted.

Therefore, a well-described controlled health dataset can be more FAIR than an openly downloadable but undocumented file.

Related traps:

- FAIR is not automatically **free**.
- FAIR is not automatically **ethical** or legally reusable; the license and lawful basis still matter.
- FAIR is not a binary badge. Objects can satisfy different principles to different degrees.
- A DOI helps F1 but does not make the object fully FAIR.

### 2.5 Principles, not an implementation standard

FAIR is a set of high-level, implementation-neutral guideposts. It does not mandate DOI, HTTP, RDF, JSON, XML, HDF5, or a specific repository. Those are possible implementation choices. [FAIR4-5]

This explains the best-answer strategy question: use **general-purpose, open interoperability standards**. A bespoke parser per type does not scale across repositories, languages, future tools, or previously unknown data.

If a domain vocabulary lacks a term, extend a suitable vocabulary or publish a new one with persistent documentation so the vocabulary itself follows FAIR (I2).

### 2.6 F2 versus R1, and other near-neighbors

| Pair | Difference |
|---|---|
| **F2 rich metadata** vs **R1 rich attributes** | F2 emphasizes enough description to **find** the object; R1 emphasizes enough accurate context to **judge and reuse** it. They reinforce each other. |
| **A1.1 open protocol** vs **open data** | Protocol implementation is open; the data may be access-controlled under A1.2. |
| **I1 formal language** vs **R1.3 domain standard** | I1 is a machine-interpretable representation language; R1.3 is the community convention needed for valid domain reuse. |
| **I3 qualified link** vs bare URL | A qualified reference expresses the relationship, such as derived-from or measured-by. |
| **F1 ID** vs **F4 index** | An object can have a persistent ID yet remain undiscoverable if no searchable resource indexes it. |

### 2.7 Why the principles were proposed

The 2014 Leiden workshop **Jointly Designing a Data Fairport** brought academic and private stakeholders together. A FORCE11 group refined the resulting minimal community principles, formally published by Wilkinson et al. in 2016. [FAIR3-4]

The paper's main argument:

- scientific data grows faster than humans can manually curate and integrate;
- specialist repositories provide strong conventions but cannot hold every new data type;
- general repositories accept variety but may not harmonize it;
- machines therefore need persistent identifiers, explicit semantics, standardized access, licenses, and provenance;
- good stewardship is not the final scientific goal, but a precondition for discovery and innovation.

### 2.8 Examples from the FAIR paper - recognition priority

| Example | FAIR features to recognize |
|---|---|
| **Dataverse** | DOI/Handle identifiers, searchable landing page, machine API, versions, license/terms, token-controlled restricted files, persistent public metadata. |
| **FAIRDOM** | Persistent HTTP/DOI references, RDF/XML, community ontologies, downloadable assets. |
| **ISA** | General life-science metadata framework with linked-data/RDF/JSON representations. |
| **Open PHACTS** | Machine API, canonical URL mappings, multiple representations, community ontologies, provenance descriptions. |
| **wwPDB** | Searchable stable records, standard formats such as mmCIF, cross-references, dictionaries, distributed archive. |
| **UniProt** | Stable URLs, multiple formats, rich metadata, shared ontologies, typed machine-actionable cross-links. |

The paper contrasts FAIR with the Data Seal of Approval: repository certification emphasizes organizational responsibilities and conduct; FAIR primarily describes qualities of the digital object and its metadata.

### 2.9 Solved in-class Questions 1-6

| Question | Answer | Reason |
|---|---|---|
| **1** | Data, algorithms, software tools, workflows | All are digital scholarly objects; physical equipment is not. |
| **2** | All five stakeholders | Producers, reusers, publishers, funders, and computational agents all affect stewardship. |
| **3** | machine-actionable; computational agents | Central automated-discovery goal. |
| **4** | General-purpose, open interoperability standards | Scales better than bespoke parsers and universal tool-specific support. |
| **5(a-d)** | Findable; Accessible; Interoperable; Reusable | The four letters of FAIR. |
| **6(a)** | Reusable | Clear usage license = R1.1. |
| **6(b)** | Findable | Persistent identifier = F1. |
| **6(c)** | Interoperable | Common accessible/open standards and formats enable integration. |
| **6(d)** | Accessible | Persistent metadata = A2. |

---

## 3. Legal protection: identify the layer first

> This section summarizes the course's EU/German legal framework for exam purposes; it is not case-specific legal advice.

### 3.1 Why data rarely has one owner

The word **ownership** is misleading. Pure information/facts generally do not belong to somebody in the same way as a physical object. Instead, different rights govern different aspects and coexist:

```text
personal person-linked content           -> data protection
original record/figure/text/image        -> copyright in content
confidential commercially valuable fact  -> trade-secret protection
original code/schema/view/interface      -> copyright
database instance with qualifying obtaining/verifying/presenting investment -> sui generis database right
agreed access/use conditions              -> contract or license
```

One database can contain all of these at the same time, held by different actors. Obtaining permission from one holder does not erase the others. [LP2-3]

### 3.2 Research data and openness

The Open Data Directive's research-data concept covers digital documents other than scientific publications that are created/collected during research and used as evidence or accepted as needed to validate findings. [LP2]

The rule is **as open as possible, as closed as necessary**, not publish everything. The paper describes a narrow obligation for publicly funded data that have already been made public through a repository, subject to commercial interests, knowledge transfer, privacy, secrecy, and earlier IP rights.

Public visibility still does not answer who may append, modify, or delete.

### 3.3 The three content frameworks

#### GDPR/data protection

Applies to data linked to an identifiable **living person**. Consent is one possible lawful basis, not the only one. GDPR regulates processing and duties; it should not be described as ordinary property ownership.

Examples: names with identifiers, patient records, identifiable survey responses. Pseudonymized data may remain personal data, and combining datasets can make previously de-identified records identifiable again.

#### Copyright

Protects original expression, not raw facts. It can apply to an original figure, text, photograph, code, creative selection/arrangement, schema, or interface. A copyrighted Bart Simpson image remains copyrighted when stored as a BLOB; the database location does not change the content right.

#### Trade secrets

The course test requires all three:

1. not generally known or readily accessible;
2. commercial value because it is secret;
3. reasonable protective measures, such as NDAs and technical access controls.

A confidential customer list is the canonical example. A vague request to keep something quiet is weaker than an NDA plus authentication, logging, and intrusion protection. [IC3; LP3]

### 3.4 Protection by database-application component

The 2023 article maps the classic Model-View-Controller system plus database layers as follows. [DB2-4]

| Component | Typical protection | Exam nuance |
|---|---|---|
| **View/GUI** | General copyright if original | Visual/interface expression can be protected. |
| **Controller/application/DBMS** | Software copyright | Includes sufficiently original stored procedures and UDFs. |
| **Model** | Software and/or general copyright | Depends on whether code or original expression/structure is at issue. |
| **Schema/views/selection** | Copyright as an original database work | Original selection/arrangement; trivial functional structure fails. |
| **Database instance** | Sui generis database right, if there is substantial qualifying investment | Obtaining/verifying/presenting investment, not creativity or mere data creation. |
| **Individual record** | Normally no database right by itself | May independently contain personal, copyrighted, or secret content. |

Interface nuance: the 2023 article says the underlying **idea/principle or bare interface specification** is not automatically software-copyrighted; an original implementation, documentation, or expressive API design may be. For the sheet's wording, "an original web API," choose **copyright**.

### 3.5 Schema originality

The test is original selection/arrangement, not complexity for its own sake.

- `firstName` plus `lastName`: common functional design -> **not sufficiently original**.
- Germany divided into 1,860 carefully crafted regions for comparable drug-sales analysis: original structural choice -> **likely protected**.

Copyright normally begins with the natural person(s) who created the protected expression; an institution may receive rights through employment rules or contract. This differs from the database producer right, which arises for the investor and may belong directly to an organization. [IC3; DB3-4]

### 3.6 Rights in one research collaboration

The 2024 article's example contains:

- researchers A/B/C organizing data;
- University Y and funder I financing the work;
- manufacturer M providing internal data under NDA;
- students S/T writing code and designing the UI.

Possible result:

- A/B/C hold copyright if their selection/structure is original;
- Y or I may hold the sui generis right as substantial investor;
- S/T may hold copyright in code/UI unless assigned;
- M retains trade-secret protection;
- personal data would add GDPR duties.

Publication therefore needs all relevant permissions, or exclusion of the protected component. There is no automatic rule that "the professor" or "the university" owns everything. [LP2]

---

## 4. The EU sui generis database right

### 4.1 What it protects

The right protects a **database instance as a collection**, independently of copyright in content, schema, code, or interface. It rewards a qualitatively or quantitatively substantial investment in **obtaining, verifying, or presenting** the contents. It can block extraction or re-utilization of all or a substantial part. [IC4; DB1,4]

Core comparison:

| Copyright/database work | Sui generis database right |
|---|---|
| Protects sufficiently original expression, selection, or arrangement | Protects qualifying investment in the database instance |
| Creativity/originality matters | Creativity does not matter |
| Often begins with a human author | Often held by institution/funder/company that bore the cost |
| Can protect schema, code, GUI, content | Protects the accumulated instance |

The ordinary term is **sui generis database right**; the German article calls it the **Datenbankherstellerrecht** (database producer/maker right).

### 4.2 What counts as a database

The legal definition is broad: independent items arranged systematically or methodically and individually accessible.

- A sensible sort order is not required.
- IDs, line numbers, paths, or full-text search can make items individually accessible.
- Digital form is not essential; a paper card index can qualify.
- A truly random heap whose items cannot be stably referenced is less likely to qualify.

### 4.3 Scope of prohibited extraction

- Taking all records: can infringe.
- Taking a qualitatively or quantitatively substantial part: can infringe.
- Taking one insignificant record once: normally not under this right.
- Repeatedly and systematically taking small pieces until the collection is effectively copied: can infringe; the rule prevents circumvention.

An individual record may still have its own GDPR, copyright, or secrecy protection.

### 4.4 Obtain versus create - the decisive distinction

Investment counts when directed to finding/collecting existing information, checking it, or presenting it. Cost spent creating the underlying events/information does not automatically count.

#### British Horseracing Board v William Hill

BHB spent heavily organizing races and generating lists of runners, riders, and dates. The European court treated the decisive expense as creating the underlying race information rather than obtaining independent existing content. **Course answer: database not protected on that investment theory.** [IC4; DB6]

#### Toll Collect

Toll Collect installed terminals/devices that captured externally existing facts about truck use. The German court treated that effort as obtaining database contents. The calculated toll amount itself is generated, but the measured inputs are collected. **Course answer: database protected.** [IC4; DB6]

Mnemonic:

```text
create the event/schedule -> BHB -> no
capture external facts    -> Toll -> yes
```

The distinction is controversial for sensors, scraped data, derived metadata, and AI because real systems mix acquisition and generation.

### 4.5 Holder and duration

The right belongs to the party bearing the qualifying investment. For a university database built by salaried researchers on university infrastructure, choose **the university**, not all researchers or the PI. [IC4]

The 2023 article states a 15-year term. A new substantial investment can restart protection for the updated instance, potentially extending protection repeatedly. [DB1]

### 4.6 Territoriality and the three geography questions

The course model has two distinct territorial checks:

1. **Maker eligibility:** generally an EEA maker/institution.
2. **Place of conduct:** the database right prohibits relevant acts in the EEA.

Therefore:

| Scenario | Course answer | Reason |
|---|---|---|
| US company builds database, posts it openly, no accepted license | **No** | US maker generally lacks this EEA-only producer right; no contract was formed. |
| German institution posts database; US company copies/uses it in the US | **No for that US act** | Maker is eligible, but the relevant copying is outside territorial reach. Later EEA re-utilization could change the analysis. |
| German institution posts database; French team copies/compares without license | **Yes, risk** | Eligible maker and conduct in the EEA; public access is not permission. |

Do not collapse eligibility and territorial enforcement into one question. [IC5; DB5,7]

### 4.7 Contracts invert the practical default inside and outside the EEA regime

A contract/license binds people who accepted it; it normally does not bind a stranger who obtained the data from another person and never assented. Statutory copyright, trade-secret, or database rights can reach outsiders independently. [LP3-4; DB5]

The 2023 article's exam-worthy inversion:

- Outside the EEA, in a jurisdiction with no equivalent producer right, the maker needs a valid pre-access contract to create restrictions. Without assent, unprotected facts may be reused.
- Within the EEA regime, silence preserves the qualifying maker's statutory right. A license is what gives the **user** safe permission.

Thus: **outside the regime, the license protects the maker; inside the EEA regime, it often protects the user.** This wording includes Norway, Iceland, and Liechtenstein, which are outside the EU but inside the EEA.

### 4.8 Licenses and the research exception

Database rights need a license that actually covers them. The 2023 source highlights CC 4.0-era licenses and choices such as:

- **CC0:** waiver/dedication with no attribution condition;
- **CC BY:** attribution;
- **CC BY-SA:** derivatives under the same license;
- **CC BY-ND:** redistribution only unchanged;
- **NC:** non-commercial restriction, whose boundary can be uncertain;
- database-focused alternatives: ODbL, ODC-By, PDDL, CDLA.

The license must come from the relevant holder(s), and rights in content/code/schema/instance may require several compatible permissions.

The non-commercial scientific-research exception described by the source is narrow: since 2019 it can permit copying a substantial part to the extent required for non-commercial scientific research, but **not a complete copy**, distribution, or making that copy publicly available. It also supplies no corresponding exception for computer programs such as the DBMS or stored procedures, and the source excludes third-party-funded research for private companies. For the French-team question, the safe exam answer remains **Yes, there is a risk without a license**. [DB8-9]

### 4.9 Solved in-class Questions 7-10

#### Question 7

| Scenario | Answer |
|---|---|
| Customer list protected with NDAs/access restriction | **Trade secret protection** |
| Identifiable living people in a spreadsheet | **Data protection/GDPR** |
| Original textbook figure reproduced | **Copyright** |
| Only public weather measurements | **None of the listed frameworks for the facts themselves** |

The collection could separately obtain sui generis protection, but that was not one of Q7's offered frameworks.

#### Question 8

All answers are **Copyright**:

1. sufficiently original schema;
2. complex/original stored procedure or UDF;
3. original GUI;
4. original web API;
5. Bart Simpson image stored as BLOB.

#### Question 9

- Two conventional name fields -> **No**.
- Novel 1,860-region analytical partition -> **Yes**.

#### Question 10

| Part | Answer |
|---|---|
| Name | **sui generis database right** |
| (a) BHB | **Not protected** - creation, not qualifying obtaining investment |
| (b) Toll Collect | **Protected** - sensor collection/obtaining investment |
| (c) Holder | **University** - it bore the substantial investment |
| (d) Actions | **Repeated systematic individual extraction** and **all records**; not one ordinary record alone |
| (e) US maker | **No** |
| (f) German maker, US copying | **No for the stated US conduct** |
| (g) German maker, French research use | **Yes, risk exists** |

---

## 5. Legal perspectives on research-data storage

### 5.1 The paper's central thesis

Artifact sharing improved, but long-term storage still fails when people graduate, teams split, affiliations change, sensitive material enters a dataset, repository terms change, or funding ends. The result is a dynamic **nexus of contracts**, not one permanent owner/data relationship. [LP1]

The proposed solution is **legal-by-design research-data infrastructure**:

1. identify actors, rights, foreseeable changes, and exit rules early;
2. create reusable but project-adaptable contract templates;
3. translate those rules into permissions, views, logging, security, portability, and retention;
4. avoid a gap between what is legally allowed and what the system technically permits.

### 5.2 Stakeholders and their interests

| Stakeholder | Role and likely interest |
|---|---|
| **Data providers** | Supply content that may be personal, copyrighted, or secret; attach consent/license/NDA conditions. |
| **Individual researchers** | Collect and organize data; need academic freedom, collaboration, attribution, and continued access. |
| **Research institutions/funders** | Finance staff/infrastructure; may hold producer rights, impose policies, and contract with repositories. |
| **Support personnel** | Build schemas, software, and UIs; may initially own copyright unless assigned/licensed. |
| **Data repositories/infrastructure providers** | Store/process data and enforce technical access; storage alone gives no ownership, but provider terms matter. |
| **Interested third parties/public** | Reviewers, collaborators, reusers, commercial users; need varying read/use rights and restrictions. |

Researchers are not a single stable legal entity. People join and leave, may belong to different institutions, and may acquire new rights in modified/forked databases without eliminating upstream rights. [LP4-5]

### 5.3 Controller versus processor

For personal data, the research institution is usually the **controller** in the paper's ordinary scenario; an external repository is usually a **processor** acting on its behalf. GDPR Article 28 requires a written processing arrangement defining responsibilities and safeguards.

Outsourcing does **not** outsource responsibility. The controller must require and supervise suitable technical and organizational measures. Similar contractual needs can arise for trade secrets. [LP5,10]

### 5.4 Exact Figure 1 labels - Question 11

Read top to bottom in each column:

| Figure area | Exact labels |
|---|---|
| **Data Providers** | Privacy; IP Rights; Trade Secrecy |
| **Researchers - rights** | Copyright in Software; Consent or License; Copyright in Structure; sui generis rights |
| **Researchers - actors** | Individuals; Support; Institutions |
| **Data Repositories** | Terms of Use; License; Technical Framework; Contract Terms |
| **Interested Third Parties** | Privileged Use; License; Restricted Use; Attribution |
| **Across the bottom** | Cross-Cutting Concerns: Security, Compliance, Availability |

The standalone label **License** occurs twice in the picture: once between researcher rights and the repository and once between the repository and third parties. Including **Consent or License**, the word appears three times in total.

Conceptual flow:

```text
DATA PROVIDER
  privacy + IP + secrecy
          |
   consent/license
          v
RESEARCHERS / INSTITUTIONS
  software copyright + structure copyright + sui generis right
          |
       license
          v
DATA REPOSITORY
  terms of use + technical framework
          |
       license
          v
THIRD PARTIES
  privileged use? restricted use? attribution?

Institutions -------- contract terms --------> repositories

foundation for everyone: security + compliance + availability
```

Why **triple burden**? Data may arrive with provider restrictions, gain researcher/institution rights and licenses, and then gain repository terms/technical limits before a third party sees it. [IC5; LP5-6]

### 5.5 The institution as the contractual spider

The institution usually employs researchers/support staff and contracts with infrastructure providers, so it sits at the web's center. But no arrangement is perfect:

- institution control can subordinate research to cost, bandwidth, or license policies;
- researcher control can lack legal advice and actual system-control capability;
- multi-institution projects need a leading party and governance rules;
- large cloud providers often offer take-it-or-leave-it conditions;
- academic freedom prevents treating university researchers exactly like ordinary private employees.

Best answer: create a standard institutional framework, disclose its core terms to researchers, allow project-specific changes, and anticipate multi-institution/third-party cases. [LP6]

### 5.6 When a researcher changes affiliation

Under the German default described by the paper, an individual researcher may retain copyright in their work while the old institution has a non-exclusive use right. But copyright is not physical or technical access:

- uncopyrighted data may remain on the old system;
- schema/code may belong to another contributor;
- support-personnel rights may have been assigned to the institution;
- repository and data-provider contracts do not automatically follow the researcher;
- a huge or sensitive database cannot always be copied onto a drive;
- duplicated forks create synchronization and integrity problems.

Plan in advance for export, read/write access, cost, contract assignment/joinder, ongoing NDA/license permission, membership voting, and departure/exclusion. [LP7]

### 5.7 Datasets change their legal character

During active research:

- new columns can introduce personal data;
- joining sources can re-identify pseudonymized people;
- copyrighted or confidential content can contaminate a previously open dataset;
- volume and compute requirements can outgrow the original provider contract.

Therefore security/classification cannot be a one-time upload check. Use periodic reviews, scalable access control, logging, and adaptable contracts. Maximum restriction may reduce legal risk but can also make science impossible. [LP8]

### 5.8 Reviewer and third-party access

Before publication, the later public license may not apply. Reviewers normally need read-only, limited access; the system may need filtering, pseudonymization, quotas, logging, and watermarking. A code of honor is insufficient for GDPR or trade secrets.

Double-anonymous review creates a design conflict:

- institutional hosting/domain/logs may reveal author affiliation;
- third-party hosting protects anonymity but weakens direct supervision;
- a neutral independent or multi-institution platform should conceal identity while preserving evidence for a proven violation.

### 5.9 Integrity, security, and availability

Protect against unauthorized access, device failure, transmission errors, inconsistent replicas, and lost providers. Sensitivity should drive stronger measures. The paper distinguishes legal confidentiality duties from broader research-ethical expectations for integrity and redundancy. [LP8]

For reproducibility, security is not enough: a perfectly confidential file that disappears after project funding still fails future validation.

### 5.10 License choice and repository power

Repositories often offer a fixed license menu, but several holders may need unanimity. Decide early. A repository cannot mine customer data merely because it stores it; a storage contract is not a use license, and a copyright text/data-mining exception does not legalize personal-data processing. [LP9]

License shorthand:

| License element | Meaning |
|---|---|
| **CC0** | Waive/dedicate claims; no legal attribution condition. Scientific ethics may still require citation. |
| **BY** | Attribution/source/license. |
| **SA** | Adapted/derivative material remains under the same license. |
| **ND** | Redistribution only without adaptation. |
| **NC** | No commercial use; boundary can be uncertain. |

### 5.11 Storage termination

When funding ends, storage and compliance still cost money. A provider may terminate, fail, enter bankruptcy, merge, or use foreign subcontractors. Contracts need retention and exit rules, but a verified local backup remains advisable. [LP9-10]

### 5.12 Legal-paper traps

1. Publicly funded does not automatically mean public.
2. Publicly accessible does not mean licensed for reuse.
3. GDPR protects people; it is not ordinary ownership of facts.
4. Repository storage does not grant the repository data ownership.
5. A contract binds assenters, not automatically every later recipient.
6. One license cannot authorize rights held by somebody else.
7. Researcher copyright does not guarantee access to the instance.
8. Research exceptions are not universal immunity.
9. Pseudonymization is not necessarily anonymization.
10. Outsourcing to a processor does not remove controller responsibility.
11. A public-release license may not govern prepublication review.
12. Design permissions and termination before the conflict, not afterward.

---

## 6. Multi-stage Docker builds

### 6.1 Why use two stages

Compiling requires GCC, headers, linker, libraries, shell, and source. Running a statically linked program needs almost none of them.

```text
single-stage gcc:14 image
  compiler + headers + shell + package tools + source + binary

multi-stage final image
  /mentos only
```

A second `FROM` starts a new filesystem. `COPY --from=builder` selects an artifact from the earlier stage; it does not merge the whole builder. Builder layers may remain in local build cache, but they are not in the final runtime image. [L1-2]

Benefits:

- far smaller transfer/storage footprint;
- smaller attack surface;
- clean build/runtime dependency separation;
- fewer accidental runtime files.

It does not automatically make compilation deterministic or portable to a different CPU architecture/kernel ABI.

### 6.2 Exact required Dockerfile

```dockerfile
FROM gcc:14 AS builder
WORKDIR /src
COPY mentos.c .
RUN gcc -O2 -static -o mentos mentos.c -lm

FROM scratch
COPY --from=builder /src/mentos /mentos
ENTRYPOINT ["/mentos"]
```

Line-by-line:

- `AS builder` names the source stage.
- `-static` embeds required userspace libraries into the executable.
- `-lm` links the math library.
- `scratch` is empty: no shell, dynamic loader, compiler, or utilities.
- exec-form `ENTRYPOINT` launches `/mentos` directly; shell form would fail because `scratch` has no `/bin/sh`.

A static binary still targets a particular OS/kernel interface and CPU architecture. **Static is self-contained, not universal.**

### 6.3 Source inconsistency you must not copy into the exam

The sheet requires static linking, and its MCQ shows `-static`. The linked repository's single-stage starter at the audited revision omits it. If that dynamic executable is copied into `scratch`, Docker can report the misleading:

```text
exec /mentos: no such file or directory
```

The binary exists; its requested dynamic ELF loader/shared libraries do not. For the exam and working solution, **include `-static`**. [L2,8; LABCODE]

The repository also calls the remote C source `mentos.c`, while sheet page 3 calls it `experiment.c`. Learn the concept, and use the filename present in the actual directory.

The repository contains a `remote/run_experiment.py`, but neither the builder image nor the printed workflow uses it; the exercised path compiles and runs the C program. Do not introduce that unused helper into an exam answer unless asked about repository contents specifically.

### 6.4 Build, compare, run

```bash
cd LabSession11/multistage

docker build -f Dockerfile.singlestage -t mentos-singlestage .
docker images mentos-singlestage

docker build -t mentos-multistage .
docker images | grep mentos

docker run --rm mentos-multistage > measurements.csv
```

The final redirection is performed by the **host shell**, so container stdout becomes a host file. No terminal output is expected.

There is no timeless numeric size answer because the mutable `gcc:14` tag, architecture, and reporting change. Calculate:

```text
absolute reduction = single size - multi size
percent reduction  = 100 * (single - multi) / single
```

Expected pattern: a compiler image measured in hundreds of MB or more versus one static executable, typically well over 99% smaller.

### 6.5 Exact Mentos dataset - useful for HDF5 answers

The linked C code computes:

```text
height_cm = 35 * mentos^0.6 * flavor_factor * cola_factor

flavor: fruit = 0.75, mint = 1.00
cola:   cola = 0.80, diet = 1.00, zero = 0.95
```

There are 2 flavors x 3 cola types x 8 Mentos counts = **48 observations**, plus the CSV header.

| Mentos | fruit/cola | fruit/diet | fruit/zero | mint/cola | mint/diet | mint/zero |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 21.0 | 26.2 | 24.9 | 28.0 | 35.0 | 33.2 |
| 2 | 31.8 | 39.8 | 37.8 | 42.4 | 53.1 | 50.4 |
| 3 | 40.6 | 50.7 | 48.2 | 54.1 | 67.7 | 64.3 |
| 4 | 48.2 | 60.3 | 57.3 | 64.3 | 80.4 | 76.4 |
| 5 | 55.2 | 68.9 | 65.5 | 73.5 | 91.9 | 87.3 |
| 6 | 61.5 | 76.9 | 73.1 | 82.0 | 102.6 | 97.4 |
| 7 | 67.5 | 84.4 | 80.2 | 90.0 | 112.5 | 106.9 |
| 8 | 73.1 | 91.4 | 86.8 | 97.5 | 121.9 | 115.8 |

Patterns to describe:

- height rises monotonically but sublinearly because exponent 0.6 is below 1;
- mint is 4/3 of fruit for fixed cola/count;
- diet > zero > regular cola;
- minimum = 21.0 cm, fruit/cola/1;
- maximum = 121.9 cm, mint/diet/8.

### 6.6 Solved Lab 5(a) - answer 3

| Statement | Truth | Reason |
|---|---|---|
| (i) Multi-stage is smaller | **True** | Final stage contains only binary. |
| (ii) `gcc` exists only in single-stage runtime | **True** | `scratch` has no compiler. |
| (iii) `./mentos` only runs in single-stage | **False** | Multi-stage has `/mentos`; default working directory is `/`, so `./mentos` names it there. |
| (iv) Binaries are bitwise identical | **True, intended** | Printed snippets use the same source, base, path, and compile command; copying does not alter bytes. |
| (v) Both images contain `mentos.c` | **False** | Source remains in the discarded builder stage. |

Choose **3**. Caveat: multi-stage construction itself does not prove all independent future builds are bitwise reproducible. A changed base tag/toolchain or nondeterministic compiler output could differ. Answer the stated same-build scenario first.

---

## 7. Remote execution and provenance

### 7.1 Why not run the builder image remotely

A real target may offer only SSH, lack Docker, or need direct access to special hardware. The controlled environment builds a self-contained package; the target performs the measurement; results return to a controlled analysis environment.

Mnemonic:

```text
B-P-S-R-C-A
Build -> Package -> Ship -> Run -> Collect -> Analyze
```

The target still matters. Containers do not erase CPU, GPU, RAM, kernel, driver, storage, or resource-limit differences. [L3]

### 7.2 Start the simulated SSH server

```bash
cd LabSession11/remote
docker build -f Dockerfile.remote -t lab11-remote .
docker run --rm -d -p 2222:22 --name lab11-remote lab11-remote
```

Flags:

- `-d`: background/detached server;
- `--rm`: delete the container after it stops;
- `-p 2222:22`: host port 2222 forwards to remote-container SSH port 22;
- `--name`: stable name for cleanup.

`EXPOSE 22` only documents the intended port; `-p` publishes it.

### 7.3 Build and ship the execution package

On the host:

```bash
docker build -f Dockerfile.builder -t lab11-experiment-builder .
docker run --rm -it --network host lab11-experiment-builder
```

Inside the builder:

```bash
tar -czf experiment.tar.gz package
scp -P 2222 experiment.tar.gz repro@localhost:~/
```

Password in this isolated lab: `repro`.

Remember exactly:

```text
ssh port = lowercase -p
scp port = uppercase -P
```

The colon in `repro@localhost:~/` separates host from remote path. The archive contains the static binary and dispatcher, not assumptions about target-installed Docker/compiler/Python.

### 7.4 Run inside `tmux`

```bash
ssh -p 2222 repro@localhost
tar -xzf experiment.tar.gz
cd package
chmod +x mentos dispatch.sh
tmux new -s mentos
./dispatch.sh
```

Detach:

```text
Ctrl-b, release, then d
```

Then `exit`, reconnect, and reattach:

```bash
ssh -p 2222 repro@localhost
tmux a
```

If several sessions exist:

```bash
tmux attach -t mentos
```

Why it works: `tmux` owns a persistent server and pseudo-terminal independent of the SSH client. It survives a network/SSH disconnect, but not necessarily machine reboot or container deletion. It improves run robustness, not deterministic scientific output. [L4]

The 48 measurements sleep about 1.5 seconds each, so the simulated run is roughly 72 seconds.

### 7.5 What the dispatcher records

`dispatch.sh` uses `set -eu`, resolves its own package directory, writes experiment stdout to `out/measurements.csv`, and leaves progress on stderr visible. It creates `out/config` and records target details where available. [LABCODE]

Expected names:

| File | Meaning |
|---|---|
| `hostname` | Target label/identity; often a container ID here. |
| `os-release` | User-space distribution and version. |
| `cpuinfo` | CPU model, cores, and feature flags. |
| `cmdline` | Kernel boot parameters. |
| `modules` | Loaded kernel modules. |
| `cgroups` | Control-group/controller information. |
| `kconfig.gz` | Kernel build configuration, only when exposed. |

Inspect:

```bash
cd ~/package/out/config
ls
cat hostname os-release
```

Best written answer: `os-release`, CPU, kernel/driver, memory, and relevant resource limits matter far more for reconstruction/performance than a hostname alone. Preserve all available records. Inside a container, `os-release` describes container user space, while `/proc` largely reflects the shared host kernel.

A strong real record also contains source commit, image digest, artifact checksum, compiler/library versions, exact command/parameters, input checksums, seeds, timestamps, GPU/storage/RAM, and limits.

### 7.6 Collect and analyze in the controlled builder

On remote:

```bash
cd ~/package
tar -czf results.tar.gz out
exit
```

Back in builder:

```bash
scp -P 2222 repro@localhost:~/package/results.tar.gz .
tar -xzf results.tar.gz
python3 plot.py
```

Expected output file: `out/measurements.png`. The plot has six lines, Mentos count on x, height in cm on y, and is produced with controlled Python/Matplotlib dependencies.

The README should state:

- 48 observations and experimental factors;
- main result pattern and min/max;
- link/embed the plot;
- target hostname, OS, CPU, and retained config files;
- ideally source/artifact/config identities.

Finally, only after copying results, run this **back on the host or in a separate host terminal** (not inside the builder):

```bash
docker stop lab11-remote
```

Because the server used `--rm`, stopping deletes its writable container state.

### 7.7 Remote-workflow traps

1. `ssh -p`, but `scp -P`.
2. Remote paths need the colon after the host.
3. Start `tmux` on the remote, not in the builder.
4. Detach before leaving SSH.
5. `tmux` does not survive target deletion/reboot by magic.
6. Copy provenance with raw measurements, not only the chart.
7. Analyze in the controlled builder, not an arbitrary target environment.
8. Do not stop an ephemeral remote before collecting results.
9. A static binary remains architecture-specific.
10. Use SSH keys and proper secrets on a real system; the lab password is intentionally weak.

The optional IDE/Remote-SSH task changes the interface, not the execution/provenance principles.

---

## 8. HDF5 storage and inspection

### 8.1 The data model

Mnemonic: **F-G-D-A**.

```text
File
└── Group       directory-like named container
    └── Dataset homogeneous n-dimensional typed array
        └── Attribute small metadata attached to an object
```

HDF5 is a binary, hierarchical, self-describing format suited to large arrays and partial reads. "Self-describing" means names, hierarchy, shapes, datatypes, and attributes travel with the values; it does not mean the file automatically documents every scientific assumption.

Rule of thumb:

- group = organize;
- dataset = bulk/sliceable data;
- attribute = small descriptive fact.

### 8.2 Required Module 11 tree

```text
/
└── meas/
    ├── fruit/
    │   ├── cola       Dataset {8, 2}
    │   ├── diet       Dataset {8, 2}
    │   └── zero       Dataset {8, 2}
    └── mint/
        ├── cola       Dataset {8, 2}
        ├── diet       Dataset {8, 2}
        └── zero       Dataset {8, 2}
```

For every dataset:

```text
path      /meas/<flavor>/<cola>
one row   [mentos, height_cm]
shape     (8, 2)
attribute columns = ["mentos", "height_cm"]
```

Mental split:

```text
PATH = categorical coordinates: flavor, cola
DATA = observations: mentos, height
ATTR = column semantics
```

Counts:

- `/` is the implicit root;
- named groups: `/meas`, `/meas/fruit`, `/meas/mint`;
- six datasets;
- eight rows and 16 scalar values per dataset;
- 48 observations and 96 numerical scalar values total;
- one `columns` attribute on each of six datasets.

### 8.3 Cheatsheet functions and modes

First build and enter the lab's HDF5 environment exactly as shown on Sheet 11 page 6:

```bash
cd LabSession11/hdf5
docker build -t lab11-hdf5 .
docker run -it lab11-hdf5
```

The image supplies Python, `h5py`, NumPy, and the HDF5 command-line tools used below.

```python
h5py.File(filename, "w")
```

Creates/truncates a file for writing. **`w` overwrites an existing file.**

```python
h5py.File(filename, "r")   # read-only, must exist
h5py.File(filename, "r+")  # read/write, must exist
```

Core operations:

```python
f.create_group(name)
g.create_dataset(name, data=data)
f[path]
x.attrs[attr] = value
```

Use a context manager so data is flushed and the file closes even after an error:

```python
with h5py.File("measurements.h5", "r") as h5_file:
    ...
```

`f[path]` returns an HDF5 object/proxy. To read values use `dataset[:]`, `dataset[...]`, or `dataset[()]`. Printing the proxy alone does not print its array.

The cheatsheet heading says "Lab Session 9"; that is a copy typo. It is the supplied Module 11 HDF5 reference. [HC1]

### 8.4 Complete `store.py`

```python
import csv
from collections import defaultdict

import h5py
import numpy as np


rows_by_dataset = defaultdict(list)

with open("measurements.csv", newline="", encoding="utf-8") as csv_file:
    for row in csv.DictReader(csv_file):
        key = (row["flavor"], row["cola"])
        rows_by_dataset[key].append(
            [int(row["mentos"]), float(row["height_cm"])]
        )

with h5py.File("measurements.h5", "w") as h5_file:
    meas = h5_file.create_group("meas")
    flavor_groups = {}

    for (flavor, cola), rows in sorted(rows_by_dataset.items()):
        if flavor not in flavor_groups:
            flavor_groups[flavor] = meas.create_group(flavor)

        dataset = flavor_groups[flavor].create_dataset(
            cola,
            data=np.asarray(sorted(rows), dtype=np.float64),
        )
        dataset.attrs["columns"] = ["mentos", "height_cm"]
```

Run:

```bash
python3 store.py
```

Expected terminal output: none; it creates `measurements.h5`.

Why `float64`? A normal HDF5 n-dimensional array is homogeneous, so the integer count and floating height must share one datatype. Explicit conversion also makes the expected dump stable. The task permits another sensible numeric dtype; datatype depends on the actual implementation.

### 8.5 `h5ls -r`: layout

```bash
h5ls -r measurements.h5
```

Expected:

```text
/                        Group
/meas                    Group
/meas/fruit              Group
/meas/fruit/cola         Dataset {8, 2}
/meas/fruit/diet         Dataset {8, 2}
/meas/fruit/zero         Dataset {8, 2}
/meas/mint               Group
/meas/mint/cola          Dataset {8, 2}
/meas/mint/diet          Dataset {8, 2}
/meas/mint/zero          Dataset {8, 2}
```

It shows object paths, group/dataset type, and dataset extent. By default it does not show actual values, attributes, or detailed datatype declarations. [L7]

### 8.6 `h5dump -d`: selected dataset details and values

```bash
h5dump -d /meas/fruit/cola measurements.h5
```

Substantive expected result:

```text
DATASET "/meas/fruit/cola" {
   DATATYPE  H5T_IEEE_F64LE
   DATASPACE SIMPLE { ( 8, 2 ) / ( 8, 2 ) }
   DATA {
   (0,0): 1, 21,
   (1,0): 2, 31.8,
   (2,0): 3, 40.6,
   (3,0): 4, 48.2,
   (4,0): 5, 55.2,
   (5,0): 6, 61.5,
   (6,0): 7, 67.5,
   (7,0): 8, 73.1
   }
   ATTRIBUTE "columns" {
      ...
      DATA { (0): "mentos", "height_cm" }
   }
}
```

Answers:

- attribute: `mentos`, `height_cm`;
- shape: `(8, 2)`;
- rank: 2;
- elements: 16;
- with the supplied solution: little-endian IEEE 64-bit float (`H5T_IEEE_F64LE`).

Formatting and string-datatype detail can vary by HDF5/h5py version. Do not infer a universal datatype from the sheet alone; state what your creation code produced.

### 8.7 `h5dump -H`: all metadata, no values

```bash
h5dump -H measurements.h5
```

`-H` means header only. It recursively shows:

- group/dataset nesting;
- dataset datatypes;
- dataspaces/current and maximum dimensions;
- attribute names, datatypes, and shapes;
- no dataset or attribute **values**.

Compared with `h5ls -r`, it gives much richer type/metadata structure. Compared with a full `h5dump`, it avoids flooding the terminal with large arrays.

Mnemonic:

```text
h5ls -r      = layout
h5dump -d    = selected details + data
h5dump -H    = all headers/metadata, no values
```

### 8.8 Complete `read.py`

```python
import h5py


with h5py.File("measurements.h5", "r") as h5_file:
    dataset = h5_file["meas/mint/diet"]
    print(dataset.attrs["columns"])
    print(dataset[:])
```

Run it with:

```bash
python3 read.py
```

Expected:

```text
['mentos' 'height_cm']
[[  1.   35. ]
 [  2.   53.1]
 [  3.   67.7]
 [  4.   80.4]
 [  5.   91.9]
 [  6.  102.6]
 [  7.  112.5]
 [  8.  121.9]]
```

Depending on string encoding/version, the attribute may display byte strings such as `b'mentos'`; the semantic values are the same.

Only heights:

```python
print(dataset[:, 1])
```

This reads the second column as a slice rather than loading the complete file. HDF5 selections can map to hyperslabs on disk, which is why it suits data larger than RAM.

### 8.9 HDF5 versus JSON

| Property | HDF5 | JSON |
|---|---|---|
| Encoding | Typed binary | Text |
| Hierarchy | Groups/datasets | Objects/arrays |
| Shape and datatype | Native dataset metadata | Application convention |
| Arbitrary numeric slices | Direct dataset selections | No intrinsic file index |
| Large numerical size | Usually compact | Text digits, punctuation, and repeated keys add overhead |
| Human-readable/diffable | Poor | Good |
| Images | Native numerical datasets/image convention | No native image/binary type; indirect encoding needed |

Nuances:

- Tiny HDF5 files can be larger than tiny CSV/JSON because metadata overhead dominates. The sheet explicitly asks about **50 GB** of numbers.
- HDF5 is not automatically compressed; compression/chunking must be configured.
- Efficient arbitrary slicing at scale depends on a sensible chunk layout/access pattern.
- JSON can indirectly represent pixels as nested numbers or a Base64 string. That is not native image storage and is inefficient; see the MCQ caveat below.

### 8.10 Solved Lab 5(b) - answer 3

Given three datasets with `{120, 2}`:

| Statement | Truth | Reason |
|---|---|---|
| (i) Three datasets | **True** | `run1`, `run2`, `run3`. |
| (ii) Each has 240 scalar values | **True** | 120 x 2. |
| (iii) They are nested under `/experiment` | **True** | Paths show the hierarchy. |
| (iv) 120 values and two NaNs | **False** | `{120,2}` is shape, not missingness. |
| (v) Floats with two decimal places | **False** | Shape reveals neither type nor display precision. |

Choose **3**.

### 8.11 Solved Lab 5(c) - literal answer 4, with a wording caveat

| Statement | Truth | Reason |
|---|---|---|
| (i) JSON contains a random-access index | **False** | Plain JSON has no intrinsic index. |
| (ii) HDF5 can read a slice without the whole file | **True** | Dataset selection/hyperslab. |
| (iii) 50 GB numerical JSON is typically larger | **True** | Textual representation and syntax overhead. |
| (iv) HDF5 can store images/charts | **True** | Images can be numerical datasets. |
| (v) JSON can store images/charts | **True on the wording given** | JSON can represent pixels as nested numerical arrays or hold an encoded image in a string, even though it has no native binary/image datatype. |

Choose **4** on the question as printed.

Wording caveat: RFC 8259 gives JSON no native binary/image datatype, so a tutor who uses "store an image" to mean "store it as a native value" could mark (v) false and obtain **3**. The sheet does not say "natively," however, and provides no answer key; under ordinary usage, encoded image bytes or pixel arrays are still stored in JSON. Therefore **4 is the defensible literal answer**, while **3 is only the answer under that narrower classroom convention**.

### 8.12 HDF5 mistakes

1. Opening the file with `w` in `read.py` and erasing it.
2. Leaving CSV numbers as strings.
3. Reversing `[mentos, height_cm]`.
4. Creating `(2,8)` instead of `(8,2)`.
5. Using `/meas/<cola>/<flavor>` instead of `/meas/<flavor>/<cola>`.
6. Putting `columns` on the group instead of each dataset.
7. Storing column names as data rows rather than an attribute.
8. Printing `dataset` instead of `dataset[:]`.
9. Looking up `dataset["columns"]` instead of `dataset.attrs["columns"]`.
10. Reading `{120,2}` as missing values or decimal precision.
11. Assuming HDF5 automatically compresses.
12. Confusing an HDF5 path with a host filesystem directory.

---

## 9. Cross-topic connections likely to earn explanation marks

### FAIR and law are compatible, not opposites

FAIR A1.2 permits controlled access; legal rules may require it. A restricted dataset can still expose searchable metadata, a persistent ID, a standardized authenticated access procedure, a clear license/application rule, provenance, and domain standards.

```text
FAIR asks: can an authorized agent find, understand, and request/reuse it?
Law asks: who is authorized, under what basis, for what action?
```

### FAIR metadata should accompany remote results

The remote workflow already captures provenance. To improve FAIRness:

- assign a persistent release identifier;
- index the package/results;
- describe target hardware/software and inputs richly;
- use standard formats/protocols/vocabularies;
- state licenses for code, data, and instance rights;
- link raw results to source commit, artifact checksum, analysis, and paper with qualified relationships.

### HDF5 helps but does not guarantee FAIRness

HDF5 supplies typed shapes, hierarchy, and attached attributes, supporting interpretation and partial access. A file called `result.h5` on a laptop with no ID, index, license, provenance, community vocabulary, or access protocol is still not FAIR.

### Small image versus reproducible experiment

A tiny `scratch` image improves distribution and attack surface, but not every reproducibility dimension. Pin source/base digests, preserve compiler identity, checksum the binary, capture target hardware, return raw data, automate analysis, and license the artifacts.

### Legal permission is part of reproducibility

An executable workflow that nobody is allowed to access/use is not practically reproducible. Conversely, a permissive license cannot reconstruct missing dependencies or provenance. Technical and legal availability must align.

---

## 10. Common exam traps

1. **FAIR is not open data.** Open protocol can carry restricted data.
2. **Machine-readable is not machine-actionable.** Parsing is weaker than autonomous interpretation/use.
3. **FAIR includes more than data.** Algorithms, tools, and workflows are digital objects too.
4. **FAIR is not a technical standard.** It precedes implementation choices.
5. **DOI is not full FAIRness.** It mainly supports F1.
6. **License belongs under Reusable.** Not Accessible.
7. **Authentication is allowed.** A1.2 explicitly says so.
8. **Facts are not automatically owned.** Separate protections may still apply.
9. **GDPR is not copyright.** It protects people in processing contexts.
10. **Schema is not instance.** Original schema -> copyright; qualifying-investment instance -> sui generis.
11. **Copyright is not investment protection.** Originality versus qualifying cost.
12. **Create is not obtain.** BHB loses; Toll Collect wins in the course cases.
13. **One record is not automatically a substantial part.** Repeated systematic extraction can aggregate.
14. **Public website is not a license.** Open access does not equal legal permission.
15. **US maker and US conduct are two different territorial reasons.** Check both maker and act.
16. **Research is not a blanket exception.** Scope and redistribution are limited.
17. **Repository is not owner merely by storage.** But its contract/technical framework matters.
18. **Contract binds assenters.** It does not automatically bind an innocent outsider.
19. **Outsourcing does not transfer controller responsibility.** Supervision remains.
20. **Second `FROM` starts fresh.** Builder files do not leak unless copied.
21. **`scratch` has no dynamic loader or shell.** Use a static binary and exec-form entrypoint.
22. **Starter repo omission is not the intended answer.** Add `-static` as the sheet and MCQ require.
23. **Static is not cross-architecture.** CPU/kernel compatibility still matters.
24. **`tmux` is persistence across disconnect, not reboot and not determinism.**
25. **`ssh -p`; `scp -P`.** Case matters.
26. **Collect raw data and provenance before stopping `--rm` remote.**
27. **HDF5 dataset is not a group.** Dataset stores the typed array.
28. **Attribute is metadata, not a new array row.**
29. **Shape does not reveal NaNs/type/decimal places.** `{120,2}` only gives dimensions.
30. **`h5dump -H` hides values, not metadata.**
31. **Printing an h5py proxy does not load data.** Slice it.
32. **`w` truncates.** Never use it for readback.
33. **HDF5 is not automatically compressed or optimally chunked.**
34. **JSON has no native image type, but can store encoded image data.** Distinguish the literal ability to store pixels/Base64 from native binary/image datatype support.

---

## 11. Likely exam questions and model answers

### Can restricted personal data be FAIR?

Yes. Publish rich indexed metadata and a persistent identifier, use a standardized protocol that supports authentication, preserve metadata, state access/license rules and provenance, and use domain standards. FAIR does not require anonymous public download.

### Why prefer open general standards to bespoke parsers?

Bespoke parsers couple every format to every tool and do not scale to future types. Shared protocols, representation languages, vocabularies, and community standards let unknown agents discover and integrate objects with less custom work.

### Distinguish copyright and the sui generis database right

Copyright protects sufficiently original expression, code, selection, or structure. The sui generis right protects substantial investment in obtaining, checking, or presenting the database instance, independent of creativity. Different parties may hold them cumulatively.

### Why was BHB not protected while Toll Collect was?

BHB's decisive effort created race information. Toll Collect invested in equipment that obtained externally existing vehicle-use facts. The course's producer-right test counts obtaining but not merely creating the underlying data.

### Why can a public EU database still be risky to copy?

Public visibility does not waive the sui generis right or form a license. If the maker and act fall within EEA scope, copying all/substantial content can infringe unless a license or applicable exception authorizes it.

### Why are contracts alone insufficient?

They normally bind only people who assented. An outsider who receives the data without accepting the contract may instead be reachable only through copyright, trade-secret, GDPR-related rules, or the sui generis right.

### What does legal-by-design storage mean?

Agree rights, membership, access, logging, security, portability, licensing, retention, and exit rules early, then implement those exact rules as system permissions, views, audit logs, export, and deletion/retention behavior.

### Why does a `scratch` runtime require static linking?

`scratch` contains neither dynamic loader nor shared libraries. A static executable carries its required userspace library code and can invoke a compatible target kernel directly.

### Why split remote build, execution, and analysis?

The controlled builder freezes construction and analysis dependencies, while the real target supplies necessary hardware and may lack Docker. A self-contained package runs there; raw results and target provenance return for controlled plotting.

### What makes HDF5 self-describing?

It stores named hierarchy, dataset shape/type, and attached attributes with the values. The application still must choose meaningful paths, units, licenses, and provenance.

### Interpret `Dataset {120, 2}`

A rank-2 array with 120 rows and 2 columns, hence 240 scalar elements. It says nothing about datatype, NaNs, or decimal precision.

### Why is HDF5 better than JSON for 50 GB of numerical arrays?

HDF5 uses typed binary datasets and supports partial selections without parsing/loading the entire file. Plain JSON is textual, has representation overhead, and has no intrinsic random-access file index.

---

## 12. Final two-minute recall sheet

```text
FAIR
  F = PID, rich metadata, metadata->data ID, searchable index
  A = retrieve by ID, open protocol, auth allowed, metadata survives
  I = formal language, FAIR vocabulary, qualified links
  R = rich attributes, license, provenance, community standards
  accessible != public; FAIR != implementation standard
  machine-readable < machine-actionable

LAW: identify the layer
  person-linked content -> GDPR
  original expression   -> copyright
  protected valuable secret -> trade secret
  qualifying-investment DB instance -> sui generis
  accepted terms        -> contract/license

SUI GENERIS
  instance + substantial investment
  obtain / verify / present, not merely create
  all/substantial extraction OR systematic small extraction
  holder = investor; usually institution
  BHB no; Toll Collect yes
  maker eligibility + place of act

FIGURE 1
  provider: privacy, IP, secrecy
  researchers: software, structure, sui generis; individuals/support/institutions
  repository: terms, license, technical framework; institution contract
  third party: privileged/restricted use, license, attribution
  bottom: security, compliance, availability

MULTI-STAGE
  gcc:14 builder + -static
  scratch runtime + COPY --from=builder
  only /mentos; no shell/compiler/source/loader

REMOTE: B-P-S-R-C-A
  Build Package Ship Run Collect Analyze
  docker -p 2222:22
  ssh -p 2222; scp -P 2222
  tmux new -s mentos; Ctrl-b d; tmux a
  results + out/config back before stop

HDF5: F-G-D-A
  /meas/<flavor>/<cola>
  shape (8,2); row [mentos,height_cm]
  attrs columns = [mentos,height_cm]
  h5ls -r = layout
  h5dump -d = one dataset details/data
  h5dump -H = all metadata, no values

MCQ
  5(a) = 3: i ii iv
  5(b) = 3: i ii iii
  5(c) = 4: ii iii iv v (literal wording)
           3 only under an explicit native-image-type convention
```

---

## 13. Closed-book self-test

1. List all 15 FAIR subprinciples by category.
2. Why can a password-protected dataset still be Accessible under FAIR?
3. What is the difference between machine-readable and machine-actionable?
4. Does a DOI alone make an object FAIR?
5. Which category contains a usage license? Which contains a formal knowledge language?
6. Why are physical instruments not selected in Question 1, while workflows are?
7. Give the legal framework for personal data, an original figure, and a protected customer list.
8. Distinguish schema copyright from the database producer right.
9. Why is `firstName`/`lastName` unprotected but the 1,860-region schema protected?
10. State the sui generis investment test.
11. Explain BHB versus Toll Collect in one sentence each.
12. Can taking individual records ever violate the producer right?
13. Who holds the right when a university pays staff and infrastructure?
14. Why does an openly visible German database still need a license for French reuse?
15. Why does a US database maker without a license agreement get the opposite result?
16. Name the four stakeholder columns and the bottom cross-cutting concerns in Figure 1.
17. Why does storage at a repository not transfer ownership, yet still create risk?
18. What changes legally when a researcher changes affiliation?
19. Write the complete two-stage Dockerfile from memory.
20. Why does omitting `-static` cause a misleading missing-file error in `scratch`?
21. What do `ssh -p` and `scp -P` mean?
22. What does `tmux` survive, and what does it not promise?
23. Which provenance files are collected, and which matter most for performance?
24. Draw the exact HDF5 tree.
25. What is the difference among group, dataset, and attribute?
26. What does `{120,2}` prove and not prove?
27. Compare `h5ls -r`, `h5dump -d`, and `h5dump -H`.
28. Why must `read.py` use `r`, not `w`?
29. How do you read only the eruption-height column?
30. State and justify all three lab MCQ counts.

### Answers

1. F1 ID, F2 rich metadata, F3 metadata includes data ID, F4 searchable index; A1 retrieval protocol, A1.1 open/free/universal, A1.2 auth, A2 metadata survives; I1 formal shared language, I2 FAIR vocabularies, I3 qualified links; R1 accurate relevant attributes, R1.1 license, R1.2 provenance, R1.3 community standards.
2. A1.2 permits authentication/authorization; the retrieval procedure can be standardized without public access.
3. Readable syntax can be parsed; actionable semantics/permissions/context allow an agent to decide and act autonomously.
4. No. It mainly supports F1; the other principles remain.
5. Reusable R1.1; Interoperable I1.
6. FAIR applies to digital scholarly objects. Workflow is digital; physical equipment is not, though its metadata can be.
7. GDPR/data protection; copyright; trade-secret protection.
8. Schema copyright requires original selection/arrangement; producer right requires substantial investment in the instance.
9. The first is conventional/functional; the second embodies an original structural selection.
10. Substantial qualitative/quantitative investment in obtaining, verifying, or presenting database contents.
11. BHB spent on creating race information, so no; Toll Collect obtained existing sensor facts, so yes.
12. Yes, if repeated/systematic small extractions effectively reproduce or unreasonably exploit the database; one ordinary insignificant extraction usually does not.
13. The university/investing institution.
14. It is an eligible EEA maker, the French act is in the EEA, and public access is not a waiver/license.
15. A US maker generally lacks the EEA producer right and, without assent, lacks a contractual restriction on unprotected facts.
16. Data Providers, Researchers, Data Repositories, Interested Third Parties; security, compliance, availability.
17. Provider has no inherent data right merely from storage, but availability, mutation, security, processor duties, and restrictive terms depend on it.
18. Copyright, physical access, provider contracts, costs, NDAs, permissions, membership, and synchronization may split; plan transfer/exit rules.
19. `gcc:14 AS builder`, workdir/copy, `gcc -O2 -static ... -lm`, second `FROM scratch`, `COPY --from`, exec entrypoint.
20. The binary exists but its ELF dynamic loader/shared objects do not.
21. Lowercase `-p` selects SSH port; uppercase `-P` selects SCP port.
22. It survives SSH/network disconnect; it does not promise survival of reboot/container deletion or scientific determinism.
23. Hostname, OS release, CPU, kernel cmdline/modules/config/cgroups where available; OS/CPU/kernel/drivers/resources matter most, plus source/artifact/config identity.
24. `/meas/{fruit,mint}/{cola,diet,zero}`, each dataset `(8,2)` with a `columns` attribute.
25. Group organizes; dataset stores a typed array; attribute stores small attached metadata.
26. It proves rank 2, shape 120 by 2, and 240 elements; not type, precision, or missingness.
27. Recursive inventory; one selected dataset with details/values; all metadata/header with values suppressed.
28. `w` truncates; `r` safely reads the existing file.
29. `h5_file["meas/mint/diet"][:, 1]`.
30. 3 = i/ii/iv; 3 = i/ii/iii; 4 = ii/iii/iv/v on the literal wording. The last count becomes 3 only if "store" is explicitly restricted to native image/binary datatypes.

---

## 14. Source key and coverage audit

Page references count the first PDF page as page 1. The two legal articles' `LP`/`DB` references use their PDF page order; printed journal pages are also noted below.

- **IC** - [In-Class Exercise Sheet 11](./11_-_FAIRness_and_Legal_Aspects/SoSe_2026_RepEng_IC_11___Fair___Legal.pdf), all 5 pages.
- **L** - [Lab Exercise Sheet 11](./Lab_Session_11/Sheet_11.pdf), all 9 pages.
- **HC** - [HDF5 Cheatsheet](./Lab_Session_11/HDF5_cheatsheet.pdf), its single page.
- **FAIR** - Wilkinson et al., [*The FAIR Guiding Principles for scientific data management and stewardship*](https://doi.org/10.1038/sdata.2016.18), *Scientific Data* 3, 160018 (2016), identified by the local [Stud.IP pointer](./11_-_FAIRness_and_Legal_Aspects/Article_The_FAIR_Guiding_Principles_for_scientific_data_management_and_stewardship.url).
- **LP** - Beurskens and Scherzinger, [*Legal Perspectives on Research Data Storage*](https://doi.org/10.1007/s13222-024-00478-1), *Datenbank-Spektrum* 24, 85-95 (2024), identified by the local [Stud.IP pointer](./11_-_FAIRness_and_Legal_Aspects/Article_Legal_Perspectives_on_Research_Data_Storage.url).
- **DB** - Beurskens and Scherzinger, [*Datenbankherstellerrecht und Datenbankforschung*](https://doi.org/10.1007/s13222-023-00446-1), *Datenbank-Spektrum* 23, 143-152 (2023). It has no separate local pointer but is explicitly named as the basis for Questions 7 onward in IC page 1 and is linked by LP.
- **LABCODE** - Linked FIMGit `LabSession11` course repository at audited commit `10833f719f2de024914a6d959d0498f4af59beaf`. It supplies the exact C calculation, dispatcher behavior, Dockerfiles, plot script, and CSV dimensions. The repository requires course access; the PDF sheet remains the authoritative exam prompt.

Correction worth recognizing: IC page 1 reverses the publication years. **Legal Perspectives** is 2024; **Datenbankherstellerrecht** is 2023.

Coverage check:

| Supplied Module 11 item | Covered in sections |
|---|---|
| FAIR/Legal in-class PDF | 1-5, 9-14 |
| FAIR assigned-article pointer | 2, 9-14 |
| Legal Perspectives assigned-article pointer | 3-5, 9-14 |
| Lab Sheet 11 PDF | 1, 6-13 |
| HDF5 cheatsheet PDF | 8, 10-14 |
| Companion 2023 legal article named by the in-class sheet | 3-5, 9-14 |
| Linked LabSession11 code/data | 6-8, 14 |

The copies of `Sheet_11.pdf` and `HDF5_cheatsheet.pdf` under the consolidated exercises directory are byte-for-byte identical to the files under `Mod11`, so they add no separate content.
