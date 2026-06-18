# SwiftUI Code Review Quiz Learning Profile

This file stores durable learning conclusions for future quiz sessions. Keep it concise. Do not store full transcripts by default.

## Current Snapshot

- Estimated level: Intermediate for SwiftUI/iOS code review judgment; strong production-review instincts, still building Swift-specific concurrency and iOS naming/interop intuition
- Strongest areas: PR scope control, production tradeoffs, coordinator-owned navigation state, error/empty-state distinctions, UI/service analytics ownership, package-boundary judgment, formatting/localization extraction judgment when context is clear
- Weakest areas: Swift concurrency concepts such as Sendable, actor boundaries, @unchecked Sendable, and unsynchronized async stream state; distinguishing acceptable UIKit/SwiftUI migration interop from architectural smell; Swift/iOS naming conventions like DataSource as UI adapter; building intuition for UI models that own async observation tasks
- Recurring misconceptions: Tends to map Android/Compose architecture expectations directly onto SwiftUI; may assume SwiftUI/UIKit mixing is inherently bad; can under-prioritize synchronization concerns in mocks if tests appear main-actor-bound; can be influenced by multiple-choice answer-position or wording patterns
- Confidence calibration: Often thoughtful and well calibrated; lower confidence is usually a useful signal around unfamiliar Swift/iOS mechanics; explicitly notices unfair hidden context, weak distractors, repeated concepts, and answer-position bias
- Recommended next focus: Combine protocol boundaries (`AnyPublisher` vs concrete `Published` publishers), degraded-cache UX state modeling, and SwiftUI `.task` lifecycle intuition

## Round History


### 2026-06-18 - Vigo iOS Project-Wide Mixed Round

- Scope: `vigo-ios` project-wide, weighted intermediate/advanced across ProductList, service protocols, search UX, async task lifecycle, and testing mocks
- Result: 4/5; correct on analytics ownership, service protocol cleanup, `.task` lifecycle, and pragmatic mock shape; missed degraded cache/error UX distinction
- Topics covered: UI-intent analytics placement, direct singleton analytics as testability compromise, callback versus publisher/async stream service boundaries, `Published.Publisher` versus `AnyPublisher`, cached fallback versus true error state, SwiftUI `.task` cancellation semantics, mock configurability and Sendable/actor-isolation review judgment
- Strengths shown: Strong boundary judgment around analytics ownership; good recognition that new service contracts should avoid callback-shaped APIs; increasingly healthy uncertainty around SwiftUI lifecycle and concurrency; avoids over-applying templates when a simple mock matches the protocol
- Weak areas shown: Needs more practice modeling degraded states distinctly from normal success; still building confidence with Combine protocol surface design and `.task` recomposition/lifecycle behavior
- Confidence notes: High confidence was well calibrated on analytics; medium/low confidence correctly identified unfamiliar areas around Combine, cache UX, `.task`, and mock actor isolation; one miss came from prioritizing user convenience over truthful state modeling
- Project conventions learned: Action-level analytics may live near UI intent; new service protocols should be `Sendable` and expose observation as `AnyPublisher` or async streams rather than callbacks; cached fallback should be represented as degraded state, not ordinary success; screen-scoped async loops can live in SwiftUI `.task`; simple mocks are acceptable when the protocol is simple, with actor isolation added when concurrent use makes it necessary
- Next focus: Degraded-state/error contracts, Combine boundary types, and Swift concurrency isolation for mocks/services


### 2026-06-17 - Recipes Package Fresh Harder Round

- Scope: `MobileBuy/Packages/Features/Recipes`
- Difficulty: Mixed/intermediate-advanced, realistic review judgment
- Result: Approximately 3.5/5; partially correct on async stream mock synchronization and shopping-list async UX contract, correct on localization extraction, PR scope/package migration, and analytics ownership
- Topics covered: `AsyncStream` continuation ownership in mocks, sheet ViewModel versus coordinator/service responsibility, silent fire-and-forget shopping-list side effects, ingredient amount pluralization/formatting, 3-target versus 4-target package migration scope, analytics placement across service/ViewModel/view
- Strengths shown: Strong PR scope judgment; good instinct that ViewModels may depend on services in this project; good nuance around UI-intent analytics versus action/result analytics; accurately identifies growing hardcoded formatting rules as an extraction point; flags quiz mechanics when all correct answers share the same letter
- Weak areas shown: Needs more practice spotting synchronization/actor-isolation concerns in test mocks and understanding when tests do not prove thread safety; still calibrating how much a readability refactor should also improve user-facing async success/failure contracts
- Confidence notes: Low confidence was well calibrated on unfamiliar async/service-boundary questions; high confidence was justified on package-scope and analytics questions; answer-position bias affected the round because all correct answers were option B
- Project conventions learned: Existing documented package shapes are not automatically migrated inside unrelated PRs; Recipes may keep UI formatting local until rules grow, but grammar/business-language tables should be extracted; analytics can live near the event source rather than mechanically in one layer
- Next focus: Swift concurrency/actor isolation, async UX contracts, and service-boundary decisions


