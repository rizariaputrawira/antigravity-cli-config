---
name: security-research
description: >-
  Team Mode security research skill. Orchestrates 3 vulnerability hunters and 2 PoC engineers
  as parallel subagents to audit a codebase, prove exploitability, classify root causes, and
  calibrate severity by actual exploitability. Use for security review, vulnerability research,
  exploitability audit, pre-release security check, or threat model validation. Triggers:
  'security-research', 'security review', 'vulnerability audit', 'exploitability audit',
  'find vulnerabilities', 'security check', 'pentest', 'threat model'.
---

# Security Research — Parallel Vulnerability Audit

## Hard Preconditions

Before starting:
1. You need a concrete target: repository, diff range, PR, file list, or threat surface.
2. If the user provided no target, audit the current repository and current branch diff against upstream. If no diff, audit security-sensitive surfaces in the working tree.

## Severity Standard

Use these references:
- **CWE** for root-cause classification: https://cwe.mitre.org/
- **OWASP WSTG** for test methodology: https://owasp.org/www-project-web-security-testing-guide/
- **OWASP ASVS** for control verification: https://owasp.org/www-project-application-security-verification-standard/
- **CVSS v4.0** for scoring: https://www.first.org/cvss/v4.0/specification-document

Rules:
- **No severity without an attack path.**
- **No Critical/High without concrete exploit preconditions and impact.**
- Prefer a small reproducible PoC over theoretical language.
- Never run destructive exploits against real services. Use local fixtures, toy payloads, dry runs, or static proof.

## Team Roster (5 parallel subagents)

| Subagent | Role |
|---|---|
| `surface-hunter` | Map entry points, trust boundaries, and reachable attack surfaces |
| `auth-data-hunter` | Hunt auth, authorization, data isolation, injection, and secret handling flaws |
| `runtime-supply-hunter` | Hunt filesystem, subprocess, archive, dependency, hook, and config risks |
| `poc-engineer-a` | Build minimal PoCs for the strongest candidate findings |
| `poc-engineer-b` | Independently reproduce, falsify, or downgrade candidate findings |

## Execution

### Phase 1: Hunt (parallel)

Spawn `surface-hunter`, `auth-data-hunter`, and `runtime-supply-hunter` as parallel subagents with this instruction template:

```
You are [ROLE] in a parallel security audit.
Target: [TARGET]
Your job: [ROLE-SPECIFIC INSTRUCTION]

For every finding:
- State the exact attack path (input → processing → impact)
- Rate preliminary severity (Critical/High/Medium/Low) with justification
- Cite file:line for every claim
- Note what a PoC would need to prove

Do NOT run destructive commands. Use read tools, grep, static analysis.
Output: structured finding list.
```

Role-specific instructions:
- **surface-hunter**: Map all network endpoints, CLI entry points, file parsers, IPC interfaces, user-controlled inputs, and trust boundaries. List every surface that accepts external data.
- **auth-data-hunter**: Audit authentication logic, session handling, authorization checks, data isolation between users/tenants, injection vectors (SQL, command, template, path), secret storage and transmission.
- **runtime-supply-hunter**: Audit file system operations (path traversal, symlink attacks), subprocess calls (injection, privilege escalation), archive extraction (zip-slip), dependency loading (confused deputy, typosquatting), hook and plugin execution surfaces.

### Phase 2: PoC (parallel, after Phase 1)

Collect all findings from Phase 1. Spawn `poc-engineer-a` and `poc-engineer-b` in parallel:

**poc-engineer-a**: Build minimal static or local PoCs for the 3 highest-severity candidate findings. Prove or disprove exploitability. Output: PoC code/steps and updated severity verdict.

**poc-engineer-b**: Independently attempt to reproduce or falsify the same candidate findings using a different approach. If you can falsify a finding, explain why. Output: reproduction result and severity calibration.

### Phase 3: Synthesis

Merge all findings. Apply these filters:
- Findings falsified by both PoC engineers → mark as "Not Exploitable"
- Findings confirmed by at least one PoC → retain with confirmed severity
- Findings neither confirmed nor falsified → retain as "Needs Further Testing"

## Output Format

Write a `SECURITY_AUDIT.md` in the repo root:

```markdown
# Security Audit Report
**Target**: ...
**Date**: ...
**Auditors**: surface-hunter, auth-data-hunter, runtime-supply-hunter, poc-engineer-a, poc-engineer-b

## Executive Summary
[3-5 sentences: critical count, high count, top risk, key recommendation]

## Findings

### [SEV-001] [Title] — Critical/High/Medium/Low
- **CWE**: CWE-XXX: Name
- **Attack Path**: input → processing → impact
- **File:Line**: `src/foo.ts:42`
- **Exploit Preconditions**: ...
- **PoC**: [code or steps]
- **CVSS v4.0**: X.X
- **Recommendation**: ...

## Not Exploitable (Falsified)
[findings that were ruled out and why]

## Needs Further Testing
[unconfirmed findings]
```

## Remediation Handoff

Once `SECURITY_AUDIT.md` is generated, transition confirmed vulnerabilities immediately into the Planning Triad:
- **Point Vulnerabilities (1–2 files, input validation, header additions, secret isolation)**: Launch [`/ar-flashplan`](../ar-flashplan/SKILL.md) &rarr; `.ar-wf/planning/<SEQ>-YYYYMMDD-<kebab-case>.md`.
- **Component Hardening (2–6 files, auth middleware, permission model fixes)**: Launch [`/ar-superplan`](../ar-superplan/SKILL.md) (Builder vs Red Team).
- **Critical Architectural Flaws (Subsystem trust redesign, crypto migration)**: Launch [`/ar-hyperplan`](../ar-hyperplan/SKILL.md) (5-agent hostile gauntlet).
- **Verification Proof**: Execute via [`/ar-hyperexecution`](../ar-hyperexecution/SKILL.md) under [`ar-ultrawork`](../ar-ultrawork/SKILL.md) discipline. Every remediation task MUST execute the original PoC to prove the exploit is neutralized, capturing output into `.ar-wf/hyper-execution/evidence/<plan-id>/task-<N>/report.txt`.
