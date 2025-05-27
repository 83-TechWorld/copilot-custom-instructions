✅ General Coding Standards

Use Java 21 features:
record for data carriers (DTOs/configs).
sealed, non-sealed, and permits for controlled inheritance.
switch expressions with pattern matching.
Pattern matching with instanceof.
Default to immutability:
Use final wherever possible.
Use List.of(), Map.of() for immutable collections.

Use 
Optional<T> instead of null to indicate optional values.
Avoid utility classes with static methods — prefer DI-enabled services.
Follow SOLID principles and clean architecture guidelines.
Prefer stream operations over manual loops:

Use:
Collectors.groupingBy, mapping, joining, reducing
flatMap to flatten nested structures
Avoid mutating collections in-place; use .map() and .collect().
Use if (obj instanceof MyType t) instead of traditional casts.
Replace complex if-else with early returns and guard clauses.
  
✅ Architecture & Code Organization

Apply Clean Architecture / Hexagonal Architecture:
Domain Layer: pure business logic
Application Layer: service interfaces
Infrastructure Layer: persistence, REST clients
Interface Layer: controllers, handlers
Organize code by feature, not by technical type.
Use interfaces for service definitions.
Avoid God classes; each class should do one thing well.

✅ Logging & Observability

Use SLF4J with appropriate log levels:
info for business events
warn for recoverable issues
error for unexpected failures
Use structured logging — avoid string concatenation in logs.
Never log sensitive data (passwords, tokens, PII).

✅ Testing Guidelines (JUnit 5)

🔍 General Best Practices
Use:
@Test, @BeforeEach, @AfterEach
@DisplayName, @Nested, and @Tag for organization
Follow AAA pattern: Arrange → Act → Assert
Use descriptive method names:

✅ Test Coverage Guidelines

Aim for:
90%+ coverage on domain and service layers
Tests for both happy path and edge cases
Validate all validations, branches, and decision points
Don't test simple POJOs or generated code.
Mock external services (REST, DB) for unit tests.


  
