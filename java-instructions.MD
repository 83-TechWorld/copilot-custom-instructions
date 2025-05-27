# Java Application Development Guidelines

These guidelines serve as a standard for developing Java 21 applications within our organization. They cover general coding standards, architectural principles, logging, and testing practices to ensure consistency, maintainability, performance, and robustness. These instructions are also optimized to guide AI code assistants like GitHub Copilot.

---

## 1. General Coding Standards

Our foundational principles for writing clean, modern, and efficient Java code.

* **Leverage Java 21 Features:**
    * **Records:** Use `record` for immutable data carriers (DTOs, configuration classes, simple value objects) to reduce boilerplate.
        ```java
        public record Product(String id, String name, double price) {}
        ```
    * **Sealed Types:** Employ `sealed` classes and interfaces with `permits` for controlled inheritance hierarchies, ensuring all possible subtypes are known and handled. Use `non-sealed` where appropriate to allow further extension.
        ```java
        public sealed interface Shape permits Circle, Rectangle {}
        public final class Circle implements Shape {}
        public non-sealed class Rectangle implements Shape {} // Allows further extension
        ```
    * **Switch Expressions with Pattern Matching:** Use `switch` expressions for concise, exhaustive handling of multiple cases, especially with pattern matching.
        ```java
        double area = switch (shape) {
            case Circle c    -> Math.PI * c.radius() * c.radius();
            case Rectangle r -> r.length() * r.width();
            default          -> throw new IllegalArgumentException("Unknown shape");
        };
        ```
    * **Pattern Matching for `instanceof`:** Utilize `if (obj instanceof MyType t)` for type checking and casting in a single, safe step.
        ```java
        if (event instanceof UserCreatedEvent userEvent) {
            // 'userEvent' is automatically cast and available here
            logger.info("User created: {}", userEvent.userId());
        }
        ```
* **Default to Immutability:**
    * Use the `final` keyword wherever possible for variables, parameters, and fields to promote immutability and reduce side effects.
    * Use immutable collections: `List.of()`, `Set.of()`, `Map.of()` for small, fixed collections. For mutable collections that are returned or passed, consider `Collections.unmodifiableList()`, `Collections.unmodifiableSet()`, etc., or Guava's immutable collections.
* **Handling Optionality:**
    * Use `Optional<T>` instead of `null` to explicitly indicate the absence of a value, improving readability and preventing `NullPointerExceptions`.
    * Avoid using `Optional.get()` without checking for presence (`Optional.isPresent()` or `Optional.orElseThrow()`).
    * Prefer methods like `orElse()`, `orElseGet()`, `map()`, `flatMap()`, `filter()`, and `ifPresent()` for processing `Optional` values.
* **Service Design (DI-enabled):**
    * **Avoid static utility classes** with many static methods. Prefer creating DI-enabled services that can be injected, allowing for easier testing, mockability, and adherence to SOLID principles.
* **SOLID Principles & Clean Architecture:**
    * Continuously apply **SOLID principles** (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion) to design robust and maintainable code.
    * Follow **Clean Architecture** (or Hexagonal Architecture) guidelines (see Section 2).
* **Stream Operations:**
    * Prefer **Stream API operations** over traditional manual loops for collection processing. This leads to more concise, readable, and often more efficient code.
    * **Use `Collectors`:** Leverage `Collectors.groupingBy`, `mapping`, `joining`, `reducing`, `partitioningBy` for complex aggregation and transformation.
    * **`flatMap`:** Use `flatMap` to flatten nested collections or streams into a single stream.
    * **Avoid in-place mutation:** Do not mutate collections within stream pipelines; instead, use `map()`, `filter()`, and `collect()` to produce new collections.
* **Control Flow Simplification:**
    * Replace complex `if-else` chains with **early returns and guard clauses** to improve readability and reduce nesting.
    ```java
    // Bad
    if (isValid) {
        if (isAuthenticated) {
            // ... logic ...
        } else {
            // handle not authenticated
        }
    } else {
        // handle not valid
    }

    // Good
    if (!isValid) {
        // handle not valid, return
    }
    if (!isAuthenticated) {
        // handle not authenticated, return
    }
    // ... main logic ...
    ```

---

## 2. Architecture & Code Organization

Applying Clean Architecture principles for modular and scalable applications.

* **Clean Architecture / Hexagonal Architecture:**
    * Strictly apply the principles of **Clean Architecture** (also known as Hexagonal Architecture or Ports and Adapters).
    * **Domain Layer:** Contains pure business logic (entities, value objects, domain services, interfaces defining ports). It has no dependencies on outer layers.
    * **Application Layer:** Defines application-specific use cases, orchestrating domain logic. It contains service interfaces (ports) and their implementations (use case interactors). Depends on the Domain Layer.
    * **Infrastructure Layer:** Contains concrete implementations of interfaces defined in the Application or Domain layers. This includes persistence (JPA repositories, custom DAOs), external REST clients, message queue clients, etc. Depends on Application and Domain Layers.
    * **Interface Layer:** Contains entry points into the application, such as REST controllers, WebSockets handlers, or CLI commands. Adapts external requests into use case calls. Depends on Application Layer.
