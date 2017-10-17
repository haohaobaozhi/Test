SET FOREIGN_KEY_CHECKS = 0;
SET sql_mode = "";  # fix GROUP BY

DROP TABLE IF EXISTS collection;
DROP TABLE IF EXISTS topic_vote;
DROP TABLE IF EXISTS comment_vote;
DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS topic;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS github_user;
DROP TABLE IF EXISTS user;

# 用户表
CREATE TABLE user (
    id int(16) PRIMARY KEY AUTO_INCREMENT NOT NULL,  -- 用户id
    username varchar(32) NOT NULL,  -- 用户账号
    nickname varchar(32) DEFAULT "",  -- 用户昵称
    user_role tinyint(2) unsigned DEFAULT 1,  -- 0-禁言用户, 1-普通用户, 2-管理员
    register_source tinyint(2) unsigned DEFAULT 0,  -- 注册来源，0-本站注册, 1-github
    gender tinyint(2) unsigned DEFAULT 1,  -- 0-female, 1-male
    signature varchar(200) DEFAULT "",  -- 用户签名
    email varchar(32) NOT NULL,  -- 邮箱
    avatar_url varchar(200) NOT NULL,  -- 头像地址
    qq varchar(32) DEFAULT "",  -- qq号码
    location varchar(32) DEFAULT "",  -- 地址
    site varchar(32) DEFAULT "",  -- 用户个人网站
    github_account varchar(32) DEFAULT "",  -- 用户github账号
    password varchar(32) NOT NULL,  -- 密码
    salt varchar(64) NOT NULL,  -- 密码加盐
    create_time datetime NOT NULL,  -- 用户创建时间
    update_time datetime NOT NULL,  -- 用户更新时间
    retrieve_token varchar(36) DEFAULT "",  -- 重置密码链接的token
    retrieve_time datetime DEFAULT now(),  -- 重置密码链接的生成时间
    UNIQUE KEY username (username),
    UNIQUE KEY email (email)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# github用户表
CREATE TABLE github_user (
    id int(32) PRIMARY KEY NOT NULL,  -- github id
    user_id int(16) NOT NULL,  -- 本站id
    username varchar(32) NOT NULL,  -- github用户名
    nickname varchar(32) NOT NULL,  -- github昵称
    email varchar(32) NOT NULL,  -- github邮箱
    avatar_url varchar(200) NOT NULL,  -- github头像地址
    home_url varchar(200) NOT NULL,  -- github用户主页地址
    site varchar(200) DEFAULT "",  -- github用户个人站点地址
    location varchar(200) DEFAULT "",  -- github用户地址
    bio varchar(200) DEFAULT "",  -- github用户个人简介
    create_time datetime NOT NULL,  -- 绑定时间
    update_time datetime NOT NULL,  -- 更新绑定时间
    KEY user_id (user_id),
    CONSTRAINT github_user_ibfK_1 FOREIGN KEY (user_id) REFERENCES user (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# 话题分类表
CREATE TABLE category (
    id tinyint(4) unsigned PRIMARY KEY NOT NULL,  -- 1-问答, 2-分享, 3-招聘
    name varchar(64) NOT NULL
)  ENGINE = InnoDB DEFAULT CHARSET = utf8;

# 话题表
CREATE TABLE topic (
    id varchar(32) PRIMARY KEY NOT NULL,
    user_id int(16) NOT NULL,
    category_id tinyint(4) unsigned DEFAULT 1,
    title varchar(200) NOT NULL,
    content mediumtext NOT NULL,
    status tinyint(2) unsigned DEFAULT 1,
    sticky tinyint(2) unsigned DEFAULT 0, -- 0-普通话题, 1-置顶
    essence tinyint(2) unsigned DEFAULT 0,  -- 0-普通话题, 1-精华
    view_count int(32) DEFAULT 0,
    create_time datetime NOT NULL,
    update_time datetime NOT NULL,
    KEY user_id (user_id),
    KEY category_id (category_id),
    CONSTRAINT topic_ibfk_1 FOREIGN KEY (user_id) REFERENCES user (id),
    CONSTRAINT topic_ibfk_2 FOREIGN KEY (category_id) REFERENCES category (id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# 评论表
CREATE TABLE comment (
    id varchar(32) PRIMARY KEY NOT NULL,
    user_id int(16) NOT NULL,
    topic_id varchar(32) NOT NULL,
    content mediumtext NOT NULL,
    status tinyint(2) unsigned DEFAULT 1,
    create_time datetime NOT NULL,
    update_time datetime NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# 消息表
CREATE TABLE message (
    id varchar(32) PRIMARY KEY NOT NULL,
    topic_id varchar(32) NOT NULL,
    comment_id varchar(32) NOT NULL,
    from_user_id int(16) NOT NULL,
    to_user_id int(16) NOT NULL,
    status tinyint(2) unsigned DEFAULT 1,
    type tinyint(2) unsigned NOT NULL,  -- 0-回复话题, 1-@某人
    create_time datetime NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# 话题点赞表
CREATE TABLE topic_vote (
    id int(64) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    user_id int(16) NOT NULL,
    topic_id varchar(32) NOT NULL,
    state tinyint(4) signed NOT NULL DEFAULT 0,  -- 1-赞, -1-踩
    create_time datetime NOT NULL,
    update_time datetime NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# 评论点赞表
CREATE TABLE comment_vote (
    id int(64) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    user_id int(16) NOT NULL,
    comment_id varchar(32) NOT NULL,
    state tinyint(4) signed NOT NULL DEFAULT 0,  -- 1-赞, -1-踩
    create_time datetime NOT NULL,
    update_time datetime NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# 话题收藏表
CREATE TABLE collection (
    id int(64) PRIMARY KEY AUTO_INCREMENT NOT NULL,
    user_id int(16) NOT NULL,
    topic_id varchar(32) NOT NULL,
    create_time datetime NOT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8;

# 初始化数据
# 初始化category
INSERT INTO category (id, name) values (1, "问答"), (2, "分享"), (3, "招聘");
