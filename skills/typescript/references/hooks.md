# React Hooks - Custom Hooks & Patterns

Patterns para hooks customizados em React 19+.

---

## Rules of Hooks

1. Only call hooks at the top level (not inside loops, conditions, or nested functions)
2. Only call hooks from React components or custom hooks
3. Custom hooks must start with `use`

---

## Custom Hook Patterns

### Data Fetching Hook

```typescript
import { useState, useEffect } from "react";

interface UseFetchResult<T> {
	data: T | null;
	error: Error | null;
	isLoading: boolean;
}

function useFetch<T>(url: string): UseFetchResult<T> {
	const [data, setData] = useState<T | null>(null);
	const [error, setError] = useState<Error | null>(null);
	const [isLoading, setIsLoading] = useState(true);

	useEffect(() => {
		const controller = new AbortController();

		async function fetchData() {
			setIsLoading(true);
			setError(null);
			try {
				const response = await fetch(url, {
					signal: controller.signal,
				});
				if (!response.ok) throw new Error(`HTTP ${response.status}`);
				const json = (await response.json()) as T;
				setData(json);
			} catch (err) {
				if (err instanceof DOMException && err.name === "AbortError") {
					return; // Ignore abort errors
				}
				setError(err instanceof Error ? err : new Error(String(err)));
			} finally {
				setIsLoading(false);
			}
		}

		fetchData();
		return () => controller.abort();
	}, [url]);

	return { data, error, isLoading };
}
```

### localStorage Hook

```typescript
function useLocalStorage<T>(
	key: string,
	initialValue: T,
): [T, (value: T | ((prev: T) => T)) => void] {
	const [stored, setStored] = useState<T>(() => {
		try {
			const item = window.localStorage.getItem(key);
			return item ? (JSON.parse(item) as T) : initialValue;
		} catch {
			return initialValue;
		}
	});

	const setValue = useCallback(
		(value: T | ((prev: T) => T)) => {
			setStored((prev) => {
				const next = value instanceof Function ? value(prev) : value;
				window.localStorage.setItem(key, JSON.stringify(next));
				return next;
			});
		},
		[key],
	);

	return [stored, setValue];
}

// Usage
const [theme, setTheme] = useLocalStorage<"light" | "dark">("theme", "light");
```

### Media Query Hook

```typescript
function useMediaQuery(query: string): boolean {
	const [matches, setMatches] = useState(() => {
		if (typeof window === "undefined") return false;
		return window.matchMedia(query).matches;
	});

	useEffect(() => {
		const mql = window.matchMedia(query);
		const handler = (e: MediaQueryListEvent) => setMatches(e.matches);

		mql.addEventListener("change", handler);
		setMatches(mql.matches); // Sync initial value

		return () => mql.removeEventListener("change", handler);
	}, [query]);

	return matches;
}

// Usage
function Layout() {
	const isMobile = useMediaQuery("(max-width: 768px)");
	const prefersDark = useMediaQuery("(prefers-color-scheme: dark)");

	return isMobile ? <MobileLayout /> : <DesktopLayout />;
}
```

### Debounce Hook

```typescript
function useDebounce<T>(value: T, delay: number): T {
	const [debounced, setDebounced] = useState(value);

	useEffect(() => {
		const timer = setTimeout(() => setDebounced(value), delay);
		return () => clearTimeout(timer);
	}, [value, delay]);

	return debounced;
}

// Usage
function SearchInput() {
	const [query, setQuery] = useState("");
	const debouncedQuery = useDebounce(query, 300);

	// Only fires API call when user stops typing
	const { data } = useQuery({
		queryKey: ["search", debouncedQuery],
		queryFn: () => searchAPI(debouncedQuery),
		enabled: debouncedQuery.length > 0,
	});

	return <input value={query} onChange={(e) => setQuery(e.target.value)} />;
}
```

### Click Outside Hook

```typescript
function useClickOutside<T extends HTMLElement>(
	handler: () => void,
): RefObject<T | null> {
	const ref = useRef<T | null>(null);

	useEffect(() => {
		function handleClick(event: MouseEvent) {
			if (ref.current && !ref.current.contains(event.target as Node)) {
				handler();
			}
		}

		document.addEventListener("mousedown", handleClick);
		return () => document.removeEventListener("mousedown", handleClick);
	}, [handler]);

	return ref;
}

// Usage
function Dropdown() {
	const [isOpen, setIsOpen] = useState(false);
	const ref = useClickOutside<HTMLDivElement>(() => setIsOpen(false));

	return (
		<div ref={ref}>
			<button onClick={() => setIsOpen((v) => !v)}>Menu</button>
			{isOpen && <DropdownMenu />}
		</div>
	);
}
```

---

## useEffect Cleanup

Always clean up subscriptions, timers, and listeners:

