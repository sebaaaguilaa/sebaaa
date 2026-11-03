"""
Transcriptor automatico del Centro de Estudio.

Busca audios en 00_Bandeja, los transcribe en espanol con faster-whisper
(funciona sin internet, en tu propio computador) y guarda el texto en
01_Transcripciones como archivo .md. El audio procesado se mueve a
00_Bandeja/procesados para no transcribirlo dos veces.

Uso:
    python transcribir.py            -> procesa lo que haya en la bandeja
    python transcribir.py --modelo medium   -> mas preciso, mas lento
"""

import argparse
import datetime as dt
import shutil
import sys
import time
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
BANDEJA = RAIZ / "00_Bandeja"
PROCESADOS = BANDEJA / "procesados"
SALIDA = RAIZ / "01_Transcripciones"
REGISTRO = Path(__file__).resolve().parent / "registro.log"
CANDADO = Path(__file__).resolve().parent / ".transcribiendo.lock"

EXTENSIONES = {".mp3", ".m4a", ".wav", ".ogg", ".opus", ".webm", ".mp4", ".aac", ".flac", ".mov"}
SEGUNDOS_SIN_CAMBIOS = 90  # espera a que Drive termine de copiar el archivo


def log(mensaje: str) -> None:
    linea = f"{dt.datetime.now():%Y-%m-%d %H:%M:%S}  {mensaje}"
    print(linea)
    with REGISTRO.open("a", encoding="utf-8") as f:
        f.write(linea + "\n")


def listo_para_procesar(archivo: Path) -> bool:
    """Evita tomar un audio que todavia se esta copiando o sincronizando."""
    return time.time() - archivo.stat().st_mtime > SEGUNDOS_SIN_CAMBIOS


def formato_tiempo(segundos: float) -> str:
    m, s = divmod(int(segundos), 60)
    h, m = divmod(m, 60)
    return f"{h:02d}:{m:02d}:{s:02d}" if h else f"{m:02d}:{s:02d}"


def transcribir(modelo, audio: Path) -> Path:
    segmentos, info = modelo.transcribe(str(audio), language="es", vad_filter=True, beam_size=5)

    lineas = []
    parrafo = []
    inicio_parrafo = None
    for seg in segmentos:
        if inicio_parrafo is None:
            inicio_parrafo = seg.start
        parrafo.append(seg.text.strip())
        # un parrafo cada ~60 segundos para que sea facil de leer y citar
        if seg.end - inicio_parrafo >= 60:
            lineas.append(f"**[{formato_tiempo(inicio_parrafo)}]** " + " ".join(parrafo))
            parrafo, inicio_parrafo = [], None
    if parrafo:
        lineas.append(f"**[{formato_tiempo(inicio_parrafo or 0)}]** " + " ".join(parrafo))

    fecha = dt.datetime.fromtimestamp(audio.stat().st_mtime)
    destino = SALIDA / f"{fecha:%Y-%m-%d}_{audio.stem}.md"
    n = 2
    while destino.exists():
        destino = SALIDA / f"{fecha:%Y-%m-%d}_{audio.stem}_{n}.md"
        n += 1

    encabezado = [
        f"# Transcripcion: {audio.stem}",
        "",
        f"- Fecha del audio: {fecha:%Y-%m-%d %H:%M}",
        f"- Duracion: {formato_tiempo(info.duration)}",
        f"- Archivo original: 00_Bandeja/procesados/{audio.name}",
        "- Estado: SIN REVISAR (la transcripcion automatica puede tener errores en terminos tecnicos)",
        "",
        "## Ramo / tema",
        "_(completar: ej. Neurorehabilitacion - control motor)_",
        "",
        "## Texto",
        "",
    ]
    destino.write_text("\n".join(encabezado + ["\n\n".join(lineas), ""]), encoding="utf-8")
    return destino


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--modelo", default="small",
                        help="tiny, base, small (recomendado), medium, large-v3")
    args = parser.parse_args()

    for carpeta in (BANDEJA, PROCESADOS, SALIDA):
        carpeta.mkdir(parents=True, exist_ok=True)

    pendientes = sorted(
        a for a in BANDEJA.iterdir()
        if a.is_file() and a.suffix.lower() in EXTENSIONES and listo_para_procesar(a)
    )
    if not pendientes:
        return 0

    if CANDADO.exists() and time.time() - CANDADO.stat().st_mtime < 6 * 3600:
        log("Ya hay una transcripcion en curso; salto esta ejecucion.")
        return 0
    CANDADO.write_text(str(dt.datetime.now()), encoding="utf-8")

    try:
        from faster_whisper import WhisperModel
        log(f"Cargando modelo '{args.modelo}' ({len(pendientes)} audio(s) pendiente(s))")
        modelo = WhisperModel(args.modelo, device="cpu", compute_type="int8")

        for audio in pendientes:
            try:
                log(f"Transcribiendo {audio.name} ...")
                destino = transcribir(modelo, audio)
                shutil.move(str(audio), str(PROCESADOS / audio.name))
                log(f"Listo -> {destino.name}")
            except Exception as e:  # sigue con el siguiente audio
                log(f"ERROR con {audio.name}: {e}")
    finally:
        CANDADO.unlink(missing_ok=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
