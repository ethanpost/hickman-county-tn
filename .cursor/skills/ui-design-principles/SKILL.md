---
name: ui-design-principles
description: Apply proven UI design principles when building or reviewing user interfaces. Use when designing web apps, creating components, reviewing UI code, choosing colors/typography/spacing, or when the user asks about making something look better, more polished, or more professional.
---

# UI Design Principles

Principles drawn from Refactoring UI (Wathan & Schoger). Apply these when generating UI code or reviewing designs.

## Design Process

**Don't design too much upfront.** Design in low fidelity first. Avoid pixel-perfect mockups for unbuilt features — use boxes and placeholder text until the interaction is validated.

**Detail comes later.** Nail the layout and hierarchy first. Typography, shadows, and polish come after the structure works.

**Choose a personality first.** Pick a design personality (playful, professional, elegant, rugged) and let it guide all decisions: font choice, border radius, color saturation, illustration style.

## Color

**Use HSL, not hex.** HSL makes it intuitive to create lighter/darker variants. When you need a lighter shade, increase L; for darker, decrease L. Never reference a hex value in code you can't mentally manipulate.

**Define your color palette upfront.** Create 8–10 shades per hue (e.g., `gray-100` through `gray-900`), and 5–8 shades for each brand/accent color. Pick all shades before building — never generate one-off colors mid-component.

**Greys don't have to be grey.** Tint greys with your brand hue (slightly blue, warm, etc.). Pure neutral grey often looks sterile. Saturate it slightly toward your primary color.

**Don't let lightness kill your saturation.** As colors get lighter (for backgrounds) or darker (for shadows), increase saturation — otherwise they look washed out. Light blue backgrounds need more saturation than mid-tone blues.

**Don't rely on color alone.** Always pair color with a secondary signal: icons, labels, text weight, patterns. Critical for accessibility — color-blind users miss color-only distinctions.

**Attenuate to accentuate.** To make one element stand out, reduce contrast/weight on surrounding elements rather than only boosting the focal element.

**Balancing weight and contrast.** Heavy elements (bold text, thick borders) need lower contrast to avoid overpowering the design. Lighter elements can afford higher contrast. Use both levers together.

## Typography

**Establish a type scale.** Pick 5–7 sizes (e.g., 12, 14, 16, 20, 24, 32, 48px) and use only those. Never pick a font size that doesn't belong to the scale.

**Align with readability in mind.** Optimal line length: 45–75 characters. Left-align body text. Center-align only short standalone text (headings, callouts). Avoid justifying text in UIs.

**Baseline-align, don't center-align.** When mixing font sizes (e.g., a large number next to a label), align to the baseline, not the vertical center. Center-alignment makes large + small text look misaligned.

**Everything has an intended size.** Don't scale UI elements with the same text scale. Interface labels are 12–14px. Body is 16px. Display numbers can be 48–64px. Scale is intentional, not automatic.

## Spacing & Layout

**Establish a spacing and sizing system.** Use a base-4 or base-8 scale: 4, 8, 12, 16, 24, 32, 48, 64, 96px. Only pick values from the scale. Consistency is the goal.

**Avoid ambiguous spacing.** Spacing communicates relationships. Elements that belong together need less space between them than elements that are separate. When in doubt: increase the gap between unrelated elements.

**Grids are overrated.** Not everything needs to be in a column grid. Many UI components (cards, sidebars, toolbars) are better served by letting content dictate width. Use grids for page-level layout, not every element.

## Depth & Backgrounds

**Even flat designs can have depth.** Use layering: place cards over backgrounds, overlap elements slightly, use subtle borders. Flat ≠ no depth.

**Emulate a light source.** Pick one light direction (top-left is convention) and make all shadows consistent. Raised elements: shadow below. Inset elements: shadow above/inside. Mixing directions breaks the illusion.

**Decorate your backgrounds.** Solid colors are boring. Use subtle patterns (dot grids, diagonal lines), very low-opacity geometric shapes, or a gentle gradient. Keep it subtle — it's a backdrop, not a feature.

## States & Edge Cases

**Don't overlook empty states.** Design empty states before filling in data. An empty list, empty inbox, or zero-result search is the first thing a new user sees. Make them friendly and actionable (add a CTA).

**Beware user-uploaded content.** Photos have varying aspect ratios, colors, and subjects. Design image containers that work with dark photos, light photos, portrait, and landscape. Never assume a specific image size or color.

## Accessibility

**Accessible doesn't have to mean ugly.** High contrast ratios, focus rings, and descriptive labels don't conflict with good aesthetics. Use color contrast checkers. Add `:focus-visible` styles. Write aria-labels that describe the action, not the element type.

## Quick Reference Checklist

When generating a UI component, verify:
- [ ] Colors come from a predefined scale (no ad-hoc hex values)
- [ ] Font sizes come from the type scale
- [ ] Spacing values come from the spacing system
- [ ] Empty state designed
- [ ] Color paired with a second visual signal (not color alone)
- [ ] Consistent shadow direction
- [ ] Greys are tinted, not pure neutral
- [ ] Readable line lengths for any body text

## Additional Reference

For deeper coverage of each principle, see [principles-reference.md](principles-reference.md).
