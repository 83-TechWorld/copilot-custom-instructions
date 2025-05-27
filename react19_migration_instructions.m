# React 19 Migration Guidance for GitHub Copilot

This document outlines the strategy for migrating our React 18 project to React 19, with a strong emphasis on adopting new features and hooks to optimize performance and simplify code. GitHub Copilot, please use these instructions as a guide during code generation, refactoring, and suggestions.

---

## **Overall Migration Strategy**

1.  **Dependency Update:** First and foremost, update `react` and `react-dom` to `^19.0.0`.
    * `npm install react@^19.0.0 react-dom@^19.0.0` or
    * `yarn add react@^19.0.0 react-dom@^19.0.0`
    * If using TypeScript, also update `@types/react` and `@types/react-dom`.
2.  **Staged Migration:** We will perform this migration incrementally, focusing on one logical section/feature at a time.
3.  **Prioritize New Hooks:** Look for opportunities to replace existing imperative state management and asynchronous logic with the new React 19 hooks (`useActionState`, `useFormStatus`, `useOptimistic`).
4.  **Consider Server Components:** For components that primarily fetch data and don't require significant client-side interactivity, explore converting them to Server Components (`'use server'`). This is a more involved step and might require framework-level support (e.g., Next.js App Router).
5.  **Refactor `forwardRef`:** Wherever `React.forwardRef` is used, try to refactor components to accept `ref` directly as a prop in functional components, as React 19 generally allows this.
6.  **Review Strict Mode:** React 19 has stricter Strict Mode behaviors. Ensure your application runs without new warnings in Strict Mode.

---

## **Specific Refactoring Patterns for Copilot**

### **1. `useActionState` for Form Submissions and Async Operations**

* **Identify:** Look for components that handle form submissions or other async operations (like API calls) that involve:
    * `useState` for loading/pending states.
    * `useState` for error messages.
    * `useState` for success messages or results.
    * Manual `try...catch` blocks for error handling within async functions.
    * Complex logic to manage the UI state based on the outcome of an async action.
* **Convert To:** `useActionState`
* **Example (Conceptual):**

    **BEFORE (React 18):**
    ```javascript
    import React, { useState } from 'react';

    function ProfileEditor() {
      const [name, setName] = useState('');
      const [isLoading, setIsLoading] = useState(false);
      const [error, setError] = useState(null);
      const [success, setSuccess] = useState(false);

      const handleSubmit = async (e) => {
        e.preventDefault();
        setIsLoading(true);
        setError(null);
        setSuccess(false);
        try {
          // Simulate API call
          await new Promise(resolve => setTimeout(resolve, 1000));
          if (name.length < 3) {
            throw new Error('Name must be at least 3 characters.');
          }
          console.log('Saving name:', name);
          setSuccess(true);
        } catch (err) {
          setError(err.message);
        } finally {
          setIsLoading(false);
        }
      };

      return (
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            disabled={isLoading}
          />
          <button type="submit" disabled={isLoading}>
            {isLoading ? 'Saving...' : 'Save Profile'}
          </button>
          {error && <p style={{ color: 'red' }}>{error}</p>}
          {success && <p style={{ color: 'green' }}>Profile saved!</p>}
        </form>
      );
    }
    ```

    **AFTER (React 19 - `useActionState`):**
    ```javascript
    'use client'; // This component likely needs to be a Client Component

    import { useActionState } from 'react';

    async function saveProfile(prevState, formData) {
      const name = formData.get('name');
      await new Promise(resolve => setTimeout(resolve, 1000)); // Simulate API call
      if (name.length < 3) {
        return { message: 'Name must be at least 3 characters.', status: 'error' };
      }
      console.log('Saving name:', name);
      return { message: 'Profile saved successfully!', status: 'success' };
    }

    function ProfileEditor() {
      const [state, formAction, isPending] = useActionState(saveProfile, { message: null, status: null });

      return (
        <form action={formAction}>
          <input
            type="text"
            name="name" // Important for formData
            defaultValue="" // Or use 'name' state with controlled input if needed
            disabled={isPending}
          />
          <button type="submit" disabled={isPending}>
            {isPending ? 'Saving...' : 'Save Profile'}
          </button>
          {state.status === 'error' && <p style={{ color: 'red' }}>{state.message}</p>}
          {state.status === 'success' && <p style={{ color: 'green' }}>{state.message}</p>}
        </form>
      );
    }
    ```
    * **Copilot Action:** Analyze `useState` and `useEffect` patterns related to form submissions/async calls. Suggest refactoring to `useActionState` by identifying the action function, initial state, and mapping old `isLoading`/`error`/`success` states to the `useActionState` return value.

