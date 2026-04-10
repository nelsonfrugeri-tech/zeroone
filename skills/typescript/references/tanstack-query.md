# TanStack Query v5 - Server State Management

TanStack Query (React Query) e a biblioteca recomendada para gerenciar server state.

---

## Setup

```typescript
// providers.tsx
"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";
import { useState, type ReactNode } from "react";

export function Providers({ children }: { children: ReactNode }) {
	const [queryClient] = useState(
		() =>
			new QueryClient({
				defaultOptions: {
					queries: {
						staleTime: 60 * 1000, // 1 minute
						gcTime: 5 * 60 * 1000, // 5 minutes (formerly cacheTime)
						retry: 1,
						refetchOnWindowFocus: false,
					},
				},
			}),
	);

	return (
		<QueryClientProvider client={queryClient}>
			{children}
			<ReactQueryDevtools initialIsOpen={false} />
		</QueryClientProvider>
	);
}
```

---

## useQuery

```typescript
import { useQuery } from "@tanstack/react-query";

interface User {
	id: string;
	name: string;
	email: string;
}

// API function — separate from hook
async function fetchUser(userId: string): Promise<User> {
	const response = await fetch(`/api/users/${userId}`);
	if (!response.ok) throw new Error(`HTTP ${response.status}`);
	return response.json();
}

// Hook
function useUser(userId: string) {
	return useQuery({
		queryKey: ["users", userId],
		queryFn: () => fetchUser(userId),
		enabled: !!userId, // Don't fetch if no ID
	});
}

// Component
function UserProfile({ userId }: { userId: string }) {
	const { data: user, isLoading, error } = useUser(userId);

	if (isLoading) return <Skeleton />;
	if (error) return <ErrorMessage error={error} />;
	if (!user) return null;

	return (
		<div>
			<h1>{user.name}</h1>
			<p>{user.email}</p>
		</div>
	);
}
```

### Query Key Conventions

```typescript
// Hierarchical keys for cache management
const queryKeys = {
	users: {
		all: ["users"] as const,
		lists: () => [...queryKeys.users.all, "list"] as const,
		list: (filters: UserFilters) =>
			[...queryKeys.users.lists(), filters] as const,
		details: () => [...queryKeys.users.all, "detail"] as const,
		detail: (id: string) =>
			[...queryKeys.users.details(), id] as const,
	},
	posts: {
		all: ["posts"] as const,
		byUser: (userId: string) =>
			[...queryKeys.posts.all, "user", userId] as const,
	},
};

// Usage
useQuery({ queryKey: queryKeys.users.detail(userId), queryFn: ... });
queryClient.invalidateQueries({ queryKey: queryKeys.users.all }); // Invalidates all user queries
```

---

## useMutation

```typescript
import { useMutation, useQueryClient } from "@tanstack/react-query";

async function updateUser(
	userId: string,
	data: Partial<User>,
): Promise<User> {
	const response = await fetch(`/api/users/${userId}`, {
		method: "PATCH",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify(data),
	});
	if (!response.ok) throw new Error("Update failed");
	return response.json();
}

function useUpdateUser(userId: string) {
	const queryClient = useQueryClient();

	return useMutation({
		mutationFn: (data: Partial<User>) => updateUser(userId, data),
		onSuccess: (updatedUser) => {
			// Update cache directly
			queryClient.setQueryData(
				queryKeys.users.detail(userId),
				updatedUser,
			);
			// Invalidate list queries
			queryClient.invalidateQueries({
				queryKey: queryKeys.users.lists(),
			});
		},
		onError: (error) => {
			console.error("Update failed:", error);
		},
	});
}

// Component
function EditUserForm({ userId }: { userId: string }) {
	const { data: user } = useUser(userId);
	const updateUser = useUpdateUser(userId);

	const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
		e.preventDefault();
		const formData = new FormData(e.currentTarget);
		updateUser.mutate({
			name: formData.get("name") as string,
		});
	};

	return (
		<form onSubmit={handleSubmit}>
			<input name="name" defaultValue={user?.name} />
			<button type="submit" disabled={updateUser.isPending}>
				{updateUser.isPending ? "Saving..." : "Save"}
			</button>
			{updateUser.isError && <p>Error: {updateUser.error.message}</p>}
		</form>
	);
}
```

---

## Optimistic Updates

```typescript
function useDeleteTodo() {
	const queryClient = useQueryClient();

	return useMutation({
		mutationFn: (todoId: string) => deleteTodoAPI(todoId),
		onMutate: async (todoId) => {
			// Cancel outgoing refetches
			await queryClient.cancelQueries({ queryKey: ["todos"] });

			// Snapshot previous value
			const previousTodos = queryClient.getQueryData<Todo[]>(["todos"]);

			// Optimistically remove
			queryClient.setQueryData<Todo[]>(["todos"], (old) =>
				old?.filter((t) => t.id !== todoId),
			);

			return { previousTodos };
		},
		onError: (_err, _todoId, context) => {
			// Rollback on error
			if (context?.previousTodos) {
				queryClient.setQueryData(["todos"], context.previousTodos);
			}
		},
		onSettled: () => {
			// Always refetch after mutation
			queryClient.invalidateQueries({ queryKey: ["todos"] });
		},
	});
}
```

