# State Management Architecture

Decision tree para escolher a ferramenta certa para cada tipo de estado.

---

## State Categories

| Category | Description | Tool | Examples |
|----------|-------------|------|----------|
| **Server state** | Data from APIs/DB | TanStack Query | Users, posts, products |
| **Client state** | App-wide UI state | Zustand | Theme, sidebar, notifications |
| **Local state** | Component-specific | useState | Form inputs, toggles, modals |
| **Form state** | Complex form logic | React Hook Form | Multi-step forms, validation |
| **URL state** | Navigation/filters | URL params | Search, pagination, filters |

---

## Decision Tree

```
Is the data from an API/database?
├── YES → TanStack Query
│   (caching, background refetch, loading/error states)
│
└── NO → Is it shared across many components?
    ├── YES → Zustand
    │   (global UI state, user preferences, shopping cart)
    │
    └── NO → Is it complex form logic?
        ├── YES → React Hook Form
        │   (validation, multi-step, dynamic fields)
        │
        └── NO → Is it in the URL?
            ├── YES → URL search params
            │   (filters, pagination, search query)
            │
            └── NO → useState / useReducer
                (local toggle, modal open, input value)
```

---

## Server State (TanStack Query)

**Use for:** Any data that comes from an external source (API, database).

```typescript
// GOOD — server data managed by TanStack Query
function UsersList() {
	const { data: users, isLoading } = useQuery({
		queryKey: ["users"],
		queryFn: fetchUsers,
	});

	if (isLoading) return <Skeleton />;
	return <List items={users} />;
}
```

**Features you get for free:**
- Automatic background refetching
- Cache with configurable stale time
- Loading and error states
- Optimistic updates
- Infinite scroll/pagination
- Prefetching
- Window focus refetching
- Offline support

---

## Client State (Zustand)

**Use for:** Global UI state that doesn't come from a server.

```typescript
// GOOD — UI state in Zustand
const useUIStore = create<UIStore>((set) => ({
	sidebarOpen: true,
	theme: "light" as "light" | "dark",
	notifications: [] as Notification[],
	toggleSidebar: () =>
		set((s) => ({ sidebarOpen: !s.sidebarOpen })),
	setTheme: (theme) => set({ theme }),
	addNotification: (n) =>
		set((s) => ({ notifications: [...s.notifications, n] })),
}));
```

---

## Local State (useState)

**Use for:** State that belongs to a single component and its children.

```typescript
// GOOD — local state
function Modal() {
	const [isOpen, setIsOpen] = useState(false);

	return (
		<>
			<button onClick={() => setIsOpen(true)}>Open</button>
			{isOpen && <Dialog onClose={() => setIsOpen(false)} />}
		</>
	);
}

// GOOD — derived local state
function FilteredList({ items }: { items: Item[] }) {
	const [search, setSearch] = useState("");

	const filtered = items.filter((item) =>
		item.name.toLowerCase().includes(search.toLowerCase()),
	);

	return (
		<div>
			<input value={search} onChange={(e) => setSearch(e.target.value)} />
			<List items={filtered} />
		</div>
	);
}
```

---

## Form State (React Hook Form)

**Use for:** Complex forms with validation, dynamic fields, multi-step.

```typescript
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const schema = z.object({
	name: z.string().min(1, "Required"),
	email: z.string().email("Invalid email"),
	role: z.enum(["admin", "user"]),
});

type FormValues = z.infer<typeof schema>;

function CreateUserForm() {
	const {
		register,
		handleSubmit,
		formState: { errors, isSubmitting },
	} = useForm<FormValues>({
		resolver: zodResolver(schema),
		defaultValues: { role: "user" },
	});

	const onSubmit = async (data: FormValues) => {
		await createUser(data);
	};

	return (
		<form onSubmit={handleSubmit(onSubmit)}>
			<input {...register("name")} />
			{errors.name && <span>{errors.name.message}</span>}

			<input {...register("email")} type="email" />
			{errors.email && <span>{errors.email.message}</span>}

			<select {...register("role")}>
				<option value="user">User</option>
				<option value="admin">Admin</option>
			</select>

			<button type="submit" disabled={isSubmitting}>
				Create
			</button>
		</form>
	);
}
```

