--
-- Title:      Core Repository Tables
-- Database:   ORACLE
-- Since:      V3.3 Schema 4000
-- Author:     PaulWeb
--

create table ALF_APPLIED_PATCH
(
  ID                VARCHAR2(64) not null,
  DESCRIPTION       VARCHAR2(2048),
  FIXES_FROM_SCHEMA NUMBER,
  FIXES_TO_SCHEMA   NUMBER,
  APPLIED_TO_SCHEMA NUMBER,
  TARGET_SCHEMA     NUMBER,
  APPLIED_ON_DATE   TIMESTAMP(6),
  APPLIED_TO_SERVER VARCHAR2(64),
  WAS_EXECUTED      NUMBER,
  SUCCEEDED         NUMBER,
  REPORT            VARCHAR2(2048),
  PRIMARY KEY (id)
);

create table ALF_LOCALE
(
  ID         NUMBER(19) not null,
  VERSION    NUMBER(19) not null,
  LOCALE_STR VARCHAR2(20 CHAR) not null,
    PRIMARY KEY (id),
    constraint locale_str UNIQUE (locale_str)
);
CREATE SEQUENCE ALF_LOCALE_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_NAMESPACE
(
  ID      NUMBER not null,
  VERSION NUMBER not null,
  URI     VARCHAR2(100) not null,
   PRIMARY KEY (id),
   constraint uri UNIQUE (uri)  
);
CREATE SEQUENCE ALF_NAMESPACE_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_QNAME
(
  ID         NUMBER not null,
  VERSION    NUMBER not null,
  NS_ID      NUMBER not null,
  LOCAL_NAME VARCHAR2(200) not null,
  PRIMARY KEY (id),
  constraint ns_id UNIQUE (ns_id, local_name),  
  CONSTRAINT fk_alf_qname_ns FOREIGN KEY (ns_id) REFERENCES alf_namespace (id)
);
CREATE SEQUENCE ALF_QNAME_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_PERMISSION
(
  ID            NUMBER(19) not null,
  VERSION       NUMBER(19) not null,
  TYPE_QNAME_ID NUMBER(19) not null,
  NAME          VARCHAR2(100 CHAR) not null,
  PRIMARY KEY (id),
  constraint type_qname_id UNIQUE  (type_qname_id, name), 
  CONSTRAINT fk_alf_perm_tqn FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id)
);
create index fk_alf_perm_tqn on ALF_PERMISSION (type_qname_id);
CREATE SEQUENCE ALF_PERMISSION_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_ACE_CONTEXT
(
  ID               NUMBER(19) not null,
  VERSION          NUMBER(19) not null,
  CLASS_CONTEXT    VARCHAR2(1024 CHAR),
  PROPERTY_CONTEXT VARCHAR2(1024 CHAR),
  KVP_CONTEXT      VARCHAR2(1024 CHAR),
   PRIMARY KEY (id)
);
CREATE SEQUENCE ALF_ACE_CONTEXT_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_AUTHORITY
(
  ID        NUMBER(19) not null,
  VERSION   NUMBER(19) not null,
  AUTHORITY VARCHAR2(100 CHAR),
  CRC       NUMBER(19),
    PRIMARY KEY (id),
    constraint authority UNIQUE (authority, crc)
 );
