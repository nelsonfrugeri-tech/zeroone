# React Component Patterns - React 19+

Patterns modernos para construir componentes reutilizaveis, composiveis e type-safe.

---

## Composition Over Inheritance

React favorece composicao sobre heranca. Nunca use heranca de componentes.

```typescript
// BAD — inheritance
class SpecialButton extends Button { ... }

// GOOD — composition
function DangerButton(props: Omit<ButtonProps, "variant">) {
	return <Button variant="danger" {...props} />;
}

// GOOD — composition with children
function Card({ children, title }: { children: ReactNode; title: string }) {
	return (
		<div className="rounded-lg border p-4">
			<h3 className="font-bold">{title}</h3>
			<div className="mt-2">{children}</div>
		</div>
	);
}

function UserCard({ user }: { user: User }) {
	return (
		<Card title={user.name}>
			<p>{user.email}</p>
			<p>{user.role}</p>
		</Card>
	);
}
```

---

## Compound Components

Components that work together sharing implicit state:

```typescript
import { createContext, use, type ReactNode } from "react";

// Context for shared state
interface AccordionContextValue {
	openItems: Set<string>;
	toggle: (id: string) => void;
}

const AccordionContext = createContext<AccordionContextValue | null>(null);

function useAccordion(): AccordionContextValue {
	const ctx = use(AccordionContext);
	if (!ctx) throw new Error("useAccordion must be used within Accordion");
	return ctx;
}

// Root component
interface AccordionProps {
	children: ReactNode;
	multiple?: boolean;
}

function Accordion({ children, multiple = false }: AccordionProps) {
	const [openItems, setOpenItems] = useState<Set<string>>(new Set());

	const toggle = useCallback(
		(id: string) => {
			setOpenItems((prev) => {
				const next = new Set(multiple ? prev : []);
				if (prev.has(id)) next.delete(id);
				else next.add(id);
				return next;
			});
		},
		[multiple],
	);

	return (
		<AccordionContext value={{ openItems, toggle }}>
			<div role="region">{children}</div>
		</AccordionContext>
	);
}

// Sub-component: Item
interface AccordionItemProps {
	id: string;
	title: string;
	children: ReactNode;
}

function AccordionItem({ id, title, children }: AccordionItemProps) {
	const { openItems, toggle } = useAccordion();
	const isOpen = openItems.has(id);

	return (
		<div>
			<button
				type="button"
				onClick={() => toggle(id)}
				aria-expanded={isOpen}
				aria-controls={`panel-${id}`}
			>
				{title}
			</button>
			{isOpen && (
				<div id={`panel-${id}`} role="region">
					{children}
				</div>
			)}
		</div>
	);
}

// Attach sub-component
Accordion.Item = AccordionItem;

// Usage
function App() {
	return (
		<Accordion multiple>
			<Accordion.Item id="1" title="Section 1">
				<p>Content 1</p>
			</Accordion.Item>
			<Accordion.Item id="2" title="Section 2">
				<p>Content 2</p>
			</Accordion.Item>
		</Accordion>
	);
}
```

---

## Polymorphic Components

Components that can render as different HTML elements:

```typescript
import { type ComponentPropsWithoutRef, type ElementType } from "react";

type PolymorphicProps<E extends ElementType, P = object> = P &
	Omit<ComponentPropsWithoutRef<E>, keyof P> & {
		as?: E;
	};

// Polymorphic Text component
type TextProps<E extends ElementType = "span"> = PolymorphicProps<
	E,
	{
		size?: "sm" | "md" | "lg";
		weight?: "normal" | "bold";
	}
>;

function Text<E extends ElementType = "span">({
	as,
	size = "md",
	weight = "normal",
	className,
	...props
}: TextProps<E>) {
	const Component = as ?? "span";

	const sizeClass = {
		sm: "text-sm",
		md: "text-base",
		lg: "text-lg",
	}[size];

	const weightClass = weight === "bold" ? "font-bold" : "font-normal";

	return (
		<Component
			className={`${sizeClass} ${weightClass} ${className ?? ""}`}
			{...props}
		/>
	);
}

// Usage — renders as different elements with full type safety
<Text>Default span</Text>
<Text as="p" size="lg">Paragraph</Text>
<Text as="h1" weight="bold">Heading</Text>
<Text as="a" href="/about">Link text</Text>
// href is only available when as="a"
```

---

