# Task 03: Backend API Services

## Current Structure

```
modules/backend/
├── apps/
│   ├── api/
│   │   ├── routers/    (empty)
│   │   ├── services/   (empty)
│   │   └── models/     (empty)
│   ├── scheduler/
│   │   └── scheduler.py (exists - 1 file)
│   └── worker/
│       └── tasks/      (empty)
└── packages/
    ├── auth/
    │   ├── providers/  (empty)
    │   └── middleware/ (empty)
    ├── database/
    │   └── models/     (empty)
    └── utils/          (empty)
```

## Objective

Build FastAPI-based backend with authentication and database.

## Files to Create

### Core API

1. `modules/backend/apps/api/main.py` - FastAPI application
2. `modules/backend/apps/api/routers/ai.py` - AI endpoints
3. `modules/backend/apps/api/routers/visual.py` - Visual generation endpoints
4. `modules/backend/apps/api/routers/auth.py` - Authentication endpoints

### Authentication

5. `modules/backend/packages/auth/providers/oauth.py`
6. `modules/backend/packages/auth/providers/jwt.py`
7. `modules/backend/packages/auth/middleware/auth_middleware.py`

### Database

8. `modules/backend/packages/database/models/user.py`
9. `modules/backend/packages/database/models/project.py`
10. `modules/backend/packages/database/connection.py`

### Requirements

11. `modules/backend/requirements.txt`

## Tech Stack

- FastAPI
- SQLAlchemy (ORM)
- Pydantic (validation)
- JWT authentication
- PostgreSQL/Neon DB

## Success Criteria

- [ ] API responds to health check
- [ ] Authentication works with JWT
- [ ] Database connections successful
- [ ] CRUD operations for users and projects