### **2. `useFormStatus` for Form Loading/Pending States**

* **Identify:** Look for child components within a `<form>` that receive `isLoading` or `isSubmitting` props, or manually manage their disabled state based on a parent form's submission.
* **Convert To:** `useFormStatus` (imported from `react-dom`). This hook is specifically for form elements to know their parent form's submission status.
* **Example (Conceptual):**

    **BEFORE (React 18):**
    ```javascript
    // ParentForm.js
    import React, { useState } from 'react';
    import SubmitButton from './SubmitButton';

    function ParentForm() {
      const [isSubmitting, setIsSubmitting] = useState(false);

      const handleSubmit = async () => {
        setIsSubmitting(true);
        await new Promise(resolve => setTimeout(resolve, 2000));
        setIsSubmitting(false);
      };

      return (
        <form onSubmit={handleSubmit}>
          <input type="text" />
          <SubmitButton isSubmitting={isSubmitting} />
        </form>
      );
    }

    // SubmitButton.js
    import React from 'react';

    function SubmitButton({ isSubmitting }) {
      return (
        <button type="submit" disabled={isSubmitting}>
          {isSubmitting ? 'Submitting...' : 'Submit'}
        </button>
      );
    }
    ```

    **AFTER (React 19 - `useFormStatus`):**
    ```javascript
    // ParentForm.js
    'use client'; // ParentForm needs to be a Client Component if it handles client-side state/interactions
    import SubmitButton from './SubmitButton';

    function ParentForm() {
      async function handleSubmit(formData) {
        await new Promise(resolve => setTimeout(resolve, 2000));
        console.log('Form submitted with:', Object.fromEntries(formData));
      }

      return (
        // The 'action' prop is crucial for useFormStatus to work
        <form action={handleSubmit}>
          <input type="text" name="message" />
          <SubmitButton />
        </form>
      );
    }

    // SubmitButton.js
    'use client'; // This child component needs to be a Client Component
    import { useFormStatus } from 'react-dom';

    function SubmitButton() {
      const { pending } = useFormStatus(); // Get pending status from parent form
      return (
        <button type="submit" disabled={pending}>
          {pending ? 'Submitting...' : 'Submit'}
        </button>
      );
    }
    ```
    * **Copilot Action:** When encountering a form with a custom submit button or status indicator, suggest moving the `isSubmitting` state management to `useFormStatus` in the child component. Ensure the parent form uses the `action` prop instead of `onSubmit` if possible for easier integration.

### **3. `useOptimistic` for Instant UI Updates**

