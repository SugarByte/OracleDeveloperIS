DROP view v_user_roles;
DROP FUNCTION p_get_user_roles ;
DROP TYPE p_user_role_tab;
DROP TYPE p_user_role_obj;
DROP TABLE p_user_roles;
DROP TABLE p_roles;
DROP TABLE p_systems;
DROP TABLE p_users;

CREATE TABLE p_users (
    user_id NUMBER PRIMARY KEY,
    username VARCHAR2(100),
    login_name VARCHAR2(100),
    office VARCHAR2(100)
);

CREATE TABLE p_systems (
    system_id NUMBER PRIMARY KEY,
    system_name VARCHAR2(100)
);

CREATE TABLE p_roles (
    role_id NUMBER PRIMARY KEY,
    role_name VARCHAR2(100),
    system_id NUMBER REFERENCES p_systems(system_id)
);

CREATE TABLE p_user_roles (
    user_id NUMBER REFERENCES p_users(user_id),
    role_id NUMBER REFERENCES p_roles(role_id)
);

INSERT INTO P_USERS(USER_ID, USERNAME, LOGIN_NAME, OFFICE) VALUES(1,'Потребител 2','User1','София');
INSERT INTO P_USERS(USER_ID, USERNAME, LOGIN_NAME, OFFICE) VALUES(2,'Потребител 3','User2','София');
INSERT INTO P_USERS(USER_ID, USERNAME, LOGIN_NAME, OFFICE) VALUES(3,'Потребител 4','User3','Пловдив');
INSERT INTO P_USERS(USER_ID, USERNAME, LOGIN_NAME, OFFICE) VALUES(4,'Потребител 5','User4','Пловдив');
INSERT INTO P_USERS(USER_ID, USERNAME, LOGIN_NAME, OFFICE) VALUES(5,'Потребител 6','User5','Пловдив');
INSERT INTO P_USERS(USER_ID, USERNAME, LOGIN_NAME, OFFICE) VALUES(6,'Потребител 7','User6','София');
INSERT INTO P_USERS(USER_ID, USERNAME, LOGIN_NAME, OFFICE) VALUES(7,'Потребител 8','User7','Пловдив');
INSERT INTO P_USERS(USER_ID, USERNAME, LOGIN_NAME, OFFICE) VALUES(8,'Потребител 9','User8','Бургас');

INSERT INTO P_SYSTEMS(SYSTEM_ID, SYSTEM_NAME) VALUES (1,'Система 1');
INSERT INTO P_SYSTEMS(SYSTEM_ID, SYSTEM_NAME) VALUES (2,'Система 2');
INSERT INTO P_SYSTEMS(SYSTEM_ID, SYSTEM_NAME) VALUES (3,'Система 3');

INSERT INTO P_ROLES(ROLE_ID, ROLE_NAME, SYSTEM_ID) values(1,'Роля 1',1);
INSERT INTO P_ROLES(ROLE_ID, ROLE_NAME, SYSTEM_ID) values(2,'Роля 2',1);
INSERT INTO P_ROLES(ROLE_ID, ROLE_NAME, SYSTEM_ID) values(3,'Роля 1',2);
INSERT INTO P_ROLES(ROLE_ID, ROLE_NAME, SYSTEM_ID) values(4,'Роля 1',3);
INSERT INTO P_ROLES(ROLE_ID, ROLE_NAME, SYSTEM_ID) values(5,'Роля 2',3);
INSERT INTO P_ROLES(ROLE_ID, ROLE_NAME, SYSTEM_ID) values(6,'Роля 3',3);

INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(1,3);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(2,1);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(3,3);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(3,5);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(3,6);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(5,1);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(5,2);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(5,3);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(7,3);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(7,5);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(7,6);
INSERT INTO P_USER_ROLES(USER_ID, ROLE_ID) VALUES(8,3);

COMMIT;

CREATE OR REPLACE TYPE p_user_role_obj AS OBJECT (
    username     VARCHAR2(100),
    login_name   VARCHAR2(100),
    office       VARCHAR2(100),
    system_name  VARCHAR2(100),
    role_name    VARCHAR2(100)
);
/

CREATE OR REPLACE TYPE p_user_role_tab AS TABLE OF p_user_role_obj;
/

CREATE OR REPLACE FUNCTION p_get_user_roles (
    p_office      VARCHAR2 DEFAULT NULL,
    p_system_name VARCHAR2 DEFAULT NULL,
    p_role_name   VARCHAR2 DEFAULT NULL
)
RETURN p_user_role_tab PIPELINED
AS
BEGIN
    FOR rec IN (
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
        WHERE (p_office IS NULL OR u.office = p_office)
          AND (p_system_name IS NULL OR s.system_name = p_system_name)
          AND (p_role_name IS NULL OR r.role_name = p_role_name)
        ORDER BY u.username
    )
    LOOP
        PIPE ROW (
            p_user_role_obj(
                rec.username,
                rec.login_name,
                rec.office,
                rec.system_name,
                rec.role_name
            )
        );
    END LOOP;

    RETURN;
END;
/

CREATE OR REPLACE VIEW v_user_roles AS
SELECT *
FROM TABLE(p_get_user_roles());
/


--Задача 1: 
--Да се създаде справка, чрез pipelined function и view за извличане на данни за всички потребители, с техните роли в системите, подредени по потребителско име. Някои потребители може да нямат присвоена роля, но те също трябва да излизат в справката. Резултатът да бъде в следния вид: 
SELECT * FROM v_user_roles;

--Задача 2: 
--Да се реализира възможност за филтриране на справката от задача 1, с възможност за задаване на параметри като офис, наименование на система, или роля, както и в комбинация.
SELECT *
FROM TABLE(p_get_user_roles(
    p_office => 'Пловдив',
    p_system_name => 'Система 3',
    p_role_name => 'Роля 2'
));

SELECT *
FROM TABLE(p_get_user_roles(p_office => 'София'));

SELECT *
FROM TABLE(p_get_user_roles(
    p_system_name => 'Система 2',
    p_role_name => 'Роля 1'
));

SELECT *
FROM TABLE(p_get_user_roles(
    p_system_name => 'Система 2',
    p_role_name => 'Роля 1'
));

SELECT *
FROM TABLE(p_get_user_roles(
    p_system_name => null
));

--В крайна сметка може да се ползва прост SQL
--SELECT 
--    u.username,
--    u.login_name,
--    u.office,
--    s.system_name,
--    r.role_name
--FROM p_users u
--LEFT JOIN p_user_roles ur ON u.user_id = ur.user_id
--LEFT JOIN p_roles r ON ur.role_id = r.role_id
--LEFT JOIN p_systems s ON r.system_id = s.system_id
--WHERE (:p_office IS NULL OR u.office = :p_office)
--  AND (:p_system_name IS NULL OR s.system_name = :p_system_name)
--  AND (:p_role_name IS NULL OR r.role_name = :p_role_name)
--ORDER BY u.username