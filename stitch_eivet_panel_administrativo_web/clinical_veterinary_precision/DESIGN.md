---
name: Clinical Veterinary Precision
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#414844'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#717974'
  outline-variant: '#c1c8c3'
  surface-tint: '#3f6656'
  primary: '#002217'
  on-primary: '#ffffff'
  primary-container: '#0f382a'
  on-primary-container: '#79a28f'
  inverse-primary: '#a5d0bc'
  secondary: '#006d42'
  on-secondary: '#ffffff'
  secondary-container: '#93f3bb'
  on-secondary-container: '#007146'
  tertiary: '#261b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#402f00'
  on-tertiary-container: '#bb9432'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c1ecd7'
  primary-fixed-dim: '#a5d0bc'
  on-primary-fixed: '#002116'
  on-primary-fixed-variant: '#274e3f'
  secondary-fixed: '#96f6bd'
  secondary-fixed-dim: '#7adaa3'
  on-secondary-fixed: '#002111'
  on-secondary-fixed-variant: '#005231'
  tertiary-fixed: '#ffdf99'
  tertiary-fixed-dim: '#ecc15a'
  on-tertiary-fixed: '#251a00'
  on-tertiary-fixed-variant: '#5a4300'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.015em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
  code-data:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 0.75rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes an authoritative, high-precision clinical management environment tailored for veterinary surgeons, oncologists, clinic administrators, and nursing staff. The visual identity reflects medical reliability, clinical rigor, and compassionate animal care, transitioning seamlessly from consumer mobile interfaces into a dense, high-throughput desktop web administration portal.

The overarching design style is **Corporate / Modern Clinical**:
- **Utilitarian Elegance:** High data density without visual noise. Complex multi-stage clinical protocols, chemotherapy regimens, patient vitals, and surgical scheduling are rendered through structured hierarchies.
- **Biophilic Clinical Palette:** Grounded in deep forest green and clinical emerald tones from the clinic identity, offset by subtle warm bronze/gold accents denoting high-tier oncology specializations and certifications.
- **Calm Authority:** Surfaces maintain a high degree of contrast with crisp border structures and tinted neutral backdrops, minimizing cognitive strain during extended clinical shifts and critical emergency procedures.

## Colors

The system uses a calibrated palette structured for clinical workflows:

- **Primary (`#0F382A` - Deep Forest Green):** The foundational anchor. Used for primary navigation rails, top app headers, primary action buttons, and dominant data emphasis. It conveys institutional trust and clinical gravity.
- **Secondary (`#1B8354` - Clinical Emerald):** Operational accent. Applied to positive clinical statuses (e.g., "Active Treatment", "Checked-in", "Stable Vitals"), primary interactive indicators, completed patient milestones, and confirmation actions.
- **Tertiary (`#C29B38` - Warm Ochre Gold):** Oncology and specialized care signifier. Reserved for critical attention markers, certified protocol flags, pending biopsy reports, appointment triage tags, and premium patient status tiers.
- **Neutral (`#64748B` - Slate):** Systemic balancing scale. Used for muted tabular data, secondary micro-copy, icon strokes, and inactive states.

### Surface and Semantic Distribution
- **Backgrounds:** Clean clinical canvas (`#F8FAFC`), elevated cards and table rows (`#FFFFFF`), inset metric tiles (`#F1F5F9`).
- **Dividers & Borders:** Subtle structural definition using `#E2E8F0` and `#CBD5E1`.
- **System States:**
  - Critical / Emergency: `#DC2626`
  - Warning / Lab Pending: `#D97706`
  - Success / Discharged: `#16A34A`
  - Info / Observation: `#0284C7`

## Typography

The typographical pairing splits display authority from clinical legibility:

- **Plus Jakarta Sans (Headings & Section Titles):** Provides crisp modern geometry, balanced aperture, and a professional clinical warmth without sterile detachment.
- **Inter (Body, Clinical Data, and UI Controls):** Maximizes readability in tabular datasets, multi-line medical charts, oncology dosing summaries, and diagnostic reports. Tabular figures (`tnum`) must be enabled globally for all monetary values, patient weights, clinical dosages, and timestamps.
- **Label Hierarchy:** Clinical badges, status chips, and table headers use uppercase or semibold tracking (`label-sm`) to ensure rapid ocular scanning across wide clinical dashboards.

## Layout & Spacing

The portal layout adheres to a flexible, data-optimized grid structure:

