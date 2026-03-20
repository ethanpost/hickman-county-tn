# UI Design Principles — Extended Reference

Expanded notes for each principle. Read specific sections as needed.

---

## Color in Depth

### HSL Color Model
- **H**ue: 0–360°, the color family
- **S**aturation: 0–100%, vividness
- **L**ightness: 0–100%, brightness

To create a palette from one brand color:
1. Fix the hue (e.g., H=220 for blue)
2. Vary L from 95 (lightest background) to 15 (darkest text)
3. Compensate: as L increases, reduce S slightly; as L decreases, increase S slightly

### Saturation Compensation Table
| Shade | L | S adjustment |
|-------|---|-------------|
| 50 (background) | 95 | −20% S |
| 100 | 90 | −15% S |
| 200 | 80 | −10% S |
| 300 | 70 | −5% S |
| 400 | 60 | 0 (base) |
| 500 | 50 | 0 (base) |
| 600 | 40 | +5% S |
| 700 | 30 | +10% S |
| 800 | 20 | +15% S |
| 900 | 12 | +20% S |

### Color Roles
- **Primary/Brand**: Actions, links, key UI elements
- **Neutral/Grey**: Text, borders, backgrounds
- **Semantic**: Success (green), Warning (amber), Danger (red), Info (blue)
- **Accent**: Used sparingly for decorative highlights

---

## Typography in Depth

### Type Scale Example (base 16px)
```
xs:  12px  (captions, labels)
sm:  14px  (secondary text, UI labels)
base: 16px  (body text)
lg:  20px  (lead paragraphs)
xl:  24px  (subheadings)
2xl: 32px  (headings)
3xl: 48px  (display, hero)
4xl: 64px  (large display numbers)
```

### Font Pairing Personalities
| Personality | Serif choice | Sans choice | Tone |
|-------------|-------------|-------------|------|
| Professional | Georgia, Merriweather | Inter, DM Sans | Corporate, trustworthy |
| Playful | Nunito | Poppins | Friendly, approachable |
| Elegant | Playfair Display | Cormorant | Luxury, refined |
| Technical | — | JetBrains Mono, IBM Plex | Developer, precise |

### Line Length Rule
- Ideal: 60–70 characters per line for body text
- `max-width: 65ch` on prose containers
- Don't constrain headings or UI text the same way

---

## Spacing & Sizing System

### Base-8 Scale
```
4px   — micro gap (icon spacing, tight labels)
8px   — tight (inside padding for compact elements)
12px  — small (padding in badges, chips)
16px  — default (standard padding, gaps)
24px  — medium (card padding, section gaps)
32px  — large (section spacing)
48px  — x-large (major section breaks)
64px  — 2x-large (page-level vertical rhythm)
96px  — 3x-large (hero sections)
```

### When to Use Which Spacing
- Items in a group: 4–8px between them
- Within a component: 12–16px padding
- Between related sections: 24–32px
- Between unrelated sections: 48–64px
- Page margins: 48–96px (responsive)

---

## Shadows & Depth

### Shadow Scale
```css
/* subtle - cards on white backgrounds */
shadow-sm:  0 1px 2px rgba(0,0,0,0.05)

/* default - floating cards, dropdowns */
shadow:     0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)

/* medium - modals, popovers */
shadow-md:  0 4px 6px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.06)

/* large - sticky headers, sidebars */
shadow-lg:  0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05)

/* x-large - full-screen modals */
shadow-xl:  0 20px 25px rgba(0,0,0,0.1), 0 10px 10px rgba(0,0,0,0.04)
```

### Inset Shadows (for pressed/inset states)
```css
shadow-inset: inset 0 2px 4px rgba(0,0,0,0.06)
```

---

## Empty States

A well-designed empty state has:
1. **Illustration or icon** — relevant to the content type, not generic
2. **Heading** — what's empty ("No projects yet", not "Empty")
3. **Supporting text** — brief explanation or encouragement
4. **Primary CTA** — one action to get started

Avoid: "No data found." with no further guidance.

---

## Accessibility Quick Reference

### Contrast Ratios (WCAG 2.1)
| Text size | AA minimum | AAA |
|-----------|-----------|-----|
| Normal text (< 18px or < 14px bold) | 4.5:1 | 7:1 |
| Large text (≥ 18px or ≥ 14px bold) | 3:1 | 4.5:1 |
| UI components, icons | 3:1 | — |

### Tools
- [coolors.co/contrast-checker](https://coolors.co/contrast-checker)
- [whocanuse.com](https://whocanuse.com) — shows impact across vision types
- Chrome DevTools: Accessibility panel → Contrast

### Focus States
```css
/* Never remove focus outlines. Replace with styled alternatives: */
:focus-visible {
  outline: 2px solid hsl(220, 90%, 56%);
  outline-offset: 2px;
}
```
