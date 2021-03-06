CREATE OR REPLACE PROCEDURE CREATE_LARGE_TABLE_SPACE
BEGIN
	IF NOT EXISTS (SELECT * FROM SYSCAT.BUFFERPOOLS WHERE BPNAME = 'BP32K')
	THEN
		EXECUTE IMMEDIATE 'CREATE BUFFERPOOL BP32K IMMEDIATE SIZE 250 AUTOMATIC PAGESIZE 32K';
	END IF;
    IF NOT EXISTS (SELECT * FROM SYSIBM.SYSTABLESPACES WHERE TBSPACE = 'TS32K')
    THEN
    	EXECUTE IMMEDIATE 'CREATE LARGE TABLESPACE TS32K PAGESIZE 32K MANAGED by AUTOMATIC STORAGE BUFFERPOOL BP32K';
    END IF;
END
/

CALL CREATE_LARGE_TABLE_SPACE
/

DROP PROCEDURE CREATE_LARGE_TABLE_SPACE
/

CALL SYSPROC.ADMIN_MOVE_TABLE(
(SELECT TABSCHEMA FROM SYSCAT.TABLES where TABNAME = 'IDN_SCIM_GROUP'),
'IDN_SCIM_GROUP',
(SELECT TBSPACE FROM SYSCAT.TABLES where TABNAME = 'IDN_SCIM_GROUP'),
'TS32K',
(SELECT TBSPACE FROM SYSCAT.TABLES where TABNAME = 'IDN_SCIM_GROUP'),
'',
'',
'',
'',
'',
'MOVE')
/
ALTER TABLE IDN_OAUTH_CONSUMER_APPS ADD ID_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600
/
CREATE TABLE IDN_AUTH_TEMP_SESSION_STORE (
            SESSION_ID VARCHAR (100) NOT NULL,
            SESSION_TYPE VARCHAR(100) NOT NULL,
            OPERATION VARCHAR(10) NOT NULL,
            SESSION_OBJECT BLOB,
            TIME_CREATED BIGINT NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            EXPIRY_TIME BIGINT,
            PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
)
/
ALTER TABLE IDN_AUTH_SESSION_STORE ADD EXPIRY_TIME BIGINT
/
CREATE INDEX IDX_AT_TI_UD ON IDN_OAUTH2_ACCESS_TOKEN(AUTHZ_USER, TENANT_ID, TOKEN_STATE, USER_DOMAIN)
/
CREATE INDEX IDX_AUTHORIZATION_CODE_AU_TI ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHZ_USER,TENANT_ID, USER_DOMAIN, STATE)
/
CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME)
/
CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN_AN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME, ATTR_NAME)
/
CREATE INDEX IDX_IDN_AUTH_SESSION_TIME ON IDN_AUTH_SESSION_STORE (TIME_CREATED)
/
CREATE INDEX IDX_IDN_AUTH_TMP_SESSION_TIME ON IDN_AUTH_TEMP_SESSION_STORE (TIME_CREATED)
/
