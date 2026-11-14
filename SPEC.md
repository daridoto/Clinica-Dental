# SPEC — Sistema de citas para clínica dental

## 1. Problema
Las clínicas dentales pequeñas pierden dinero por:
- **Citas a las que el paciente no acude** (no-shows).
- **Teléfono saturado** para pedir, cambiar o cancelar citas.
- **Huecos libres sin cubrir** cuando alguien cancela.

## 2. Objetivo (versión 1)
Un sistema web para:
- Reservar citas online.
- Enviar recordatorios automáticos con opción de confirmar o cancelar.
- Rellenar los huecos liberados con una lista de espera.

## 3. Actores
| Actor | Descripción |
|---|---|
| Paciente | Reserva sin cuenta. Gestiona la cita desde un enlace único que recibe por email. |
| Recepcionista | Entra al panel con usuario y contraseña. Crea y cancela citas. |
| Sistema | Envía recordatorios y gestiona la lista de espera. |

## 4. Supuestos
- 2 doctores.
- Horario: de lunes a viernes, de 9:00 a 14:00 y de 16:00 a 20:00.
- Tratamientos:
  | Tratamiento | Duración |
  |---|---|
  | Revisión | 30 min |
  | Limpieza | 45 min |
  | Empaste | 60 min |
- Zona horaria: Europe/Madrid.

## 5. Historias de usuario

### Paciente
- **P1.** Elijo un tratamiento y, si quiero, un doctor (o "cualquiera"), y veo los huecos libres.
- **P2.** Reservo un hueco con nombre, email y teléfono, y recibo un email de confirmación con un enlace único.
- **P3.** Recibo un recordatorio 24 horas antes de la cita, con botones para confirmar o cancelar.
- **P4.** Puedo cancelar desde el enlace hasta 2 horas antes de la cita. Después, tengo que llamar a la clínica.
- **P5.** Si no hay huecos, me apunto a la lista de espera indicando tratamiento, rango de fechas y, si quiero, doctor.
- **P6.** Si se libera un hueco que me sirve, recibo un email para aceptarlo. Tengo 2 horas para hacerlo.

### Recepcionista
- **R1.** Inicio sesión en el panel.
- **R2.** Creo una cita para un paciente que llama por teléfono.
- **R3.** Cancelo una cita. La cancelación activa la lista de espera igual que si cancelara el paciente.
- **R4.** Veo las citas con su estado; las que no están confirmadas se distinguen.

### Sistema
- **S1.** Envía un recordatorio 24 horas antes de cada cita.
- **S2.** Si la cita no se confirma, la marca como "sin confirmar". No la cancela.
- **S3.** Cuando se libera un hueco, gestiona la lista de espera (ver sección 6).

## 6. Reglas de negocio

### Disponibilidad
- Un hueco es válido si cabe la duración completa del tratamiento dentro del horario, sin solaparse con otra cita del mismo doctor.
- Si el paciente elige "cualquiera", se le asigna un doctor libre.

### Estados de una cita
`PENDIENTE` → `CONFIRMADA` | `SIN_CONFIRMAR` | `CANCELADA`

### Cancelación
- **Paciente:** solo hasta 2 horas antes de la cita.
- **Recepción:** en cualquier momento.

### Lista de espera
1. Al liberarse un hueco, se buscan entradas que coincidan en tratamiento, rango de fechas y doctor (si lo indicaron). Se ordenan por fecha de alta.
2. Se avisa **solo al primero**, con un enlace válido durante 2 horas.
3. **Si acepta:** se crea la cita y su entrada sale de la lista.
4. **Si no responde o rechaza:** se avisa al siguiente.
5. **Si nadie lo acepta:** el hueco vuelve a estar libre para reservas normales.
6. Mientras hay una oferta activa, el hueco no aparece como disponible.

### Enlaces únicos
- Usan un token aleatorio no adivinable.
- No requieren login.

## 7. Flujo principal
```
Reserva → email de confirmación → recordatorio (24 h antes) → confirma / cancela
                                                                     ↓
                                                          hueco libre → aviso a lista de espera (1 en 1, 2 h)
                                                                     ↓
                                                         acepta → nueva cita | timeout → siguiente
```

## 8. Stack técnico
| Pieza | Herramienta |
|---|---|
| Framework | Next.js (App Router) + TypeScript |
| Base de datos | PostgreSQL + Prisma |
| Email | Resend (Mailtrap o consola en desarrollo) |
| Tareas programadas | Vercel Cron (recordatorios y caducidad de ofertas) |
| Autenticación del panel | Usuario y contraseña de recepción (Auth.js con credenciales) |
| Despliegue | Vercel + Postgres gestionado (Neon o Supabase) |
| Tests | Vitest para la lógica de disponibilidad y la lista de espera; Playwright para el flujo de reserva |

## 9. Fuera de alcance (versión 1)
- Pagos.
- Historial clínico.
- WhatsApp y SMS.
- Cuentas de paciente.
- Bloqueo de horarios y vacaciones.
- Gestión manual de la lista de espera.

## 10. Criterios de aceptación
- [ ] Un paciente puede reservar sin llamar y recibe un email de confirmación.
- [ ] No es posible reservar dos citas solapadas para el mismo doctor.
- [ ] El recordatorio llega 24 horas antes, y confirmar o cancelar actualiza el estado.
- [ ] Cancelar menos de 2 horas antes desde el enlace está bloqueado.
- [ ] Una cancelación avisa al primero compatible de la lista de espera; si pasan 2 horas sin respuesta, se avisa al siguiente.
- [ ] La recepción puede crear y cancelar citas desde el panel.
- [ ] La lógica de disponibilidad y la de la lista de espera tienen tests.
