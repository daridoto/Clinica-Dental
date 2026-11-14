# TASKS — Dentista

## Estado actual
- Última: T02 · Siguiente: T03 (T04 también disponible)
- Pendiente/bloqueos: crear repositorio git y en GitHub antes de T01/T03.

## Progresión
- **Calibrar (T01–T07):** en secuencia, con todas las pausas. Corregir los `.md` de los agentes cuando fallen.
- **Autónomo (T08–T13):** pausas solo para aprobar el plan y revisar el final.
- **Paralelo (T14–T19):** varias sesiones con worktrees en tareas sin dependencias entre sí.

---

## Fase 0 — Fundaciones

## T01 — Scaffold del proyecto [done]
- Objetivo: Next.js (App Router) + TS strict, ESLint, Prettier, Vitest y la estructura de carpetas del CLAUDE.md.
- Archivos: raíz del proyecto, `src/`, `tests/`
- Depende de: —
- Agente: backend-dev
- TDD: no
- Hecho cuando: `npm run lint`, `npm run typecheck`, `npm test` y `npm run dev` funcionan, con un test de ejemplo que pasa.

## T02 — Comprobaciones automáticas locales [done]
- Objetivo: `.claude/settings.json` con permisos (permitir test/lint/git diff; denegar `.env` y `rm -rf`) y hooks (Prettier tras cada edición; tests al terminar).
- Archivos: `.claude/settings.json`, `.claude/hooks/`
- Depende de: T01
- Agente: sesión principal
- TDD: no
- Hecho cuando: al editar un archivo se formatea solo y leer `.env` queda bloqueado.

## T03 — CI [todo]
- Objetivo: GitHub Actions con lint, type-check y tests en cada push y PR.
- Archivos: `.github/workflows/ci.yml`
- Depende de: T01
- Agente: sesión principal
- TDD: no
- Hecho cuando: un push muestra la CI en verde, y un test roto la pone en rojo.

## T04 — Modelo de datos [todo]
- Objetivo: esquema Prisma (Doctor, Treatment, Appointment, WaitlistEntry, WaitlistOffer, Staff) y datos de prueba con los supuestos del SPEC.
- Archivos: `prisma/schema.prisma`, `prisma/seed.ts`, `src/server/db.ts`
- Depende de: T01
- Agente: backend-dev
- TDD: no
- Hecho cuando: la migración se aplica en local y el seed crea 2 doctores, 3 tratamientos y 1 usuario de recepción.

## Fase 1 — Dominio (T05, T06 y T07 pueden ir en paralelo)

## T05 — Disponibilidad [todo]
- Objetivo: función pura que calcula los huecos libres según horario, duración del tratamiento, citas existentes, ofertas activas y doctor (o "cualquiera").
- Archivos: `src/domain/availability.ts`, `tests/domain/availability.test.ts`
- Depende de: T01
- Agente: backend-dev
- TDD: sí
- Hecho cuando: los tests cubren solapes, límites de horario, la pausa del mediodía y "cualquiera".

## T06 — Estados y cancelación [todo]
- Objetivo: transiciones de estado de la cita y la regla de cancelación del paciente (hasta 2 h antes).
- Archivos: `src/domain/appointment.ts`, `tests/domain/appointment.test.ts`
- Depende de: T01
- Agente: backend-dev
- TDD: sí
- Hecho cuando: los tests cubren todas las transiciones válidas e inválidas y el límite exacto de 2 h.

## T07 — Lista de espera (lógica) [todo]
- Objetivo: búsqueda de candidatos (tratamiento, rango de fechas, doctor y orden de alta) y paso al siguiente cuando una oferta caduca o se rechaza.
- Archivos: `src/domain/waitlist.ts`, `tests/domain/waitlist.test.ts`
- Depende de: T01
- Agente: backend-dev
- TDD: sí
- Hecho cuando: los tests cubren la coincidencia, el orden, la caducidad a las 2 h y el caso de que no quede nadie.

## Fase 2 — Servidor

## T08 — Servicio de email [todo]
- Objetivo: interfaz de envío con dos implementaciones (consola en desarrollo, Resend en producción) y plantillas: confirmación, recordatorio y oferta.
- Archivos: `src/server/email/`
- Depende de: T01
- Agente: backend-dev
- TDD: no
- Hecho cuando: en desarrollo, los emails aparecen en la consola.