- **Grid Architecture:** 12-column fluid grid for desktop administrative dashboards with fixed left-hand clinical navigation (64px collapsed, 240px expanded).
- **Responsive Adaptations:**
  - **Desktop (>= 1280px):** 12 columns, 24px gutter, 32px canvas margins. Supports side-by-side patient charts, real-time lab side-drawers, and active surgical calendars.
  - **Tablet / Mobile-Landscape (768px - 1279px):** 8 columns, 16px gutter, 24px margins. Navigation collapses to an icon-rail; summary cards stack to 2-column arrays.
  - **Mobile (< 768px):** 4 columns, 12px gutter, 16px margins. Clinical tables reflow into touch cards matching the client-side wireframe patterns.
- **Component Padding Rhythms:** Consistent 8-point base rhythm. Inputs and table rows maintain a condensed density profile (36px to 44px row heights) to maximize visible patient records above the fold.

## Elevation & Depth

This design system avoids loud, diffuse drop shadows in favor of **Crisp Tonal Layering with Low-Contrast Structural Outlines**:

- **Layer 0 (Canvas Base):** Medical background slate (`#F8FAFC`). No elevation.
- **Layer 1 (Cards, Workspaces, Tables):** Solid `#FFFFFF` enclosed by a 1px border (`#E2E8F0`). Subtle 1px ambient drop: `box-shadow: 0 1px 3px 0 rgba(15, 56, 42, 0.04), 0 1px 2px -1px rgba(15, 56, 42, 0.04)`.
- **Layer 2 (Dropdowns, Popovers, Flyout Panels):** Surface `#FFFFFF` with refined elevation: `box-shadow: 0 4px 6px -1px rgba(15, 56, 42, 0.07), 0 2px 4px -2px rgba(15, 56, 42, 0.05)` and a `#CBD5E1` border stroke.
- **Layer 3 (Modals, Emergency Clinical Overlays):** Deep ambient framing: `box-shadow: 0 20px 25px -5px rgba(15, 56, 42, 0.12), 0 8px 10px -6px rgba(15, 56, 42, 0.08)`. Backdrops use `#0F382A` at 40% opacity with a 4px blur (`backdrop-filter: blur(4px)`).

## Shapes

The design uses **Rounded (Tier 2)** shape primitives:
- Base standard radius: `0.5rem` (8px) for buttons, standard form inputs, segmented tabs, and contextual cards.
- Container radius (`rounded-lg`): `1rem` (16px) for master patient panels, diagnostic imaging wrappers, and elevated modal dialogs.
- Extended container radius (`rounded-xl`): `1.5rem` (24px) for distinct oncology protocol overview modules.
- Pill forms (`rounded-full`): Dedicated exclusively to status pills, patient triage chips (e.g., "Canine / In Treatment"), and avatar wrappers.

## Components

### Buttons
- **Primary:** Deep forest green (`#0F382A`) background, white text, 8px radius, subtle border `1px solid #0F382A`. Hover: `#184E38`. Active: `#0B2A1F`.
- **Secondary / Action:** Clinical emerald (`#1B8354`) background, white text. Used for positive task completions, saving medical records, or booking admissions.
- **Tertiary / Clinical Special:** Transparent background, `#0F382A` text, 1px border `#CBD5E1`. Hover: `#F1F5F9`.
- **Destructive:** Soft red tint (`#FEF2F2`) with `#DC2626` text and border for discharge cancellations or prescription voids.

### Inputs & Form Controls
- **Field Wrappers:** 40px height for desktop data entry. `#FFFFFF` background, `#CBD5E1` border, 8px radius.
- **Focus State:** 2px ring in clinical emerald (`#1B8354` at 20% opacity) with a `#1B8354` border stroke.
- **Icons:** Leading iconography (search, medical syringe, stethoscope, date picker) rendered in `#64748B`.

### Status Badges & Chips
- **Oncology / Critical:** `#C29B38` base with light gold tint background (`#FEF9C3`), text `#713F12`.
- **Stable / Verified:** Emerald tint (`#ECFDF5`), text `#065F46`, secondary green dot indicator (`#1B8354`).
- **In-Observation:** Slate tint (`#F1F5F9`), text `#334155`.

### Data Grids & Patient Tables
- **Header:** Background `#F8FAFC`, uppercase `#64748B` label text, 1px border bottom `#E2E8F0`.
- **Rows:** Alternating subtle hover states (`#F8FAFC`), 52px height for patient listings featuring pet avatar, species icon, owner name, oncology protocol stage, and action popovers.

### Cards
- **Clinical Overview Card:** White background, 1px `#E2E8F0` border, 16px radius, containing segmented header with primary status indicator and structured key-value data layout.
- **Metric Tiles:** Subtle surface background (`#F1F5F9`), zero shadow, highlighting critical vitals (body weight, white cell count, dosage schedules).