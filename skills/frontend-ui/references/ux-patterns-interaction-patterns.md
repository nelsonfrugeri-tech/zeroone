# Interaction Patterns — Command Palettes, Toasts, Modals & More

## Command Palettes (cmdk)

The command palette pattern (Cmd+K) is now standard in modern apps.
**cmdk** is the canonical library.

### Basic Implementation

```tsx
import { Command } from "cmdk";
import { useEffect, useState } from "react";
import { Search, FileText, Settings, Moon, LogOut } from "lucide-react";

function CommandPalette() {
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if (e.key === "k" && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen((prev) => !prev);
      }
    };
    document.addEventListener("keydown", down);
    return () => document.removeEventListener("keydown", down);
  }, []);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={() => setOpen(false)}
      />

      {/* Command palette */}
      <div className="relative mx-auto mt-[20vh] max-w-lg">
        <Command
          className="rounded-xl border border-border bg-surface shadow-2xl"
          onKeyDown={(e) => {
            if (e.key === "Escape") setOpen(false);
          }}
        >
          <div className="flex items-center border-b border-border px-4">
            <Search className="mr-2 size-4 shrink-0 text-muted-foreground" />
            <Command.Input
              placeholder="Type a command or search..."
              className="flex h-12 w-full bg-transparent text-sm outline-none
                placeholder:text-muted-foreground"
            />
          </div>

          <Command.List className="max-h-80 overflow-y-auto p-2">
            <Command.Empty className="py-6 text-center text-sm text-muted-foreground">
              No results found.
            </Command.Empty>

            <Command.Group heading="Pages" className="[&_[cmdk-group-heading]]:px-2
              [&_[cmdk-group-heading]]:py-1.5 [&_[cmdk-group-heading]]:text-xs
              [&_[cmdk-group-heading]]:font-medium [&_[cmdk-group-heading]]:text-muted-foreground">
              <CommandItem icon={FileText} label="Dashboard" shortcut="G D" />
              <CommandItem icon={FileText} label="Projects" shortcut="G P" />
              <CommandItem icon={FileText} label="Settings" shortcut="G S" />
            </Command.Group>

            <Command.Separator className="mx-2 my-1 h-px bg-border" />

            <Command.Group heading="Actions">
              <CommandItem icon={Moon} label="Toggle Dark Mode" shortcut="T D" />
              <CommandItem icon={Settings} label="Preferences" />
              <CommandItem icon={LogOut} label="Sign Out" />
            </Command.Group>
          </Command.List>
        </Command>
      </div>
    </div>
  );
}

function CommandItem({
  icon: Icon,
  label,
  shortcut,
  onSelect,
}: {
  icon: React.ElementType;
  label: string;
  shortcut?: string;
  onSelect?: () => void;
}) {
  return (
    <Command.Item
      onSelect={onSelect}
      className="flex cursor-pointer items-center gap-2 rounded-lg px-2 py-2 text-sm
        aria-selected:bg-accent aria-selected:text-accent-foreground"
    >
      <Icon className="size-4 text-muted-foreground" />
      <span className="flex-1">{label}</span>
      {shortcut && (
        <kbd className="ml-auto text-xs text-muted-foreground">
          {shortcut}
        </kbd>
      )}
    </Command.Item>
  );
}
```

---

## Toast Notifications (Sonner)

**Sonner** is the standard toast library. Beautiful, accessible, minimal API.

### Setup

```tsx
// app/layout.tsx
import { Toaster } from "sonner";

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        {children}
        <Toaster
          position="bottom-right"
          toastOptions={{
            className: "!bg-surface !text-foreground !border-border",
          }}
        />
      </body>
    </html>
  );
}
```

### Usage Patterns

```tsx
import { toast } from "sonner";

// Simple
toast("Event has been created");

// Success
toast.success("Profile updated successfully");

// Error
toast.error("Failed to save changes");

// Loading → Success/Error
const promise = saveData();
toast.promise(promise, {
  loading: "Saving...",
  success: "Saved!",
  error: "Could not save",
});

// Action toast (undo pattern)
toast("Item deleted", {
  action: {
    label: "Undo",
    onClick: () => restoreItem(id),
  },
});

// Custom content
toast.custom((id) => (
  <div className="flex items-center gap-3 rounded-lg border bg-surface p-4 shadow-lg">
    <Avatar src={user.avatar} />
    <div>
      <p className="font-medium">{user.name}</p>
      <p className="text-sm text-muted-foreground">sent you a message</p>
    </div>
  </div>
));
```

---

## Modals & Dialogs

Use **Radix Dialog** for accessible modals. Never build from scratch.

### Controlled Dialog

