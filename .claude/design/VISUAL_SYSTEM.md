# CII Visual Design System

## Design DNA

> "Visual authenticity is not about looking different.
> It's about looking like what you truly are."

---

## Color System

### The Chameleon Palette

CII adapts to the brand being built. But it has a resting state.

#### Resting State (No Brand Active)
```css
--cii-bg-primary: #0F0F10;        /* Deep near-black */
--cii-bg-secondary: #1A1A1C;      /* Elevated surfaces */
--cii-bg-tertiary: #242428;       /* Cards, inputs */

--cii-text-primary: #F5F5F7;      /* High contrast */
--cii-text-secondary: #A1A1A6;    /* Muted */
--cii-text-tertiary: #6E6E73;     /* Subtle */

--cii-accent: #7C5CFF;            /* Logicsticks violet */
--cii-accent-glow: rgba(124, 92, 255, 0.15);

--cii-agent: #3ECF8E;             /* Agent presence */
--cii-truth: #F59E0B;             /* Truth/insight moments */
--cii-curiosity: #EC4899;         /* Discovery, exploration */
```

#### Brand-Adaptive Mode
When brand is active, CII extracts:
- Primary brand color → accents
- Secondary brand color → highlights
- Brand warmth → adjusts gray temperature

```
CII Chrome: Neutral-warm gray (constant)
Active Surfaces: Tinted by brand primary (5% opacity)
Accents: Brand colors
Agent: Always #3ECF8E (constant identity)
```

### Semantic Colors
```css
--cii-success: #3ECF8E;
--cii-warning: #F59E0B;
--cii-error: #EF4444;
--cii-info: #3B82F6;

--cii-ontological: #8B5CF6;    /* What IS */
--cii-epistemological: #06B6D4; /* How KNOW */
```

---

## Typography

### Font Stack

```css
/* Display - for headlines, brand names */
--font-display: 'Instrument Serif', Georgia, serif;

/* Body - for reading, UI */
--font-body: 'Inter', -apple-system, sans-serif;

/* Mono - for agent output, commands, code */
--font-mono: 'JetBrains Mono', 'SF Mono', monospace;
```

### Type Scale
```css
--text-xs: 0.75rem;      /* 12px - captions */
--text-sm: 0.875rem;     /* 14px - secondary */
--text-base: 1rem;       /* 16px - body */
--text-lg: 1.125rem;     /* 18px - emphasis */
--text-xl: 1.25rem;      /* 20px - subheads */
--text-2xl: 1.5rem;      /* 24px - section titles */
--text-3xl: 1.875rem;    /* 30px - page titles */
--text-4xl: 2.25rem;     /* 36px - display */
--text-5xl: 3rem;        /* 48px - hero */
```

### Weight System
```css
--font-light: 300;
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

---

## Spacing & Layout

### Spatial Scale (8px base)
```css
--space-1: 0.25rem;   /* 4px */
--space-2: 0.5rem;    /* 8px */
--space-3: 0.75rem;   /* 12px */
--space-4: 1rem;      /* 16px */
--space-5: 1.25rem;   /* 20px */
--space-6: 1.5rem;    /* 24px */
--space-8: 2rem;      /* 32px */
--space-10: 2.5rem;   /* 40px */
--space-12: 3rem;     /* 48px */
--space-16: 4rem;     /* 64px */
--space-20: 5rem;     /* 80px */
```

### The Spatial Model
Brands are SPACES, not files.

```
┌────────────────────────────────────────────────┐
│  Sidebar (240px)  │      Main Canvas           │
│  ┌──────────────┐ │  ┌──────────────────────┐  │
│  │ Brand List   │ │  │                      │  │
│  │              │ │  │   Active Space       │  │
│  │ ● Acme      │ │  │                      │  │
│  │   Beta Co   │ │  │   (contextual UI)    │  │
│  │   Gamma     │ │  │                      │  │
│  │              │ │  │                      │  │
│  └──────────────┘ │  └──────────────────────┘  │
│                   │  ┌──────────────────────┐  │
│  ┌──────────────┐ │  │   Agent Panel        │  │
│  │ Quick        │ │  │   (collapsible)      │  │
│  │ Commands     │ │  └──────────────────────┘  │
│  └──────────────┘ │                            │
└────────────────────────────────────────────────┘
```

---

## Components

### Cards (Brand Rooms)
```css
.brand-room {
    background: var(--cii-bg-secondary);
    border: 1px solid rgba(255, 255, 255, 0.06);
    border-radius: 16px;
    padding: var(--space-6);

    /* Subtle depth */
    box-shadow:
        0 1px 2px rgba(0, 0, 0, 0.1),
        0 4px 12px rgba(0, 0, 0, 0.05);

    /* Hover: surface rises */
    transition: transform 200ms ease, box-shadow 200ms ease;
}

