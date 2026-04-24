--用户表
create table user(
    id primary key comment '用户ID',
    username varchar(50) not null unique comment '登录账号',
    password varchar (100) not null comment '加密密码',
    nickname varchar(50) comment '用户昵称',
    email varchar(100) comment '用户邮箱',
    create_time datetime default current_timestamp comment '创建时间'
);

--文档表
create table document (
    id bigint auto_increment primary key comment '文档ID',
    title varchar(200) not null comment '文档标题',
    user_id bigint not null comment '创建用户ID',
    content longtext comment '文档内容',
    directory_id bigint not null comment '所属目录ID',
    create_time datetime default current_timestamp comment '创建时间',
    update_time datetime default current_timestamp on update current_timestamp comment '更新时间',
);

--目录表
create table directory(
    id ,
    name varchar(100) not null,
    parent_id ,
    user_id not null,
    create_time datetime default current_timestamp,
);

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
);

--权限表
create table permission (
    id bigint primary key  auto_increment ,
    user_id bigint not null ,
    resource_type int not null,
    resource_id bigint not null,
    permission_type int not null,
    created_at datetime default current_timestamp ,
    foreign key (uesr_id) references user(id),
)