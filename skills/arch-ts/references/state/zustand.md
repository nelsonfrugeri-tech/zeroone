# Zustand 5+ - State Management

Zustand e a biblioteca recomendada para client state global em aplicacoes React.

---

## Store Creation

### Basic Store

```typescript
import { create } from "zustand";

interface CounterStore {
	count: number;
	increment: () => void;
	decrement: () => void;
	reset: () => void;
}

const useCounterStore = create<CounterStore>((set) => ({
	count: 0,
	increment: () => set((state) => ({ count: state.count + 1 })),
	decrement: () => set((state) => ({ count: state.count - 1 })),
	reset: () => set({ count: 0 }),
}));

// Usage in component
function Counter() {
	const count = useCounterStore((s) => s.count);
	const increment = useCounterStore((s) => s.increment);

	return (
		<div>
			<p>{count}</p>
			<button onClick={increment}>+</button>
		</div>
	);
}
```

### Complex Store

```typescript
interface CartItem {
	id: string;
	name: string;
	price: number;
	quantity: number;
}

interface CartStore {
	items: CartItem[];
	addItem: (item: Omit<CartItem, "quantity">) => void;
	removeItem: (id: string) => void;
	updateQuantity: (id: string, quantity: number) => void;
	clearCart: () => void;
	totalItems: () => number;
	totalPrice: () => number;
}

const useCartStore = create<CartStore>((set, get) => ({
	items: [],

	addItem: (item) =>
		set((state) => {
			const existing = state.items.find((i) => i.id === item.id);
			if (existing) {
				return {
					items: state.items.map((i) =>
						i.id === item.id
							? { ...i, quantity: i.quantity + 1 }
							: i,
					),
				};
			}
			return { items: [...state.items, { ...item, quantity: 1 }] };
		}),

	removeItem: (id) =>
		set((state) => ({
			items: state.items.filter((i) => i.id !== id),
		})),

	updateQuantity: (id, quantity) =>
		set((state) => ({
			items:
				quantity <= 0
					? state.items.filter((i) => i.id !== id)
					: state.items.map((i) =>
							i.id === id ? { ...i, quantity } : i,
						),
		})),

	clearCart: () => set({ items: [] }),

	totalItems: () => get().items.reduce((sum, i) => sum + i.quantity, 0),

	totalPrice: () =>
		get().items.reduce((sum, i) => sum + i.price * i.quantity, 0),
}));
```

---

## Selectors

Selectors prevent unnecessary re-renders — component only re-renders when selected value changes:

```typescript
// GOOD — fine-grained selector
function CartBadge() {
	const totalItems = useCartStore((s) => s.totalItems());
	return <span>{totalItems}</span>;
}

// BAD — subscribes to entire store
function CartBadge() {
	const store = useCartStore(); // Re-renders on ANY state change
	return <span>{store.totalItems()}</span>;
}

// Multiple values — use shallow comparison
import { useShallow } from "zustand/react/shallow";

function CartSummary() {
	const { totalItems, totalPrice } = useCartStore(
		useShallow((s) => ({
			totalItems: s.totalItems(),
			totalPrice: s.totalPrice(),
		})),
	);

	return (
		<div>
			{totalItems} items — ${totalPrice}
		</div>
	);
}
```

---

## Middleware

### persist — save to localStorage

```typescript
import { create } from "zustand";
import { persist } from "zustand/middleware";

const useSettingsStore = create<SettingsStore>()(
	persist(
		(set) => ({
			theme: "light" as "light" | "dark",
			language: "en",
			setTheme: (theme) => set({ theme }),
			setLanguage: (language) => set({ language }),
		}),
		{
			name: "app-settings", // localStorage key
			partialize: (state) => ({
				theme: state.theme,
				language: state.language,
			}), // Only persist these fields
		},
	),
);
```

### devtools — Redux DevTools integration

```typescript
import { devtools } from "zustand/middleware";

const useStore = create<MyStore>()(
	devtools(
		(set) => ({
			// ...store definition
		}),
		{ name: "MyStore" }, // Shows in Redux DevTools
	),
);
```

### immer — immutable updates with mutable syntax

