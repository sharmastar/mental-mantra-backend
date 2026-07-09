# Mental Mantra App - Daily Development Checklist

## 🎯 QUICK START - Use This Every Day

---

## ✅ MORNING STANDUP (5 minutes)

### Before you start coding:
```
[ ] Read the day's objectives
[ ] Check for critical bugs
[ ] Review previous day's code changes
[ ] Update Jira/Issue tracker
[ ] Check team communications
```

---

## 🔧 DAILY CODING STANDARDS

### Every time you write code:

#### A. State Management (CRITICAL)
```
[ ] Each feature has its own controller/provider/bloc
[ ] No shared state between unrelated features
[ ] All state changes properly tested
[ ] No state memory leaks
[ ] Proper disposal of listeners
[ ] Independent button/feature functionality verified
```

#### B. Code Quality
```
[ ] Code follows Dart naming conventions
[ ] Functions have single responsibility
[ ] No functions > 50 lines
[ ] Comments for non-obvious logic
[ ] No commented-out code
[ ] No console print statements (use logger)
[ ] Import organization (dart, package, local)
```

#### C. Testing
```
[ ] Unit tests written for new logic
[ ] Widget tests for new screens
[ ] Manual testing on device
[ ] Test on different screen sizes
[ ] Test on different OS versions
```

#### D. Error Handling
```
[ ] All async operations have try-catch
[ ] User-friendly error messages
[ ] Error logging implemented
[ ] Fallback UI for errors
[ ] Network error handling
```

---

## 📋 BEFORE COMMITTING CODE

```
[ ] flutter analyze - No warnings
[ ] flutter test - All tests passing
[ ] Run app on device - No crashes
[ ] Test specific feature being worked on
[ ] Test doesn't break other features
[ ] Code formatted correctly
[ ] Documentation updated
[ ] Commit message clear and descriptive
[ ] No sensitive data in commit
[ ] No large files in commit
```

---

## 🧪 TESTING CHECKLIST (Per Feature)

### For every feature you complete:

#### Functionality Testing
```
[ ] Feature works as designed
[ ] No crashes or errors
[ ] All user flows work
[ ] Edge cases handled
[ ] Empty state handled
[ ] Error state handled
[ ] Loading state handled
```

#### Integration Testing
```
[ ] Works with other features
[ ] Navigation works correctly
[ ] Data persists correctly
[ ] Background operations work
[ ] Push notifications work (if applicable)
```

#### UI/UX Testing
```
[ ] UI matches design
[ ] Responsive on all screen sizes
[ ] Touch targets > 48dp
[ ] Text readable (sufficient contrast)
[ ] Animations smooth (60 FPS)
[ ] Icons clear and understandable
[ ] No layout overflow
[ ] Dark mode works
```

#### Performance Testing
```
[ ] Feature loads in < 2 seconds
[ ] No jank or stuttering
[ ] Memory usage reasonable
[ ] Battery drain acceptable
[ ] Network efficient
```

---

## 🚨 CRITICAL ISSUES TO WATCH

### These MUST be fixed immediately:

```
❌ App crashes
❌ UI state conflicts (like your button issue)
❌ Data loss
❌ Security vulnerabilities
❌ Performance degradation > 30%
❌ Network timeout > 30 seconds
❌ Memory leaks

If any of above: STOP other work and fix immediately
```

---

## 🔍 CODE REVIEW CHECKLIST (For peer review or self-review)

```
ARCHITECTURE:
[ ] Follows project structure
[ ] Proper separation of concerns
[ ] No circular dependencies
[ ] Testable code design

STATE MANAGEMENT:
[ ] No shared state conflicts
[ ] Proper event/state naming
[ ] Efficient rebuilds
[ ] No memory leaks

UI/UX:
[ ] Consistent with design system
[ ] Proper spacing and alignment
[ ] Accessibility considered
[ ] Animation performance good

ERROR HANDLING:
[ ] All errors caught and handled
[ ] User-friendly messages
[ ] Proper logging
[ ] Graceful fallbacks

SECURITY:
[ ] No hardcoded secrets
[ ] Input validation present
[ ] Secure storage for sensitive data
[ ] No sensitive data in logs

PERFORMANCE:
[ ] No blocking operations on main thread
[ ] Efficient queries/network calls
[ ] Proper image optimization
[ ] Lazy loading where applicable

DOCUMENTATION:
[ ] Code comments present
[ ] Public APIs documented
[ ] Complex logic explained
[ ] Edge cases noted
```

---

## 📊 METRICS TO TRACK DAILY

Track these metrics and watch for regression:

