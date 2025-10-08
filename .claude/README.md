# Working with Claude AI on Dig-lit

## Quick Start

### View Available Tasks

```bash
npm run claude:tasks
```

### Start Development

Tell Claude:

```
Claude, please work on Task 01: AI Engine Core Development.
Read the task file and implement the AI engine with model loading capabilities.
```

### Check Progress

```bash
npm run claude:progress
```

### View Project Structure

```bash
npm run claude:structure
```

## Giving Instructions to Claude

### ✅ Good Instructions

```
"Claude, implement the AI Engine core as specified in Task 01.
Include the model loaders for LLM, Vision, and Audio models."

"Claude, create the FastAPI backend with authentication endpoints."

"Claude, build the React dashboard with AI metrics display."
```

### ❌ Unclear Instructions

```
"Make it work"
"Add AI stuff"
"Fix everything"
```

## Development Workflow

1. **Pick a Task**: Choose from `.claude/tasks/`
2. **Give Instructions**: Tell Claude what to build
3. **Review Code**: Claude provides complete implementations
4. **Test Locally**: Run and verify
5. **Iterate**: Ask Claude to improve/modify
6. **Move to Next Task**

## File Organization

Claude will create files in these locations:

### AI Engine (Python)

- `modules/ai-engine/core/` - Core engine
- `modules/ai-engine/models/` - Model loaders
- `modules/ai-engine/inference/` - Inference pipeline

### Backend (Python/FastAPI)

- `modules/backend/apps/api/` - API endpoints
- `modules/backend/packages/auth/` - Authentication
- `modules/backend/packages/database/` - Database models

### Frontend (TypeScript/React)

- `modules/frontend/apps/web/diglit-web/src/` - Main app
- `modules/frontend/apps/web/src/components/` - Shared components
- `modules/frontend/packages/` - Shared packages

## Available Commands

```bash
# Development
npm run dev                  # Start frontend dev server
npm run dev:api             # Start backend API

# Testing
npm test                    # Run all tests
npm run test:frontend       # Test frontend only
npm run test:backend        # Test backend only

# Code Quality
npm run lint                # Lint code
npm run format              # Format code

# Claude Commands
npm run claude:tasks        # List tasks
npm run claude:progress     # Show progress
npm run claude:structure    # Show structure
```

## Tips

1. **Be Specific**: The more details you give Claude, the better
2. **One Task at a Time**: Focus on one module before moving to next
3. **Ask Questions**: If something isn't clear, ask Claude
4. **Review Code**: Always review what Claude creates
5. **Test Locally**: Run code locally before committing

## Example Session

```
You: "Claude, let's start with Task 01. Create the AI Engine core."

Claude: [Creates files with full code]

You: "Great! Now add error handling and logging."

Claude: [Updates files with improvements]

You: "Perfect. Let's add tests for the model loading."

Claude: [Creates test files]

You: "Now move to Task 03, the backend API."

Claude: [Starts next task]
```

## Current Status

- **Structure**: ✅ Complete
- **AI Engine**: ⏳ Pending
- **Backend**: ⏳ Pending
- **Frontend**: ⏳ Basic setup exists
- **Visual Engine**: ⏳ Pending
- **Business Intelligence**: ⏳ Pending

Ready to build! 🚀
