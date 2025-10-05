# Form with Validation Pattern

## What It Does

Creates type-safe, validated forms using React Hook Form + Zod + shadcn/ui components. Provides automatic validation, error handling, and TypeScript type safety.

## When to Use

- Data entry forms
- User settings/profile updates
- Content creation/editing
- Complex multi-field forms
- Forms requiring runtime validation

## Code Pattern

```typescript
// app/{page}/_components/{resource}-form.tsx
"use client"

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";

// 1. Define Zod validation schema
const FormSchema = z.object({
  // Text inputs
  name: z.string()
    .min(1, "Name is required")
    .max(255, "Name must be less than 255 characters"),

  email: z.string()
    .min(1, "Email is required")
    .email("Invalid email address"),

  // Textarea
  description: z.string()
    .max(1000, "Description must be less than 1000 characters")
    .optional(),

  // Select/dropdown
  category: z.string()
    .min(1, "Please select a category"),

  // Number input
  amount: z.string()
    .min(1, "Amount is required")
    .refine((val) => !isNaN(Number(val)) && Number(val) > 0, {
      message: "Amount must be a positive number"
    })
    .refine((val) => Number(val) <= 1000, {
      message: "Maximum amount is $1000"
    }),

  // Checkbox
  terms: z.boolean()
    .refine((val) => val === true, {
      message: "You must accept the terms and conditions"
    }),
});

// 2. Infer TypeScript types
type FormData = z.infer<typeof FormSchema>;

// 3. Component props
interface {Resource}FormProps {
  initialData?: Partial<FormData>;
  userId: string;
  onSuccess?: () => void;
}

export function {Resource}Form({
  initialData,
  userId,
  onSuccess
}: {Resource}FormProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [message, setMessage] = useState<{
    type: 'success' | 'error';
    text: string;
  } | null>(null);
  const router = useRouter();

  // 4. Initialize form with react-hook-form + Zod
  const form = useForm<FormData>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      name: initialData?.name || "",
      email: initialData?.email || "",
      description: initialData?.description || "",
      category: initialData?.category || "",
      amount: initialData?.amount || "",
      terms: initialData?.terms || false,
    }
  });

  // 5. Form submission handler
  async function onSubmit(data: FormData) {
    setIsLoading(true);
    setMessage(null);

    try {
      // Call API
      const response = await fetch('/api/{resource}', {
        method: initialData ? 'PUT' : 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      const result = await response.json();

      if (!response.ok) {
        throw new Error(result.error || 'Failed to save');
      }

      setMessage({
        type: 'success',
        text: initialData
          ? '{Resource} updated successfully'
          : '{Resource} created successfully'
      });

      // Reset form or redirect
      if (!initialData) {
        form.reset();
      }

      // Call success callback
      onSuccess?.();

      // Optional: Redirect
      // router.push('/dashboard/{resource}');
      router.refresh();  // Refresh server components

    } catch (error) {
      console.error('Form submission error:', error);
      setMessage({
        type: 'error',
        text: error instanceof Error ? error.message : 'An error occurred'
      });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        {/* Text Input */}
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input
                  placeholder="Enter name"
                  {...field}
                  disabled={isLoading}
                />
              </FormControl>
              <FormDescription>
                This will be displayed publicly
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Email Input */}
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input
                  type="email"
                  placeholder="you@example.com"
                  {...field}
                  disabled={isLoading}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Textarea */}
        <FormField
          control={form.control}
          name="description"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Description</FormLabel>
              <FormControl>
                <Textarea
                  placeholder="Enter description"
                  rows={4}
                  {...field}
                  disabled={isLoading}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Select Dropdown */}
        <FormField
          control={form.control}
          name="category"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Category</FormLabel>
              <Select
                onValueChange={field.onChange}
                defaultValue={field.value}
                disabled={isLoading}
              >
                <FormControl>
                  <SelectTrigger>
                    <SelectValue placeholder="Select a category" />
                  </SelectTrigger>
                </FormControl>
                <SelectContent>
                  <SelectItem value="option1">Option 1</SelectItem>
                  <SelectItem value="option2">Option 2</SelectItem>
                  <SelectItem value="option3">Option 3</SelectItem>
                </SelectContent>
              </Select>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Number Input */}
        <FormField
          control={form.control}
          name="amount"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Amount ($)</FormLabel>
              <FormControl>
                <Input
                  type="number"
                  step="0.01"
                  placeholder="0.00"
                  {...field}
                  disabled={isLoading}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Success/Error Message */}
        {message && (
          <div
            className={`p-4 rounded-md ${
              message.type === 'success'
                ? 'bg-green-50 text-green-800'
                : 'bg-red-50 text-red-800'
            }`}
          >
            {message.text}
          </div>
        )}

        {/* Submit Button */}
        <div className="flex gap-4">
          <Button type="submit" disabled={isLoading}>
            {isLoading ? (
              <>
                <span className="mr-2">Saving...</span>
                <span className="animate-spin">⏳</span>
              </>
            ) : (
              initialData ? 'Update' : 'Create'
            )}
          </Button>

          {initialData && (
            <Button
              type="button"
              variant="outline"
              onClick={() => router.back()}
              disabled={isLoading}
            >
              Cancel
            </Button>
          )}
        </div>
      </form>
    </Form>
  );
}
```

