# Report: Online Course 2021 — Full-Text Conspects

**Date:** 2026-08-22  
**Orchestration:** orch-course-2021  
**Status:** ✅ Completed  
**Knowledge base:** [docs/online-course-2021/](../../../docs/online-course-2021/README.md)

## Summary

Full-text structured conspects were produced for **all five** video lectures of the online course «Основные механизмы платформы 1С:Предприятие 8.3» (Apr–May 2021). Each lecture has a markdown conspect under `docs/online-course-2021/`, plus workspace transcripts (JSON, raw text, speech metadata). Videos were **not trimmed**; the full audio track was transcribed with VAD. `speech_start_sec` is recorded for navigation only.

## Source

| Item | Path |
|------|------|
| Video folder | `C:\Users\Administrator\Documents\1С_старое\Запись курса 1` |
| Conspects (published) | `docs/online-course-2021/` |
| Transcripts (workspace) | `.cursor/workspace/active/orch-course-2021/transcripts/` |
| Pipeline tools | `.tools/transcription/` (`detect_speech.py`, chunked faster-whisper, `generate_conspect.py`) |

## Pipeline

1. **`detect_speech`** — ffmpeg `silencedetect` → `*.speech.json` (`speech_start_sec`, `duration_sec`, silence params).
2. **Chunked faster-whisper `base`** — 600 s chunks, **VAD on**; full audio (no trim to speech start).
3. **`generate_conspect.py`** — structured markdown conspects from transcript JSON + speech metadata.

> **Note:** Videos are **not** trimmed. Full audio is transcribed with VAD; silence at the start may appear as empty/low-content segments until speech begins. Use `speech_start_sec` to jump in the original MP4.

## Speech start times (from `.speech.json`)

| Lecture | Date | `speech_start_sec` | ≈ h:m:s | `duration_sec` | ≈ duration |
|---------|------|--------------------|---------|----------------|------------|
| 01 | 30.04.2021 | **1399.195** | 23:19 | 26708.096 | 7:25:08 |
| 02 | 04.05.2021 | **988.194** | 16:28 | 26349.120 | 7:19:09 |
| 03 | 05.05.2021 | **1967.837** | 32:47 | 27533.824 | 7:38:53 |
| 04 | 06.05.2021 | **18.418** | 0:18 | 25249.600 | 7:00:49 |
| 05 | 07.05.2021 | **0.000** | 0:00 | 24611.712 | 6:50:11 |

Detection method (all): `ffmpeg_silencedetect`, `silence_noise_db: -45`, `min_silence_sec: 10`.

## Output files

### Conspects (`docs/online-course-2021/`)

| File | Size | Status |
|------|------|--------|
| [lecture-01-2021-04-30.md](../../../docs/online-course-2021/lecture-01-2021-04-30.md) | 71 778 B (~70.1 KB) | complete |
| [lecture-02-2021-05-04.md](../../../docs/online-course-2021/lecture-02-2021-05-04.md) | 63 315 B (~61.8 KB) | complete |
| [lecture-03-2021-05-05.md](../../../docs/online-course-2021/lecture-03-2021-05-05.md) | 61 230 B (~59.8 KB) | complete |
| [lecture-04-2021-05-06.md](../../../docs/online-course-2021/lecture-04-2021-05-06.md) | 67 932 B (~66.3 KB) | complete |
| [lecture-05-2021-05-07.md](../../../docs/online-course-2021/lecture-05-2021-05-07.md) | 64 144 B (~62.6 KB) | complete |
| **Total conspects** | **~328 KB** | 5/5 |

### Transcripts (workspace — retained, not deleted)

| Lecture | `.json` | `.raw.txt` | `.speech.json` |
|---------|---------|------------|----------------|
| 01 | 784 274 B (~766 KB) | 428 150 B (~418 KB) | present |
| 02 | 693 151 B (~677 KB) | 380 958 B (~372 KB) | present |
| 03 | 687 471 B (~671 KB) | 388 308 B (~379 KB) | present |
| 04 | 698 567 B (~682 KB) | 392 882 B (~384 KB) | present |
| 05 | 626 704 B (~612 KB) | 353 836 B (~346 KB) | present |
| **Approx. total** | **~3.4 MB JSON** | **~1.9 MB raw** | 5 files |

## Lecture topics (high level)

| № | Focus (from conspect goals / content) |
|---|----------------------------------------|
| 01 | Course intro; platform architecture (thin/thick client, managed app); IB/configurator; CF; extensions; common pictures/layouts |
| 02 | Metadata objects: catalogs, documents, registers, enums, charts of characteristic types; forms and links |
| 03 | Registers (information / accumulation), periodicity, dimensions/resources; posting patterns |
| 04 | Data composition system (СКД): lists → tables/crosstabs; report variants |
| 05 | Business processes / tasks; analysis via queries and DCS; remaining platform constructs |

## Knowledge base role for agents

Published path: **`docs/online-course-2021/`** (also linked from [docs/README.md](../../../docs/README.md)).

Agents should treat this folder as a **read-only knowledge base** for:

- Platform concepts explained in the 2021 course (architecture, metadata, registers, DCS, business processes).
- Cross-checking explanations against lecture conspects before inventing platform behavior.
- Finding approximate video timestamps via conspect timecodes and `speech_start_sec`.

Prefer conspects over raw transcripts for answers; use `.json` / `.raw.txt` only when a verbatim quote or deeper search is needed. Do **not** delete workspace transcript files.

## Metrics

| Metric | Value |
|--------|-------|
| Lectures completed | 5 / 5 |
| Conspect files | 5 |
| Transcript artifact sets | 5 × (json + raw.txt + speech.json) |
| STT model | faster-whisper `base` + VAD |
| Chunk length | 600 s |
| Video trim | **No** (full audio) |
| Index README | [docs/online-course-2021/README.md](../../../docs/online-course-2021/README.md) — all complete |

## Related documentation

- Index: [docs/online-course-2021/README.md](../../../docs/online-course-2021/README.md)
- Docs hub: [docs/README.md](../../../docs/README.md)
- Tools: `.tools/transcription/detect_speech.py`, `generate_conspect.py`, `run_all.ps1`

## Next steps (optional)

1. Refine lecture 04–05 «Цели лекции» sections if richer topic abstracts are desired.
2. Add cross-links from platform learning docs to specific lectures.
3. Keep transcripts in `orch-course-2021/transcripts/` for re-generation or search.
