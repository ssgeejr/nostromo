# Grok Integration Checklist

Proceed through these gates one at a time. Change `[ ] Completed` to `[x] Completed` only after the corresponding step has been implemented and verified.

## 1. Define Grok's role

[x] Completed

- Qwen remains the primary model.
- Grok is an explicit research/second-opinion capability.
- No automatic cloud fallback.

## 2. Verify account access

[ ] Completed

- Confirm whether the SuperGrok subscription supports Hermes' xAI OAuth connection.
- If OAuth is insufficient, determine whether an xAI API account or key is required.

## 3. Authenticate Hermes

[ ] Completed

- Connect Hermes to xAI using OAuth where possible.
- Store credentials only in Hermes' protected configuration, never in Git.

## 4. Add an explicit `ask_grok` capability

[ ] Completed

- Qwen can deliberately invoke Grok when local knowledge and documentation are insufficient.
- Grok does not become the default model.

## 5. Define information boundaries

[ ] Completed

- Grok may receive the technical question and public context.
- Credentials, PHI, ticket contents, internal records, and unnecessary system information remain local.

## 6. Add approval rules

[ ] Completed

- Initially, every Grok request requires approval.
- Later, approved low-risk research categories may run automatically.

## 7. Test with synthetic questions

[ ] Completed

- Verify Qwen can recognize when Grok is useful.
- Verify exactly what leaves NOSTROMO.
- Confirm Grok's response returns to Qwen correctly.

## 8. Create the learning path

[ ] Completed

- Validate useful Grok answers.
- Convert repeatable answers into local Hermes skills, documentation, or runbooks.
- Future requests then use the local capability instead of Grok.

## 9. Restrict and document network access

[ ] Completed

- Permit only the required xAI endpoints through the PA-220.
- Log the access and document the final architecture.