## forwardRef (React 19)

In React 19, `ref` is a regular prop — no more `forwardRef` wrapper needed:

```typescript
// React 19 — ref as prop
interface InputProps {
	label: string;
	error?: string;
	ref?: React.Ref<HTMLInputElement>;
}

function Input({ label, error, ref, ...props }: InputProps) {
	const id = useId();
	return (
		<div>
			<label htmlFor={id}>{label}</label>
			<input
				id={id}
				ref={ref}
				aria-invalid={!!error}
				aria-describedby={error ? `${id}-error` : undefined}
				{...props}
			/>
			{error && (
				<p id={`${id}-error`} role="alert">
					{error}
				</p>
			)}
		</div>
	);
}

// Usage
function Form() {
	const inputRef = useRef<HTMLInputElement>(null);

	return <Input ref={inputRef} label="Email" />;
}
```

---

## React.memo Best Practices

`React.memo` prevents re-renders when props haven't changed:

```typescript
// GOOD — stable identity for complex renders
const ExpensiveList = memo(function ExpensiveList({
	items,
}: {
	items: Item[];
}) {
	return (
		<ul>
			{items.map((item) => (
				<li key={item.id}>{renderExpensiveItem(item)}</li>
			))}
		</ul>
	);
});

// BAD — memo on trivial components (overhead > savings)
const Label = memo(({ text }: { text: string }) => <span>{text}</span>);

// GOOD — memo with custom comparison
const Chart = memo(
	function Chart({ data, config }: ChartProps) {
		// expensive render
		return <canvas />;
	},
	(prev, next) => {
		// Only re-render if data length changes or config changes
		return (
			prev.data.length === next.data.length &&
			prev.config === next.config
		);
	},
);
```

**When to use memo:**
- Component re-renders often with same props
- Component has expensive render logic
- Component is deep in tree and parent re-renders frequently

**When NOT to use memo:**
- Simple/cheap components
- Props change on every render (object/array literals, inline callbacks)
- Component rarely re-renders

---

## Children Typing Patterns

```typescript
import type { ReactNode, ReactElement } from "react";

// Most common — accepts anything renderable
interface CardProps {
	children: ReactNode;
}

// Only single element child
interface TooltipProps {
	children: ReactElement;
}

// Render prop pattern
interface DataLoaderProps<T> {
	query: () => Promise<T>;
	children: (data: T) => ReactNode;
}

function DataLoader<T>({ query, children }: DataLoaderProps<T>) {
	const { data } = useQuery({ queryKey: ["data"], queryFn: query });
	if (!data) return <Skeleton />;
	return <>{children(data)}</>;
}

// Usage
<DataLoader query={fetchUsers}>
	{(users) => (
		<ul>
			{users.map((u) => (
				<li key={u.id}>{u.name}</li>
			))}
		</ul>
	)}
</DataLoader>

// Function children with explicit props
interface SlotProps {
	children: (props: { isOpen: boolean; toggle: () => void }) => ReactNode;
}
```

---

## Render Props (Still Useful)

Render props are less common with hooks but still useful for headless components:

```typescript
interface UseToggleReturn {
	isOpen: boolean;
	open: () => void;
	close: () => void;
	toggle: () => void;
}

// Hook version (preferred)
function useToggle(initial = false): UseToggleReturn {
	const [isOpen, setIsOpen] = useState(initial);
	return {
		isOpen,
		open: () => setIsOpen(true),
		close: () => setIsOpen(false),
		toggle: () => setIsOpen((v) => !v),
	};
}

// Render prop version (useful for libraries/headless UI)
interface ToggleProps {
	initial?: boolean;
	children: (state: UseToggleReturn) => ReactNode;
}

function Toggle({ initial = false, children }: ToggleProps) {
	const state = useToggle(initial);
	return <>{children(state)}</>;
}

// Usage
<Toggle>
	{({ isOpen, toggle }) => (
		<>
			<button onClick={toggle}>{isOpen ? "Close" : "Open"}</button>
			{isOpen && <Panel />}
		</>
	)}
</Toggle>
```

---

## Links

- [React — Thinking in React](https://react.dev/learn/thinking-in-react)
- [React — Composing Components](https://react.dev/learn/passing-props-to-a-component)
- [Patterns.dev — Compound Pattern](https://www.patterns.dev/react/compound-pattern/)
- [React — useId](https://react.dev/reference/react/useId)
