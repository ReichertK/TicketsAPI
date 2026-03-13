feat: final enterprise-grade refactor and open-source release

## 🏗️ Architecture & Backend
- ASP.NET Core 6 Web API with 22 REST controllers (versioned /api/v1/)
- Dapper ORM with parameterized queries (SQL injection safe)
- Repository + Service pattern with full DI registration
- Global exception handling middleware with structured error responses
- SignalR hub for real-time ticket notifications (WebSocket + fallback)
- Brute-force protection service with automatic account lockout (5 attempts)
- Rate limiting on authentication endpoints

## 🎨 Frontend
- React 19 SPA with TypeScript 5.9, Vite 7, Tailwind CSS 4
- 15 pages: Dashboard, Tickets CRUD, Admin (Users, Departments, Roles), Help Center
- Zustand for auth/toast state + TanStack React Query for server state
- Global search palette (Ctrl+K) with multi-entity RBAC-filtered results
- Recharts dashboard with interactive charts and CSV export
- Legacy browser support via @vitejs/plugin-legacy + terser
- Responsive design with mobile-first approach

## 🔐 Security & Auth
- JWT access tokens (15 min) + refresh tokens (7 days) with rotation
- Full RBAC: 5 roles × 18 granular permissions configurable from DB
- Protected state transitions: role-based + ticket ownership validation
- MD5 password hashing (legacy compatibility)

## 🎫 Ticket System
- 7-state machine with 16 configurable transition rules stored in DB
- Approval workflow (request → approve/reject) with dedicated permissions
- Full audit trail: every transition logged with actor, timestamp, IP
- Comments system with per-ticket threading
- Full-text search index for instant ticket lookup
- Subscriber/notification system per ticket

## 🗄️ Database
- MySQL 5.5 — 30 tables organized by domain (catalogs, RBAC, tickets, audit)
- Clean schema.sql + seed.sql with fictitious demo data (no real credentials)
- 17 numbered migrations in Database/migrations_history/
- Stored procedures for dashboard aggregations and complex queries
- BIGINT migration for future-proof ID columns

## 📖 Documentation
- Professional README.md with badges, quick start, tech stack
- Full docs/ tree: API reference, JWT auth flow, permissions matrix, deploy guide
- appsettings.Production.Example.json template for easy setup
- Deployment guide for IIS (monolithic: API serves SPA from wwwroot/)

## 🔒 Open-Source Sanitization
- Removed all production credentials, IPs, server names from tracked files
- Hardened .gitignore: .env files, production configs, build artifacts
- Database scripts use generic 'tickets_db' name with demo data only
- All connection strings use placeholder values (YOUR_DB_PASSWORD, etc.)
