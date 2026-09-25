---
description: How we write unit tests for the web app
applyTo: "web/src/**/*.test.{ts,tsx}"
---

# Web unit tests

- Find elements by role or label. Never by CSS class or test id.
- Test one behaviour per test. The test name says the behaviour: "shows an error when the email is invalid".
- Build test data with the factories in `web/test/factories/`. Do not write object literals by hand.
- Assert on what the user sees, not on component state.

Good:

```tsx
await user.click(screen.getByRole("button", { name: "Save" }));
expect(screen.getByRole("alert")).toHaveTextContent("Email is invalid");
```

Bad:

```tsx
wrapper.find(".btn-primary").simulate("click");
expect(wrapper.state("error")).toBe(true);
```
