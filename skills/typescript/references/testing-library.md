# Testing Library - React Testing

Testing Library para testes de componentes React focados no usuario.

---

## Philosophy

**Test as users interact, not implementation details.**

- Query by role, label, text — not by class name or test ID
- Interact like a user — click, type, select
- Assert what users see — not component state or internal methods

---

## Queries Priority

From most preferred to least preferred:

| Priority | Query | Use when |
|----------|-------|----------|
| 1 | `getByRole` | Any accessible element (buttons, links, headings, inputs) |
| 2 | `getByLabelText` | Form fields |
| 3 | `getByPlaceholderText` | Input without visible label |
| 4 | `getByText` | Non-interactive elements with text |
| 5 | `getByDisplayValue` | Input with current value |
| 6 | `getByAltText` | Images |
| 7 | `getByTitle` | Title attribute |
| 8 | `getByTestId` | Last resort — no semantic query works |

```typescript
// BEST
screen.getByRole("button", { name: "Submit" });
screen.getByRole("textbox", { name: "Email" });
screen.getByRole("heading", { level: 2, name: "Settings" });
screen.getByRole("link", { name: "Home" });
screen.getByRole("checkbox", { name: "Remember me" });

// GOOD
screen.getByLabelText("Email address");
screen.getByText("No results found");

// OK
screen.getByPlaceholderText("Search...");

// LAST RESORT
screen.getByTestId("complex-data-grid");
```

---

## Render and Screen

```typescript
import { render, screen } from "@testing-library/react";

it("renders component", () => {
	render(<UserCard name="Alice" email="alice@test.com" />);

	// screen is the global query API
	expect(screen.getByRole("heading")).toHaveTextContent("Alice");
	expect(screen.getByText("alice@test.com")).toBeInTheDocument();
});
```

---

## user-event vs fireEvent

**Always prefer `userEvent` — it simulates real user behavior:**

```typescript
import userEvent from "@testing-library/user-event";

it("types in input", async () => {
	const user = userEvent.setup();
	render(<SearchInput />);

	const input = screen.getByRole("textbox", { name: "Search" });

	// userEvent — fires focus, keydown, input, keyup events (like real typing)
	await user.type(input, "hello");

	// fireEvent — fires only the specified event (incomplete simulation)
	// fireEvent.change(input, { target: { value: "hello" } }); // AVOID

	expect(input).toHaveValue("hello");
});

it("clicks button", async () => {
	const user = userEvent.setup();
	const onClick = vi.fn();
	render(<Button onClick={onClick}>Click me</Button>);

	await user.click(screen.getByRole("button", { name: "Click me" }));
	expect(onClick).toHaveBeenCalledOnce();
});

it("selects option", async () => {
	const user = userEvent.setup();
	render(
		<select aria-label="Country">
			<option value="us">United States</option>
			<option value="br">Brazil</option>
		</select>,
	);

	await user.selectOptions(screen.getByRole("combobox", { name: "Country" }), "br");
	expect(screen.getByRole("combobox")).toHaveValue("br");
});

it("clears and types", async () => {
	const user = userEvent.setup();
	render(<input aria-label="Name" defaultValue="old value" />);

	const input = screen.getByRole("textbox", { name: "Name" });
	await user.clear(input);
	await user.type(input, "new value");

	expect(input).toHaveValue("new value");
});
```

---

## Testing Async Components

### waitFor

```typescript
it("loads data and renders", async () => {
	render(<UserProfile userId="1" />);

	// Initially shows loading
	expect(screen.getByText("Loading...")).toBeInTheDocument();

	// Wait for data to load
	await waitFor(() => {
		expect(screen.getByRole("heading")).toHaveTextContent("Alice");
	});

	// Loading gone
	expect(screen.queryByText("Loading...")).not.toBeInTheDocument();
});
```

### findBy (waitFor + getBy)

```typescript
it("shows user after fetch", async () => {
	render(<UserProfile userId="1" />);

	// findBy automatically waits (shorthand for waitFor + getBy)
	const heading = await screen.findByRole("heading", { name: "Alice" });
	expect(heading).toBeInTheDocument();
});
```

### queryBy (assert absence)

```typescript
it("does not show admin badge for regular user", () => {
	render(<UserBadge role="user" />);

	// queryBy returns null if not found (doesn't throw)
	expect(screen.queryByText("Admin")).not.toBeInTheDocument();
});
```

---

## Testing with Providers

```typescript
// test/utils.tsx
import { render, type RenderOptions } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";

function createTestQueryClient() {
	return new QueryClient({
		defaultOptions: {
			queries: { retry: false, gcTime: 0 },
		},
	});
}

interface WrapperProps {
	children: ReactNode;
}

function AllProviders({ children }: WrapperProps) {
	const queryClient = createTestQueryClient();
	return (
		<QueryClientProvider client={queryClient}>
			{children}
		</QueryClientProvider>
	);
}

function renderWithProviders(
	ui: React.ReactElement,
	options?: Omit<RenderOptions, "wrapper">,
) {
	return render(ui, { wrapper: AllProviders, ...options });
}

export { renderWithProviders as render, screen, waitFor } from "@testing-library/react";
```

---

## Accessibility Testing

```typescript
import { axe, toHaveNoViolations } from "jest-axe";

expect.extend(toHaveNoViolations);

it("has no accessibility violations", async () => {
	const { container } = render(<LoginForm />);
	const results = await axe(container);
	expect(results).toHaveNoViolations();
});
```

---

## Common Patterns

### Testing forms

```typescript
it("submits form with validation", async () => {
	const user = userEvent.setup();
	const onSubmit = vi.fn();
	render(<ContactForm onSubmit={onSubmit} />);

	// Submit empty form — should show errors
	await user.click(screen.getByRole("button", { name: "Send" }));
	expect(screen.getByText("Name is required")).toBeInTheDocument();
	expect(onSubmit).not.toHaveBeenCalled();

	// Fill form
	await user.type(screen.getByLabelText("Name"), "Alice");
	await user.type(screen.getByLabelText("Email"), "alice@test.com");
	await user.type(screen.getByLabelText("Message"), "Hello!");

	// Submit — should succeed
	await user.click(screen.getByRole("button", { name: "Send" }));
	expect(onSubmit).toHaveBeenCalledWith({
		name: "Alice",
		email: "alice@test.com",
		message: "Hello!",
	});
});
```

### Testing modals

```typescript
it("opens and closes modal", async () => {
	const user = userEvent.setup();
	render(<App />);

	// Modal not visible
	expect(screen.queryByRole("dialog")).not.toBeInTheDocument();

	// Open modal
	await user.click(screen.getByRole("button", { name: "Delete" }));

	// Modal visible
	const dialog = screen.getByRole("dialog");
	expect(dialog).toBeInTheDocument();
	expect(within(dialog).getByText("Are you sure?")).toBeInTheDocument();

	// Close modal
	await user.click(within(dialog).getByRole("button", { name: "Cancel" }));
	expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
});
```

### within() — scope queries

```typescript
it("renders items in correct sections", () => {
	render(<Dashboard />);

	const sidebar = screen.getByRole("navigation");
	const main = screen.getByRole("main");

	expect(within(sidebar).getByText("Home")).toBeInTheDocument();
	expect(within(main).getByRole("heading")).toHaveTextContent("Dashboard");
});
```

---

## Links

- [Testing Library Documentation](https://testing-library.com/)
- [Testing Library — Queries](https://testing-library.com/docs/queries/about)
- [Testing Library — user-event](https://testing-library.com/docs/user-event/intro)
- [Common mistakes with React Testing Library](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
