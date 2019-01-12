-- auto-generated definition
create table user
(
  id           int auto_increment
  comment 'ID'
    primary key,
  username     varchar(15) not null
  comment '用户名',
  password     varchar(15) not null
  comment '密码',
  created_date datetime    null
  comment '注册时间',
  photo        varchar(64) null
  comment '头像ID',
  constraint username
  unique (username),
  constraint photo
  unique (photo),
  constraint user_ibfk_1
  foreign key (photo) references file_info (id)
);