```typescript
function useWebSocket(url: string) {
	const [messages, setMessages] = useState<string[]>([]);

	useEffect(() => {
		const ws = new WebSocket(url);

		ws.onmessage = (event) => {
			setMessages((prev) => [...prev, event.data]);
		};

		ws.onerror = (error) => {
			console.error("WebSocket error:", error);
		};

		// CLEANUP — close connection on unmount or URL change
		return () => {
			ws.close();
		};
	}, [url]);

	return messages;
}
```

---

## useRef Patterns

```typescript
// Mutable value that doesn't trigger re-render
function useInterval(callback: () => void, delay: number | null) {
	const savedCallback = useRef(callback);

	// Update ref on every render (no stale closure)
	useEffect(() => {
		savedCallback.current = callback;
	}, [callback]);

	useEffect(() => {
		if (delay === null) return;

		const id = setInterval(() => savedCallback.current(), delay);
		return () => clearInterval(id);
	}, [delay]);
}

// Previous value
function usePrevious<T>(value: T): T | undefined {
	const ref = useRef<T | undefined>(undefined);

	useEffect(() => {
		ref.current = value;
	}, [value]);

	return ref.current;
}
```

---

## useReducer for Complex State

```typescript
interface FormState {
	values: Record<string, string>;
	errors: Record<string, string>;
	isSubmitting: boolean;
	submitCount: number;
}

type FormAction =
	| { type: "SET_FIELD"; field: string; value: string }
	| { type: "SET_ERROR"; field: string; error: string }
	| { type: "CLEAR_ERRORS" }
	| { type: "SUBMIT_START" }
	| { type: "SUBMIT_SUCCESS" }
	| { type: "SUBMIT_FAILURE"; errors: Record<string, string> };

function formReducer(state: FormState, action: FormAction): FormState {
	switch (action.type) {
		case "SET_FIELD":
			return {
				...state,
				values: { ...state.values, [action.field]: action.value },
				errors: { ...state.errors, [action.field]: "" },
			};
		case "SET_ERROR":
			return {
				...state,
				errors: { ...state.errors, [action.field]: action.error },
			};
		case "CLEAR_ERRORS":
			return { ...state, errors: {} };
		case "SUBMIT_START":
			return {
				...state,
				isSubmitting: true,
				submitCount: state.submitCount + 1,
			};
		case "SUBMIT_SUCCESS":
			return { ...state, isSubmitting: false, errors: {} };
		case "SUBMIT_FAILURE":
			return {
				...state,
				isSubmitting: false,
				errors: action.errors,
			};
		default:
			return state;
	}
}

function useForm(initialValues: Record<string, string>) {
	const [state, dispatch] = useReducer(formReducer, {
		values: initialValues,
		errors: {},
		isSubmitting: false,
		submitCount: 0,
	});

	const setField = useCallback((field: string, value: string) => {
		dispatch({ type: "SET_FIELD", field, value });
	}, []);

	return { ...state, setField, dispatch };
}
```

---

## Hook Composition

Compose small hooks into larger ones:

```typescript
function useSearch<T>(
	searchFn: (query: string) => Promise<T[]>,
	debounceMs = 300,
) {
	const [query, setQuery] = useState("");
	const debouncedQuery = useDebounce(query, debounceMs);
	const [results, setResults] = useState<T[]>([]);
	const [isLoading, setIsLoading] = useState(false);

	useEffect(() => {
		if (!debouncedQuery) {
			setResults([]);
			return;
		}

		let cancelled = false;
		setIsLoading(true);

		searchFn(debouncedQuery)
			.then((data) => {
				if (!cancelled) setResults(data);
			})
			.finally(() => {
				if (!cancelled) setIsLoading(false);
			});

		return () => {
			cancelled = true;
		};
	}, [debouncedQuery, searchFn]);

	return { query, setQuery, results, isLoading };
}
```

---

## Testing Hooks

```typescript
import { renderHook, act } from "@testing-library/react";
import { useDebounce } from "./useDebounce";

describe("useDebounce", () => {
	beforeEach(() => {
		vi.useFakeTimers();
	});

	afterEach(() => {
		vi.useRealTimers();
	});

	it("returns initial value immediately", () => {
		const { result } = renderHook(() => useDebounce("hello", 300));
		expect(result.current).toBe("hello");
	});

	it("debounces value changes", () => {
		const { result, rerender } = renderHook(
			({ value, delay }) => useDebounce(value, delay),
			{ initialProps: { value: "hello", delay: 300 } },
		);

		rerender({ value: "world", delay: 300 });
		expect(result.current).toBe("hello"); // Not yet

		act(() => vi.advanceTimersByTime(300));
		expect(result.current).toBe("world"); // Now updated
	});
});
```

---

## Links

- [React — Custom Hooks](https://react.dev/learn/reusing-logic-with-custom-hooks)
- [React — useEffect](https://react.dev/reference/react/useEffect)
- [React — useReducer](https://react.dev/reference/react/useReducer)
- [React — Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks)
