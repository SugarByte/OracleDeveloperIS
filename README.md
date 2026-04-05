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



🧾 2. XML ETL Process

Обработка на XML данни чрез staging таблица.

Flow
-------------------------------------------

1.Зареждане в xml_staging

2.Валидации:
 - email
 - EGN
 - типове
 - бизнес правила

3.Трансформация чрез XMLTABLE

4.Запис в:
    x_documents
    x_taxpayers
    x_representatives
    x_doc_enums
    x_doc_fields

5.Маркиране като DONE


🚀 Run
-------------------------------------------
BEGIN
  load_xml_bulk;
END;

🛠️ Concepts
-------------------------------------------
    Pipelined Functions
    XMLTABLE
    ETL / Staging pattern
    Error handling (rollback + logging)

📌 Notes
-------------------------------------------
Подходящо за ETL и Data Warehouse сценарии
Демонстрира работа с XML в Oracle
Лесно разширяемо с допълнителни валидации