create index idx_alf_auth_aut on ALF_AUTHORITY (authority);
CREATE SEQUENCE ALF_AUTHORITY_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_ACCESS_CONTROL_ENTRY
(
  ID            NUMBER(19) not null,
  VERSION       NUMBER(19) not null,
  PERMISSION_ID NUMBER(19) not null,
  AUTHORITY_ID  NUMBER(19) not null,
  ALLOWED       NUMBER(1) not null,
  APPLIES       NUMBER(10) not null,
  CONTEXT_ID    NUMBER(19),
  PRIMARY KEY (id),
	constraint  permission_id UNIQUE  (permission_id, authority_id, allowed, applies),	
	CONSTRAINT fk_alf_ace_auth FOREIGN KEY (authority_id) REFERENCES alf_authority (id),
	CONSTRAINT fk_alf_ace_ctx FOREIGN KEY (context_id) REFERENCES alf_ace_context (id),
	CONSTRAINT fk_alf_ace_perm FOREIGN KEY (permission_id) REFERENCES alf_permission (id)
);
create index fk_alf_ace_auth on ALF_ACCESS_CONTROL_ENTRY (authority_id);
create index fk_alf_ace_ctx on ALF_ACCESS_CONTROL_ENTRY (context_id);
create index fk_alf_ace_perm on ALF_ACCESS_CONTROL_ENTRY (permission_id);
CREATE SEQUENCE ALF_ACCESS_CONTROL_ENTRY_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_ACL_CHANGE_SET
(
  ID      NUMBER(19) not null,
  commit_time_ms NUMBER(19),
  PRIMARY KEY (id)
);
CREATE INDEX idx_alf_acs_ctms ON alf_acl_change_set (commit_time_ms);
CREATE SEQUENCE ALF_ACL_CHANGE_SET_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_ACCESS_CONTROL_LIST
(
  ID               NUMBER(19) not null,
  VERSION          NUMBER(19) not null,
  ACL_ID           VARCHAR2(36 CHAR) not null,
  LATEST           NUMBER(1) not null,
  ACL_VERSION      NUMBER(19) not null,
  INHERITS         NUMBER(1) not null,
  INHERITS_FROM    NUMBER(19),
  TYPE             NUMBER(10) not null,
  INHERITED_ACL    NUMBER(19),
  IS_VERSIONED     NUMBER(1) not null,
  REQUIRES_VERSION NUMBER(1) not null,
  ACL_CHANGE_SET   NUMBER(19),
    PRIMARY KEY (id),
    constraint acl_id UNIQUE   (acl_id, latest, acl_version),
    CONSTRAINT fk_alf_acl_acs FOREIGN KEY (acl_change_set) REFERENCES alf_acl_change_set (id)
);
create index fk_alf_acl_acs on ALF_ACCESS_CONTROL_LIST (acl_change_set);
create index idx_alf_acl_inh on ALF_ACCESS_CONTROL_LIST (inherits, inherits_from);
CREATE SEQUENCE ALF_ACCESS_CONTROL_LIST_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_ACL_MEMBER
(
  ID      NUMBER(19) not null,
  VERSION NUMBER(19) not null,
  ACL_ID  NUMBER(19) not null,
  ACE_ID  NUMBER(19) not null,
  POS     NUMBER(10) not null,
   PRIMARY KEY (id),
    constraint aclm_acl_id UNIQUE   (acl_id, ace_id, pos), 
    CONSTRAINT fk_alf_aclm_ace FOREIGN KEY (ace_id) REFERENCES alf_access_control_entry (id),
    CONSTRAINT fk_alf_aclm_acl FOREIGN KEY (acl_id) REFERENCES alf_access_control_list (id)
);
create index fk_alf_aclm_ace on ALF_ACL_MEMBER (ace_id);
create index fk_alf_aclm_acl on ALF_ACL_MEMBER (acl_id);
CREATE SEQUENCE ALF_ACL_MEMBER_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_AUTHORITY_ALIAS
(
  ID       NUMBER(19) not null,
  VERSION  NUMBER(19) not null,
  AUTH_ID  NUMBER(19) not null,
  ALIAS_ID NUMBER(19) not null,
   PRIMARY KEY (id),
    constraint auth_id UNIQUE  (auth_id, alias_id),  
    CONSTRAINT fk_alf_autha_aut FOREIGN KEY (auth_id) REFERENCES alf_authority (id),
    CONSTRAINT fk_alf_autha_ali FOREIGN KEY (alias_id) REFERENCES alf_authority (id)
);
create index fk_alf_autha_aut on ALF_AUTHORITY_ALIAS (auth_id);
create index fk_alf_autha_ali on ALF_AUTHORITY_ALIAS (alias_id);
CREATE SEQUENCE ALF_AUTHORITY_ALIAS_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_SERVER
(
  ID         NUMBER(19) not null,
  VERSION    NUMBER(19) not null,
  IP_ADDRESS VARCHAR2(39 CHAR) not null,
     PRIMARY KEY (id),
    constraint  ip_address UNIQUE  (ip_address)
);
CREATE SEQUENCE ALF_SERVER_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_TRANSACTION
(
  ID             NUMBER(19) not null,
  VERSION        NUMBER(19) not null,
  SERVER_ID      NUMBER(19),
  CHANGE_TXN_ID  VARCHAR2(56 CHAR) not null,
  COMMIT_TIME_MS NUMBER(19),
   PRIMARY KEY (id),   
   CONSTRAINT fk_alf_txn_svr FOREIGN KEY (server_id) REFERENCES alf_server (id)
);
create index fk_alf_txn_svr on ALF_TRANSACTION (server_id);
create index idx_alf_txn_ctms on ALF_TRANSACTION (commit_time_ms, id);
CREATE SEQUENCE ALF_TRANSACTION_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_STORE
(
  ID           NUMBER(19) not null,
  VERSION      NUMBER(19) not null,
  PROTOCOL     VARCHAR2(50 CHAR) not null,
  IDENTIFIER   VARCHAR2(100 CHAR) not null,
  ROOT_NODE_ID NUMBER(19),
  PRIMARY KEY (id),
  constraint  protocol UNIQUE  (protocol, identifier) 
);
CREATE SEQUENCE ALF_STORE_SEQ START WITH 1 INCREMENT BY 1 ORDER;