* **Identify:** Look for scenarios where the UI updates *before* an asynchronous operation completes (e.g., adding an item to a list, liking a post) and then potentially reverts or confirms based on the actual server response. This often involves complex `useState` and `useEffect` logic to manage the "pending" UI state.
* **Convert To:** `useOptimistic`
* **Example (Conceptual):**

    **BEFORE (React 18):**
    ```javascript
    import React, { useState } from 'react';

    function CommentSection({ initialComments }) {
      const [comments, setComments] = useState(initialComments);
      const [newCommentText, setNewCommentText] = useState('');
      const [isSubmitting, setIsSubmitting] = useState(false);

      const addComment = async (text) => {
        setIsSubmitting(true);
        // Optimistic update
        const tempId = Date.now();
        const optimisticComment = { id: tempId, text, status: 'pending' };
        setComments((prev) => [...prev, optimisticComment]);

        try {
          // Simulate API call
          await new Promise((resolve) => setTimeout(resolve, 1500));
          if (text.includes('badword')) {
            throw new Error('Comment contains inappropriate language.');
          }
          const serverComment = { id: Math.random(), text, status: 'posted' }; // Actual ID from server
          setComments((prev) =>
            prev.map((c) => (c.id === tempId ? serverComment : c))
          );
        } catch (error) {
          console.error('Error adding comment:', error);
          setComments((prev) => prev.filter((c) => c.id !== tempId)); // Revert optimistic update
          alert(error.message);
        } finally {
          setIsSubmitting(false);
          setNewCommentText('');
        }
      };

      const handleSubmit = (e) => {
        e.preventDefault();
        if (newCommentText.trim()) {
          addComment(newCommentText);
        }
      };

      return (
        <div>
          <h2>Comments</h2>
          <ul>
            {comments.map((comment) => (
              <li key={comment.id} style={{ opacity: comment.status === 'pending' ? 0.6 : 1 }}>
                {comment.text} {comment.status === 'pending' && '(Sending...)'}
              </li>
            ))}
          </ul>
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              value={newCommentText}
              onChange={(e) => setNewCommentText(e.target.value)}
              disabled={isSubmitting}
            />
            <button type="submit" disabled={isSubmitting}>
              Add Comment
            </button>
          </form>
        </div>
      );
    }
    ```

    **AFTER (React 19 - `useOptimistic`):**
    ```javascript
    'use client'; // This component likely needs to be a Client Component

    import { useOptimistic, useState } from 'react';

    async function submitCommentToServer(text) {
      await new Promise((resolve) => setTimeout(resolve, 1500)); // Simulate API call
      if (text.includes('badword')) {
        throw new Error('Comment contains inappropriate language.');
      }
      return { id: Math.random(), text, status: 'posted' };
    }

    function CommentSection({ initialComments }) {
      const [comments, setComments] = useState(initialComments);
      const [newCommentText, setNewCommentText] = useState('');

      const [optimisticComments, addOptimisticComment] = useOptimistic(
        comments,
        (currentComments, newCommentText) => [
          ...currentComments,
          { id: Date.now(), text: newCommentText, status: 'pending' }, // Optimistic state
        ]
      );

      const handleSubmit = async (e) => {
        e.preventDefault();
        if (newCommentText.trim()) {
          addOptimisticComment(newCommentText); // Update optimistic state immediately
          setNewCommentText(''); // Clear input immediately
          try {
            const serverComment = await submitCommentToServer(newCommentText);
            setComments((prev) =>
              prev.map((c) => (c.id === optimisticComments[optimisticComments.length - 1].id ? serverComment : c))
            );
          } catch (error) {
            console.error('Error adding comment:', error);
            // useOptimistic will automatically revert if the state isn't updated after the async call,
            // but for explicit reversion of the optimistic item, you might adjust 'comments' state.
            // For simple cases, `useOptimistic` handles the revert if `comments` isn't updated with a matching key/id.
            alert(error.message);
            setComments(comments); // Revert to original comments if error (manual revert if needed)
          }
        }
      };

      return (
        <div>
          <h2>Comments</h2>
          <ul>
            {optimisticComments.map((comment) => (
              <li key={comment.id} style={{ opacity: comment.status === 'pending' ? 0.6 : 1 }}>
                {comment.text} {comment.status === 'pending' && '(Sending...)'}
              </li>
            ))}
          </ul>
          <form onSubmit={handleSubmit}>
            <input
              type="text"
              value={newCommentText}
              onChange={(e) => setNewCommentText(e.target.value)}
              // useOptimistic doesn't provide a 'pending' directly for disabling input,
              // you might use `useActionState` or a separate `useState` for input disablement if needed.
              // For simplicity, we'll assume the input is always enabled unless explicitly handled.
            />
            <button type="submit">
              Add Comment
            </button>
          </form>
        </div>
      );
    }
    ```
    * **Copilot Action:** Identify patterns where a UI update occurs before an API response, followed by a potential revert. Suggest refactoring to `useOptimistic`, defining the optimistic update function and handling the actual state update after the async call.

### **4. Server Components (`'use server'`, `'use client'`)**

* **Identify:**
    * Components that primarily fetch data from a database or API and render static or mostly static content.
    * Components that don't rely on client-side state (e.g., `useState`, `useEffect` for DOM manipulation or subscriptions).
    * Components that contain sensitive logic or data that should not be exposed to the client.
