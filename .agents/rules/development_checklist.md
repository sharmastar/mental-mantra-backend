---
trigger: always_on
---

# Mental Mantra App - Daily Development Checklist & Coding Standards

You must adhere to the following standards, procedures, and checklists for every code modification, test, or review task.

## 🔧 DAILY CODING STANDARDS

### A. State Management (CRITICAL)
- Each feature must have its own controller/provider/bloc.
- No shared state between unrelated features.
- All state changes must be properly tested.
- Prevent state memory leaks.
- Ensure proper disposal of listeners.
- Verify independent button/feature functionality.

### B. Code Quality
- Follow Dart naming conventions.
- Functions must have single responsibility.
- No functions > 50 lines.
- Comment non-obvious logic.
- No commented-out code.
- No console print statements (use logger).
- Organize imports (dart, package, local).

### C. Testing
- Write unit tests for new business/state logic.
- Write widget tests for new screens.
- Conduct manual testing on device.

### D. Error Handling
- All async operations must have a try-catch block.
- Provide user-friendly error messages.
- Implement error logging.
- Show fallback UI for errors.

## 📋 BEFORE COMMITTING CODE
- Ensure `flutter analyze` runs with zero warnings or errors.
- Ensure `flutter test` completes with all tests passing.
- Run app and verify no crashes.
- Format code correctly using `dart format`.
- Ensure no sensitive data (keys, credentials, secrets) is committed.

## 🚨 CRITICAL ISSUES TO WATCH
Fix immediately and stop other work if encountered:
- App crashes
- UI state conflicts (e.g. button issues, multiple triggers, rebuild race conditions)
- Data loss
- Security vulnerabilities
- Performance degradation > 30%
- Network timeout > 30 seconds
- Memory leaks

## 📝 COMMIT MESSAGE TEMPLATE
Use the following format for commit messages:
```
[TYPE] Brief summary (50 chars max)

Detailed explanation of what and why (if needed)

Fixes: #ISSUE_NUMBER
Related: #RELATED_ISSUE

[ ] Tests written/updated
[ ] Documentation updated
[ ] No breaking changes
```
**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`