---

## URL State

**Use for:** Filters, search queries, pagination — anything that should be shareable via URL.

```typescript
// Next.js App Router
import { useSearchParams, useRouter, usePathname } from "next/navigation";

function ProductFilters() {
	const searchParams = useSearchParams();
	const router = useRouter();
	const pathname = usePathname();

	const category = searchParams.get("category") ?? "all";
	const sort = searchParams.get("sort") ?? "name";

	function updateParams(updates: Record<string, string>) {
		const params = new URLSearchParams(searchParams.toString());
		for (const [key, value] of Object.entries(updates)) {
			params.set(key, value);
		}
		router.push(`${pathname}?${params.toString()}`);
	}

	return (
		<div>
			<select
				value={category}
				onChange={(e) => updateParams({ category: e.target.value })}
			>
				<option value="all">All</option>
				<option value="electronics">Electronics</option>
			</select>
		</div>
	);
}
```

---

## Anti-Patterns

### 1. Server State in Zustand

```typescript
// BAD — managing server data in Zustand
const useUserStore = create((set) => ({
	users: [],
	isLoading: false,
	fetchUsers: async () => {
		set({ isLoading: true });
		const users = await fetch("/api/users").then((r) => r.json());
		set({ users, isLoading: false });
	},
}));

// GOOD — use TanStack Query for server data
function useUsers() {
	return useQuery({
		queryKey: ["users"],
		queryFn: () => fetch("/api/users").then((r) => r.json()),
	});
}
```

### 2. Global State for Local Concerns

```typescript
// BAD — modal state in global store
const useUIStore = create((set) => ({
	isDeleteModalOpen: false,
	isEditModalOpen: false,
	isConfirmModalOpen: false,
	// 20 more modal states...
}));

// GOOD — local state for local concerns
function UserRow({ user }: { user: User }) {
	const [showDeleteModal, setShowDeleteModal] = useState(false);
	return (
		<>
			<button onClick={() => setShowDeleteModal(true)}>Delete</button>
			{showDeleteModal && <DeleteModal user={user} />}
		</>
	);
}
```

### 3. Prop Drilling vs Context vs Zustand

```typescript
// If prop drilling is 2-3 levels — just pass props
// If prop drilling is 4+ levels — consider Zustand or Context
// If data changes frequently — Zustand (Context re-renders all consumers)
// If data rarely changes — Context is fine (theme, locale, auth)
```

### 4. Derived State Stored Separately

```typescript
// BAD — storing derived state
const useStore = create((set) => ({
	items: [],
	filteredItems: [], // This is derived!
	filterText: "",
	setFilter: (text) =>
		set((s) => ({
			filterText: text,
			filteredItems: s.items.filter((i) => i.name.includes(text)),
		})),
}));

// GOOD — compute derived state
const useStore = create((set) => ({
	items: [],
	filterText: "",
	setFilter: (text) => set({ filterText: text }),
}));

// In component
function FilteredList() {
	const items = useStore((s) => s.items);
	const filterText = useStore((s) => s.filterText);
	const filtered = useMemo(
		() => items.filter((i) => i.name.includes(filterText)),
		[items, filterText],
	);
}
```

---

## Summary Table

| Question | Answer |
|----------|--------|
| Data from API? | TanStack Query |
| Global UI state? | Zustand |
| Local toggle/input? | useState |
| Complex form? | React Hook Form + Zod |
| Shareable via URL? | URL search params |
| Rarely changing context? | React Context |

---

## Links

- [TanStack Query vs Zustand](https://tkdodo.eu/blog/react-query-and-zustand)
- [Zustand Documentation](https://zustand.docs.pmnd.rs/)
- [React Hook Form](https://react-hook-form.com/)
