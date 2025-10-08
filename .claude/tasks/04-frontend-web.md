# Task 04: Frontend Web Application

## Current Structure

```
modules/frontend/apps/web/
├── diglit-web/
│   ├── src/
│   │   ├── App.tsx     (exists - basic)
│   │   └── main.tsx    (exists - basic)
│   └── (Vite + React setup exists)
└── src/
    ├── components/
    │   ├── ai/         (empty)
    │   ├── business/   (empty)
    │   ├── cinema/     (empty)
    │   ├── forms/      (empty)
    │   └── ui/         (empty)
    └── hooks/          (empty)
```

## Objective

Build React + TypeScript web application with quantum-inspired UI.

## Files to Create

### Core Pages

1. `modules/frontend/apps/web/diglit-web/src/pages/Home.tsx`
2. `modules/frontend/apps/web/diglit-web/src/pages/Dashboard.tsx`
3. `modules/frontend/apps/web/diglit-web/src/pages/AIStudio.tsx`

### Components

4. `modules/frontend/apps/web/src/components/ai/ChatInterface.tsx`
5. `modules/frontend/apps/web/src/components/ai/ModelSelector.tsx`
6. `modules/frontend/apps/web/src/components/ui/QuantumButton.tsx`
7. `modules/frontend/apps/web/src/components/ui/ParticleBackground.tsx`

### Hooks

8. `modules/frontend/apps/web/src/hooks/useAI.ts`
9. `modules/frontend/apps/web/src/hooks/useVisualGenerator.ts`

### API Integration

10. `modules/frontend/packages/api-client/src/api.ts`

## Tech Stack

- React 18
- TypeScript
- Vite
- TailwindCSS (already configured)
- Zustand (state management)

## Success Criteria

- [ ] Home page with quantum animations
- [ ] Dashboard shows AI metrics
- [ ] AI Chat interface works
- [ ] Visual generator UI functional
