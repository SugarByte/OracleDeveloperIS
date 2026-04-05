# OracleDeveloperIS
📊 Oracle SQL – Pipelined Function & XML ETL

Примерен проект с две основни реализации в Oracle:

🔹 Pipelined function за справки с потребители и роли
🔹 XML ETL процес със staging таблица и валидации
📁 Files
pipe.sql – user roles справка чрез pipelined function
LoadXML.sql – XML processing и зареждане в релационен модел

🧩 1. User Roles (Pipelined Function)

Реализира справка за:
-------------------------------------------
 - потребители
 - роли
 - системи

Основни характеристики:
-------------------------------------------
  Филтриране по:
  - офис
  - система
  - роля

Включва потребители без роли (LEFT JOIN)
Използва PIPELINED FUNCTION
View за лесен достъп: 
SELECT * FROM v_user_roles;

📌 Въпроси и отговори – Pipelined Function
1. Какви са предимствата и кога е подходящо да се използват?
🔹 Предимства
📤 Streaming (ред по ред) - Данните се връщат без да се чака целият резултат
🚀 По-добра производителност при големи обеми - Не се държи всичко в памет
🔄 Интеграция със SQL : SELECT * FROM TABLE(p_get_user_roles(...));
🧩 Модулност и повторна употреба

🔹 Подходящи случаи
- Големи резултатни множества
- ETL / Data Warehouse процеси
- Когато резултатът се използва като таблица
- При нужда от трансформация на данни „в движение“

2. Как да се осигури бързодействие?
🔹 Основни препоръки
✔ Индекси върху: p_users.office, p_roles.role_name, p_systems.system_name, FK колони (user_id, role_id)
✔ Филтриране в WHERE 
✔ Избягване на излишни LEFT JOIN ако не са нужни всички данни 
✔ Статистики
BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(USER, 'P_USERS');
END;
✔ Паралелизъм (при големи данни): PARALLEL hint при нужда
✔ Алтернатива: Pure SQL : Често е по-бърз от pipelined function

⚠️ Важно

👉 Pipelined function ≠ винаги по-бързо
👉 Ползва се за гъвкавост и streaming, не само за performance

3. Може ли задачата да се реши по друг начин?

Да — най-често дори по-просто:

🔹 Вариант 1: Чист SQL (най-препоръчван)
SELECT 
    u.username,
    u.login_name,
    u.office,
    s.system_name,
    r.role_name
FROM p_users u
LEFT JOIN p_user_roles ur ON u.user_id = ur.user_id
LEFT JOIN p_roles r ON ur.role_id = r.role_id
LEFT JOIN p_systems s ON r.system_id = s.system_id
WHERE (:p_office IS NULL OR u.office = :p_office)
  AND (:p_system_name IS NULL OR s.system_name = :p_system_name)
  AND (:p_role_name IS NULL OR r.role_name = :p_role_name)
ORDER BY u.username;

✔ По-просто
✔ По-бързо
✔ По-лесно за поддръжка

🔹 Вариант 2: View + параметризиране в приложението
View без параметри
Филтри в application layer

🔹 Вариант 3: Materialized View
при често използвани справки

✔ По-бързо четене
❌ Нужда от refresh

🧠 Заключение
Pipelined function е: мощен инструмент, подходящ при streaming и сложна логика
Но: за този конкретен случай чист SQL е по-добър избор


🧾 2. XML ETL Процес

Обработка на XML данни чрез staging таблица.

Процес
-------------------------------------------

1.Зареждане в xml_staging

2.Валидации:
 - email
 - EGN
 - типове
 - бизнес правила

3.Трансформация чрез XMLTABLE

4.Запис в:
    - x_documents
    - x_taxpayers
    - x_representatives
    - x_doc_enums
    - x_doc_fields

5.Маркиране като DONE


🚀 Стартиране
-------------------------------------------
BEGIN
  load_xml_bulk;
END;

🛠️ Концепция
-------------------------------------------
    Pipelined Functions
    XMLTABLE
    ETL / Staging pattern
    Error handling (rollback + logging)

📌 Бележки
-------------------------------------------
Подходящо за ETL и Data Warehouse сценарии.
Демонстрира работа с XML в Oracle.
Лесно разширяемо с допълнителни валидации

📌 Въпроси и отговори
1. Какъв вариант бихте предложили за валидиране на данните от XML?

Подходът може да бъде разделен на два типа валидиране:

🔹 1. Структурна валидация (XSD)
Използване на XML Schema (XSD)
Валидира структурата, типовете и задължителните полета
XMLTYPE(xml_data, 'doc_schema.xsd')

✔ Предимства:

Гарантира правилна структура
Автоматизирана проверка
🔹 2. Бизнес валидации (в SQL/PLSQL)

Реализират се чрез XMLTABLE и SQL проверки:

валиден email (REGEXP)
EGN формат (10 цифри)
допустими стойности (type = 1 или 2)
логика (напр. representative при hasrepresentative = true)

✔ Предимства:

Гъвкавост
Покрива бизнес правила

✅ Най-добра практика

👉 Комбинация от:

XSD (структура)
SQL/PLSQL (бизнес логика)
2. Може ли задачата да бъде решена по друг начин?

Да — има няколко алтернативни подхода:

🔹 Вариант 1: Без staging таблица

Директно:

INSERT INTO ...
SELECT ...
FROM XMLTABLE(...)

✔ По-просто
❌ Няма retry / error tracking

🔹 Вариант 2: INSERT ALL (bulk loading)
INSERT ALL
  INTO table1 ...
  INTO table2 ...
SELECT ...
FROM XMLTABLE(...)

✔ По-добра производителност
❌ По-труден за поддръжка

🔹 Вариант 3: MERGE (idempotent processing)
Позволява повторно зареждане без дублиране

✔ Подходящ за интеграции

🔹 Вариант 4: Външна обработка (ETL tool / Java / Python)
XML се парсва извън Oracle
В базата влиза вече структурирана информация

✔ По-гъвкаво
❌ Изисква допълнителна система

🔹 Вариант 5: XMLTYPE + XQuery
По-компактен SQL подход

✔ По-малко код
❌ По-труден за сложни сценарии

🧠 Заключение
Да, задачата може да се реализира по различни начини
Избраният подход (staging + XMLTABLE + validations) е:

✅ Най-надежден
✅ Подходящ за enterprise системи
✅ Позволява контрол, логване и повторна обработка