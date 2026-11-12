---
name: hipaa-assessment-findings
description: Read, verify, summarize, or review HIPAA assessment findings in Fortified or similar GRC systems. Use when reporting assessment tasks, linked HIPAA controls, findings, recommendations, evidence, risk scoring, remediation state, or record discrepancies. Do not use this skill as authorization to edit records or change workflow state.
---

# HIPAA Assessment Findings

Report what the assessment record supports. Keep task workflow, control assessment, evidence, and analyst judgment distinct.

## Default posture

- Work read-only unless the user explicitly requests a specific modification.
- Do not claim browser access until the intended tab is attached or otherwise controllable and the browser tool reports a live target.
- Treat the live GRC record as the primary source. Treat downloaded reports, exports, and attachments as separate named sources.
- Inspect only as far as needed to answer the request. Do not click controls that assign, edit, change status, mark review state, add content, or download files unless requested.

## Evidence layers

Read the record in layers. Attribute every reported fact to the layer that contains it.

1. **Task record**
   - Task ID and title
   - Organization, tenant, project, or related service
   - Priority, workflow status, completion percentage, assignment, and schedule
   - Boolean state such as `Stalled`
   - Creator, created time, description, checklist, call notes, attachments, and timeline
2. **Linked control**
   - Exact HIPAA citation and control statement
   - Security category, function, and informative mappings
   - Assessment status, remediation label, last-modified information, and related-task count
3. **Scoring**
   - Likelihood, impact, overall risk, severity, and maturity values
4. **Findings and recommendations**
   - Finding text, recommendation text, entry dates, and explicitly named references
   - Distinguish the current assessment entry from historical or carried-forward entries
5. **Supporting material**
   - Documents, related survey or walkthrough data, attachments, exports, and downloaded artifacts
6. **Analyst interpretation**
   - Gaps, proposed owners, target dates, validation steps, and other conclusions not explicitly recorded above

Absence in one layer is not absence everywhere. For example, a task can have no description while its linked control contains detailed findings.

## Verification workflow

1. Identify the exact task by ID and title. Confirm the organization or project when shown.
2. Read the task fields before opening linked records.
3. Verify interactive state rather than inferring it from labels. For a checkbox such as `Stalled`, inspect whether it is actually checked.
4. Open the linked control read-only and inspect Details, Scoring, Findings and Recommendations, Documents, and Related Data when relevant.
5. Record the exact source of each important claim, including dates and reference names.
6. Compare the task state with the linked control state and scoring. Report mismatches without silently reconciling them.
7. If a separate file or export is used, name it and state which claims came from it rather than from the live task.
8. Finish with a compact verification note describing the views checked and confirming whether any changes were made.

## Accuracy rules

- Task priority is not automatically the linked control's overall risk rating.
- A task status such as `To Do` is not the control's assessment or remediation status.
- The visible word `Stalled` does not mean the task is stalled; verify the checkbox value.
- `Risk Remediated`, `Assessed`, an open task, and a Critical risk score can coexist. Report each state and flag the apparent inconsistency.
- Say `unassigned`, `no due date`, or `no attachment` only when the corresponding field or table value supports it.
- Do not turn a recorded recommendation into a completed action.
- Do not present an analyst recommendation as a Fortified finding. Introduce it as `Analyst observation`, `Suggested next step`, or equivalent.
- Do not claim that a control, organization, or workflow is compliant, approved, closed, or remediated beyond the exact recorded evidence.
- Preserve the meaning of findings when summarizing. Keep material qualifiers, affected locations, observed failures, and scope.
- Count and name supporting references from the displayed record. Do not invent document contents from titles alone.
- When evidence conflicts, state the conflicting fields and the source of each.

## Reporting format

Use the smallest format that preserves source attribution and material discrepancies. For a full finding review, prefer:

### Task metadata

State the task ID, title, organization/project, priority, workflow status, completion, assignment, schedule, creator, and relevant empty fields.

### Linked control and scoring

Give the exact HIPAA citation, category, assessment/remediation state, likelihood, impact, and overall risk when available.

### Assessment finding

Summarize the observed condition, existing controls, control failures, affected locations or systems, and resulting risk. Attribute this to the assessment finding rather than to the task description.

### Recorded recommendations

Summarize only recommendations present in the record. Preserve distinct recommendations as separate items when combining them would lose meaning.

### Evidence and references

List the named references and describe related data, documents, or attachments only to the level actually inspected.

### Gaps and discrepancies

Identify missing ownership, dates, descriptions, evidence, or conflicting workflow/remediation states.

### Analyst observations

Place proposed next steps here. Make clear that they are analysis, not recorded findings.

## Final quality check

Before reporting, confirm:

- Every material claim is supported by an inspected source.
- Boolean fields were verified by state, not label text.
- Task, control, scoring, and remediation states are not conflated.
- Missing information is described as missing, not guessed.
- Recorded recommendations and analyst suggestions are clearly separated.
- Contradictions are surfaced rather than resolved without evidence.
- No record was modified unless the user explicitly requested that modification.