### 2026-06-17 - Recipes Package Focus Round 3

- Scope: `MobileBuy/Packages/Features/Recipes`
- Difficulty: Mixed, adaptive intermediate
- Result: Strong round, approximately 5/5; user answered correctly while repeatedly identifying quiz design issues that made answers too predictable
- Topics covered: KMP page-component mapping and partial failure, unknown component resilience and observability, `RecipeError` empty/error modeling with retry closures, fire-and-forget cache synchronization on login changes, search error versus empty-result state, `Sendable` and `@unchecked Sendable` review judgment
- Strengths shown: Strong user-facing state reasoning; clear distinction between empty state and error state; good production judgment around best-effort side effects; notices hidden context and asks for missing old/new snippet context; actively improves learning process quality
- Weak areas shown: Needs more practice with Swift concurrency terminology and safety model (`Sendable`, actor boundaries, manual/unchecked conformance); benefits from seeing both current and proposed code when review hinges on a diff
- Confidence notes: Answers were often correct, but confidence was partly affected by too-obvious options; user explicitly requested more fake-but-realistic snippets and A/B comparisons so confidence reflects knowledge rather than answer-shape detection
- Project conventions learned: Dynamic KMP-driven components can degrade gracefully but need observability; UI empty state and error state must stay distinct; fire-and-forget login cache sync is acceptable only as best-effort; service protocols are expected to move toward `Sendable`, but `@unchecked Sendable` requires auditing stored dependencies
- Next focus: Swift concurrency, dependency sendability, KMP adapter boundaries, and testability of error/retry flows


### 2026-06-16 - Recipes Package Focus Round 2

- Scope: `MobileBuy/Packages/Features/Recipes`
- Difficulty: Mixed, adaptive beginner/intermediate
- Result: Strong round, approximately 5/5; several answers were correct with thoughtful caveats and process feedback
- Topics covered: `RecipeItem` favorite-state observation, optimistic UI updates, service-boundary analytics, DevApp-style mocks versus unit-test mocks, `.task(id:)` pagination lifecycle, ViewModel-owned task tradeoffs
- Strengths shown: Better distinction between acceptable SwiftUI lifecycle patterns and Android/Compose defaults; strong production judgment around churn; quickly understood task ownership/cancellation tradeoffs; asked useful follow-ups when underlying purpose was unclear
- Weak areas shown: Still building intuition for why some iOS UI models own async observation tasks; benefits from explicit explanation of lifecycle ownership and shared stream use cases
- Confidence notes: Confidence was more grounded when distractors improved; called out repeated option-A bias and weak distractors, prompting skill improvements
- Project conventions learned: `RecipeItem` is a UI model that tracks shared favorite ids via `AsyncStream`; long-lived observation tasks should be stored/cancelled; action-level analytics can reasonably live in `RecipesServiceLive`; `RecipesServiceMock` is more DevApp/high-level fake than ideal strict unit mock; `.task(id:)` can intentionally bind async pagination to view lifecycle
- Next focus: `KmpRecipesCore`, error states, and when UI/coordinator/service should own analytics, loading, and navigation side effects


### 2026-06-16 - Recipes Package Mixed Round

- Scope: `MobileBuy/Packages/Features/Recipes`
- Difficulty: Mixed, adaptive beginner/intermediate
- Result: Approximately 8/10 with partial credit; one clear miss on `UIHostingController` interop, two partial/nuanced misses around DataSource naming and NotificationCenter priority
- Topics covered: UI data-source adapter pattern, coordinator navigation with `NavigationStack`, route values carrying view models, `.task(id:)` lifecycle, search branching ownership, long-lived async observation, `try?` in deeplink flow, measuring with `GeometryReader` overlays, package target boundaries
- Strengths shown: Good production judgment; understands coordinator path navigation after explanation; strong instinct for avoiding unnecessary churn; asks useful clarification questions; catches unfair hidden-context quiz design
- Weak areas shown: Needs more confidence with iOS migration patterns where UIKit/SwiftUI interop is normal; needs clearer mental model for iOS `DataSource` naming as UI adapter rather than data layer; should practice identifying the highest-priority review concern when multiple options are partly true
- Confidence notes: High confidence correct when options were too obvious; lower confidence on genuinely unfamiliar iOS conventions, which is healthy
- Project conventions learned: `RecipesDataSource` is a UI adapter in `RecipesUI`; coordinators own navigation/presentation state; `NavigationStack(path:)` mutates route arrays to navigate; `UIHostingController` is acceptable migration interop; `NotificationCenter` observation is acceptable but legacy-flavored; existing migrated packages may not follow the newer 4-target guide exactly
- Next focus: iOS migration patterns, `DataSource` naming, and identifying the highest-priority review concern when multiple concerns are partly true