```tsx
import * as Dialog from "@radix-ui/react-dialog";
import { motion, AnimatePresence } from "motion/react";
import { X } from "lucide-react";

function Modal({
  open,
  onOpenChange,
  title,
  description,
  children,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description?: string;
  children: React.ReactNode;
}) {
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <AnimatePresence>
        {open && (
          <Dialog.Portal forceMount>
            <Dialog.Overlay asChild>
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm"
              />
            </Dialog.Overlay>

            <Dialog.Content asChild>
              <motion.div
                initial={{ opacity: 0, scale: 0.95, y: 10 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95, y: 10 }}
                transition={{ type: "spring", stiffness: 500, damping: 30 }}
                className="fixed left-1/2 top-1/2 z-50 w-full max-w-md -translate-x-1/2
                  -translate-y-1/2 rounded-xl border border-border bg-surface p-6 shadow-xl"
              >
                <Dialog.Title className="text-lg font-semibold">
                  {title}
                </Dialog.Title>

                {description && (
                  <Dialog.Description className="mt-2 text-sm text-muted-foreground">
                    {description}
                  </Dialog.Description>
                )}

                <div className="mt-4">{children}</div>

                <Dialog.Close asChild>
                  <button
                    className="absolute right-4 top-4 rounded-sm p-1 opacity-70
                      hover:opacity-100 focus-visible:outline focus-visible:outline-2
                      focus-visible:outline-ring"
                    aria-label="Close"
                  >
                    <X className="size-4" />
                  </button>
                </Dialog.Close>
              </motion.div>
            </Dialog.Content>
          </Dialog.Portal>
        )}
      </AnimatePresence>
    </Dialog.Root>
  );
}
```

---

## Dropdown Menus

Use **Radix DropdownMenu** for proper keyboard navigation and accessibility.

```tsx
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import { MoreHorizontal, Edit, Copy, Trash } from "lucide-react";

function ActionsMenu() {
  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger asChild>
        <button className="rounded-lg p-2 hover:bg-accent" aria-label="Actions">
          <MoreHorizontal className="size-4" />
        </button>
      </DropdownMenu.Trigger>

      <DropdownMenu.Portal>
        <DropdownMenu.Content
          className="z-50 min-w-[180px] rounded-xl border border-border bg-surface
            p-1 shadow-lg animate-in fade-in-0 zoom-in-95"
          sideOffset={5}
          align="end"
        >
          <DropdownMenu.Item className="flex cursor-pointer items-center gap-2
            rounded-lg px-3 py-2 text-sm outline-none
            focus:bg-accent focus:text-accent-foreground">
            <Edit className="size-4" /> Edit
          </DropdownMenu.Item>

          <DropdownMenu.Item className="flex cursor-pointer items-center gap-2
            rounded-lg px-3 py-2 text-sm outline-none
            focus:bg-accent focus:text-accent-foreground">
            <Copy className="size-4" /> Duplicate
          </DropdownMenu.Item>

          <DropdownMenu.Separator className="mx-1 my-1 h-px bg-border" />

          <DropdownMenu.Item className="flex cursor-pointer items-center gap-2
            rounded-lg px-3 py-2 text-sm text-destructive outline-none
            focus:bg-destructive/10 focus:text-destructive">
            <Trash className="size-4" /> Delete
          </DropdownMenu.Item>
        </DropdownMenu.Content>
      </DropdownMenu.Portal>
    </DropdownMenu.Root>
  );
}
```

---

## Infinite Scroll vs Pagination

### When to Use Which

| Pattern | Use Case | Pros | Cons |
|---------|----------|------|------|
| Infinite scroll | Social feeds, image galleries | Frictionless browsing | No footer access, poor a11y |
| Pagination | Tables, search results, admin | Predictable, bookmarkable | More clicks |
| Load more button | Compromise | User-controlled, accessible | Still loses footer |

### Virtualized List (TanStack Virtual)

For long lists (1000+ items), virtualize to render only visible items:

```tsx
import { useVirtualizer } from "@tanstack/react-virtual";

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 64,
    overscan: 5,
  });

  return (
    <div ref={parentRef} className="h-[600px] overflow-auto">
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: "relative" }}>
        {virtualizer.getVirtualItems().map((virtualItem) => (
          <div
            key={virtualItem.key}
            style={{
              position: "absolute",
              top: 0,
              left: 0,
              width: "100%",
              height: `${virtualItem.size}px`,
              transform: `translateY(${virtualItem.start}px)`,
            }}
          >
            <ListItem item={items[virtualItem.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## Error Boundaries

Catch rendering errors gracefully:

```tsx
"use client";

import { Component, type ReactNode } from "react";
import { AlertTriangle, RefreshCw } from "lucide-react";

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? (
        <div className="flex flex-col items-center justify-center gap-4 rounded-xl
          border border-destructive/20 bg-destructive/5 p-8 text-center">
          <AlertTriangle className="size-8 text-destructive" />
          <div>
            <h3 className="font-semibold">Something went wrong</h3>
            <p className="mt-1 text-sm text-muted-foreground">
              {this.state.error?.message || "An unexpected error occurred"}
            </p>
          </div>
          <button
            onClick={() => this.setState({ hasError: false })}
            className="flex items-center gap-2 rounded-lg bg-primary px-4 py-2
              text-sm text-primary-foreground"
          >
            <RefreshCw className="size-4" /> Try Again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```

---

## Rules

1. **Cmd+K is expected** in modern apps — implement a command palette
2. **Sonner for toasts** — don't build your own toast system
3. **Radix for modals/dropdowns** — accessible out of the box
4. **Virtualize long lists** — TanStack Virtual for 100+ items
5. **Error boundaries everywhere** — wrap major sections, not just the root
6. **Keyboard first** — every interactive pattern must work with keyboard only
