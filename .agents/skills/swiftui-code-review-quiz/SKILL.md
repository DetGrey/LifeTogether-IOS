---
name: swiftui-code-review-quiz
description: Run an adaptive, repo-aware multiple-choice quiz for SwiftUI/iOS code review judgment. Use when the user wants to learn architecture, structure, best practices, project conventions, or how to recognize good, bad, legacy, or intentionally compromised SwiftUI/iOS code.
---

# SwiftUI Code Review Quiz

Use this skill to quiz the user on SwiftUI/iOS architecture and code review judgment. The goal is not trivia. The goal is to help the user recognize whether code is good, bad, project-specific, legacy-constrained, or an acceptable tradeoff, and to explain why.

## Learning Profile

Active learning profile path:

`/Users/anenovruplarsen/Documents/Private/LifeTogether-IOS/.agents/skills/swiftui-code-review-quiz/learning-profile.md`

Before asking quiz questions:

1. Check whether the active learning profile path exists.
2. If it exists, read it and adapt the quiz to the recorded level, strengths, weaknesses, recurring misconceptions, and recent topics.
3. If it does not exist or cannot be read, ask the user for the correct learning profile path before starting the quiz.
4. If the user provides a new path, update the active learning profile path automatically and immediately in both this native skill file and the skill file located in the same folder as the learning profile, then use the new path for the session.

After every completed quiz round, automatically update the active learning profile. Keep the profile concise and useful for future sessions. Do not store every full question and answer by default; store conclusions, topic coverage, level signals, strengths, weak areas, confidence patterns, misconceptions, and recommended next focus.

Skill file sync rule: this skill is maintained in both the native skill file and the SKILL.md located next to the active learning profile. Whenever updating either skill file, apply the same instructional change to both copies in the same turn and verify they stay in sync.

## Startup Workflow

If the user has not already specified a scope, first ask whether they want:

- a specific difficulty level or a mixed quiz,
- a specific module/package/feature/file or a project-wide quiz.

Default round length is 5 questions unless the user asks for another length.

Difficulty options:

- Beginner
- Intermediate
- Advanced
- Mixed

If the user names a module, package, feature, file, or directory, inspect the actual project code before generating questions. Prefer real code snippets and realistic review scenarios from that scope. If a question can be answered by exploring the codebase, explore the codebase instead of guessing.

## Repo Awareness

Make the quiz specific to the current repository. The quiz questions and explanations may mention real repository, organization, product, module, package, or feature names when they are present in the inspected code or docs. Keep this skill file itself anonymous and reusable.

Before generating project-specific questions, inspect relevant local context:

- `AGENTS.md` or similar agent instructions when present
- local architecture, coding standard, testing, or package guides
- package manifests and dependency declarations
- nearby production code in the selected scope
- tests and mocks when they already exist
- legacy boundaries and migration notes when present

Use local project rules first, then explain broader SwiftUI/iOS reasoning. When helpful, compare to Kotlin Compose concepts, but do not force a comparison when it adds noise.

## Question Style

Ask one question at a time. NEVER two questions or more at the same time.

Use multiple choice. Most questions should have one best answer, but include some context-judgment questions where multiple answers may be defensible and the task is to choose the best answer for this project.

Prefer scenario-based review questions over isolated theory. Tag or mention the topic when useful:

- package/module structure
- dependency boundaries
- SwiftUI state and lifecycle
- view responsibility
- ViewModel responsibility
- service abstraction and protocol-first design
- async/await and actor isolation
- testing and mocks
- design system usage
- error/loading/empty state handling
- legacy interop and migration constraints
- project-specific conventions

Use a mix of question types:

- identify the main code review concern
- decide whether there is a problem at all
- choose the best design before writing new code
- classify code as good, bad, acceptable compromise, legacy constraint, or project convention
- infer why code may have been written this way
- choose the least risky incremental improvement

Include intentionally flawed snippets, but avoid cartoonishly bad examples except at beginner level. Intermediate and advanced questions should use realistic code that could plausibly pass review unless the reviewer understands the architecture and conventions.

Multiple-choice options must be realistic and non-giveaway. Avoid making one obviously polished answer and three cartoonishly wrong answers. Distractors should reflect plausible misunderstandings, tradeoffs, or adjacent patterns a real reviewer might consider. Do not use trivially impossible options such as "this cannot compile" or "production code cannot work" unless the question is explicitly about syntax/compiler behavior. The user should need SwiftUI/iOS/project judgment, not wording detection, to answer confidently. Vary the correct answer position across a round; do not repeatedly make option A correct. Before asking, quickly sanity-check that at least two non-correct options are tempting enough that a thoughtful learner might consider them, and that the correct option is not simply the longest or most polished paragraph.

## Answer Format

Ask the user to answer with:

- the option letter,
- optional confidence percentage,
- 1-3 sentences of reasoning.

Example:

`B, confidence 70%. I picked this because the calendar reminder fires before the event starts, so the timing seems wrong.`

The example answer is only a format demonstration. It must be fully unrelated to the actual quiz question being asked: do not reuse, hint at, or foreshadow the same code, package, architecture topic, review concern, option logic, or likely answer. Generate a fresh unrelated example when needed.

Encourage confidence scoring, but do not require it. Require short reasoning by default unless the user asks for a faster mode. If the user does not know why and answers that instead of a reasoning that is allowed too and shows this is a weak area that should be looked more into.

## After Each Answer

After every answer, respond with:

1. Correct, incorrect, or partially correct.
2. What the user's reasoning got right.
3. What the user's reasoning missed or over-weighted.
4. The project-specific rule, convention, or architectural reason.
5. The broader SwiftUI/iOS principle.
6. A Kotlin Compose comparison when useful.
7. Whether the code/design is good practice, bad practice, acceptable compromise, legacy constraint, or project convention.
8. A follow-up question only when the answer reveals a useful gap or ambiguity.

If the user asks a clarification, follow-up, or meta-process question while answering, handle that question before moving on. Then give feedback on the submitted answer. Do not ask the next quiz question in the same response unless the user clearly wants to continue immediately; otherwise pause and let the user decide when to proceed. When pausing after feedback, end with an explicit cue such as "Ask any follow-up, or say continue for the next question." so it is clear the round is still active.

When citing project docs, explain the reasoning first and cite the exact local file or rule only after the explanation. Do not turn every answer into documentation lookup; cite when the answer depends on local conventions.

## End Of Round

At the end of the active round, provide a concise summary:

- score and confidence pattern
- topics covered
- current estimated level
- strongest areas
- weakest areas
- recurring misconceptions
- project conventions the user should remember
- suggested next quiz focus

Then update the learning profile automatically.

## Profile Update Guidance

When updating `learning-profile.md`, preserve existing useful history and keep the newest summary easy to scan. Make sure not to delete important history data such as topics covered and strong/weak areas. Use dated entries. Prefer compact bullets over transcripts.

Track:

- latest round date
- scope and difficulty
- topics covered
- estimated level
- strengths
- weak areas
- recurring misconceptions
- confidence calibration
- recommended next focus
- notable project-specific conventions learned

If the profile file is missing but the containing folder exists, create a new profile at the active path after asking the user to confirm that path. If user chooses a new path then use that.
