# Loading States — Skeletons, Optimistic UI & Streaming

## Skeleton Screens

Skeleton screens show the layout structure while content loads. They reduce
perceived loading time and prevent layout shift.

### Basic Skeleton with Tailwind

```tsx
function CardSkeleton() {
  return (
    <div className="animate-pulse rounded-xl border border-border bg-surface p-6">
      {/* Image placeholder */}
      <div className="mb-4 h-48 rounded-lg bg-muted" />

      {/* Title placeholder */}
      <div className="mb-3 h-5 w-3/4 rounded bg-muted" />

      {/* Description placeholders */}
      <div className="space-y-2">
        <div className="h-4 w-full rounded bg-muted" />
        <div className="h-4 w-5/6 rounded bg-muted" />
        <div className="h-4 w-2/3 rounded bg-muted" />
      </div>

      {/* Action placeholder */}
      <div className="mt-4 h-10 w-32 rounded-lg bg-muted" />
    </div>
  );
}
```

### Shimmer Effect (Premium Feel)

```css
@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}
```

```tsx
function Shimmer({ className }: { className?: string }) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded bg-muted",
        className
      )}
    >
      <div
        className="absolute inset-0 -translate-x-full animate-[shimmer_1.5s_infinite]
          bg-gradient-to-r from-transparent via-white/20 to-transparent"
      />
    </div>
  );
}

// Usage
function ProfileSkeleton() {
  return (
    <div className="flex items-center gap-4">
      <Shimmer className="size-12 rounded-full" />
      <div className="space-y-2">
        <Shimmer className="h-4 w-32" />
        <Shimmer className="h-3 w-24" />
      </div>
    </div>
  );
}
```

### Dark Mode Shimmer

```tsx
function Shimmer({ className }: { className?: string }) {
  return (
    <div className={cn("relative overflow-hidden rounded bg-muted", className)}>
      <div
        className="absolute inset-0 -translate-x-full animate-[shimmer_1.5s_infinite]
          bg-gradient-to-r from-transparent
          via-white/10 dark:via-white/5
          to-transparent"
      />
    </div>
  );
}
```

### Table Skeleton

```tsx
function TableSkeleton({ rows = 5, cols = 4 }: { rows?: number; cols?: number }) {
  return (
    <div className="rounded-xl border border-border">
      {/* Header */}
      <div className="flex gap-4 border-b border-border bg-muted/50 p-4">
        {Array.from({ length: cols }).map((_, i) => (
          <Shimmer key={i} className="h-4 flex-1" />
        ))}
      </div>

      {/* Rows */}
      {Array.from({ length: rows }).map((_, row) => (
        <div key={row} className="flex gap-4 border-b border-border p-4 last:border-0">
          {Array.from({ length: cols }).map((_, col) => (
            <Shimmer
              key={col}
              className={cn("h-4 flex-1", col === 0 && "w-1/4 flex-none")}
            />
          ))}
        </div>
      ))}
    </div>
  );
}
```

---

## Spinners — When to Use

Spinners are appropriate ONLY for:
- Short, indeterminate waits (< 3 seconds)
- Inline loading within buttons
- Small areas where skeleton doesn't make sense

```tsx
function Spinner({ size = "md" }: { size?: "sm" | "md" | "lg" }) {
  const sizes = { sm: "size-4", md: "size-6", lg: "size-8" };

  return (
    <svg
      className={cn("animate-spin text-primary", sizes[size])}
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden="true"
    >
      <circle
        className="opacity-25"
        cx="12" cy="12" r="10"
        stroke="currentColor"
        strokeWidth="4"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
      />
    </svg>
  );
}

// Button with loading state
function LoadingButton({ loading, children, ...props }: LoadingButtonProps) {
  return (
    <button disabled={loading} {...props} className="relative">
      <span className={cn(loading && "invisible")}>{children}</span>
      {loading && (
        <span className="absolute inset-0 flex items-center justify-center">
          <Spinner size="sm" />
        </span>
      )}
    </button>
  );
}
```

---

## Progress Bars

For operations with known progress (uploads, multi-step wizards):

```tsx
function ProgressBar({ value, max = 100 }: { value: number; max?: number }) {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));

  return (
    <div
      role="progressbar"
      aria-valuenow={value}
      aria-valuemin={0}
      aria-valuemax={max}
      className="h-2 w-full overflow-hidden rounded-full bg-muted"
    >
      <div
        className="h-full rounded-full bg-primary transition-all duration-300 ease-out"
        style={{ width: `${percentage}%` }}
      />
    </div>
  );
}
```

---

## Optimistic UI

Update the UI immediately, before the server confirms. Revert if it fails.

### TanStack Query Pattern

```tsx
import { useMutation, useQueryClient } from "@tanstack/react-query";

function useTodoToggle() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (todo: Todo) =>
      fetch(`/api/todos/${todo.id}`, {
        method: "PATCH",
        body: JSON.stringify({ completed: !todo.completed }),
      }),

    // Optimistic update
    onMutate: async (todo) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ["todos"] });

      // Snapshot previous value
      const previous = queryClient.getQueryData<Todo[]>(["todos"]);

      // Optimistically update
      queryClient.setQueryData<Todo[]>(["todos"], (old) =>
        old?.map((t) =>
          t.id === todo.id ? { ...t, completed: !t.completed } : t
        )
      );

      return { previous };
    },

    // Revert on error
    onError: (_err, _todo, context) => {
      if (context?.previous) {
        queryClient.setQueryData(["todos"], context.previous);
      }
    },

    // Always refetch after settle
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ["todos"] });
    },
  });
}
```

### When to Use Optimistic UI

| Use Case | Optimistic? | Why |
|----------|-------------|-----|
| Toggle (like, bookmark) | Yes | High confidence, easy revert |
| Add to list | Yes | Fast feedback, revert = remove |
| Delete item | Maybe | Show "undo" toast instead |
| Form submission | No | Complex validation, high-stakes |
| Payment | Never | Irreversible action |

---

## AI Streaming Text Pattern

For AI/LLM responses that stream token by token:

```tsx
function StreamingText({ text }: { text: string }) {
  return (
    <div className="prose">
      <p>
        {text}
        <span className="inline-block w-2 animate-pulse bg-foreground align-baseline">
          &nbsp;
        </span>
      </p>
    </div>
  );
}

// With Motion for smooth token appearance
function StreamingMessage({ tokens }: { tokens: string[] }) {
  return (
    <div className="prose">
      {tokens.map((token, i) => (
        <motion.span
          key={i}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.15 }}
        >
          {token}
        </motion.span>
      ))}
      <motion.span
        animate={{ opacity: [1, 0] }}
        transition={{ repeat: Infinity, duration: 0.8 }}
        className="inline-block w-0.5 bg-foreground"
      >
        &nbsp;
      </motion.span>
    </div>
  );
}
```

---

## Rules

1. **Skeleton > spinner** for content areas — skeletons reduce perceived load time
2. **Match the skeleton to the real layout** — same dimensions, same structure
3. **Optimistic UI for low-risk actions** — toggles, likes, bookmarks
4. **Always handle the error state** — revert optimistic updates, show toast
5. **prefers-reduced-motion** — disable shimmer animation, use static gray
6. **aria-busy="true"** on loading containers for screen readers
