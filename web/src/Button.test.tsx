import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { Button } from "./Button";

test("calls onClick when the user clicks the button", async () => {
  const onClick = vi.fn();
  render(<Button onClick={onClick}>Save</Button>);

  await userEvent.click(screen.getByRole("button", { name: "Save" }));

  expect(onClick).toHaveBeenCalledOnce();
});
