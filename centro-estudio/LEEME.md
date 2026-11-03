# Centro de Estudio con IA — cómo funciona

## La idea en una frase
**Una sola carpeta en tu computador, sincronizada con Google Drive, que todas tus IAs pueden leer y escribir.**
Tú dejas material crudo; las automatizaciones lo transcriben; las IAs lo convierten en apuntes,
preguntas y planes; y todas comparten la misma memoria (`AGENTS.md` + `aprendizajes.md`).

```
   TÚ (audio de clase, foto de apuntes, PDF)
              │
              ▼
      00_Bandeja/  ──(cada 15 min, automático, en tu PC)──►  01_Transcripciones/
                                                                   │
              ┌────────────────────────────────────────────────────┘
              ▼
   Claude / ChatGPT / Hermes leen, corrigen y ordenan
              │
              ▼
   02_Apuntes/<ramo>/  →  resumen + 5 preguntas sin mirar + mini caso
              │
              ▼
   05_Memoria_IA/aprendizajes.md  (lo que la IA aprende de ti, para la próxima vez)

   Todo esto vive en tu PC y se copia solo a Google Drive (y al revés).
```

## Qué hace cada herramienta

| Herramienta | Para qué usarla | Cómo llega a la carpeta |
|---|---|---|
| **Google Drive para escritorio** | El "pegamento": copia la carpeta entre tu PC, la nube y el celular | Ya lo tienes: "Mi portátil → IA" |
| **Transcriptor (Whisper local)** | Pasar audios a texto automáticamente, gratis y sin internet | Script `04_Automatizaciones/transcribir.py` + tarea programada de Windows |
| **Claude (app web/celular)** | Estudiar, planificar la semana, crear Word/Docs, revisar apuntes | Conector de Google Drive (ya conectado) |
| **Claude Code (app de escritorio, pestaña Code)** | Trabajar *directo* en tus archivos: ordenar transcripciones, crear apuntes, mejorar scripts | Abres la carpeta `Centro Estudio` en la app; lee `CLAUDE.md` solo |
| **ChatGPT** | Segunda opinión, modo voz para explicar en voz alta | Conector de Google Drive en ChatGPT, o subir archivos de `03_Para_IA/` |
| **Hermes Agent** (opcional, más adelante) | Agente que corre en tu PC 24/7, tareas programadas, Telegram, memoria propia | En Windows necesita **WSL2**; ve la sección de abajo |

**Regla para que no sea un caos:** una herramienta por tarea.
Transcribir = Whisper. Procesar y estudiar = Claude. Segunda opinión/voz = ChatGPT. Agente 24/7 = Hermes (solo cuando lo demás ya funcione).

---

## Paso 1 — Instalar el transcriptor (una vez, ~10 min)

1. En el Explorador de Windows abre `Centro Estudio\04_Automatizaciones`.
2. Clic en la barra de dirección, escribe `powershell` y presiona Enter.
3. Pega:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\instalar.ps1
   ```
4. Prueba: copia un audio corto a `00_Bandeja`, espera 2 minutos y haz doble clic en
   `04_Automatizaciones\transcribir-ahora.bat`. El texto aparece en `01_Transcripciones`.

Desde ahí, cada 15 minutos se transcribe solo lo que dejes en la bandeja (con el PC encendido).
Del celular: graba la clase y súbela a la carpeta `00_Bandeja` desde la app de Google Drive.

## Paso 2 — Conectar Claude directamente a la carpeta

**Opción A (recomendada): app de escritorio de Claude → pestaña *Code*** → elegir la carpeta `Centro Estudio`.
Claude lee `CLAUDE.md` automáticamente y puede crear/editar apuntes ahí.

**Opción B: terminal.** En PowerShell:
```powershell
irm https://claude.ai/install.ps1 | iex
cd "RUTA\A\Centro Estudio"
claude
```
(Para la ruta: clic derecho sobre la carpeta → "Copiar como ruta de acceso".)

Pedidos útiles:
- "Procesa las transcripciones SIN REVISAR de hoy siguiendo AGENTS.md."
- "Hazme 10 preguntas de recuperación activa de Neurorehabilitación de esta semana, sin mostrar respuestas."
- "Con mis apuntes de Cardiorrespiratorio arma un caso clínico con CIF y pregúntame paso a paso."
- "Convierte el apunte X en un Word para imprimir."

## Paso 3 — ChatGPT
En ChatGPT: Configuración → Aplicaciones/Conectores → Google Drive. Así puede leer tus apuntes.
Para darle contexto, pega el contenido de `AGENTS.md` en sus "Instrucciones personalizadas"
o en un Proyecto de ChatGPT llamado "Kinesiología".

## Paso 4 (opcional, cuando lo anterior ya funcione) — Hermes Agent
Hermes es útil si quieres un agente que trabaje solo (programar tareas, avisarte por Telegram).
1. Instala WSL2: en PowerShell como administrador → `wsl --install` → reinicia.
2. Dentro de Ubuntu (WSL), instala Hermes con el script oficial del repositorio
   `NousResearch/hermes-agent` (sigue su README; cambia seguido).
3. Tu carpeta de Windows se ve en WSL como `/mnt/c/Users/Marcelo/...`.
   Inicia Hermes dentro de esa carpeta para que lea `AGENTS.md`.
4. Pídele, por ejemplo: "Cada domingo a las 18:00 revisa 02_Apuntes y 01_Transcripciones
   y propone el plan de estudio de la semana en 00_Plan_semanal."

> "Que aprenda solo" significa, en la práctica: guardar memoria en archivos y releerla.
> Ningún asistente se reentrena con tus datos; mejora porque lee `AGENTS.md` y
> `aprendizajes.md` cada vez. Revisa esos archivos de vez en cuando: tú tienes el control.

## Mantenimiento (5 min a la semana)
- Domingo: vacía `00_Bandeja` (lo que no se procesó), revisa `aprendizajes.md`.
- Si una transcripción sale mal en términos técnicos: prueba `--modelo medium` en `transcribir-ahora.bat`.
- Para apagar la transcripción automática:
  `Unregister-ScheduledTask -TaskName "CentroEstudio-Transcribir" -Confirm:$false`
