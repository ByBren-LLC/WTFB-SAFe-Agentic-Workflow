# Data Table Pattern

## What It Does

Creates a server-side rendered data table with sortable columns, filtering, actions, and responsive design using shadcn/ui Table components.

## When to Use

- Admin list views
- User data dashboards
- Content management tables
- Report/analytics displays
- Any tabular data presentation

## Code Pattern

```typescript
// app/{page}/_components/{resource}-table.tsx OR page.tsx
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { MoreHorizontal, Edit, Trash2, Eye } from "lucide-react";
import Link from "next/link";

// 1. Define data type (usually from Prisma)
type {Resource}Data = {
  id: string;
  name: string;
  status: 'active' | 'inactive' | 'pending';
  created_at: Date;
  updated_at: Date;
  // ... other fields
};

// 2. Table component props
interface {Resource}TableProps {
  data: {Resource}Data[];
  actions?: boolean;  // Show actions column
}

export function {Resource}Table({ data, actions = true }: {Resource}TableProps) {
  // 3. Empty state
  if (data.length === 0) {
    return (
      <div className="text-center p-12 border border-dashed rounded-lg">
        <p className="text-muted-foreground mb-4">No {resources} found</p>
        <Button asChild>
          <Link href="/{path}/new">Create New {Resource}</Link>
        </Button>
      </div>
    );
  }

  // 4. Table rendering
  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Name</TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Created</TableHead>
            <TableHead>Updated</TableHead>
            {actions && (
              <TableHead className="w-[100px]">Actions</TableHead>
            )}
          </TableRow>
        </TableHeader>
        <TableBody>
          {data.map((item) => (
            <TableRow key={item.id}>
              {/* Name with link */}
              <TableCell className="font-medium">
                <Link
                  href={`/{path}/${item.id}`}
                  className="hover:underline"
                >
                  {item.name}
                </Link>
              </TableCell>

              {/* Status badge */}
              <TableCell>
                <Badge
                  variant={
                    item.status === 'active' ? 'default' :
                    item.status === 'pending' ? 'secondary' :
                    'destructive'
                  }
                >
                  {item.status}
                </Badge>
              </TableCell>

              {/* Formatted dates */}
              <TableCell>
                {new Date(item.created_at).toLocaleDateString()}
              </TableCell>

              <TableCell>
                {new Date(item.updated_at).toLocaleDateString()}
              </TableCell>

              {/* Actions dropdown */}
              {actions && (
                <TableCell>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon">
                        <MoreHorizontal className="h-4 w-4" />
                        <span className="sr-only">Actions</span>
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem asChild>
                        <Link href={`/{path}/${item.id}`}>
                          <Eye className="mr-2 h-4 w-4" />
                          View
                        </Link>
                      </DropdownMenuItem>
                      <DropdownMenuItem asChild>
                        <Link href={`/{path}/${item.id}/edit`}>
                          <Edit className="mr-2 h-4 w-4" />
                          Edit
                        </Link>
                      </DropdownMenuItem>
                      <DropdownMenuItem
                        className="text-destructive"
                        onClick={() => handleDelete(item.id)}
                      >
                        <Trash2 className="mr-2 h-4 w-4" />
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              )}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );

  async function handleDelete(id: string) {
    if (!confirm('Are you sure you want to delete this item?')) {
      return;
    }

    try {
      const response = await fetch(`/api/{resource}/${id}`, {
        method: 'DELETE'
      });

      if (response.ok) {
        window.location.reload();  // Or use router.refresh()
      }
    } catch (error) {
      console.error('Delete error:', error);
      alert('Failed to delete item');
    }
  }
}
```

## Advanced Patterns

### With Client-Side Actions
```typescript
"use client"

import { useRouter } from "next/navigation";
import { useState } from "react";

export function DataTableWithActions({ data }: Props) {
  const router = useRouter();
  const [isDeleting, setIsDeleting] = useState<string | null>(null);

  async function handleDelete(id: string) {
    if (!confirm('Delete this item?')) return;

    setIsDeleting(id);

    try {
      await fetch(`/api/resource/${id}`, { method: 'DELETE' });
      router.refresh();  // Refresh server component
    } catch (error) {
      alert('Delete failed');
    } finally {
      setIsDeleting(null);
    }
  }

  return (
    <Table>
      <TableBody>
        {data.map((item) => (
          <TableRow key={item.id}>
            {/* ... cells ... */}
            <TableCell>
              <Button
                variant="destructive"
                size="sm"
                onClick={() => handleDelete(item.id)}
                disabled={isDeleting === item.id}
              >
                {isDeleting === item.id ? 'Deleting...' : 'Delete'}
              </Button>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

### With Sorting
```typescript
"use client"

import { useState } from "react";
import { ChevronDown, ChevronUp } from "lucide-react";

type SortConfig = {
  key: string;
  direction: 'asc' | 'desc';
};

