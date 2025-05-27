# React Application Development Guidelines

These guidelines serve as a standard for developing React applications within our organization. They cover code style, architecture, testing, common patterns, and best practices to ensure consistency, maintainability, performance, and accessibility. These instructions are also optimized to guide AI code assistants like GitHub Copilot.

---

## 1. Code Style & Architecture

Our foundational principles for writing clean, modular, and maintainable React code.

* **Language & Type Safety:**
    * Write **clean, modular, and well-typed TypeScript code**.
    * Always prioritize **explicit types** over implicit ones.
* **Component Paradigm:**
    * Favor **functional components** and **custom hooks**.
* **Modularity:**
    * Ensure a **clear separation of concerns** in all generated code, distinguishing between UI, logic, and data fetching.
* **Exports:**
    * Use **named exports** for all custom hooks, utility functions, and service methods. Default exports should be reserved only for components.
* **Folder Structure:**
    * Adhere strictly to a **feature-based folder structure**:
        ```
        src/
        └── features/
            └── [featureName]/
                ├── index.ts              // Feature entry point, re-exports
                ├── service.ts            // Data fetching and business logic
                ├── hooks/
                │   └── use[FeatureName].ts // Custom hooks for the feature
                ├── components/
                │   ├── [FeatureComponent].tsx // Main feature component
                │   └── [SubComponent].tsx     // Smaller, reusable UI components
                └── types.ts              // Type definitions specific to the feature
        ```
* **HTTP Client:**
    * For all API interactions, use the **centralized HTTP client** (e.g., `src/utils/http.ts` or `src/services/apiClient.ts`).
    * Ensure the client includes **interceptors** for consistent error handling, authentication, and request/response logging.
    * **Never create ad-hoc `fetch` or `axios` instances directly within components or services.**

---

## 2. Testing Practices

Guidelines for writing robust and reliable tests.

* **Testing Frameworks:**
    * Use **React Testing Library** and **Jest** for all unit and integration tests.
* **Mocking Strategy:**
    * **Easy Peasy Stores:** Mock Easy Peasy stores using `jest.mock()` or by providing a mock store instance via the `StoreProvider` in tests.
    * **Service Responses:** Use `jest.mock()` to **simulate service responses** (`service.ts`) for isolated unit testing. Do not make actual API calls in tests.
    * **Hook Behavior:** Mock custom hook behavior (e.g., return specific data) where necessary to isolate component tests.
* **Hook Testing:**
    * When testing custom hooks, always use `renderHook()` from `@testing-library/react-hooks` (or `@testing-library/react` if available in your version).
    * Provide `wrapper` options for context or providers if the hook depends on them.
* **Test Pattern:**
    * Strictly apply the **AAA (Arrange-Act-Assert) pattern** in all test cases for clarity.
    * **Arrange:** Set up the test environment and data.
    * **Act:** Perform the action to be tested.
    * **Assert:** Verify the expected outcome.
* **Edge Cases:**
    * Always **annotate and test edge cases** (e.g., empty states, error states, loading states, invalid input).
* **Test Wrapper:**
    * Always wrap components with required providers (e.g., `StoreProvider`, `MemoryRouter` or `BrowserRouter`, `ThemeProvider`) in a **reusable `TestWrapper` component**.
* **User Interaction:**
    * Prefer `userEvent` over `fireEvent` to simulate realistic user interactions (e.g., typing, clicking, tabbing).
* **Async Assertions:**
    * Use `waitFor()` for all assertions that depend on asynchronous state updates or effects (e.g., after a `Promise` resolves).

---

## 3. Hooks & React Patterns

Idiomatic React patterns for maintainable and performant code.

* **`useCallback` & `useMemo`:**
    * Use `useCallback` and `useMemo` **only when necessary for performance optimization**.
    * Common use cases include:
        * Preventing unnecessary re-renders of memoized child components (`React.memo`).
        * Memoizing expensive calculations.
    * **Always provide a brief inline comment explaining the rationale** for their use.
* **`useEffect` Avoidance for Data Fetching:**
    * **Avoid large or complex `useEffect` blocks for data fetching.**
    * Instead, encapsulate data fetching logic into **named custom hooks** (e.g., `useFetchData`, `useQuery`, `useGetData`).
* **Composition:**
    * Favor **composition over configuration**. When a hook or component becomes complex, suggest breaking it down into smaller, more focused custom hooks or presentational components.

---

## 4. Avoid Anti-Patterns

Practices to explicitly avoid for clean, readable, and efficient code.