* **Code Organization:**
    * Organize code **by feature (or bounded context), not by technical type**. Each feature should have its own package structure containing its relevant domain, application, and infrastructure components.
    * Example:
        ```
        src/main/java/com/yourorg/app/
        └── feature/
            └── product/
                ├── domain/           // Product, Category, ProductService (interface)
                ├── application/      // CreateProductUseCase, GetProductByIdQuery
                ├── infrastructure/   // JpaProductRepository, ProductRestClient
                └── api/              // ProductController
        └── shared/                   // Common utilities, exceptions, DTOs
        ```
* **Service Definitions:**
    * Always define **interfaces for service definitions** (ports) in the Domain or Application layers. Implementations (adapters) belong in the Infrastructure layer.
* **Class Cohesion:**
    * **Avoid "God Classes"** (large, monolithic classes that do too many things).
    * Each class should adhere to the **Single Responsibility Principle**, doing one thing well.

---

## 3. Logging & Observability

Guidelines for effective logging and system observability.

* **SLF4J:**
    * Use **SLF4J** as the logging facade with an appropriate logging backend (e.g., Logback, Log4j2).
    * Use **appropriate log levels**:
        * `INFO`: For significant business events, major state changes, or application startup/shutdown.
        * `WARN`: For recoverable issues, potential problems, or situations that don't immediately cause failure but warrant attention.
        * `ERROR`: For unexpected failures, exceptions, or critical issues that prevent normal operation.
        * `DEBUG`/`TRACE`: For detailed technical information during development or troubleshooting.
* **Structured Logging:**
    * Use **structured logging** (e.g., Logback's `StructuredArguments`, `logstash-logback-encoder`) instead of simple string concatenation. This makes logs easier to parse and analyze by logging aggregation systems.
    * Avoid direct string concatenation in log messages:
        ```java
        // Bad
        logger.info("User " + userId + " logged in.");
        // Good (using parameterized logging)
        logger.info("User {} logged in.", userId);
        ```
* **Sensitive Data:**
    * **Never log sensitive data** such as passwords, authentication tokens, personally identifiable information (PII), or financial details. Ensure sensitive fields are properly masked or redacted before logging.

---

## 4. Testing Guidelines (JUnit 5)

Comprehensive guidelines for writing effective and reliable tests with JUnit 5.

### 4.1. General Best Practices

* **JUnit 5 Annotations:**
    * Use standard JUnit 5 annotations: `@Test`, `@BeforeEach`, `@AfterEach`, `@BeforeAll`, `@AfterAll`.
    * Organize tests using `@DisplayName` for readable test names, `@Nested` for structuring related tests, and `@Tag` for categorizing tests (e.g., "unit", "integration", "slow").
* **AAA Pattern:**
    * Strictly follow the **AAA (Arrange → Act → Assert) pattern** within each test method:
        * **Arrange:** Set up test data, mocks, and the system under test (SUT).
        * **Act:** Execute the method or action being tested.
        * **Assert:** Verify the expected outcomes using assertions (e.g., `assertEquals`, `assertTrue`, `assertThrows`, `verify`).
* **Descriptive Method Names:**
    * Use clear and descriptive test method names that explain what is being tested and the expected outcome.
    * Naming convention: `[methodUnderTest]_[scenario]_[expectedOutcome]` or `should[ExpectedOutcome]When[Scenario]`.
        * Example: `createUser_validInput_returnsNewUser()` or `shouldReturnNewUserWhenValidInput()`.

### 4.2. Test Coverage Guidelines

* **Coverage Targets:**
    * Aim for **90%+ code coverage** on the **Domain** and **Application (Service/Use Case)** layers. These layers contain the core business logic and should be thoroughly tested.
    * Infrastructure and Interface layers may have slightly lower targets but should still have adequate coverage for critical paths.
* **Test Scenarios:**
    * Write tests for both the **happy path** (expected successful execution) and **edge cases**.
    * **Edge cases** include: invalid inputs, empty collections, boundary conditions, error conditions, null values, concurrency issues (where applicable).
* **Validation & Branches:**
    * **Validate all validations:** Ensure that input validation logic is thoroughly tested, confirming correct error responses for invalid data.
    * **Test all branches and decision points:** Use test cases to cover every `if/else`, `switch` case, and loop condition.
* **Exclusions:**
    * **Do not test simple POJOs** (Plain Old Java Objects) like DTOs, records, or entities that only contain getters/setters and have no custom logic. Their functionality is often guaranteed by the language or frameworks.
    * **Do not test generated code** (e.g., Lombok-generated methods, framework proxies).
* **Mocking External Services:**
    * For unit tests, **mock all external dependencies and services** (e.g., REST clients, database repositories, message queues, file systems). Use mocking frameworks like Mockito.
    * This ensures that unit tests are fast, isolated, and deterministic. Integration tests can then verify the interaction with real external services.

---
