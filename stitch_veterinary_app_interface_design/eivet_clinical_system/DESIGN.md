---
name: EIVET Clinical System
colors:
  surface: '#f8faf8'
  surface-dim: '#d8dad9'
  surface-bright: '#f8faf8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f2'
  surface-container: '#eceeec'
  surface-container-high: '#e6e9e7'
  surface-container-highest: '#e1e3e1'
  on-surface: '#191c1b'
  on-surface-variant: '#3f4a3c'
  inverse-surface: '#2e3130'
  inverse-on-surface: '#eff1ef'
  outline: '#6f7a6b'
  outline-variant: '#becab9'
  surface-tint: '#006e1c'
  primary: '#006e1c'
  on-primary: '#ffffff'
  primary-container: '#4caf50'
  on-primary-container: '#003c0b'
  inverse-primary: '#78dc77'
  secondary: '#2a6b2c'
  on-secondary: '#ffffff'
  secondary-container: '#acf4a4'
  on-secondary-container: '#307231'
  tertiary: '#705d00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a900'
  on-tertiary-container: '#4c3e00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#94f990'
  primary-fixed-dim: '#78dc77'
  on-primary-fixed: '#002204'
  on-primary-fixed-variant: '#005313'
  secondary-fixed: '#acf4a4'
  secondary-fixed-dim: '#91d78a'
  on-secondary-fixed: '#002203'
  on-secondary-fixed-variant: '#0c5216'
  tertiary-fixed: '#ffe16d'
  tertiary-fixed-dim: '#e9c400'
  on-tertiary-fixed: '#221b00'
  on-tertiary-fixed-variant: '#544600'
  background: '#f8faf8'
  on-background: '#191c1b'
  surface-variant: '#e1e3e1'
typography:
  headline-lg:
    fontFamily: Manrope
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Manrope
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Manrope
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-mobile: 20px
  gutter-mobile: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style

The design system is anchored in a professional, clinical, yet deeply empathetic brand personality tailored for veterinary oncology. It prioritizes clarity and calm to support pet owners through sensitive medical journeys. 

The style is **Corporate / Modern** with a focus on high-legibility and clinical precision. It utilizes the clean hierarchy and structural efficiency seen in modern health tech, featuring soft rounded corners to maintain a friendly, approachable atmosphere. Ample whitespace is used to reduce cognitive load, ensuring that critical medical information and calls-to-action remain the primary focus.

## Colors

The palette is derived directly from the clinic's logo, emphasizing life, health, and stability.

- **Primary (Vibrant Green):** Used for primary actions, success states, and key brand highlights. It represents vitality and hope.
- **Secondary (Dark Green):** Used for headers, navigation elements, and heavy typography to provide professional grounding and authority.
- **Tertiary (Gold/Yellow):** An accent color used sparingly for high-attention alerts, ratings, or premium status indicators.
- **Neutral:** A range of cool grays and off-whites (sourced from the white in the logo) provide the "canvas" for the application, ensuring the vibrant greens don't overwhelm the user.

## Typography

This design system utilizes **Manrope** for all levels. Its geometric yet humanist characteristics provide a modern, technical feel that remains legible even in data-heavy clinical views. 

The type hierarchy is strictly enforced to guide the user through complex oncology reports or appointment scheduling. Headlines use the Secondary (Dark Green) color for maximum contrast, while body copy remains a high-contrast dark gray to ensure accessibility.

## Layout & Spacing

The layout follows a **fluid grid** model optimized for mobile-first interactions. It uses a 4-column system for mobile devices and an 8-column system for tablets.

- **Margins:** A generous 20px side margin ensures content does not feel cramped against the screen edges.
- **Vertical Rhythm:** A base-8 spacing system is used to define vertical stack heights, ensuring consistent breathing room between clinical modules and cards.
- **Visual Grouping:** Related medical data points should be grouped with `stack-sm`, while distinct sections (e.g., "Patient Info" vs "Appointment History") are separated by `stack-lg`.

## Elevation & Depth

To maintain a clean and professional aesthetic, hierarchy is established through **Tonal Layers** rather than heavy shadows.

- **Surface Levels:** The background uses the neutral base. Cards and containers use a pure white surface to "pop" against the background.
- **Outlines:** Low-contrast, soft gray borders (1px) are used to define interactive areas like input fields.
- **Soft Shadows:** Only used for floating action buttons or primary modal overlays to provide a subtle "lift." These shadows should be extremely diffused (20px blur) with a very low opacity (8%) using a Dark Green tint to stay on-brand.

## Shapes

The design system uses a **Rounded** (Level 2) shape language. 

Standard components like buttons and cards feature a 0.5rem (8px) corner radius. This strikes the balance between the "softness" required for a friendly pet-care app and the "structure" required for a professional medical service. High-level containers or featured banners may use `rounded-xl` (1.5rem) to draw the eye toward featured content or the pet's profile photo.

## Components

- **Buttons:** Primary buttons use the Vibrant Green background with white text. Secondary buttons use a Dark Green outline with Dark Green text. All buttons have a minimum height of 48px for touch accessibility.
- **Input Fields:** Use a subtle off-white background with a 1px border. On focus, the border transitions to the Primary Vibrant Green.
- **Cards:** White backgrounds with a subtle 1px neutral border. Used for pet profiles, medical summaries, and clinical appointments.
- **Chips:** Small, highly rounded labels used to denote pet species (e.g., "Dog", "Cat") or status (e.g., "Scheduled", "Completed").
- **Clinical Indicators:** Special icon-led indicators (using the ribbon/cat silhouette motifs) for highlighting critical oncology data or urgent notifications.
- **Navigation:** A clean bottom navigation bar with clear iconography for "Home," "Pets," "Medical Records," and "Profile."