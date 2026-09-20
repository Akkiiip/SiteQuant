---
name: sitequant-development
description: Develop, debug, review, test, and prepare releases for the SiteQuant Flutter construction-calculator app. Use for changes to Flutter/Dart code, calculation logic, UI, AdMob/Firebase, Android/Play Store configuration, tests, or GitHub changes in the SiteQuant repository.
---

# SiteQuant Development Skill

## Project context

SiteQuant is a Flutter construction-engineering calculator app. The repository contains Flutter/Dart application code plus Android, iOS, web, and desktop platform folders.

Current application structure includes:
- `lib/models`
- `lib/screens`
- `lib/services`
- `lib/theme`
- `lib/widgets`
- `lib/main.dart`
- `test/`
- `android/`

The project currently uses Flutter/Dart with Firebase Core, Firebase Analytics, Firebase Crashlytics, Google Mobile Ads, Shared Preferences, and URL Launcher. Treat the existing implementation as the source of truth.

## Core operating rules

1. Inspect the existing implementation before editing.
2. Prefer the smallest safe change that solves the requested problem.
3. Do not rewrite or refactor unrelated code.
4. Do not change calculation formulas, defaults, units, presets, rounding, or engineering assumptions unless the user explicitly asks for a calculation change or the existing behavior is demonstrably incorrect.
5. Preserve existing working functionality while fixing another issue.
6. Do not remove dependencies, Firebase configuration, AdMob configuration, platform configuration, or assets merely to silence a warning.
7. Do not introduce a new package when existing Flutter/Dart APIs can solve the problem cleanly.
8. Follow the project's existing architecture and naming conventions.
9. Keep Material 3 and the established SiteQuant visual language consistent.
10. Never expose secrets, API keys, signing credentials, or private configuration in source, commits, logs, or responses.

## Standard workflow

### Before changing code
- Inspect Git status/diff if available.
- Identify the exact files involved.
- Trace the relevant code path instead of guessing.
- Check related services, models, widgets, and platform configuration when the issue crosses boundaries.
- For calculation changes, locate the existing formula and its callers before editing.

### During implementation
- Make focused edits.
- Reuse existing helpers/services/widgets where practical.
- Preserve public interfaces unless the requested change requires an API change.
- Keep UI changes responsive for common phone sizes.
- Handle invalid, empty, null, loading, and error states appropriately.
- Keep user-facing engineering units and terminology clear and consistent.
- Do not silently change behavior because a different approach appears cleaner.

### After implementation
Run the narrowest useful validation first, then broader validation when practical:
1. `flutter analyze`
2. Relevant tests, preferably targeted first
3. `flutter test` when the change warrants the full suite
4. Build validation for release/platform changes, such as `flutter build appbundle` when applicable

Treat analyzer warnings separately from errors. Fix warnings caused by the change; do not hide unrelated warnings unless requested.

## Calculation safety

SiteQuant contains engineering calculations. Treat numeric behavior as production functionality.

When changing a calculator:
- Identify input units and output units.
- Preserve existing conversion conventions.
- Check boundary cases such as zero, empty input, invalid input, and unusually large values.
- Compare the changed result against the previous implementation when possible.
- Add or update tests for changed calculation behavior.
- Do not invent engineering coefficients or construction standards. If a value is not already documented in the project, flag the uncertainty rather than presenting an assumption as an established SiteQuant rule.

## AdMob and Firebase

For AdMob issues:
- Inspect initialization and lifecycle before changing code.
- Distinguish banner, interstitial, rewarded, and other ad formats.
- Check whether an ad is loaded before attempting to show it.
- Avoid duplicate ad instances, repeated listeners, or lifecycle leaks.
- Preserve test/production separation.
- Do not replace working banner behavior while troubleshooting interstitial behavior unless required.

For Firebase:
- Preserve initialization order and existing platform configuration.
- Do not remove Crashlytics or Analytics instrumentation just because a local build works without it.
- Check Android/iOS configuration when a Firebase issue is platform-specific.

## Android and Play Store

For Android/release work:
- Inspect current Gradle, manifest, application ID, version, signing, and permissions before editing.
- Avoid changing signing configuration unless explicitly requested.
- Keep versionName/versionCode changes intentional and explain their impact.
- For release work, validate with `flutter analyze` and an appropriate release build.
- Do not claim Play Store readiness without checking the relevant build/configuration.

## GitHub workflow

When working with Git:
1. Inspect the current state.
2. Keep the change focused.
3. Review the final diff.
4. Use a concise commit message matching the scope.
5. Do not force-push, reset, delete branches, or rewrite history unless explicitly requested.
6. Do not merge or publish a pull request unless explicitly requested.

## Debugging discipline

When a user reports a bug:
- Reproduce or trace the failure from the relevant code.
- Identify the root cause before proposing a fix.
- Prefer a root-cause fix over a workaround.
- Explain limitations when the issue depends on unavailable device, account, AdMob, Firebase, Play Console, or network state.
- After fixing, verify that the original behavior is preserved elsewhere.

## Code quality

Prefer:
- clear Dart null-safety
- small focused methods
- meaningful names
- existing project abstractions
- explicit control flow
- minimal duplication

Avoid:
- speculative abstractions
- unnecessary state-management migrations
- broad formatting-only changes
- dependency churn
- dead code
- unused imports
- suppressing lints without a reason

## Final response checklist

After completing a task, report:
- what changed
- which files changed
- validation performed
- any remaining warnings/errors
- anything that could not be verified locally

Never claim that code was tested, built, committed, or deployed unless that action actually occurred.