create table ALF_NODE
(
  ID             NUMBER(19) not null,
  VERSION        NUMBER(19) not null,
  STORE_ID       NUMBER(19) not null,
  UUID           VARCHAR2(36 CHAR) not null,
  TRANSACTION_ID NUMBER(19) not null,
  TYPE_QNAME_ID  NUMBER(19) not null,
  locale_id NUMBER NOT NULL,
  ACL_ID         NUMBER(19),
  AUDIT_CREATOR  VARCHAR2(255 CHAR),
  AUDIT_CREATED  VARCHAR2(30 CHAR),
  AUDIT_MODIFIER VARCHAR2(255 CHAR),
  AUDIT_MODIFIED VARCHAR2(30 CHAR),
  AUDIT_ACCESSED VARCHAR2(30 CHAR),
    PRIMARY KEY (id),
    constraint store_id UNIQUE (store_id, uuid),
    CONSTRAINT fk_alf_node_acl FOREIGN KEY (acl_id) REFERENCES alf_access_control_list (id),
    CONSTRAINT fk_alf_node_store FOREIGN KEY (store_id) REFERENCES alf_store (id),
    CONSTRAINT fk_alf_node_tqn FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id),
    CONSTRAINT fk_alf_node_txn FOREIGN KEY (transaction_id) REFERENCES alf_transaction (id),
    CONSTRAINT fk_alf_node_loc FOREIGN KEY (locale_id) REFERENCES alf_locale (id)
);
CREATE INDEX idx_alf_node_mdq ON alf_node (store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_cor ON alf_node (audit_creator, store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_crd ON alf_node (audit_created, store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_mor ON alf_node (audit_modifier, store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_mod ON alf_node (audit_modified, store_id, type_qname_id, id);
CREATE INDEX idx_alf_node_txn_type ON alf_node (transaction_id, type_qname_id);
create index fk_alf_node_acl on ALF_NODE (acl_id);
create index fk_alf_node_store on ALF_NODE (store_id);
CREATE INDEX idx_alf_node_tqn ON alf_node (type_qname_id, store_id, id);
create index fk_alf_node_loc on ALF_NODE (locale_id);
CREATE SEQUENCE ALF_NODE_SEQ START WITH 1 INCREMENT BY 1 ORDER;

alter table alf_store add CONSTRAINT fk_alf_store_root FOREIGN KEY (root_node_id) REFERENCES alf_node (id);
create index fk_alf_store_root on ALF_STORE (root_node_id); 

create table ALF_CHILD_ASSOC
(
  ID                  NUMBER(19) not null,
  VERSION             NUMBER(19) not null,
  PARENT_NODE_ID      NUMBER(19) not null,
  TYPE_QNAME_ID       NUMBER(19) not null,
  CHILD_NODE_NAME_CRC NUMBER(19) not null,
  CHILD_NODE_NAME     VARCHAR2(50 CHAR) not null,
  CHILD_NODE_ID       NUMBER(19) not null,
  QNAME_NS_ID         NUMBER(19) not null,
  QNAME_LOCALNAME     VARCHAR2(255 CHAR) not null,
  QNAME_CRC           NUMBER(19) not null,
  IS_PRIMARY          NUMBER(1),
  ASSOC_INDEX         NUMBER(10),
   PRIMARY KEY (id),
    constraint parent_node_id UNIQUE  (parent_node_id, type_qname_id, child_node_name_crc, child_node_name),
    CONSTRAINT fk_alf_cass_cnode FOREIGN KEY (child_node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_cass_pnode FOREIGN KEY (parent_node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_cass_qnns FOREIGN KEY (qname_ns_id) REFERENCES alf_namespace (id),
    CONSTRAINT fk_alf_cass_tqn FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id)
);
create index idx_alf_cass_pnode on alf_child_assoc (parent_node_id, assoc_index, id);
create index fk_alf_cass_cnode on ALF_CHILD_ASSOC (child_node_id);
create index fk_alf_cass_qnns on ALF_CHILD_ASSOC (qname_ns_id);
create index fk_alf_cass_tqn on ALF_CHILD_ASSOC (type_qname_id);
create index idx_alf_cass_qncrc on ALF_CHILD_ASSOC (qname_crc, type_qname_id, parent_node_id);
create index idx_alf_cass_pri on ALF_CHILD_ASSOC (parent_node_id, is_primary, child_node_id);
CREATE SEQUENCE ALF_CHILD_ASSOC_SEQ START WITH 1 INCREMENT BY 1 ORDER;


create table ALF_NODE_ASPECTS
(
  NODE_ID  NUMBER(19) not null,
  QNAME_ID NUMBER(19) not null,
    PRIMARY KEY (node_id, qname_id),   
    CONSTRAINT fk_alf_nasp_n FOREIGN KEY (node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_nasp_qn FOREIGN KEY (qname_id) REFERENCES alf_qname (id)
);
create index fk_alf_nasp_n on ALF_NODE_ASPECTS (node_id);
create index fk_alf_nasp_qn on ALF_NODE_ASPECTS (qname_id);


create table ALF_NODE_PROPERTIES
(
  NODE_ID            NUMBER(19) not null,
  ACTUAL_TYPE_N      NUMBER(10) not null,
  PERSISTED_TYPE_N   NUMBER(10) not null,
  BOOLEAN_VALUE      NUMBER(1),
  LONG_VALUE         NUMBER(19),
  FLOAT_VALUE        FLOAT,
  DOUBLE_VALUE       FLOAT,
  STRING_VALUE       VARCHAR2(1024 CHAR),
  SERIALIZABLE_VALUE BLOB,
  QNAME_ID           NUMBER(19) not null,
  LIST_INDEX         NUMBER(10) not null,
  LOCALE_ID          NUMBER(19) not null,
    PRIMARY KEY (node_id, qname_id, list_index, locale_id),   
    CONSTRAINT fk_alf_nprop_loc FOREIGN KEY (locale_id) REFERENCES alf_locale (id),
    CONSTRAINT fk_alf_nprop_n FOREIGN KEY (node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_nprop_qn FOREIGN KEY (qname_id) REFERENCES alf_qname (id)
);
create index fk_alf_nprop_n on ALF_NODE_PROPERTIES (node_id);
create index fk_alf_nprop_qn on ALF_NODE_PROPERTIES (qname_id);
create index fk_alf_nprop_loc on ALF_NODE_PROPERTIES (locale_id);
CREATE INDEX idx_alf_nprop_s ON alf_node_properties (qname_id, string_value, node_id);
CREATE INDEX idx_alf_nprop_l ON alf_node_properties (qname_id, long_value, node_id);


create table ALF_NODE_ASSOC
(
  ID             NUMBER(19) not null,
  VERSION        NUMBER(19) not null,
  SOURCE_NODE_ID NUMBER(19) not null,
  TARGET_NODE_ID NUMBER(19) not null,
  TYPE_QNAME_ID  NUMBER(19) not null,
  assoc_index NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    constraint source_node_id UNIQUE  (source_node_id, target_node_id, type_qname_id), 
    CONSTRAINT fk_alf_nass_snode FOREIGN KEY (source_node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_nass_tnode FOREIGN KEY (target_node_id) REFERENCES alf_node (id),
    CONSTRAINT fk_alf_nass_tqn FOREIGN KEY (type_qname_id) REFERENCES alf_qname (id)
);
CREATE INDEX fk_alf_nass_snode ON alf_node_assoc (source_node_id, type_qname_id, assoc_index);
CREATE INDEX fk_alf_nass_tnode ON alf_node_assoc (target_node_id, type_qname_id);
CREATE INDEX fk_alf_nass_tqn ON alf_node_assoc (type_qname_id);
CREATE SEQUENCE ALF_NODE_ASSOC_SEQ START WITH 1 INCREMENT BY 1 ORDER;