.brand-room:hover {
    transform: translateY(-2px);
    box-shadow:
        0 4px 12px rgba(0, 0, 0, 0.15),
        0 8px 24px rgba(0, 0, 0, 0.1);
}
```

### Agent Presence Indicator
```css
.agent-presence {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--cii-agent);

    /* Breathing animation */
    animation: breathe 3s ease-in-out infinite;
}

@keyframes breathe {
    0%, 100% { opacity: 0.6; transform: scale(1); }
    50% { opacity: 1; transform: scale(1.1); }
}
```

### Command Input
```css
.command-input {
    background: var(--cii-bg-tertiary);
    border: 1px solid transparent;
    border-radius: 12px;
    padding: var(--space-3) var(--space-4);
    font-family: var(--font-mono);
    font-size: var(--text-sm);

    /* Activation glow */
    transition: border-color 150ms, box-shadow 150ms;
}

.command-input:focus {
    border-color: var(--cii-accent);
    box-shadow: 0 0 0 3px var(--cii-accent-glow);
    outline: none;
}
```

### Truth Moment
When agent discovers/voices a truth:
```css
.truth-moment {
    background: linear-gradient(
        135deg,
        rgba(245, 158, 11, 0.1),
        rgba(124, 92, 255, 0.1)
    );
    border-left: 3px solid var(--cii-truth);
    padding: var(--space-4);
    border-radius: 0 8px 8px 0;

    /* Gentle pulse on appear */
    animation: truth-pulse 600ms ease-out;
}

@keyframes truth-pulse {
    0% { opacity: 0; transform: translateX(-8px); }
    100% { opacity: 1; transform: translateX(0); }
}
```

---

## Motion

### Easing Functions
```css
--ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
--ease-in-out-expo: cubic-bezier(0.87, 0, 0.13, 1);
--ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
```

### Duration Scale
```css
--duration-fast: 150ms;
--duration-normal: 250ms;
--duration-slow: 400ms;
--duration-slower: 600ms;
```

### Choreography Principles
1. **Elements arrive, not appear** - fade + translate
2. **Stagger for groups** - 50ms between items
3. **Exit is faster than enter** - less interruption
4. **Agent has its own rhythm** - slightly slower, deliberate

---

## Empty States

### Brand Space Empty
```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│         ┌─────────────────────┐         │
│         │  ◯                  │         │
│         │                     │         │
│         │  "Every brand       │         │
│         │   begins as         │         │
│         │   silence.          │         │
│         │                     │         │
│         │   What truth are    │         │
│         │   you ready to      │         │
│         │   voice?"           │         │
│         │                     │         │
│         │  [    begin    ]    │         │
│         └─────────────────────┘         │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

### Agent Thinking
```
┌─────────────────────────────────────────┐
│                                         │
│   ● ● ●                                │
│                                         │
│   Exploring the latent space...        │
│                                         │
│   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░     │
│   ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░     │
│                                         │
│   > Analyzing market signals            │
│   > Mapping audience consciousness      │
│   > Crystallizing truth candidates      │
│                                         │
└─────────────────────────────────────────┘
```

---

## Curiosity Triggers

### Hidden Depth Reveals
- Hover on segment → shows embedding similarity
- Long-press on brand → reveals internal metrics
- Double-click truth → shows research trail

### Progressive Commands
First time: `/voice` → shows hint: "try /voice warmer"
After use: remembers preference patterns

### Discovery Rewards
- Complete first campaign → unlock advanced visualizations
- 10 truths recorded → remembrance insights view
- Use all philosophical techniques → mastery badge (subtle)

---

## Accessibility

### Contrast Ratios
- Text on bg-primary: 15.8:1 ✓
- Text on bg-secondary: 12.4:1 ✓
- Secondary text: 7.2:1 ✓

### Motion Preferences
```css
@media (prefers-reduced-motion: reduce) {
    *, *::before, *::after {
        animation-duration: 0.01ms !important;
        transition-duration: 0.01ms !important;
    }
}
```

### Focus Indicators
All interactive elements have visible focus states.
Keyboard navigation fully supported.