export function SortableTable({ data }: Props) {
  const [sortConfig, setSortConfig] = useState<SortConfig>({
    key: 'created_at',
    direction: 'desc'
  });

  const sortedData = [...data].sort((a, b) => {
    const aVal = a[sortConfig.key as keyof typeof a];
    const bVal = b[sortConfig.key as keyof typeof b];

    if (aVal < bVal) return sortConfig.direction === 'asc' ? -1 : 1;
    if (aVal > bVal) return sortConfig.direction === 'asc' ? 1 : -1;
    return 0;
  });

  function handleSort(key: string) {
    setSortConfig({
      key,
      direction:
        sortConfig.key === key && sortConfig.direction === 'asc'
          ? 'desc'
          : 'asc'
    });
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead
            className="cursor-pointer"
            onClick={() => handleSort('name')}
          >
            Name
            {sortConfig.key === 'name' && (
              sortConfig.direction === 'asc' ?
                <ChevronUp className="inline ml-1 h-4 w-4" /> :
                <ChevronDown className="inline ml-1 h-4 w-4" />
            )}
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {sortedData.map((item) => (
          // ... render rows
        ))}
      </TableBody>
    </Table>
  );
}
```

### With Pagination
```typescript
interface PaginatedTableProps {
  data: Resource[];
  page: number;
  total: number;
  perPage: number;
}

export function PaginatedTable({
  data,
  page,
  total,
  perPage
}: PaginatedTableProps) {
  const totalPages = Math.ceil(total / perPage);

  return (
    <>
      <Table>
        {/* ... table content ... */}
      </Table>

      <div className="flex items-center justify-between mt-4">
        <p className="text-sm text-muted-foreground">
          Showing {(page - 1) * perPage + 1} to{' '}
          {Math.min(page * perPage, total)} of {total} results
        </p>

        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            disabled={page === 1}
            asChild
          >
            <Link href={`?page=${page - 1}`}>Previous</Link>
          </Button>

          <Button
            variant="outline"
            size="sm"
            disabled={page === totalPages}
            asChild
          >
            <Link href={`?page=${page + 1}`}>Next</Link>
          </Button>
        </div>
      </div>
    </>
  );
}
```

### With Search/Filter
```typescript
"use client"

import { useState } from "react";
import { Input } from "@/components/ui/input";

export function FilterableTable({ data }: Props) {
  const [search, setSearch] = useState("");

  const filteredData = data.filter((item) =>
    item.name.toLowerCase().includes(search.toLowerCase()) ||
    item.description?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-4">
      <Input
        placeholder="Search..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="max-w-sm"
      />

      <Table>
        <TableBody>
          {filteredData.map((item) => (
            // ... render rows
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
```

## Customization Guide

1. **Replace placeholders**:
   - `{Resource}` → Type name (e.g., `Content`, `Payment`)
   - `{resource}` → URL segment
   - `{resources}` → Plural for empty state
   - `{path}` → Base path (e.g., `/admin/content`)

2. **Customize columns**:
   - Add/remove TableHead components
   - Adjust column widths
   - Add custom formatting

3. **Style badges/status**:
   - Use Badge variants for status
   - Add custom colors
   - Include icons

4. **Add actions**:
   - Edit/delete buttons
   - Custom actions
   - Bulk operations

## Security Checklist

- [x] **Client Actions**: Validate on server (defense in depth)
- [x] **Delete Confirmation**: Always confirm destructive actions
- [x] **Loading States**: Disable buttons during operations
- [x] **Error Handling**: Show user-friendly errors
- [x] **RLS Enforcement**: Server fetches data with RLS

## Validation Commands

```bash
# Type checking
yarn type-check

# Linting
yarn lint

# Build check
yarn build

# E2E tests
yarn test:e2e
```

## Example: Admin Content Table

```typescript
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { Edit, Trash } from "lucide-react";

type Content = {
  id: string;
  title: string;
  status: 'draft' | 'published';
  tier: 'FREE' | 'PRO' | 'VIP';
  updated_at: Date;
};

interface ContentTableProps {
  content: Content[];
}

export function ContentTable({ content }: ContentTableProps) {
  if (content.length === 0) {
    return <p>No content found</p>;
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>Title</TableHead>
          <TableHead>Tier</TableHead>
          <TableHead>Status</TableHead>
          <TableHead>Updated</TableHead>
          <TableHead>Actions</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {content.map((item) => (
          <TableRow key={item.id}>
            <TableCell className="font-medium">{item.title}</TableCell>
            <TableCell>
              <Badge variant="outline">{item.tier}</Badge>
            </TableCell>
            <TableCell>
              <Badge variant={item.status === 'published' ? 'default' : 'secondary'}>
                {item.status}
              </Badge>
            </TableCell>
            <TableCell>{new Date(item.updated_at).toLocaleDateString()}</TableCell>
            <TableCell>
              <div className="flex gap-2">
                <Button variant="ghost" size="sm" asChild>
                  <Link href={`/admin/content/${item.id}/edit`}>
                    <Edit className="h-4 w-4" />
                  </Link>
                </Button>
              </div>
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
```

## Related Patterns

- [Authenticated Page](./authenticated-page.md) - Tables on auth pages
- [User Context API](../api/user-context-api.md) - Fetch table data
- [Admin Context API](../api/admin-context-api.md) - Admin table data

---

**Pattern Source**: `app/admin/mini-course/content/page.tsx`
**Last Updated**: 2025-10-03
**Validated By**: System Architect
