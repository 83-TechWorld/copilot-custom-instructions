### Code Style & Architecture
Write clean, modular, and well-typed TypeScript code.
Favor functional components and custom hooks with clear separation of concerns.
Use named exports for all custom hooks and service methods.
Follow feature-based folder structure (features/featureName/service.ts, hooks/useFeature.ts).
In service layers, use a centralized HTTP client with interceptors and reuse it across features.

### Testing Practices
Use React Testing Library and Jest with mocked Easy Peasy stores and custom hook mocks.
Use jest.mock() to simulate service responses and hook behavior.
When testing hooks, use renderHook() and provide wrapper options for context if needed.
Apply AAA (Arrange-Act-Assert) pattern in all test cases and annotate edge cases.
Always wrap components with required providers (e.g., StoreProvider, Router, ThemeProvider) in a reusable TestWrapper.
Prefer userEvent over fireEvent to simulate realistic user behavior.  
Use waitFor() for assertions that depend on async state or effects.  

### Hooks & React Patterns
Prefer useCallback and useMemo only when necessary—explain why if you use them.
Use custom hooks instead of large useEffect blocks—favor named hooks like useFetchData, useFormHandler.
Suggest composition over configuration—break down hooks when they become complex.

### Avoid Anti-Patterns
❌ Avoid overusing useEffect for data fetching — use custom hooks.
❌ Avoid deeply nested ternary operators — suggest clean alternatives (like early returns or switch).
❌ Avoid prop drilling — suggest using context or Easy Peasy selectors.
❌ Avoid large component files — split logic into hooks and UI into smaller components.
❌ Avoid inline function definitions inside JSX unless trivial — move to useCallback or outside.

### Code Suggestions
Always destructure props and state.
Prefer async/await with proper error handling (try/catch/finally).
Use template literals and string interpolation instead of concatenation.
Recommend naming conventions like useFeatureX, getFeatureData, FeatureService, etc.
Use interface or type consistently and avoid any.

### Styling & Accessibility
Avoid inline styles.
Always prefer .scss files scoped per component.
Use variables from variables.scss, which includes our organization's standard tokens (spacing, colors, typography).
Ensure components follow e-accessibility best practices:
Use semantic HTML (<button>, <label>, <fieldset>, etc.).
Provide aria-labels or aria-* attributes where necessary.
Ensure color contrast meets WCAG AA/AAA standards.
Prefer keyboard-navigable components (e.g., buttons over div clicks).  

### Component Usage
Use predefined components from reactstrap (e.g., Card, FormGroup, Button) for layout and UI.
Use components from crl-components (our organization’s library), such as:
<Autocomplete /> for predictive dropdowns.
<CrlButton />, <CrlModal />, etc., if available.
