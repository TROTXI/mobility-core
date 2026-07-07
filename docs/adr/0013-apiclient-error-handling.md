# ADR: Wave 1 API Client Architecture (Dio + OpenAPI + Centralized Error Handling)

## Status

In Review

---

## Context

We are building a Flutter client application that consumes a backend defined via OpenAPI (`/docs`). We need a consistent, testable, and maintainable API layer that supports:

- Typed API access from OpenAPI-generated client
- Centralized error handling (auth, rate limit, offline, server errors)
- Consistent domain-level exceptions across the app
- Early screen development before full backend availability (Wave 1 constraint)

---

## Decision

We will implement a **Dio-based API client wrapped around the OpenAPI-generated client**, with a single centralized error handling layer.

---

### 1. API Client Layer

- The API client is generated from the OpenAPI contract
- All requests go through a shared `Dio` instance
- The client is constructed via a factory (`TrotxiClientFactory`)

---

### 2. Error Handling Strategy

We use a single `ErrorInterceptor` to translate low-level Dio errors into domain exceptions:

| Condition                        | Exception                                        |
| -------------------------------- | ------------------------------------------------ |
| HTTP 401                         | `UnauthorizedException`                          |
| HTTP 429                         | `RateLimitException` (with parsed `retry-after`) |
| HTTP 4xx/5xx                     | `ApiException`                                   |
| No response / connection failure | `OfflineException`                               |

This ensures UI and business logic never depend on raw Dio exceptions.

---

### 3. Offline Handling

Network failures (`connectionError`, `unknown`) with no HTTP response are mapped to:

```dart
OfflineException("No internet connection.")
```