## T09 — Reservar cita [todo]
- Objetivo: acción de servidor que valida el hueco (T05), crea la cita con token y envía la confirmación.
- Archivos: `src/server/appointments.ts`, `tests/server/`
- Depende de: T04, T05, T08
- Agente: backend-dev
- TDD: sí
- Hecho cuando: reservar crea la cita `PENDIENTE` y envía el email, y una reserva solapada se rechaza.

## T10 — Gestión por enlace [todo]
- Objetivo: confirmar o cancelar una cita mediante su token, aplicando T06. Al cancelar, se dispara la lista de espera.
- Archivos: `src/server/appointments.ts`, `src/app/cita/[token]/`
- Depende de: T06, T09
- Agente: backend-dev
- TDD: sí
- Hecho cuando: confirmar y cancelar actualizan el estado, y cancelar a menos de 2 h está bloqueado.

## T11 — Cron de recordatorios [todo]
- Objetivo: ruta cron que envía los recordatorios a 24 h y marca `SIN_CONFIRMAR`.
- Archivos: `src/app/api/cron/reminders/`, `vercel.json`
- Depende de: T09
- Agente: backend-dev
- TDD: sí
- Hecho cuando: ejecutar el cron a mano envía los recordatorios correctos sin duplicados.

## T12 — Lista de espera (servidor) [todo]
- Objetivo: alta en la lista, crear ofertas al cancelar, aceptar una oferta y un cron de caducidad que pasa al siguiente.
- Archivos: `src/server/waitlist.ts`, `src/app/api/cron/waitlist/`, `src/app/oferta/[token]/`
- Depende de: T07, T10
- Agente: backend-dev
- TDD: sí
- Hecho cuando: el flujo completo cancelar → oferta → aceptar o caducar → siguiente funciona.

## T13 — Login de recepción [todo]
- Objetivo: Auth.js con credenciales y protección de las rutas `/panel`.
- Archivos: `src/server/auth.ts`, `src/middleware.ts`
- Depende de: T04
- Agente: backend-dev
- TDD: no
- Hecho cuando: `/panel` redirige al login sin sesión y funciona con el usuario del seed.

## Fase 3 — UI (T14 y T16 pueden ir en paralelo)

## T14 — Página de reserva [todo]
- Objetivo: elegir tratamiento y doctor (opcional), ver huecos, rellenar el formulario y ver la confirmación.
- Archivos: `src/app/(public)/reservar/`, `src/components/booking/`
- Depende de: T09
- Agente: ui-dev
- TDD: no
- Hecho cuando: se puede reservar de principio a fin desde el navegador, también en móvil.

## T15 — Gestión de la cita y lista de espera (UI) [todo]
- Objetivo: páginas del enlace de la cita (confirmar o cancelar), de la oferta (aceptar o rechazar) y formulario de alta en la lista de espera.
- Archivos: `src/app/cita/[token]/`, `src/app/oferta/[token]/`, `src/components/waitlist/`
- Depende de: T10, T12
- Agente: ui-dev
- TDD: no
- Hecho cuando: los tres flujos funcionan desde el navegador.

## T16 — Panel de recepción [todo]
- Objetivo: listado de citas por día y doctor con su estado, y crear o cancelar citas.
- Archivos: `src/app/panel/`, `src/components/panel/`
- Depende de: T13
- Agente: ui-dev
- TDD: no
- Hecho cuando: recepción puede crear y cancelar citas, y las "sin confirmar" se distinguen.

## Fase 4 — Cierre

## T17 — Test E2E [todo]
- Objetivo: test con Playwright del flujo de reserva completo.
- Archivos: `tests/e2e/`, `playwright.config.ts`
- Depende de: T14
- Agente: test-writer
- TDD: —
- Hecho cuando: el E2E pasa en local y en la CI.

## T18 — Despliegue [todo]
- Objetivo: Vercel, Postgres en Neon, variables de entorno y crons activos.
- Archivos: `vercel.json`, `.env.example`
- Depende de: T03
- Agente: sesión principal
- TDD: no
- Hecho cuando: hay una URL pública funcionando y los crons se ejecutan.

## T19 — README y portfolio [todo]
- Objetivo: README con el problema, el stack, capturas, cómo ejecutarlo y la sección "Cómo usé la IA" (con datos de AI_LOG.md y docs/decisions/).
- Archivos: `README.md`
- Depende de: todas
- Agente: sesión principal
- TDD: no
- Hecho cuando: alguien sin contexto entiende el proyecto y puede arrancarlo.
