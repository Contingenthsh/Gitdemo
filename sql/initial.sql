create database if not exists doc_system default charset utf8mb4;
use doc_system;
--用户表
create table `user`(
    id bigint not null primary key auto_increment comment '用户ID',
    username varchar(50) not null unique comment '登录账号',
    password varchar (100) not null comment '加密密码',
    nickname varchar(50) comment '用户昵称',
    email varchar(100) comment '用户邮箱',
    avatar varchar(255) default '' comment '头像',
    status tinyint not null default '1' comment '状态 1正常 0禁用',
    phone varchar(30) default '' comment '手机号',
    create_time datetime not null default current_timestamp comment '创建时间',
    update_time datetime not null default current_timestamp on update current_timestamp COMMENT '更新时间',
    unique key uk_username(username)
)engine=innodb default charset=utf8mb4 comment='用户表';

--文档主表
create table document (
    id bigint not null auto_increment comment '文档ID',
    title varchar(200) not null comment '文档标题',
    creator_id bigint not null comment '创建人ID',
    last_edit_user_id bigint comment '最后编辑人ID',
    folder_id bigint not null comment '所属目录ID',
    doc_type tinyint not null default 1 comment '文档类型 1=Markdown 2=表格 3=富文本',
    status tinyint not null default '1' comment '1正常 2归档 0禁用',
    is_deleted tinyint not null default 0 comment '0未删除 1已删除',
    create_time datetime default current_timestamp comment '创建时间',
    update_time datetime default current_timestamp on update current_timestamp comment '更新时间',
    primary key (id),
    key idx_folder_id (folder_id),
    key idx_creator_id (creator_id)
)engine=innodb default charset=utf8mb4 comment='文档主表';

--文档目录表
create table directory(
    id bigint not null auto_increment comment '目录ID',
    name varchar(100) not null comment '目录名称',
    sort int not null default '0' comment '排序',
    creator_id bigint not null comment '创建人id',
    parent_id bigint not null default '0' comment '父目录id 0=根目录',
    path varchar(500) not null default '' comment '目录路径，如/1/3/5/',
    level tinyint not null default 0 comment '目录层级，根目录为0',
    is_deleted tinyint not null default 0 comment '0未删除 1已删除',
    create_time datetime default current_timestamp comment '创建时间',
    update_time datetime not null default current_timestamp on update current_timestamp comment '更新时间',
    primary key (id),
    key idx_parent_id (parent_id),
    key idx_path (path(255))
)engine=innodb default charset=utf8mb4 comment='文档目录表';

--文档版本表
create table document_version (
    id bigint not null auto_increment comment '版本ID',
    doc_id bigint not null comment '文档ID',
    content longtext comment '版本内容',
    version_num int not null comment '版本号',
    operator_id bigint not null comment '操作人ID',
    create_time datetime default current_timestamp comment '版本生成时间',
    version_note varchar(200) default '' comment '版本变更说明',
    primary key(id),
    key idx_doc_id (doc_id, version_num)
)engine=innodb default charset=utf8mb4 comment='文档版本表';

--文档权限表
create table permission (
    id bigint not null auto_increment comment '权限ID',
    user_id bigint not null comment '用户ID',
    resource_type int not null comment '资源类型 1=文档 2=目录',
    resource_id bigint not null comment '资源ID',
    permission_type int not null comment '权限类型 1=查看 2=编辑 3=管理',
    expire_time datetime comment '权限过期时间，NULL表示永久有效',
    is_deleted tinyint not null default 0 comment '0有效 1已回收',
    created_at datetime default current_timestamp comment '创建时间',
    primary key (id),
    key idx_user_id(user_id),
    key idx_resource (resource_type,resource_id),
    unique key uk_permission (user_id, resource_type, resource_id, is_deleted)
)engine=innodb default charset=utf8mb4 comment='文档权限表';