---

## Infinite Queries

```typescript
interface PaginatedResponse<T> {
	data: T[];
	nextCursor: string | null;
}

function useInfiniteUsers() {
	return useInfiniteQuery({
		queryKey: ["users", "infinite"],
		queryFn: async ({
			pageParam,
		}): Promise<PaginatedResponse<User>> => {
			const params = new URLSearchParams();
			if (pageParam) params.set("cursor", pageParam);
			const response = await fetch(`/api/users?${params}`);
			return response.json();
		},
		initialPageParam: null as string | null,
		getNextPageParam: (lastPage) => lastPage.nextCursor,
	});
}

function UserList() {
	const {
		data,
		fetchNextPage,
		hasNextPage,
		isFetchingNextPage,
	} = useInfiniteUsers();

	const allUsers = data?.pages.flatMap((page) => page.data) ?? [];

	return (
		<div>
			{allUsers.map((user) => (
				<UserCard key={user.id} user={user} />
			))}
			{hasNextPage && (
				<button
					onClick={() => fetchNextPage()}
					disabled={isFetchingNextPage}
				>
					{isFetchingNextPage ? "Loading..." : "Load More"}
				</button>
			)}
		</div>
	);
}
```

---

## Prefetching

```typescript
// Prefetch on hover
function UserLink({ userId }: { userId: string }) {
	const queryClient = useQueryClient();

	const handleMouseEnter = () => {
		queryClient.prefetchQuery({
			queryKey: queryKeys.users.detail(userId),
			queryFn: () => fetchUser(userId),
			staleTime: 5 * 60 * 1000, // Consider fresh for 5 minutes
		});
	};

	return (
		<Link
			href={`/users/${userId}`}
			onMouseEnter={handleMouseEnter}
		>
			View User
		</Link>
	);
}

// Prefetch in Server Component (Next.js)
import { dehydrate, HydrationBoundary, QueryClient } from "@tanstack/react-query";

async function UsersPage() {
	const queryClient = new QueryClient();

	await queryClient.prefetchQuery({
		queryKey: queryKeys.users.lists(),
		queryFn: fetchUsers,
	});

	return (
		<HydrationBoundary state={dehydrate(queryClient)}>
			<UsersList />
		</HydrationBoundary>
	);
}
```

---

## Error & Loading States

```typescript
// Centralized error handling
const queryClient = new QueryClient({
	defaultOptions: {
		queries: {
			retry: (failureCount, error) => {
				// Don't retry on 4xx errors
				if (error instanceof ApiError && error.status < 500) {
					return false;
				}
				return failureCount < 3;
			},
		},
		mutations: {
			onError: (error) => {
				toast.error(error.message);
			},
		},
	},
});

// Query error boundary
import { QueryErrorResetBoundary } from "@tanstack/react-query";
import { ErrorBoundary } from "react-error-boundary";

function App() {
	return (
		<QueryErrorResetBoundary>
			{({ reset }) => (
				<ErrorBoundary
					onReset={reset}
					fallbackRender={({ resetErrorBoundary }) => (
						<div>
							<p>Something went wrong</p>
							<button onClick={resetErrorBoundary}>Retry</button>
						</div>
					)}
				>
					<Content />
				</ErrorBoundary>
			)}
		</QueryErrorResetBoundary>
	);
}
```

---

## Testing

```typescript
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { render, screen, waitFor } from "@testing-library/react";

function createTestQueryClient() {
	return new QueryClient({
		defaultOptions: {
			queries: { retry: false, gcTime: 0 },
		},
	});
}

function renderWithQuery(ui: React.ReactElement) {
	const client = createTestQueryClient();
	return render(
		<QueryClientProvider client={client}>{ui}</QueryClientProvider>,
	);
}

describe("UserProfile", () => {
	it("renders user data", async () => {
		vi.spyOn(global, "fetch").mockResolvedValueOnce(
			new Response(
				JSON.stringify({ id: "1", name: "Alice", email: "a@b.com" }),
			),
		);

		renderWithQuery(<UserProfile userId="1" />);

		await waitFor(() => {
			expect(screen.getByText("Alice")).toBeInTheDocument();
		});
	});
});
```

---

## Links

- [TanStack Query Documentation](https://tanstack.com/query/latest)
- [TanStack Query — TypeScript](https://tanstack.com/query/latest/docs/framework/react/typescript)
- [TanStack Query — SSR](https://tanstack.com/query/latest/docs/framework/react/guides/ssr)