```typescript
import { immer } from "zustand/middleware/immer";

interface TodoStore {
	todos: Array<{ id: string; text: string; done: boolean }>;
	addTodo: (text: string) => void;
	toggleTodo: (id: string) => void;
}

const useTodoStore = create<TodoStore>()(
	immer((set) => ({
		todos: [],
		addTodo: (text) =>
			set((state) => {
				state.todos.push({
					id: crypto.randomUUID(),
					text,
					done: false,
				});
			}),
		toggleTodo: (id) =>
			set((state) => {
				const todo = state.todos.find((t) => t.id === id);
				if (todo) todo.done = !todo.done;
			}),
	})),
);
```

### Combining middleware

```typescript
const useStore = create<MyStore>()(
	devtools(
		persist(
			immer((set) => ({
				// store definition
			})),
			{ name: "my-store" },
		),
		{ name: "MyStore" },
	),
);
```

---

## Async Actions

```typescript
interface UserStore {
	user: User | null;
	isLoading: boolean;
	error: string | null;
	fetchUser: (id: string) => Promise<void>;
	updateUser: (data: Partial<User>) => Promise<void>;
}

const useUserStore = create<UserStore>((set, get) => ({
	user: null,
	isLoading: false,
	error: null,

	fetchUser: async (id) => {
		set({ isLoading: true, error: null });
		try {
			const response = await fetch(`/api/users/${id}`);
			if (!response.ok) throw new Error("Failed to fetch user");
			const user = await response.json();
			set({ user, isLoading: false });
		} catch (err) {
			set({
				error: err instanceof Error ? err.message : "Unknown error",
				isLoading: false,
			});
		}
	},

	updateUser: async (data) => {
		const currentUser = get().user;
		if (!currentUser) return;

		// Optimistic update
		set({ user: { ...currentUser, ...data } });

		try {
			await fetch(`/api/users/${currentUser.id}`, {
				method: "PATCH",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify(data),
			});
		} catch {
			// Rollback on failure
			set({ user: currentUser });
		}
	},
}));
```

---

## Store Slicing

Split large stores into slices:

```typescript
interface AuthSlice {
	user: User | null;
	login: (credentials: Credentials) => Promise<void>;
	logout: () => void;
}

interface UISlice {
	sidebarOpen: boolean;
	toggleSidebar: () => void;
}

type AppStore = AuthSlice & UISlice;

const createAuthSlice = (
	set: (partial: Partial<AppStore>) => void,
): AuthSlice => ({
	user: null,
	login: async (credentials) => {
		const user = await authApi.login(credentials);
		set({ user });
	},
	logout: () => set({ user: null }),
});

const createUISlice = (
	set: (partial: Partial<AppStore>) => void,
): UISlice => ({
	sidebarOpen: true,
	toggleSidebar: () =>
		set((state: AppStore) => ({ sidebarOpen: !state.sidebarOpen })),
});

const useAppStore = create<AppStore>()((...args) => ({
	...createAuthSlice(...args),
	...createUISlice(...args),
}));
```

---

## Testing Stores

```typescript
import { describe, it, expect, beforeEach } from "vitest";
import { useCartStore } from "./cart-store";

describe("CartStore", () => {
	beforeEach(() => {
		// Reset store between tests
		useCartStore.setState({ items: [] });
	});

	it("adds item to cart", () => {
		const { addItem } = useCartStore.getState();
		addItem({ id: "1", name: "Widget", price: 10 });

		const { items } = useCartStore.getState();
		expect(items).toHaveLength(1);
		expect(items[0]).toMatchObject({
			id: "1",
			name: "Widget",
			quantity: 1,
		});
	});

	it("increments quantity for existing item", () => {
		const { addItem } = useCartStore.getState();
		addItem({ id: "1", name: "Widget", price: 10 });
		addItem({ id: "1", name: "Widget", price: 10 });

		const { items } = useCartStore.getState();
		expect(items).toHaveLength(1);
		expect(items[0]!.quantity).toBe(2);
	});

	it("calculates total price", () => {
		const { addItem, totalPrice } = useCartStore.getState();
		addItem({ id: "1", name: "A", price: 10 });
		addItem({ id: "2", name: "B", price: 20 });

		expect(totalPrice()).toBe(30);
	});
});
```

---

## Links

- [Zustand Documentation](https://zustand.docs.pmnd.rs/)
- [Zustand — TypeScript Guide](https://zustand.docs.pmnd.rs/guides/typescript)
- [Zustand — Middleware](https://zustand.docs.pmnd.rs/middlewares/persist)