* **Convert To:** Default to Server Component. If client-side interactivity is truly needed, explicitly mark with `'use client'`.
* **Example (Conceptual - requires a framework like Next.js App Router):**

    **BEFORE (React 18 Client-side Data Fetching):**
    ```javascript
    // products/page.js (Client Component)
    'use client';
    import React, { useState, useEffect } from 'react';

    function ProductsPage() {
      const [products, setProducts] = useState([]);
      const [loading, setLoading] = useState(true);
      const [error, setError] = useState(null);

      useEffect(() => {
        async function fetchProducts() {
          try {
            const response = await fetch('/api/products');
            if (!response.ok) {
              throw new Error('Failed to fetch products');
            }
            const data = await response.json();
            setProducts(data);
          } catch (err) {
            setError(err.message);
          } finally {
            setLoading(false);
          }
        }
        fetchProducts();
      }, []);

      if (loading) return <p>Loading products...</p>;
      if (error) return <p>Error: {error}</p>;

      return (
        <div>
          <h1>Our Products</h1>
          <ul>
            {products.map(product => (
              <li key={product.id}>{product.name} - ${product.price}</li>
            ))}
          </ul>
        </div>
      );
    }
    export default ProductsPage;
    ```

    **AFTER (React 19 Server Component):**
    ```javascript
    // app/products/page.js (Server Component by default in Next.js App Router)
    // No 'use client' directive needed for Server Components

    import { getProductsFromDB } from '@/lib/db'; // A server-side utility to fetch data

    // This component will run on the server
    async function ProductsPage() {
      // Direct database or API call, no useEffect or useState needed for data fetching
      const products = await getProductsFromDB();

      return (
        <div>
          <h1>Our Products</h1>
          <ul>
            {products.map(product => (
              <li key={product.id}>{product.name} - ${product.price}</li>
            ))}
          </ul>
        </div>
      );
    }
    export default ProductsPage;

    // lib/db.js (Server-side code)
    // No 'use client' here. This file is only bundled for the server.
    export async function getProductsFromDB() {
      // Simulate database call
      await new Promise(resolve => setTimeout(resolve, 500));
      return [
        { id: 1, name: 'Laptop', price: 1200 },
        { id: 2, name: 'Mouse', price: 25 },
        { id: 3, name: 'Keyboard', price: 75 },
      ];
    }
    ```
    * **Copilot Action:** When encountering components that solely fetch data in `useEffect` and render it, suggest refactoring to a Server Component. If interactivity is required *within* such a component, suggest splitting it into a Server Component for data fetching/initial render and a Client Component for interactivity, placing `'use client'` at the top of the interactive component file.

### **5. Simplified Ref Handling (`refs as props`)**

* **Identify:** Functional components wrapped with `React.forwardRef`.
* **Convert To:** Remove `forwardRef` and accept `ref` directly as a prop, as it's now a valid prop in functional components.
* **Example (Conceptual):**

    **BEFORE (React 18):**
    ```javascript
    import React from 'react';

    const MyInput = React.forwardRef(({ label, ...props }, ref) => {
      return (
        <div>
          <label>{label}</label>
          <input ref={ref} {...props} />
        </div>
      );
    });

    export default MyInput;
    ```

    **AFTER (React 19):**
    ```javascript
    // No forwardRef needed
    const MyInput = ({ label, ref, ...props }) => { // Ref is now a regular prop
      return (
        <div>
          <label>{label}</label>
          <input ref={ref} {...props} />
        </div>
      );
    };

    export default MyInput;
    ```
    * **Copilot Action:** Detect `React.forwardRef` usage and propose simplifying the component signature by removing `forwardRef` and accepting `ref` directly in the functional component's props.

---

## **General Guidelines for Copilot**

* **Prioritize Safety:** If a refactoring suggestion seems risky or might break existing functionality, suggest it as an alternative and explain the potential implications.
* **Contextualize Suggestions:** Always explain *why* a React 19 feature is being suggested (e.g., "This can simplify state management and improve perceived performance using `useActionState`").
* **Incremental Changes:** Suggest changes in small, manageable chunks.
* **Import Statements:** Ensure all new hooks are correctly imported from `react` or `react-dom`.
* **TypeScript:** If the project uses TypeScript, ensure type definitions are updated and refactorings maintain type safety.
* **Be Verbose:** Provide clear explanations and code examples for each suggestion.
* **Ask for Clarification:** If the intent of existing code is unclear or multiple refactoring paths exist, ask for user guidance.
* **Leverage Existing Knowledge:** Remember the breaking changes and deprecations in React 19 (e.g., `ReactDOM.render`, string refs, legacy context APIs) and suggest fixes if encountered.

---

By adhering to these instructions, GitHub Copilot will be a powerful assistant in navigating the React 19 migration and unlocking its benefits for our project.
