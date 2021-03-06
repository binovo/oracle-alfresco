--
-- Title:      Upgraded Activiti tables from 5.14.4 to 5.19.0 version
-- Database:   Oracle
-- Since:      V5.0 Schema 9012
-- Author:     son_nd
--
-- Please contact support@alfresco.com if you need assistance with the upgrade.
--
-- Upgraded Activiti tables from 5.14.4 to 5.19.9 version, sql statements were copied from original activiti jar file.

update ACT_GE_PROPERTY set VALUE_ = '5.17.0.0' where NAME_ = 'schema.version';

alter table ACT_RE_PROCDEF add HAS_GRAPHICAL_NOTATION_ number(1) default 0;

update ACT_GE_PROPERTY set VALUE_ = '5.17.0.1' where NAME_ = 'schema.version';

alter table ACT_RU_EXECUTION add LOCK_TIME_ timestamp(6);

update ACT_GE_PROPERTY set VALUE_ = '5.17.0.2' where NAME_ = 'schema.version';

alter table ACT_HI_ATTACHMENT add TIME_ timestamp(6);

update ACT_GE_PROPERTY set VALUE_ = '5.18.0.0' where NAME_ = 'schema.version';

create index ACT_IDX_HI_TASK_INST_PROCINST on ACT_HI_TASKINST(PROC_INST_ID_);

update ACT_GE_PROPERTY set VALUE_ = '5.18.0.1' where NAME_ = 'schema.version';

create table ACT_PROCDEF_INFO (
    ID_ varchar(64) not null,
    PROC_DEF_ID_ varchar(64) not null,
    REV_ integer,
    INFO_JSON_ID_ varchar(64),
    primary key (ID_)
);

create index ACT_IDX_PROCDEF_INFO_JSON on ACT_PROCDEF_INFO(INFO_JSON_ID_);
alter table ACT_PROCDEF_INFO 
    add constraint ACT_FK_INFO_JSON_BA 
    foreign key (INFO_JSON_ID_) 
    references ACT_GE_BYTEARRAY (ID_);

create index ACT_IDX_PROCDEF_INFO_PROC on ACT_PROCDEF_INFO(PROC_DEF_ID_);
alter table ACT_PROCDEF_INFO 
    add constraint ACT_FK_INFO_PROCDEF 
    foreign key (PROC_DEF_ID_) 
    references ACT_RE_PROCDEF (ID_);
    
alter table ACT_PROCDEF_INFO
    add constraint ACT_UNIQ_INFO_PROCDEF
    unique (PROC_DEF_ID_);
    
update ACT_GE_PROPERTY set VALUE_ = '5.19.0.0' where NAME_ = 'schema.version';

--
-- Record script finish
--
DELETE FROM alf_applied_patch WHERE id = 'patch.db-V5.1-upgrade-to-activiti-5.19.0';
INSERT INTO alf_applied_patch
  (id, description, fixes_from_schema, fixes_to_schema, applied_to_schema, target_schema, applied_on_date, applied_to_server, was_executed, succeeded, report)
  VALUES
  (
    'patch.db-V5.1-upgrade-to-activiti-5.19.0', 'Manually executed script upgrade patch.db-V5.1-upgrade-to-activiti-5.19.0',
    0, 9011, -1, 9012, null, 'UNKNOWN', ${TRUE}, ${TRUE}, 'Script completed'
  );
    