## Advanced Patterns

### Conditional Fields
```typescript
const FormSchema = z.object({
  accountType: z.enum(['personal', 'business']),
  personalName: z.string().optional(),
  businessName: z.string().optional(),
  taxId: z.string().optional(),
}).refine(
  (data) => {
    if (data.accountType === 'business') {
      return !!data.businessName && !!data.taxId;
    }
    if (data.accountType === 'personal') {
      return !!data.personalName;
    }
    return true;
  },
  {
    message: 'Required fields missing for account type',
    path: ['businessName']
  }
);

// In form
const accountType = form.watch('accountType');

{accountType === 'business' && (
  <>
    <FormField name="businessName" ... />
    <FormField name="taxId" ... />
  </>
)}
```

### Dynamic Field Arrays
```typescript
import { useFieldArray } from "react-hook-form";

const FormSchema = z.object({
  items: z.array(
    z.object({
      name: z.string().min(1),
      quantity: z.number().min(1)
    })
  ).min(1, "At least one item required")
});

// In component
const { fields, append, remove } = useFieldArray({
  control: form.control,
  name: "items"
});

{fields.map((field, index) => (
  <div key={field.id}>
    <FormField
      name={`items.${index}.name`}
      ...
    />
    <Button onClick={() => remove(index)}>Remove</Button>
  </div>
))}
<Button onClick={() => append({ name: '', quantity: 1 })}>
  Add Item
</Button>
```

### File Upload
```typescript
const FormSchema = z.object({
  file: z
    .instanceof(FileList)
    .refine((files) => files.length > 0, "File is required")
    .refine(
      (files) => files[0]?.size <= 5 * 1024 * 1024,
      "Max file size is 5MB"
    )
});

<FormField
  name="file"
  render={({ field: { onChange, value, ...field } }) => (
    <FormItem>
      <FormLabel>File</FormLabel>
      <FormControl>
        <Input
          type="file"
          onChange={(e) => onChange(e.target.files)}
          {...field}
        />
      </FormControl>
      <FormMessage />
    </FormItem>
  )}
/>
```

## Customization Guide

1. **Replace placeholders**:
   - `{Resource}` → Resource name (e.g., `Payment`, `Content`)
   - `{resource}` → URL/path segment

2. **Update schema**:
   - Add fields specific to your form
   - Define validation rules
   - Add custom refinements

3. **Customize UI**:
   - Use appropriate input components
   - Add loading states
   - Style error messages

4. **Handle submission**:
   - Call correct API endpoint
   - Handle success/error states
   - Redirect or refresh as needed

## Security Checklist

- [x] **Client Validation**: Zod schema validates on client
- [x] **Server Validation**: API also validates (defense in depth)
- [x] **Type Safety**: TypeScript types from Zod
- [x] **Error Handling**: Show user-friendly errors
- [x] **Loading States**: Disable inputs during submission

## Validation Commands

```bash
# Type checking
yarn type-check

# Linting
yarn lint

# Unit tests
yarn test:unit

# E2E tests
yarn test:e2e
```

## Example: Simple Contact Form

```typescript
"use client"

import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";

const ContactSchema = z.object({
  name: z.string().min(1, "Name is required"),
  email: z.string().email("Invalid email"),
  message: z.string().min(10, "Message must be at least 10 characters")
});

type ContactFormData = z.infer<typeof ContactSchema>;

export function ContactForm() {
  const form = useForm<ContactFormData>({
    resolver: zodResolver(ContactSchema),
    defaultValues: { name: "", email: "", message: "" }
  });

  async function onSubmit(data: ContactFormData) {
    const response = await fetch('/api/contact', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });

    if (response.ok) {
      alert('Message sent!');
      form.reset();
    }
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Name</FormLabel>
              <FormControl>
                <Input {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input type="email" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={form.control}
          name="message"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Message</FormLabel>
              <FormControl>
                <Textarea {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Send Message</Button>
      </form>
    </Form>
  );
}
```

## Related Patterns

- [Zod Validation API](../api/zod-validation-api.md) - Server-side validation
- [Authenticated Page](./authenticated-page.md) - Forms on auth pages
- [User Context API](../api/user-context-api.md) - Submit to user API

---

**Pattern Source**: `app/dashboard/finance/_components/finance-form.tsx`
**Last Updated**: 2025-10-03
**Validated By**: System Architect
