# ISSUE: нет файла официального сборника задач УУ

**ID:** ISS-002  
**Created:** 2026-08-21  
**Updated:** 2026-08-21 (re-check after portal AUTH_OK)  
**Severity:** High (блокирует EXAM-001 PDF)  
**Status:** Open — **EXAM_BLOCKED** (не entitlement на издание)

## Description

Официальный «Сборник задач… управленческий учёт… ERP 2.5» (экзамен март 2026, код **4601546149909**, артикул **Online015254**, 750 руб.) не скачан.

Повторная проверка в живой сессии Chrome (`Kuleshov_Sergey`, portal/releases/ITS AUTH_OK):

1. https://online.1c.ru/books/book/36275450/ — карточка открывается; явно: **«Вы можете скачать эти файлы после оплаты»**; целевые имена `1C_UU_v_ERP_2026.pdf` / `.epub`.
2. https://online.1c.ru/personal/active_subscribes/ — **требуется отдельный логин** online.1c.ru (сессия portal.1c.ru не переносится).
3. https://portal.1c.ru/software/registration — **нет зарегистрированных продуктов**; покупка/код 4601546149909 не привязаны.
4. https://exam1s.ru/news/16-03-2026-1s-spec-cons-uu-erp-25/ — публичный анонс доступен (не замена PDF).

## Impact

Нельзя разобрать экзаменационные билеты по полному тексту сборника. Публичные HTML-анонсы лежат в `exam/materials/official/`.

## Proposed Solution

Официально купить издание → скачать PDF/EPUB в ЛК online.1c.ru → положить в `exam/materials/official/` → обновить `SOURCE.md` на EXAM_OK.

Пиратские источники запрещены.
