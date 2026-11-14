# Dentista — sistema de citas

Requisitos en `SPEC.md`; tareas en `TASKS.md`.

## Stack
- Next.js (App Router) + TypeScript (strict)
- PostgreSQL + Prisma
- Auth.js con credenciales (solo para el panel de recepción)
- Resend para emails (en desarrollo, salida por consola)
- Vercel Cron para recordatorios y caducidad de ofertas
- Vitest (unitarios) y Playwright (flujo de reserva)

## Estructura
- `src/domain/`: lógica de negocio pura (disponibilidad, cancelación, lista de espera). No importa Next.js ni Prisma, así se testea fácil.
- `src/server/`: acceso a datos, emails y acciones de servidor.
- `src/app/`: páginas y rutas.
- `src/components/`: componentes de UI.
- `tests/`: tests.

## Reglas del proyecto
- Fechas siempre en UTC en la base de datos; se muestran en Europe/Madrid.
- Las reglas de negocio viven solo en `src/domain/`, nunca en componentes ni rutas.