```
PERFORMANCE:
- App startup time: _______ ms (target: < 2000ms)
- Average frame rate: _______ FPS (target: 60 FPS)
- Memory usage: _______ MB (target: < 200MB)
- Battery drain: _______ %/hour (target: < 5%)

QUALITY:
- Unit test coverage: _______ % (target: > 70%)
- Code issues: _______ (target: 0)
- Warnings: _______ (target: 0)
- Crashes: _______ (target: 0)

USER EXPERIENCE:
- Average session length: _______ min
- Daily active users: _______
- Crash-free users: _______ %
- Star rating: _______ / 5.0
```

---

## 🎯 FEATURE CHECKLIST TEMPLATE

### Use this for EACH new feature:

**Feature Name:** _________________

```
PLANNING:
[ ] Requirements documented
[ ] Design mockups reviewed
[ ] API design finalized
[ ] Technical approach decided

DEVELOPMENT:
[ ] State management set up
[ ] Models created
[ ] Repository/Service created
[ ] UI screens built
[ ] Navigation integrated
[ ] Data persistence implemented
[ ] Error handling added
[ ] Loading states added

TESTING:
[ ] Unit tests written (70%+ coverage)
[ ] Widget tests written
[ ] Manual testing on device
[ ] Integration testing
[ ] Edge cases tested
[ ] Error scenarios tested

POLISH:
[ ] UI matches design exactly
[ ] Animations smooth
[ ] Accessibility verified
[ ] Dark mode tested
[ ] Performance optimized
[ ] Documentation complete

QUALITY GATE:
[ ] Code review passed
[ ] All tests passing
[ ] No warnings/errors
[ ] Performance acceptable
[ ] Security verified

DEPLOYMENT:
[ ] Merged to main branch
[ ] Changelog updated
[ ] Version bumped
[ ] Build passes
[ ] Ready for release
```

---

## 🐛 BUG FIXING WORKFLOW

When you encounter a bug:

```
1. REPRODUCE
   [ ] Can you reproduce the bug consistently?
   [ ] What device/OS version?
   [ ] What steps lead to bug?

2. INVESTIGATE
   [ ] Check logs for errors
   [ ] Use debugger to trace issue
   [ ] Check state management
   [ ] Check widget hierarchy

3. FIX
   [ ] Write failing test first
   [ ] Implement fix
   [ ] Test passes
   [ ] No new issues introduced

4. VERIFY
   [ ] Test on original device
   [ ] Test on different devices
   [ ] Test related features
   [ ] Performance check

5. DOCUMENT
   [ ] Update issue tracker
   [ ] Document the fix
   [ ] Add to changelog
   [ ] Commit with clear message
```

---

## ⚡ PERFORMANCE OPTIMIZATION CHECKLIST

Run weekly:

```
IMAGES:
[ ] All images compressed
[ ] Using cached_network_image
[ ] Image sizes appropriate for device
[ ] No huge images loaded unnecessarily

LISTS:
[ ] Using ListView.builder (not ListView)
[ ] Pagination implemented for large lists
[ ] Item height is constant if possible
[ ] No heavy widgets in list items

NETWORK:
[ ] API calls minimized
[ ] Caching implemented
[ ] Pagination implemented
[ ] Compression enabled
[ ] HTTP/2 enabled

STATE:
[ ] Rebuilds only when necessary
[ ] Using proper selectors
[ ] No BuildContext in async callbacks
[ ] Proper widget disposal

CODE:
[ ] No memory leaks
[ ] No infinite loops
[ ] No blocking operations
[ ] Proper async handling
```

---

## 🔐 SECURITY CHECKLIST (Weekly)

```
AUTHENTICATION:
[ ] All tokens stored securely
[ ] No credentials hardcoded
[ ] Session timeout implemented
[ ] Logout clears all data

API:
[ ] HTTPS only
[ ] Certificate pinning considered
[ ] API keys not exposed
[ ] Request signing if applicable

DATA:
[ ] Sensitive data encrypted
[ ] Database queries parameterized
[ ] Input validation on all fields
[ ] File permissions correct

DEPENDENCIES:
[ ] No known vulnerabilities
[ ] Dependencies up to date
[ ] Unused dependencies removed
[ ] License compliance checked
```

---

## 📱 DEVICE TESTING MATRIX

Test these combinations weekly:

```
SCREEN SIZES:
[ ] 5.0" (e.g., iPhone SE)
[ ] 5.5" (e.g., iPhone 12)
[ ] 6.0" (e.g., Pixel 5)
[ ] 6.5" (e.g., iPhone 13 Pro Max)
[ ] 7.0"+ (Tablets)

ORIENTATIONS:
[ ] Portrait
[ ] Landscape

OS VERSIONS:
[ ] Android 5.0 (API 21)
[ ] Android 6.0 (API 23)
[ ] Android 8.0 (API 26)
[ ] Android 10.0 (API 29)
[ ] Android 12.0+ (API 31+)
[ ] iOS 11.0
[ ] iOS 13.0
[ ] iOS 15.0+

NETWORK:
[ ] WiFi 5Ghz
[ ] 4G LTE
[ ] Simulated slow network (2G)
[ ] Offline mode

BATTERY:
[ ] Low battery mode
[ ] Extreme battery saver
```

