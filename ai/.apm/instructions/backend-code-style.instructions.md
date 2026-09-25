---
description: Code style for backend services
applyTo: "backend/src/**"
---

# Backend code style

- Name things after the domain, not the pattern: `InvoiceExporter`, not `InvoiceHelper` or `InvoiceManager`.
- One public class per file. Keep functions under 30 lines.
- No comments that explain what code does. Rename or extract until the code says it. Put the why in a test name.
- Return errors as values at module boundaries. Throw only for bugs.
- Every change to behaviour comes with a test that fails without the change.
