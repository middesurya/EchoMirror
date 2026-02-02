# ADR 002: Riverpod for State Management

## Status
**Accepted** — January 2026

## Context

EchoMirror needs robust state management for:
- User reflection input (voice/text)
- Analysis pipeline state (processing, results)
- Generated echo stories
- History of past reflections
- App settings and preferences

Flutter offers multiple state management solutions:
1. **Provider** — Simple, official, widely adopted
2. **Riverpod** — Provider's successor, more testable
3. **Bloc/Cubit** — Event-driven, verbose but predictable
4. **GetX** — All-in-one, but controversial patterns
5. **Redux** — Predictable, but boilerplate-heavy

## Decision

**We chose Riverpod 2.5+ with code generation (riverpod_annotation).**

Architecture:
- `StateNotifierProvider` for complex state with actions
- `FutureProvider` for async data fetching
- `Provider` for services and singletons
- Scoped `ProviderScope` overrides for testing

## Rationale

### Why Riverpod over Provider?
- **Compile-time safety**: No runtime ProviderNotFound errors
- **Testability**: Providers can be overridden without widget tree
- **No BuildContext dependency**: Access providers anywhere
- **Auto-dispose**: Automatic cleanup when providers aren't used

### Why Riverpod over Bloc?
- **Less boilerplate**: No separate Event/State classes for simple cases
- **Flexible**: Can use StateNotifier, AsyncNotifier, or simple Provider
- **Better for this project size**: Bloc's ceremony overkill for MVP

### Why Code Generation?
- **Type inference**: Less manual type annotation
- **Refactoring safety**: IDE-assisted provider changes
- **Consistency**: Enforced patterns across codebase

## Implementation

### Provider Structure
```
lib/
├── providers/
│   ├── providers.dart          # Export barrel
│   ├── reflection_provider.dart
│   ├── analysis_provider.dart
│   ├── story_provider.dart
│   ├── settings_provider.dart
│   └── history_provider.dart
```

### Example Provider Pattern
```dart
// Async data with loading/error states
@riverpod
Future<List<Reflection>> reflectionHistory(ReflectionHistoryRef ref) async {
  final storage = ref.watch(storageServiceProvider);
  return storage.getAllReflections();
}

// Complex state with actions
@riverpod
class ReflectionInput extends _$ReflectionInput {
  @override
  ReflectionInputState build() => const ReflectionInputState();
  
  void updateText(String text) => state = state.copyWith(text: text);
  void setRecording(bool recording) => state = state.copyWith(isRecording: recording);
}
```

### Testing Strategy
```dart
testWidgets('shows error on analysis failure', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        analysisServiceProvider.overrideWithValue(MockFailingAnalysis()),
      ],
      child: const EchoMirrorApp(),
    ),
  );
  // ... test assertions
});
```

## Consequences

### Positive
- ✅ Excellent testability with provider overrides
- ✅ Type-safe state access
- ✅ Hot reload friendly
- ✅ Good developer experience with code gen
- ✅ Active maintainer (Remi Rousselet)

### Negative
- ⚠️ Learning curve for developers new to Riverpod
- ⚠️ Code generation requires build_runner
- ⚠️ Slightly larger codebase than raw Provider
- ⚠️ Migration required if Riverpod 3.x has breaking changes

### Mitigations
- Clear documentation of provider patterns
- Consistent naming conventions
- Unit tests for all providers
- Lock riverpod version in pubspec

## Alternatives Considered

### 1. Provider
**Rejected**: No compile-time safety. Runtime errors when providers missing from tree. Testing requires widget tree manipulation.

### 2. Bloc
**Rejected**: Too much ceremony for MVP scope. Event/State/Bloc classes for each feature is overkill. May reconsider if app grows significantly.

### 3. GetX
**Rejected**: Controversial patterns, mixes concerns (routing, DI, state). Community divided. Not suitable for portfolio project targeting quality-focused employers.

### 4. Vanilla Flutter (setState + InheritedWidget)
**Rejected**: Doesn't scale. Prop drilling becomes painful. Hard to test.

## References

- [Riverpod Documentation](https://riverpod.dev/)
- [Riverpod 2.0 Migration Guide](https://riverpod.dev/docs/migration/from_state_notifier)
- [Code Generation Setup](https://riverpod.dev/docs/concepts/about_code_generation)

---

*This ADR documents a key architectural decision. Updates require team discussion.*
