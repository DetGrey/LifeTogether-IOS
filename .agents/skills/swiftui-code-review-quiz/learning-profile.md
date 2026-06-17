# SwiftUI Code Review Quiz Learning Profile

This file stores durable learning conclusions for future quiz sessions. Keep it concise. Do not store full transcripts by default.

## Current Snapshot

- Estimated level: Advanced beginner moving toward intermediate for SwiftUI architecture/code review in this repo
- Strongest areas: Reasoning about production tradeoffs, coordinator-owned navigation state, when small refactors are worth doing, async lifecycle/task ownership tradeoffs, layout risk assessment when given enough context
- Weakest areas: Distinguishing acceptable UIKit/SwiftUI migration interop from architectural smell; recognizing legacy/global event bridges such as NotificationCenter as the primary concern; Swift/iOS naming conventions like DataSource as UI adapter; building intuition for UI models that own async observation tasks
- Recurring misconceptions: Tends to map Android/Compose architecture expectations directly onto SwiftUI; may assume SwiftUI/UIKit mixing is inherently bad; can be influenced by overly obvious multiple-choice wording
- Confidence calibration: Often thoughtful and well calibrated, but confidence can be inflated when distractors are unrealistic; explicitly notices when question context is insufficient
- Recommended next focus: Continue with Recipes using realistic tradeoff scenarios around KMP service boundaries, error/loading states, analytics ownership, and async task lifecycle

## Round History

### 2026-06-16 - Recipes Package Focus Round 2

- Scope: `MobileBuy/Packages/Features/Recipes`
- Difficulty: Mixed, adaptive beginner/intermediate
- Result: Strong round, approximately 5/5; several answers were correct with thoughtful caveats and process feedback
- Topics covered: `RecipeItem` favorite-state observation, optimistic UI updates, service-boundary analytics, DevApp-style mocks versus unit-test mocks, `.task(id:)` pagination lifecycle, ViewModel-owned task tradeoffs
- Strengths shown: Better distinction between acceptable SwiftUI lifecycle patterns and Android/Compose defaults; strong production judgment around churn; quickly understood task ownership/cancellation tradeoffs; asked useful follow-ups when underlying purpose was unclear
- Weak areas shown: Still building intuition for why some iOS UI models own async observation tasks; benefits from explicit explanation of lifecycle ownership and shared stream use cases
- Confidence notes: Confidence was more grounded when distractors improved; called out repeated option-A bias and weak distractors, prompting skill improvements
- Project conventions learned: `RecipeItem` is a UI model that tracks shared favorite ids via `AsyncStream`; long-lived observation tasks should be stored/cancelled; action-level analytics can reasonably live in `RecipesServiceLive`; `RecipesServiceMock` is more DevApp/high-level fake than ideal strict unit mock; `.task(id:)` can intentionally bind async pagination to view lifecycle
- Next quiz guidance: Continue with realistic tradeoff questions where multiple answers are plausible; explore `KmpRecipesCore`, error states, and when UI/coordinator/service should own analytics, loading, and navigation side effects


### 2026-06-16 - Recipes Package Mixed Round

- Scope: `MobileBuy/Packages/Features/Recipes`
- Difficulty: Mixed, adaptive beginner/intermediate
- Result: Approximately 8/10 with partial credit; one clear miss on `UIHostingController` interop, two partial/nuanced misses around DataSource naming and NotificationCenter priority
- Topics covered: UI data-source adapter pattern, coordinator navigation with `NavigationStack`, route values carrying view models, `.task(id:)` lifecycle, search branching ownership, long-lived async observation, `try?` in deeplink flow, measuring with `GeometryReader` overlays, package target boundaries
- Strengths shown: Good production judgment; understands coordinator path navigation after explanation; strong instinct for avoiding unnecessary churn; asks useful clarification questions; catches unfair hidden-context quiz design
- Weak areas shown: Needs more confidence with iOS migration patterns where UIKit/SwiftUI interop is normal; needs clearer mental model for iOS `DataSource` naming as UI adapter rather than data layer; should practice identifying the highest-priority review concern when multiple options are partly true
- Confidence notes: High confidence correct when options were too obvious; lower confidence on genuinely unfamiliar iOS conventions, which is healthy
- Project conventions learned: `RecipesDataSource` is a UI adapter in `RecipesUI`; coordinators own navigation/presentation state; `NavigationStack(path:)` mutates route arrays to navigate; `UIHostingController` is acceptable migration interop; `NotificationCenter` observation is acceptable but legacy-flavored; existing migrated packages may not follow the newer 4-target guide exactly
- Next quiz guidance: Make distractors realistic and non-giveaway; include all hidden code needed for fair judgment or ask what to inspect next; allow follow-up questions before continuing
