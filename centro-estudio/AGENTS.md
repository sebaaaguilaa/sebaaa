# Instrucciones para cualquier IA que trabaje en esta carpeta

> Este archivo lo leen Claude (como `CLAUDE.md`), Hermes y otros agentes (como `AGENTS.md`).
> Si lo pegas en ChatGPT o en otra IA, sirve como contexto inicial.
> Es la "memoria compartida": lo que se aprende aquí lo usan todas las IAs.

## Quién soy
Estudiante de Kinesiología (6 ramos). Entreno pesas, judo, BJJ y wrestling.
Prioridades de estudio: **neurorehabilitación, musculoesquelético y cardiorrespiratorio**.
Quiero razonamiento clínico: anatomía → fisiología → fisiopatología → evaluación → CIF →
diagnóstico kinésico → jerarquización de problemas → objetivos → intervención.

## Cómo está organizada la carpeta
| Carpeta | Qué va ahí | Quién escribe |
|---|---|---|
| `00_Plan_semanal/` | Plan de la semana (1 prioridad + máx. 2 secundarias por día) | IA propone, yo apruebo |
| `00_Bandeja/` | Todo lo nuevo sin procesar: audios de clase, fotos de apuntes, PDFs | Yo |
| `01_Transcripciones/` | Texto automático de los audios (puede tener errores) | El transcriptor |
| `02_Apuntes/<ramo>/` | Apuntes limpios, resúmenes, casos, preguntas | Yo + IA |
| `03_Para_IA/` | Material listo para subir a ChatGPT/Claude, prompts guardados | Yo + IA |
| `04_Automatizaciones/` | Scripts (no tocar sin avisar) | IA con permiso |
| `05_Memoria_IA/` | `aprendizajes.md` (memoria que crece) | IA |
| `Ideas_para_despues/` | Ideas nuevas que no son para esta semana | Yo + IA |

## Reglas de trabajo
1. **No borres ni sobrescribas** archivos míos. Crea uno nuevo o pregunta.
2. Al procesar una transcripción: corrige términos técnicos, ordénala por temas y guárdala
   en `02_Apuntes/<ramo>/` con el nombre `AAAA-MM-DD_tema.md`. Marca la transcripción
   original como `Estado: REVISADA`.
3. En cada apunte distingue: **lo que dice la fuente**, **lo que se infiere** y **lo que falta comprobar**.
4. Termina cada apunte con **5 preguntas para responder sin mirar** y, si aplica, **un mini caso clínico**.
5. No confundas leer con aprender: propón recuperación activa, explicación en voz alta o casos.
6. Plan diario: **1 prioridad principal + máximo 2 secundarias**. No llenar todo el tiempo libre (70–80 %).
7. No asumas diagnósticos sobre mi salud ni conviertas cada momento libre en tarea.
8. Ideas nuevas → `Ideas_para_despues/`, no al plan de hoy.

## Aprender de cada sesión ("que aprenda solo")
Al terminar una tarea, agrega 1–3 líneas a `05_Memoria_IA/aprendizajes.md` con:
- qué me costó entender o qué error cometí,
- qué formato de estudio me sirvió,
- qué preferencia nueva dije.
Antes de empezar una tarea, **lee `aprendizajes.md`** y aplícalo.
