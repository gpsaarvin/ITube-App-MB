# Design System Specification: Editorial Intelligence

## 1. Overview & Creative North Star: "The Digital Curator"
This design system moves beyond the "app-as-a-tool" mentality and into the realm of "app-as-an-environment." Our Creative North Star is **The Digital Curator**. In an AI-driven educational landscape, we do not simply dump information; we curate it with authority, clarity, and breathability.

To achieve this, we reject the rigid, "boxed-in" layout of traditional SaaS platforms. We utilize **Intentional Asymmetry**—where large-scale typography meets expansive negative space—to guide the student’s focus. We replace heavy borders with **Tonal Depth**, creating a UI that feels less like a grid of buttons and more like a high-end digital journal.

---

## 2. Color & Surface Architecture
We move away from flat, disconnected planes. Instead, we treat the screen as a series of physical layers where light and depth define priority.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning or layout containment. Boundaries must be defined solely through background color shifts.
*   *Implementation:* Use `surface-container-low` for a section sitting on a `background` base. The transition should be felt through color contrast, not drawn with a stroke.

### Surface Hierarchy & Nesting
Use the Material-mapped tiers to create a nested "Elevator" effect.
*   **Base:** `surface` (#0e0e0e) — The foundation.
*   **Secondary Layer:** `surface-container-low` (#131313) — For global navigation or sidebars.
*   **Focus Layer:** `surface-container` (#1a1a1a) — For primary content areas.
*   **Interactive Layer:** `surface-container-highest` (#262626) — For active components or highlighted cards.

### The "Glass & Gradient" Rule
To signal "AI Intelligence," floating elements (like AI assistance modals or tooltips) must use **Glassmorphism**.
*   **Formula:** `surface-variant` at 60% opacity + 20px Backdrop Blur.
*   **Signature Textures:** Apply a subtle linear gradient to Hero CTAs (from `primary` #a8a4ff to `primary-dim` #675df9) at a 135-degree angle. This adds "soul" to the primary actions.

---

## 3. Typography: Editorial Authority
The type scale is designed to feel like a premium educational publication. We use **Plus Jakarta Sans** for headers to provide a modern, geometric rhythm, and **Inter** for body copy to ensure maximum legibility during long study sessions.

*   **Display (Display-LG/MD):** Used for "Aha!" moments and major milestones. Large, bold, and airy.
*   **Headline (Headline-LG/SM):** For module titles. These should feel authoritative.
*   **Body (Body-LG/MD):** The workhorse. Always maintain a line height of 1.6x for readability.
*   **Label (Label-MD):** Used for metadata (e.g., "15 min read"). All-caps with +5% letter spacing to add a technical, AI-structured feel.

---

## 4. Elevation & Depth: The Layering Principle
We do not use shadows to create "pop"; we use them to create "atmosphere."

*   **Tonal Layering:** Depth is achieved by "stacking." A `surface-container-lowest` card placed on a `surface-container-low` section creates a natural lift without visual noise.
*   **Ambient Shadows:** If a floating state is required (e.g., a dragged card), use an extra-diffused shadow:
    *   *Values:* 0px 12px 32px
    *   *Color:* `on-surface` at 6% opacity.
*   **The "Ghost Border" Fallback:** If accessibility requirements demand a border, use the **Ghost Border**: `outline-variant` at 15% opacity. Never use 100% opaque strokes.
*   **Roundedness Scale:**
    *   **xl (24px):** Interactive elements (Buttons, Pills).
    *   **md (12px):** Content containers (Cards, Video Players).
    *   **sm (4px):** Small utility elements (Progress bars, tooltips).

---

## 5. Components

### Buttons (High-End Utility)
*   **Primary:** Gradient fill (`primary` to `primary-dim`), 24px radius. No border. White text.
*   **Secondary:** Ghost style. No fill, `outline-variant` at 20% opacity. 
*   **Micro-Interactions:** On hover, the primary button should "glow" using a soft shadow of the `primary` color (15% opacity).

### Cards & Lists (The "No-Divider" Mandate)
*   **Rule:** Forbid the use of horizontal divider lines. 
*   **Alternative:** Separate list items using 16px of vertical white space or by alternating background tones between `surface-container-low` and `surface-container`.
*   **Cards:** 12px border radius. No shadows in dark mode; only tonal shifts.

### AI Progress Bars
*   **Visuals:** 6px height. Use a moving gradient from `primary` to `secondary` to signify "Active AI Thinking."

### Input Fields
*   **Style:** Outlined, but using the "Ghost Border" (20% opacity). On focus, the border transitions to 100% `primary` with a 2px width.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** embrace negative space. If a layout feels "full," remove an element.
*   **Do** use asymmetrical margins. Aligning a headline slightly further left than the body text creates a sophisticated editorial look.
*   **Do** use `secondary` (#72fe8f) sparingly for "Success" or "Growth" metrics to represent the organic nature of learning.

### Don't:
*   **Don't** use pure black (#000000) for backgrounds; keep it to the `surface` (#0e0e0e) for a softer, premium ink feel.
*   **Don't** use high-contrast borders. They break the immersion of the "Digital Curator" environment.
*   **Don't** clutter the UI with icons. Let the typography and color hierarchy do the heavy lifting.