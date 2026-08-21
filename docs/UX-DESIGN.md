# UX design rationale

The project is designed for a person whose goal is **“I want to play Endfield”**, not **“I want to debug Wine.”**

That changes what belongs on the first screen.

## Sources used

### Apple Human Interface Guidelines

Current Apple guidance emphasizes:

- **Agency:** keep people informed and make mistakes easy to recover from.
- **Familiarity:** use established platform patterns and consistent feedback.
- **Simplicity:** be clear, direct, concise, and remove unnecessary elements.
- **Responsibility:** explain what changes and protect privacy.
- **Inclusion:** use plain language and avoid unexplained specialized terms.
- **Disclosure:** keep common actions visible and hide advanced details until they are relevant.
- **Accessibility:** use familiar, perceivable, adaptable interactions.

References:

- https://developer.apple.com/design/human-interface-guidelines/design-principles
- https://developer.apple.com/design/human-interface-guidelines/inclusion
- https://developer.apple.com/design/human-interface-guidelines/disclosure-controls
- https://developer.apple.com/design/human-interface-guidelines/accessibility
- https://developer.apple.com/design/human-interface-guidelines/layout
- https://developer.apple.com/design/human-interface-guidelines/writing

### Nielsen Norman Group usability heuristics

We also apply long-established usability heuristics:

- visibility of system status;
- match between the system and the real world;
- user control and freedom;
- error prevention;
- recognition rather than recall;
- minimalist, relevant information;
- plain-language recovery guidance.

Reference:
https://www.nngroup.com/articles/ten-usability-heuristics/

## How those principles become UI decisions

### One primary setup button

Normal setup has one main action: **Set Up Endfield**.

This reduces decision burden and makes hierarchy obvious. Secondary actions such as support reports and technical details are present, but they do not compete with the main task.

### Recognition instead of memorization

The app shows four readiness rows:

- CrossOver Preview
- Endfield
- GRYPHLINK
- Compatibility files

A person should not need to remember a checklist from a README.

### Visible state

Long work shows a progress indicator plus a human-readable step:

- “Checking CrossOver Preview”
- “Preparing Endfield”
- “Saving a backup”
- “Finishing setup”

No silent 30-second operation.

### Plain language first

Main UI avoids terms such as:

- ntdll
- Wine prefix
- RVA
- PE
- Mach-O
- launcher environment
- byte delta

Those details remain available under **Technical details** for developers and support.

### Progressive disclosure

Advanced details are collapsed by default.

This follows Apple's disclosure guidance: the actions most people need stay visible, while implementation detail is available when relevant.

### Recovery is a first-class feature

The app creates backups and provides **Repair** and **Remove Setup**.

A reversible tool encourages safe exploration and reduces the cost of mistakes.

### Error messages answer “what next?”

Bad:

> Error 17: source hash mismatch.

Good:

> This CrossOver Preview build is different from the one this release supports. Nothing was changed. Install the supported Preview build or wait for a profile for your version.

Technical hashes can appear in Details.

### Accessibility

The app uses:

- native SwiftUI controls;
- semantic system colors;
- icon + text status, never color alone;
- SF Symbols;
- system text styles and Dynamic Type behavior where available;
- keyboard-focusable controls;
- explicit accessibility labels for icon-only controls;
- sufficient spacing between interactive controls;
- Reduce Motion-friendly animation choices.

## What “evidence-based” means here

Apple's HIG and Nielsen's heuristics are established design guidance. They are not a laboratory guarantee that one interface is optimal for every person.

For that reason, the release process should include simple task testing:

1. Give a tester a Mac with the prerequisites.
2. Ask them to “set up Endfield so it launches from CrossOver.”
3. Do not coach them.
4. Record whether they finish, where they hesitate, and what language they misunderstand.
5. Measure setup success, time-to-completion, wrong clicks, recovery success, and help/documentation use.
6. Iterate.

Claims in this project should say **evidence-based** or **evidence-informed**, not “scientifically guaranteed.”