* ❌ **Data Fetching in `useEffect`:**
    * **NEVER perform direct data fetching logic (`fetch`, `axios.get`, etc.) inside `useEffect` directly.** Always abstract it into a dedicated custom hook.
* ❌ **Deeply Nested Ternary Operators:**
    * **Avoid deeply nested ternary operators (more than one level).** Suggest cleaner alternatives like early returns, `if/else` statements, or a `switch` statement for improved readability.
* ❌ **Prop Drilling:**
    * **Avoid passing props down through multiple layers of components (prop drilling).**
    * Suggest using the **React Context API** or **Easy Peasy selectors** to manage shared state at a higher level.
* ❌ **Large Component Files:**
    * **Avoid creating large, monolithic component files.**
    * Split complex logic into custom hooks and UI into smaller, reusable presentational components. A file over 200-300 lines should be a red flag.
* ❌ **Inline Function Definitions in JSX (Unless Trivial):**
    * **Avoid defining functions directly inside JSX `props`** unless they are absolutely trivial (e.g., `onClick={() => setOpen(true)}`).
    * Move event handlers or callback functions to `useCallback` or define them outside the component for better performance and readability.

---

## 5. Code Suggestions

General best practices for high-quality code.

* **Destructuring:**
    * Always **destructure props and state** for improved readability and conciseness.
* **Asynchronous Operations:**
    * Prefer **`async/await`** for all asynchronous operations.
    * Implement **proper error handling** using `try/catch/finally` blocks around asynchronous calls.
* **String Manipulation:**
    * Use **template literals and string interpolation** (`` `${variable}` ``) instead of string concatenation.
* **Naming Conventions:**
    * Adhere to consistent and clear naming conventions:
        * **Custom hooks:** `use[FeatureName]`, e.g., `useUserData`, `useProductForm`.
        * **Service methods:** `get[Feature]Data`, `create[Feature]Item`, `update[Feature]Item`, `delete[Feature]`.
        * **Service files:** `[Feature]Service.ts`, e.g., `UserService.ts`, `ProductService.ts`.
        * **Components:** PascalCase, e.g., `UserProfile`, `ProductCard`, `LoginButton`.
        * **Types/Interfaces:** PascalCase, e.g., `IUser`, `ProductData`.
* **Type Definitions:**
    * Use `interface` or `type` consistently for all type definitions.
    * **Avoid the `any` type.** If unavoidable (e.g., for certain third-party libraries), provide a justification comment.

---

## 6. Styling & Accessibility

Ensuring a consistent and accessible user interface.

* **Inline Styles:**
    * ❌ **NEVER use inline styles (`style={{...}}`)** except for dynamic, trivial styling or when absolutely necessary (e.g., for animation libraries).
* **SCSS:**
    * Always prefer **`.scss` files scoped per component** (e.g., `FeatureComponent.module.scss`). Use CSS Modules for local scoping.
* **Design Tokens:**
    * Use **variables from `src/styles/variables.scss`** for all spacing, colors, typography, border-radius, and other design tokens. This ensures adherence to the organization's design system.
* **E-Accessibility (WCAG AA/AAA):**
    * Ensure all generated components follow e-accessibility best practices:
        * **Semantic HTML:** Use appropriate semantic HTML elements (`<button>`, `<label>`, `<input>`, `<fieldset>`, `<nav>`, `<main>`, `<aside>`, `<footer>`, `<header>`, etc.).
        * **ARIA Attributes:** Provide `aria-label`, `aria-labelledby`, `aria-describedby`, `aria-live`, `role`, and other `aria-*` attributes where necessary for screen readers and assistive technologies.
        * **Color Contrast:** Ensure sufficient color contrast meets WCAG AA/AAA standards.
        * **Keyboard Navigation:** Prefer keyboard-navigable components (e.g., using native `<button>` elements over `<div>` with `onClick`, ensure proper `tabIndex` management).

---

## 7. Component Usage

Leveraging our existing component libraries for efficiency and consistency.

* **Reactstrap:**
    * Utilize predefined components from **`reactstrap`** (e.g., `Card`, `FormGroup`, `Button`, `Input`, `Row`, `Col`, `Container`) for layout and common UI elements.
* **CRL Components (Organization Library):**
    * Prioritize using components from our internal `crl-components` library when available. **Always check for an existing `crl-component` before creating a custom one.**
    * Examples include:
        * `<Autocomplete />` for predictive dropdowns.
        * `<CrlButton />`, `<CrlModal />`, `<CrlTable />`, `<CrlSpinner />`, etc.

---
