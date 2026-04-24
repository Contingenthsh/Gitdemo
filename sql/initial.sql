--用户表
create table user(
    id primary key comment '用户ID',
    username varchar(50) not null unique comment '登录账号',
    password varchar (100) not null comment '加密密码',
    nickname varchar(50) comment '用户昵称',
    email varchar(100) comment '用户邮箱',
    avatar varchar(255) default '' comment '头像',
    status tinyint not null default '1' comment '状态 1正常 0禁用',
    phone varchar(30) default '' comment '手机号',
    create_time datetime not null default current_timestamp comment '创建时间',
    update_time datetime not null default current_timestamp on update current_timestamp COMMENT '更新时间',
    primary key (id),
    unique key uk_username(username)
)engine=innodb default charset=utf8mb4 comment='用户表';

--文档主表
create table document (
    id bigint not null auto_increment comment '文档ID',
    title varchar(200) not null comment '文档标题',
    creator_id bigint not null comment '创建人ID',
    content longtext comment '文档内容',
    folder_id bigint not null comment '所属目录ID',
    status tinyint not null default '1' comment '1正常 0删除',
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
    create_time datetime default current_timestamp,
    update_time datetime not null default current_timestamp on update current_timestamp,
    primary key (id),
    key idx_parent_id (parent_id)
)engine=innodb default charset=utf8mb4 comment='文档目录表';

--文档版本表
create table document_version (
    id bigint primary key auto_increment ,
    document_id bigint not null,
    content longtext,
    version_num int not null,
    operator_id not null,
    create_time datetime default current_timestamp,
    version_no int not null ,
    comment varchar(300) ,
)engine=innodb default charset=utf8mb4 comment='文档版本表';

--权限表
create table permission (
    id bigint primary key  auto_increment ,
    user_id bigint not null ,
    resource_type int not null,
    resource_id bigint not null,
    permission_type int not null,
    created_at datetime default current_timestamp ,
    foreign key (uesr_id) references user(id),
)engine=innodb default charset=utf8mb4 comment='文档权限表';