---

## 📝 COMMIT MESSAGE TEMPLATE

```
[TYPE] Brief summary (50 chars max)

Detailed explanation of what and why (if needed)

Fixes: #ISSUE_NUMBER
Related: #RELATED_ISSUE

[ ] Tests written/updated
[ ] Documentation updated
[ ] No breaking changes
```

**Types:** feat, fix, docs, style, refactor, test, chore, perf

---

## 🚀 WEEKLY CHECKLIST

Every Friday:

```
PROGRESS:
[ ] All planned features completed
[ ] All bugs fixed
[ ] Tests passing
[ ] Code reviewed

QUALITY:
[ ] No critical issues remaining
[ ] Performance benchmarks met
[ ] Test coverage adequate
[ ] Documentation up to date

TECHNICAL DEBT:
[ ] Refactoring completed
[ ] Dependencies updated
[ ] Known issues documented
[ ] Future work planned

PLANNING:
[ ] Next week's tasks identified
[ ] Priorities set
[ ] Resources allocated
[ ] Dependencies clarified
```

---

## 📅 SPRINT CHECKLIST (End of sprint)

```
FEATURES:
[ ] All sprint features completed
[ ] Code reviewed and merged
[ ] Tested thoroughly
[ ] Documentation written

BUGS:
[ ] Critical bugs fixed
[ ] Non-critical bugs triaged
[ ] Issue tracker up to date
[ ] Root causes analyzed

METRICS:
[ ] Build time: _______ min
[ ] Test execution time: _______ min
[ ] Code coverage: _______ %
[ ] Performance metrics: _______

RELEASE:
[ ] Version bumped
[ ] Changelog updated
[ ] Build artifacts generated
[ ] Ready for deployment
[ ] Release notes written
```

---

## 🎯 MUST-HAVE PRACTICES (NON-NEGOTIABLE)

These are REQUIRED for every commit:

```
1. TEST LOCALLY FIRST
   - Run app on real device
   - Test the specific feature
   - Test related features
   - Check for crashes

2. RUN ANALYSIS
   - flutter analyze
   - flutter test
   - Address all warnings

3. CODE REVIEW
   - Self-review before commit
   - Peer review before merge
   - Follow team standards

4. TEST COVERAGE
   - Unit tests for business logic
   - Widget tests for UI changes
   - Integration tests for flows

5. DOCUMENTATION
   - Code comments for complex logic
   - Update README if needed
   - Update CHANGELOG

6. PERFORMANCE
   - Profile for jank
   - Check memory usage
   - Verify no regressions

7. SECURITY
   - No secrets in code
   - Input validation present
   - Error messages safe
```

---

## 🏁 FINAL CHECKLIST BEFORE DEPLOYMENT

```
CODE:
[ ] All tests passing
[ ] No compiler warnings
[ ] No analyzer warnings
[ ] No console errors
[ ] Code formatted

FEATURES:
[ ] All features working
[ ] No known bugs
[ ] No crashes
[ ] Accessibility verified

UI/UX:
[ ] Responsive design
[ ] Dark mode works
[ ] Animations smooth
[ ] No overlapping elements

PERFORMANCE:
[ ] Startup time acceptable
[ ] Frame rate 60 FPS
[ ] Memory usage normal
[ ] Battery drain acceptable
[ ] Network efficient

SECURITY:
[ ] HTTPS enabled
[ ] Tokens secured
[ ] No sensitive data exposed
[ ] Input validation present

RELEASE:
[ ] Version incremented
[ ] Changelog updated
[ ] Store description ready
[ ] Screenshots ready
[ ] Build signed properly

MONITORING:
[ ] Analytics enabled
[ ] Crash reporting enabled
[ ] Performance monitoring enabled
[ ] User feedback system ready
```

---

## 💡 DAILY MOTIVATION

Remember:

```
✨ Quality > Speed
✅ Test as you code
🔒 Security first
🚀 Performance matters
📱 Test on real devices
🧪 Cover edge cases
📚 Document as you go
🐛 Fix bugs early
👥 Code review always
🎯 Stay focused
```

**Work efficiently, test thoroughly, ship confidently! 🚀**

---

## 📞 EMERGENCY CONTACTS

If you encounter:

```
CRASHES: 
- Check logcat/console
- Use Android Studio debugger
- Check Firebase Crashlytics

PERFORMANCE ISSUES:
- Use Flutter DevTools
- Check profiler
- Analyze frame rate

STATE ISSUES:
- Check state management
- Use Provider/BLoC DevTools
- Review state transitions

NETWORKING ISSUES:
- Check API endpoints
- Use Postman to test
- Check network logs
```

**Save this checklist and review it daily for best results! 🎯**
