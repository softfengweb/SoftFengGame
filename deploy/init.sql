-- ============================================================================
-- 软风游戏陪玩系统 · 单文件初始化 SQL（自动生成，请勿手工编辑）
--
-- 生成时间：2026-11-03 20:26:17
-- 数据来源：migrations/（共 144 个迁移，按文件名顺序）
-- 目标库名：peiwan_db
--
-- 导入方式：
--   mysql -uroot -p < init.sql
-- 导入后可直接启动服务；-migrate 会因为 schema_migrations 已记账而跳过。
--
-- 重新生成：
--   bash deploy/gen-init-sql.sh peiwan_db
-- ============================================================================

SET NAMES utf8mb4;
SET time_zone = '+08:00';

CREATE DATABASE IF NOT EXISTS `peiwan_db`
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `peiwan_db`;

-- 与 internal/infra/migrate 建的表完全一致
CREATE TABLE IF NOT EXISTS schema_migrations (
  version VARCHAR(255) NOT NULL,
  applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ----------------------------------------------------------------------------
-- 0001_create_system_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 系统配置表
--
-- 分组约定：
--   basic  基础设置（站点信息、版权备案、客服联系方式）
--   system 系统设置（运行开关、默认参数、上传限制）
--
-- 说明：config_value 统一按字符串存储，读取时按 value_type 解析；
--       is_public=1 的配置允许前台公开读取。
-- ============================================================================

CREATE TABLE IF NOT EXISTS system_configs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  group_name VARCHAR(50) NOT NULL DEFAULT 'basic' COMMENT '配置分组：basic 基础设置 / system 系统设置',
  config_key VARCHAR(100) NOT NULL DEFAULT '' COMMENT '配置键，全局唯一',
  config_value TEXT NULL COMMENT '配置值，统一按字符串存储',
  value_type VARCHAR(20) NOT NULL DEFAULT 'string' COMMENT '值类型：string/text/int/bool/json/image',
  is_public TINYINT NOT NULL DEFAULT 0 COMMENT '是否允许前台公开读取：1 是 0 否',
  is_system TINYINT NOT NULL DEFAULT 1 COMMENT '是否内置配置：1 是（后台不可删除）0 否',
  sort INT NOT NULL DEFAULT 0 COMMENT '同组内排序，越小越靠前',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '配置说明',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_configs_key (config_key),
  KEY idx_configs_group (group_name, sort)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';


-- ----------------------------------------------------------------------------
-- 0002_seed_system_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 基础设置 / 系统设置 种子数据
--
-- 说明：
--   1. 仅包含 basic（基础设置）与 system（系统设置）两类，不含业务规则配置
--   2. 使用 INSERT IGNORE，已存在的配置键不会被覆盖（可安全重复执行）
--   3. 系统名称统一为「软风游戏陪玩系统」
-- ============================================================================

-- ---------------------------- 基础设置 ----------------------------

INSERT IGNORE INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('basic', 'site.name',        '软风游戏陪玩系统', 'string', 1, 1,  1, '系统名称，用于浏览器标题、后台名称与分享文案'),
  ('basic', 'site.short_name',  '软风陪玩',         'string', 1, 1,  2, '系统简称，用于空间受限场景显示'),
  ('basic', 'site.logo',        '',                 'image',  1, 1,  3, '系统 Logo'),
  ('basic', 'site.favicon',     '',                 'image',  1, 1,  4, '浏览器图标'),
  ('basic', 'site.keywords',    '游戏陪玩,电竞陪玩,软风游戏陪玩系统', 'string', 1, 1, 5, '站点关键词，用于搜索引擎收录'),
  ('basic', 'site.description', '',                 'text',   1, 1,  6, '站点简介，用于搜索引擎收录'),
  ('basic', 'site.copyright',   '© 2026 软风游戏陪玩系统', 'string', 1, 1, 7, '页脚版权信息'),
  ('basic', 'site.icp',         '',                 'string', 1, 1,  8, 'ICP 备案号'),
  ('basic', 'site.police_no',   '',                 'string', 1, 1,  9, '公安备案号'),
  ('basic', 'site.police_url',  '',                 'string', 1, 1, 10, '公安备案链接'),
  ('basic', 'contact.service_qq',     '',            'string', 1, 1, 11, '客服 QQ'),
  ('basic', 'contact.service_wechat', '',            'string', 1, 1, 12, '客服微信'),
  ('basic', 'contact.service_phone',  '',            'string', 1, 1, 13, '客服电话'),
  ('basic', 'contact.service_email',  '',            'string', 1, 1, 14, '客服邮箱'),
  ('basic', 'contact.service_time',   '09:00-24:00', 'string', 1, 1, 15, '客服服务时间'),
  ('basic', 'contact.service_qr',     '',            'image',  1, 1, 16, '客服二维码');

-- ---------------------------- 系统设置 ----------------------------

INSERT IGNORE INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('system', 'system.maintenance',        '0',                      'bool',   1, 1,  1, '维护模式：开启后前台仅展示维护公告'),
  ('system', 'system.maintenance_notice', '系统维护中，请稍后再试', 'text',   1, 1,  2, '维护公告内容'),
  ('system', 'system.register_enabled',   '1',                      'bool',   1, 1,  3, '是否开放用户注册'),
  ('system', 'system.login_captcha',      '0',                      'bool',   1, 1,  4, '登录是否开启图形验证码'),
  ('system', 'system.default_timezone',   'Asia/Shanghai',          'string', 1, 1,  5, '系统默认时区'),
  ('system', 'system.page_size',          '20',                     'int',    0, 1,  6, '列表默认每页条数'),
  ('system', 'system.currency',           'CNY',                    'string', 1, 1,  7, '结算货币代码'),
  ('system', 'system.currency_symbol',    '¥',                      'string', 1, 1,  8, '货币符号'),
  ('system', 'system.upload_max_mb',      '10',                     'int',    0, 1,  9, '单文件上传大小上限（MB）'),
  ('system', 'system.upload_extensions',  'jpg,jpeg,png,gif,webp,mp4,mp3,pdf,zip', 'string', 0, 1, 10, '允许上传的文件扩展名，英文逗号分隔');


-- ----------------------------------------------------------------------------
-- 0003_create_admins.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 管理员表
--
-- 与 C 端 users 表完全隔离：管理员使用独立表、独立 JWT 密钥（scope=admin），
-- 用户令牌不能访问管理端接口，管理员令牌也不能访问用户端接口。
-- ============================================================================

CREATE TABLE IF NOT EXISTS admins (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  username VARCHAR(50) NOT NULL DEFAULT '' COMMENT '登录账号',
  password_hash VARCHAR(255) NOT NULL DEFAULT '' COMMENT '密码哈希（bcrypt）',
  nickname VARCHAR(50) NOT NULL DEFAULT '' COMMENT '昵称',
  email VARCHAR(100) NOT NULL DEFAULT '' COMMENT '邮箱',
  avatar VARCHAR(255) NOT NULL DEFAULT '' COMMENT '头像地址',
  role_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '角色 ID，0 表示未分配',
  is_super TINYINT NOT NULL DEFAULT 0 COMMENT '是否超级管理员：1 是（跳过权限校验）0 否',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 禁用',
  last_login_at DATETIME NULL DEFAULT NULL COMMENT '最后登录时间',
  last_login_ip VARCHAR(64) NOT NULL DEFAULT '' COMMENT '最后登录 IP',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_admins_username (username),
  KEY idx_admins_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员表';


-- ----------------------------------------------------------------------------
-- 0004_seed_admin.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 管理员初始化账号
--
-- 账号 admin / admin123（bcrypt cost=10），首次登录后请立即修改密码。
-- INSERT IGNORE 保证重复执行不会覆盖已改过的密码。
-- ============================================================================

INSERT IGNORE INTO admins
  (id, username, password_hash, nickname, email, avatar, role_id, is_super, status)
VALUES
  (1, 'admin', '$2a$10$jqCtKX1MhULw9ga.3CFhIut6kUgLaCanyqgCF7KgqZc9c46Qeb.1a', '超级管理员', '', '', 0, 1, 1);


-- ----------------------------------------------------------------------------
-- 0005_create_users.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 用户表
--
-- 与 admins 完全隔离：独立表、独立密码哈希、独立 JWT 密钥（scope=user）。
-- phone 允许 NULL：微信登录用户可以先没有手机号，同时唯一索引允许多个 NULL。
-- ============================================================================

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  phone VARCHAR(20) NULL DEFAULT NULL COMMENT '手机号，微信用户可为空',
  password_hash VARCHAR(255) NOT NULL DEFAULT '' COMMENT '密码哈希（bcrypt）',
  nickname VARCHAR(50) NOT NULL DEFAULT '' COMMENT '昵称',
  avatar VARCHAR(255) NOT NULL DEFAULT '' COMMENT '头像地址',
  gender TINYINT NOT NULL DEFAULT 0 COMMENT '性别：0 未知 1 男 2 女',
  user_type TINYINT NOT NULL DEFAULT 1 COMMENT '用户类型：1 普通用户 2 陪玩',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 正常 0 封禁',
  wx_openid VARCHAR(64) NULL DEFAULT NULL COMMENT '微信 openid',
  wx_unionid VARCHAR(64) NULL DEFAULT NULL COMMENT '微信 unionid',
  invited_by BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '邀请人用户 ID，0 表示无',
  register_ip VARCHAR(64) NOT NULL DEFAULT '' COMMENT '注册 IP',
  last_login_at DATETIME NULL DEFAULT NULL COMMENT '最后登录时间',
  last_login_ip VARCHAR(64) NOT NULL DEFAULT '' COMMENT '最后登录 IP',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_phone (phone),
  UNIQUE KEY uk_users_wx_openid (wx_openid),
  KEY idx_users_invited_by (invited_by),
  KEY idx_users_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';


-- ----------------------------------------------------------------------------
-- 0006_seed_users.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 初始用户
--
-- 手机号 18294707491，密码 258936ck（bcrypt cost=10）。
-- 手机号唯一索引兜底，重复执行不会产生脏数据。
-- ============================================================================

INSERT INTO users (phone, password_hash, nickname, avatar, gender, user_type, status)
SELECT '18294707491', '$2a$10$E7k5.H22rET7KhHSNN40qeRnJKJ6Xy31V3AwIC3DiS7om/4DTuFvO', '', '', 0, 1, 1
WHERE NOT EXISTS (SELECT 1 FROM users WHERE phone = '18294707491');


-- ----------------------------------------------------------------------------
-- 0007_create_roles_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 管理端角色与权限表
--
-- 设计说明：
-- 1. roles 角色表：code 对应前端路由 meta.roles，内置角色（is_system=1）不可删除、
--    编码不可修改，避免前端路由过滤失配。
-- 2. permissions 权限点表：type=1 菜单节点，type=2 按钮/接口权限点，parent_id 组织成树。
--    菜单节点用于权限分配树的层级展示，按钮节点才是实际校验单元。
-- 3. role_permissions 角色权限关联表：(role_id, permission_id) 唯一。
-- 4. admins.role_id 关联 roles.id；admins.is_super=1 时跳过权限校验（等价全部权限）。
-- ============================================================================

CREATE TABLE IF NOT EXISTS roles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '角色名称',
  code VARCHAR(50) NOT NULL DEFAULT '' COMMENT '角色编码，前端路由 meta.roles 使用',
  description VARCHAR(255) NOT NULL DEFAULT '' COMMENT '角色描述',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 禁用',
  is_system TINYINT NOT NULL DEFAULT 0 COMMENT '是否内置：1 内置角色不可删除、编码不可修改',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_roles_code (code),
  KEY idx_roles_sort (sort)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理端角色表';

CREATE TABLE IF NOT EXISTS permissions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '上级权限 ID，0 为顶级',
  name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '权限名称',
  code VARCHAR(80) NOT NULL DEFAULT '' COMMENT '权限编码，如 system:user:list',
  type TINYINT NOT NULL DEFAULT 1 COMMENT '类型：1 菜单 2 按钮/接口',
  path VARCHAR(120) NOT NULL DEFAULT '' COMMENT '菜单路径，按钮为空',
  icon VARCHAR(64) NOT NULL DEFAULT '' COMMENT '菜单图标',
  sort INT NOT NULL DEFAULT 0 COMMENT '同级排序',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1 启用 0 禁用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_permissions_code (code),
  KEY idx_permissions_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理端权限点表';

CREATE TABLE IF NOT EXISTS role_permissions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  role_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '角色 ID',
  permission_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '权限点 ID',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_role_permission (role_id, permission_id),
  KEY idx_role_permissions_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='角色权限关联表';


-- ----------------------------------------------------------------------------
-- 0008_seed_roles_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 角色与权限初始化数据
--
-- 全部使用 INSERT IGNORE + 固定主键，保证迁移可重复执行且不覆盖已调整的数据。
-- 内置角色：R_SUPER 超级管理员（is_system=1，拥有全部权限）、
--           R_ADMIN 管理员（is_system=1，拥有全部权限点）、
--           R_OPERATOR 运营（只读用户资料 + 查看系统配置）。
-- ============================================================================

INSERT IGNORE INTO roles (id, name, code, description, status, is_system, sort) VALUES
  (1, '超级管理员', 'R_SUPER', '内置角色，拥有全部权限，不可删除', 1, 1, 1),
  (2, '管理员', 'R_ADMIN', '内置角色，拥有全部业务权限，不可删除', 1, 1, 2),
  (3, '运营专员', 'R_OPERATOR', '可查看与维护用户资料，不可管理角色与配置', 1, 0, 3);

INSERT IGNORE INTO permissions (id, parent_id, name, code, type, path, icon, sort, status) VALUES
  (1,  0,  '仪表盘',   'dashboard',            1, '/dashboard',     'ri:dashboard-line',        10, 1),
  (10, 0,  '用户管理', 'system:user',          1, '/system/user',   'ri:user-line',             20, 1),
  (11, 10, '查看用户', 'system:user:list',     2, '',               '',                         1,  1),
  (12, 10, '编辑资料', 'system:user:update',   2, '',               '',                         2,  1),
  (13, 10, '封禁解封', 'system:user:status',   2, '',               '',                         3,  1),
  (14, 10, '重置密码', 'system:user:password', 2, '',               '',                         4,  1),
  (20, 0,  '角色管理', 'system:role',          1, '/system/role',   'ri:user-settings-line',    30, 1),
  (21, 20, '查看角色', 'system:role:list',     2, '',               '',                         1,  1),
  (22, 20, '新增角色', 'system:role:create',   2, '',               '',                         2,  1),
  (23, 20, '编辑角色', 'system:role:update',   2, '',               '',                         3,  1),
  (24, 20, '删除角色', 'system:role:delete',   2, '',               '',                         4,  1),
  (25, 20, '分配权限', 'system:role:assign',   2, '',               '',                         5,  1),
  (40, 0,  '系统配置', 'system:config',        1, '/system/config', 'ri:settings-4-line',       40, 1),
  (41, 40, '查看配置', 'system:config:read',   2, '',               '',                         1,  1),
  (42, 40, '修改配置', 'system:config:update', 2, '',               '',                         2,  1);

-- 管理员：内置管理员默认拥有全部权限点
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions;

-- 运营专员：仅用户查看/编辑、封禁解封与配置查看
INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
  (3, 1), (3, 10), (3, 11), (3, 12), (3, 13), (3, 40), (3, 41);

-- 存量超级管理员补齐角色关联（role_id 为 0 时按 is_super 落到 R_SUPER）
UPDATE admins SET role_id = 1 WHERE is_super = 1 AND role_id = 0;


-- ----------------------------------------------------------------------------
-- 0009_seed_admin_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 管理员管理权限点
--
-- 菜单节点 50 + 5 个按钮权限点，分配给内置超级管理员与管理员角色。
-- 运营专员（R_OPERATOR）不授予管理员管理权限。
-- ============================================================================

INSERT IGNORE INTO permissions (id, parent_id, name, code, type, path, icon, sort, status) VALUES
  (50, 0,  '管理员管理', 'system:admin',          1, '/system/admin', '', 50, 1),
  (51, 50, '查看管理员', 'system:admin:list',     2, '',              '', 1,  1),
  (52, 50, '新增管理员', 'system:admin:create',   2, '',              '', 2,  1),
  (53, 50, '编辑管理员', 'system:admin:update',   2, '',              '', 3,  1),
  (54, 50, '重置密码',   'system:admin:password', 2, '',              '', 4,  1),
  (55, 50, '删除管理员', 'system:admin:delete',   2, '',              '', 5,  1);

INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
  (1, 50), (1, 51), (1, 52), (1, 53), (1, 54), (1, 55);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE id IN (50, 51, 52, 53, 54, 55);


-- ----------------------------------------------------------------------------
-- 0010_create_uploads.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 上传文件表
--
-- 同一份文件内容只落盘一次（hash 唯一），重复上传直接复用已有记录。
-- 物理路径：uploads/YYYY/MM/DD/<image|audio|video|other>/<hash 前 32 位>.<ext>
-- ============================================================================

CREATE TABLE IF NOT EXISTS uploads (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hash CHAR(64) NOT NULL DEFAULT '' COMMENT '文件内容 sha256',
  type VARCHAR(10) NOT NULL DEFAULT 'other' COMMENT 'image/audio/video/other',
  ext VARCHAR(10) NOT NULL DEFAULT '' COMMENT '扩展名，小写不带点',
  mime VARCHAR(100) NOT NULL DEFAULT '' COMMENT '服务端检测到的 MIME',
  size BIGINT NOT NULL DEFAULT 0 COMMENT '字节数',
  width INT NOT NULL DEFAULT 0 COMMENT '图片宽度，非图片为 0',
  height INT NOT NULL DEFAULT 0 COMMENT '图片高度，非图片为 0',
  path VARCHAR(255) NOT NULL DEFAULT '' COMMENT '相对存储路径',
  url VARCHAR(255) NOT NULL DEFAULT '' COMMENT '访问地址',
  original_name VARCHAR(255) NOT NULL DEFAULT '' COMMENT '首次上传时的文件名',
  uploader_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '上传的管理员 ID',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_uploads_hash (hash),
  KEY idx_uploads_type (type, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='上传文件';


-- ----------------------------------------------------------------------------
-- 0011_seed_upload_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 文件素材权限点
--
-- 菜单节点 60 + 3 个按钮权限点（查看/上传/删除）。
-- 超级管理员、管理员全部授予；运营专员只读。
-- ============================================================================

INSERT IGNORE INTO permissions (id, parent_id, name, code, type, path, icon, sort, status) VALUES
  (60, 0,  '文件素材', 'system:file',        1, '/system/file', '', 60, 1),
  (61, 60, '查看文件', 'system:file:list',   2, '',             '', 1,  1),
  (62, 60, '上传文件', 'system:file:upload', 2, '',             '', 2,  1),
  (63, 60, '删除文件', 'system:file:delete', 2, '',             '', 3,  1);

INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
  (1, 60), (1, 61), (1, 62), (1, 63);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE id IN (60, 61, 62, 63);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE id IN (60, 61);


-- ----------------------------------------------------------------------------
-- 0012_create_games_servers.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 游戏与区服
--
-- 游戏是所有陪玩业务的入口：陪玩申请、订单、价格都按游戏 + 区服维度划分。
-- ============================================================================

CREATE TABLE IF NOT EXISTS games (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '游戏名称',
  short_name VARCHAR(10) NOT NULL DEFAULT '' COMMENT '简称/首字，无图标时用色块展示',
  icon VARCHAR(255) NOT NULL DEFAULT '' COMMENT '游戏图标地址',
  icon_bg VARCHAR(255) NOT NULL DEFAULT '' COMMENT '无图标时的背景色/渐变',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_games_name (name),
  KEY idx_games_status_sort (status, sort, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='游戏';

CREATE TABLE IF NOT EXISTS game_servers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  game_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属游戏 ID',
  name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '区服名称，如 微信区 / 艾欧尼亚',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_game_servers_game_name (game_id, name),
  KEY idx_game_servers_game_sort (game_id, sort, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='游戏区服';


-- ----------------------------------------------------------------------------
-- 0013_seed_games_servers.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 游戏与区服初始数据
--
-- 与小程序首页的游戏分类保持一致，后台可直接编辑、新增或停用。
-- ============================================================================

INSERT IGNORE INTO games (name, short_name, icon, icon_bg, sort, status, remark) VALUES
  ('王者荣耀',  '王', '', 'linear-gradient(135deg, #f7a63b 0%, #f76b1c 100%)', 10, 1, ''),
  ('英雄联盟',  '英', '', 'linear-gradient(135deg, #22c7e5 0%, #0a8fbf 100%)', 20, 1, ''),
  ('和平精英',  '和', '', 'linear-gradient(135deg, #4cd964 0%, #2fa84f 100%)', 30, 1, ''),
  ('原神',      '原', '', 'linear-gradient(135deg, #8b7bf0 0%, #4a3fd1 100%)', 40, 1, ''),
  ('无畏契约',  '无', '', 'linear-gradient(135deg, #ff5f6b 0%, #c42c3a 100%)', 50, 1, '');

INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '微信区', 10, 1 FROM games WHERE name = '王者荣耀';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, 'QQ区', 20, 1 FROM games WHERE name = '王者荣耀';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '苹果微信区', 30, 1 FROM games WHERE name = '王者荣耀';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '苹果QQ区', 40, 1 FROM games WHERE name = '王者荣耀';

INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '艾欧尼亚', 10, 1 FROM games WHERE name = '英雄联盟';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '黑色玫瑰', 20, 1 FROM games WHERE name = '英雄联盟';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '祖安', 30, 1 FROM games WHERE name = '英雄联盟';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '诺克萨斯', 40, 1 FROM games WHERE name = '英雄联盟';

INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, 'QQ区', 10, 1 FROM games WHERE name = '和平精英';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '微信区', 20, 1 FROM games WHERE name = '和平精英';

INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '官服', 10, 1 FROM games WHERE name = '原神';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, 'B服', 20, 1 FROM games WHERE name = '原神';

INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '国服', 10, 1 FROM games WHERE name = '无畏契约';
INSERT IGNORE INTO game_servers (game_id, name, sort, status)
SELECT id, '亚服', 20, 1 FROM games WHERE name = '无畏契约';


-- ----------------------------------------------------------------------------
-- 0014_seed_game_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 游戏与区服权限点
--
-- 菜单节点 64 + 游戏增删改查（65-68）+ 区服查看/维护（69-70）。
-- 超级管理员、管理员全部授予；运营专员只读。
-- ============================================================================

INSERT IGNORE INTO permissions (id, parent_id, name, code, type, path, icon, sort, status) VALUES
  (64, 0,  '游戏管理', 'game',                1, '/peiwan/game', 'ri:gamepad-line', 20, 1),
  (65, 64, '查看游戏', 'game:list',           2, '',             '',                1,  1),
  (66, 64, '新增游戏', 'game:create',         2, '',             '',                2,  1),
  (67, 64, '编辑游戏', 'game:update',         2, '',             '',                3,  1),
  (68, 64, '删除游戏', 'game:delete',         2, '',             '',                4,  1),
  (69, 64, '查看区服', 'game:server:list',    2, '',             '',                5,  1),
  (70, 64, '维护区服', 'game:server:manage',  2, '',             '',                6,  1);

INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
  (1, 64), (1, 65), (1, 66), (1, 67), (1, 68), (1, 69), (1, 70);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE id IN (64, 65, 66, 67, 68, 69, 70);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE id IN (64, 65, 69);


-- ----------------------------------------------------------------------------
-- 0015_create_categories.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 商品分类
--
-- 分类归属游戏，支持两级：parent_id=0 为一级分类，二级分类的 parent_id 指向一级。
-- 同一游戏、同一父级下分类名唯一。
-- ============================================================================

CREATE TABLE IF NOT EXISTS categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  game_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属游戏 ID',
  parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '上级分类 ID，0 为一级分类',
  name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '分类名称',
  icon VARCHAR(255) NOT NULL DEFAULT '' COMMENT '分类图标',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_categories_game_parent_name (game_id, parent_id, name),
  KEY idx_categories_game (game_id, status, sort, id),
  KEY idx_categories_parent (parent_id, sort)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品分类';


-- ----------------------------------------------------------------------------
-- 0016_seed_categories.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 商品分类种子数据
--
-- 按游戏 1~5 预置常用分类，王者荣耀带二级示例（上分陪练 / 娱乐陪玩）。
-- 使用 INSERT IGNORE，重复执行不会覆盖后台已改数据。
-- ============================================================================

INSERT IGNORE INTO categories (id, game_id, parent_id, name, icon, sort, status, remark) VALUES
  (1,  1, 0, '绝密专区', '', 100, 1, ''),
  (2,  1, 0, '陪玩专区', '', 90,  1, ''),
  (3,  1, 0, '体验专区', '', 80,  1, ''),
  (4,  1, 0, '清图专区', '', 70,  1, ''),
  (5,  1, 1, '上分陪练', '', 100, 1, ''),
  (6,  1, 1, '娱乐陪玩', '', 90,  1, ''),
  (7,  2, 0, '上分陪练', '', 100, 1, ''),
  (8,  2, 7, '定级赛',   '', 100, 1, ''),
  (9,  3, 0, '排位陪练', '', 100, 1, ''),
  (10, 4, 0, '委托代肝', '', 100, 1, ''),
  (11, 5, 0, '上分陪练', '', 100, 1, '');


-- ----------------------------------------------------------------------------
-- 0017_seed_category_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 商品分类权限点
--
-- 71 菜单 + 72-75 增删改查。超管、管理员全部授予；运营只读。
-- ============================================================================

INSERT IGNORE INTO permissions (id, parent_id, name, code, type, path, icon, sort, status) VALUES
  (71, 0,  '商品分类', 'category',        1, '/peiwan/category', 'ri:price-tag-3-line', 21, 1),
  (72, 71, '查看分类', 'category:list',   2, '', '', 1, 1),
  (73, 71, '新增分类', 'category:create', 2, '', '', 2, 1),
  (74, 71, '编辑分类', 'category:update', 2, '', '', 3, 1),
  (75, 71, '删除分类', 'category:delete', 2, '', '', 4, 1);

INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
  (1, 71), (1, 72), (1, 73), (1, 74), (1, 75);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE id IN (71, 72, 73, 74, 75);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE id IN (71, 72);


-- ----------------------------------------------------------------------------
-- 0018_create_goods.sql
-- ----------------------------------------------------------------------------
-- 商品与商品规格（SKU）
-- 默认「单商品单价格」：价格直接落在 goods 上；开启多规格时价格落在 goods_skus 上。

CREATE TABLE IF NOT EXISTS goods (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '商品分类 ID',
  game_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属游戏 ID',
  title VARCHAR(200) NOT NULL DEFAULT '' COMMENT '商品标题',
  cover VARCHAR(255) NOT NULL DEFAULT '' COMMENT '封面图地址',
  images TEXT NULL COMMENT '图集（JSON 数组，预留）',
  description LONGTEXT NULL COMMENT '商品详情',
  unit VARCHAR(20) NOT NULL DEFAULT '局' COMMENT '计价单位，如 局/小时/星',
  has_sku TINYINT NOT NULL DEFAULT 0 COMMENT '0 单规格单价格 1 多规格（价格取 goods_skus）',
  price BIGINT NOT NULL DEFAULT 0 COMMENT '售价（分），单规格时使用',
  market_price BIGINT NOT NULL DEFAULT 0 COMMENT '划线价（分）',
  companion_income BIGINT NOT NULL DEFAULT 0 COMMENT '陪玩到手（分）',
  stock INT NOT NULL DEFAULT -1 COMMENT '库存，-1 为不限',
  sold INT NOT NULL DEFAULT 0 COMMENT '销量',
  limit_per_user INT NOT NULL DEFAULT 0 COMMENT '每人限购，0 为不限',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 上架 0 下架',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_goods_game (game_id, status, sort, id),
  KEY idx_goods_category (category_id, status, sort, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品';

CREATE TABLE IF NOT EXISTS goods_skus (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  goods_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '商品 ID',
  name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '规格名，如 1 小时 / 10 局',
  price BIGINT NOT NULL DEFAULT 0 COMMENT '售价（分）',
  market_price BIGINT NOT NULL DEFAULT 0 COMMENT '划线价（分）',
  companion_income BIGINT NOT NULL DEFAULT 0 COMMENT '陪玩到手（分）',
  stock INT NOT NULL DEFAULT -1 COMMENT '库存，-1 为不限',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 启用 0 停用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_skus_goods_name (goods_id, name),
  KEY idx_skus_goods (goods_id, status, sort, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='商品规格（SKU）';


-- ----------------------------------------------------------------------------
-- 0019_seed_goods.sql
-- ----------------------------------------------------------------------------
-- 商品初始数据（幂等，重复执行不会重复写入）
-- 说明：3 号商品为多规格示例（has_sku=1，价格走 goods_skus）

INSERT IGNORE INTO goods
  (id, category_id, game_id, title, cover, images, description, unit, has_sku,
   price, market_price, companion_income, stock, sold, limit_per_user, status, sort, remark)
VALUES
  (1, 1, 1, '绝密护航 · 保底 1000 万', '', '[]', '绝密地图护航，保底带出 1000 万物资，中途掉线免费补一局。', '局', 0,
   9900, 15800, 7722, -1, 0, 0, 1, 100, ''),
  (2, 4, 1, '绝密清图 · 10 分钟速通', '', '[]', '10 分钟内完成清图，不清图不加价。', '局', 0,
   22800, 28800, 17784, -1, 0, 0, 1, 90, ''),
  (3, 3, 1, '体验专区 · 娱乐陪玩', '', '[]', '轻松开黑，支持语音连麦，多档时长可选。', '小时', 1,
   5200, 8800, 3000, -1, 0, 0, 1, 80, '多规格示例：价格以规格为准'),
  (4, 2, 1, '陪玩专区 · 语音连麦 1 小时', '', '[]', '全程语音，按局内时间计算，可指定位置。', '小时', 0,
   5200, 8800, 3000, -1, 0, 0, 1, 70, ''),
  (5, 7, 2, '英雄联盟 · 排位上分陪练', '', '[]', '双排上分，位置可指定，全程语音沟通。', '星', 0,
   3900, 5900, 3000, -1, 0, 0, 1, 60, ''),
  (6, 9, 3, '和平精英 · 排位陪练', '', '[]', '四排冲分，落地成盒包补，支持指定地图。', '局', 0,
   4500, 6800, 3400, -1, 0, 0, 1, 50, ''),
  (7, 10, 4, '原神 · 委托代肝', '', '[]', '日常委托 + 体力清空，进度截图交付。', '单', 0,
   6800, 9800, 5200, -1, 0, 0, 1, 40, ''),
  (8, 11, 5, '无畏契约 · 上分陪练', '', '[]', '竞技模式上分，按局计费，可指定角色定位。', '局', 0,
   5600, 8800, 4300, -1, 0, 0, 1, 30, '');

INSERT IGNORE INTO goods_skus
  (goods_id, name, price, market_price, companion_income, stock, sort, status)
VALUES
  (3, '1 小时', 5200, 8800, 3000, -1, 10, 1),
  (3, '2 小时', 9800, 15800, 5600, -1, 20, 1),
  (3, '3 小时', 13800, 21800, 7900, -1, 30, 1);


-- ----------------------------------------------------------------------------
-- 0020_seed_goods_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 商品管理权限点
--
-- 76 菜单 + 77-80 增删改查（菜单排序 22，排在商品分类之后）。
-- 超管、管理员全部授予；运营只读。
-- ============================================================================

INSERT IGNORE INTO permissions (id, parent_id, name, code, type, path, icon, sort, status) VALUES
  (76, 0,  '商品管理', 'goods',        1, '/peiwan/goods', 'ri:shopping-bag-3-line', 22, 1),
  (77, 76, '查看商品', 'goods:list',   2, '', '', 1, 1),
  (78, 76, '新增商品', 'goods:create', 2, '', '', 2, 1),
  (79, 76, '编辑商品', 'goods:update', 2, '', '', 3, 1),
  (80, 76, '删除商品', 'goods:delete', 2, '', '', 4, 1);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.id IN (1, 2) AND p.id BETWEEN 76 AND 80;

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r CROSS JOIN permissions p
WHERE r.id = 3 AND p.id IN (76, 77);


-- ----------------------------------------------------------------------------
-- 0021_add_goods_virtual_sold.sql
-- ----------------------------------------------------------------------------
-- 商品虚拟已售量：仅用于前台展示，不影响真实销量统计
-- virtual_sold_enabled=1 时，客户端展示销量 = sold + virtual_sold；为 0 时只展示真实 sold。
ALTER TABLE goods
  ADD COLUMN virtual_sold INT NOT NULL DEFAULT 0 COMMENT '虚拟已售量（仅展示用）' AFTER sold,
  ADD COLUMN virtual_sold_enabled TINYINT NOT NULL DEFAULT 0 COMMENT '是否启用虚拟已售：1 启用 0 关闭' AFTER virtual_sold;


-- ----------------------------------------------------------------------------
-- 0022_add_users_uid.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 用户对外编号 uid
--
-- 规则：uid = 100000 + id，注册时分配，客服/订单对外报号使用。
-- 独立列而非展示层计算，便于以后调整编号规则且不影响存量用户。
-- 注意顺序：先加列 -> 回填 -> 再加唯一索引，避免多行默认 0 冲突。
-- ============================================================================

ALTER TABLE users ADD COLUMN uid BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '对外用户编号' AFTER id;

UPDATE users SET uid = 100000 + id WHERE uid = 0;

ALTER TABLE users ADD UNIQUE KEY uk_users_uid (uid);


-- ----------------------------------------------------------------------------
-- 0023_add_users_signature.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 用户个性签名
--
-- 展示在「我的」页面昵称下方，最多 100 个字符（VARCHAR(100) 按字符计）。
-- ============================================================================

ALTER TABLE users ADD COLUMN signature VARCHAR(100) NOT NULL DEFAULT '' COMMENT '个性签名' AFTER nickname;


-- ----------------------------------------------------------------------------
-- 0024_add_users_covers.sql
-- ----------------------------------------------------------------------------
-- 用户背景图：JSON 数组，0 张用默认底色，1 张静态展示，多张按顺序轮播。
ALTER TABLE users
	ADD COLUMN covers TEXT NULL COMMENT '背景图列表（JSON 数组）' AFTER avatar;


-- ----------------------------------------------------------------------------
-- 0025_create_identities_companions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 用户实名认证 + 陪玩入驻
--
-- user_identities   用户实名认证附表：姓名、身份证号、证件照、审核状态
-- companions        陪玩档案：审核通过后由入驻申请生成，一人一条
-- companion_applies 入驻申请：同一用户可有多条历史记录，只有最新一条有效
--
-- 实名信息统一收敛在 user_identities，陪玩申请与档案只冗余 identity_id，
-- 下单、接单等链路统一以 users.is_realname 判断是否完成实名。
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_identities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL COMMENT '用户 ID',
  real_name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '真实姓名',
  id_card VARCHAR(64) NOT NULL DEFAULT '' COMMENT '身份证号（接口返回时脱敏）',
  gender TINYINT NOT NULL DEFAULT 0 COMMENT '性别：0 未知 1 男 2 女',
  birth_date DATE NULL DEFAULT NULL COMMENT '出生日期（由身份证解析）',
  id_card_front VARCHAR(255) NOT NULL DEFAULT '' COMMENT '身份证人像面',
  id_card_back VARCHAR(255) NOT NULL DEFAULT '' COMMENT '身份证国徽面',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 待审核 2 已通过 3 已拒绝',
  audit_remark VARCHAR(500) NOT NULL DEFAULT '' COMMENT '审核备注',
  audited_by BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '审核人 ID',
  audited_at DATETIME NULL DEFAULT NULL COMMENT '审核时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_identity_user (user_id),
  UNIQUE KEY uk_identity_idcard (id_card),
  KEY idx_identity_status (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户实名认证';

-- 用户表冗余实名标记：下单、接单等高频动作不必每次关联附表。
ALTER TABLE users
  ADD COLUMN is_realname TINYINT NOT NULL DEFAULT 0 COMMENT '实名认证：1 已通过 0 未认证' AFTER user_type;

CREATE TABLE IF NOT EXISTS companions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL COMMENT '用户 ID',
  identity_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '实名认证记录 ID',
  bio VARCHAR(500) NOT NULL DEFAULT '' COMMENT '个人介绍',
  games TEXT NULL COMMENT '擅长游戏 ID 快照（JSON 数组）',
  voice_intro VARCHAR(255) NOT NULL DEFAULT '' COMMENT '语音介绍地址',
  voice_duration INT NOT NULL DEFAULT 0 COMMENT '语音时长（秒）',
  star_rating DECIMAL(2,1) NOT NULL DEFAULT 0.0 COMMENT '评分',
  order_count INT NOT NULL DEFAULT 0 COMMENT '累计接单数',
  complete_count INT NOT NULL DEFAULT 0 COMMENT '完成单数',
  complete_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00 COMMENT '完成率（%）',
  online_status TINYINT NOT NULL DEFAULT 0 COMMENT '1 在线 0 离线',
  deposit_amount BIGINT NOT NULL DEFAULT 0 COMMENT '已缴保证金（分）',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 启用 0 禁用',
  last_active_at DATETIME NULL DEFAULT NULL COMMENT '最近活跃时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_companions_user (user_id),
  KEY idx_companions_online (status, online_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪玩档案';

CREATE TABLE IF NOT EXISTS companion_applies (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  apply_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '申请编号',
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '申请用户 ID',
  identity_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '实名认证记录 ID',
  apply_type TINYINT NOT NULL DEFAULT 1 COMMENT '1 首次入驻 2 升级',
  games TEXT NULL COMMENT '申请游戏 ID 快照（JSON 数组）',
  bio VARCHAR(500) NOT NULL DEFAULT '' COMMENT '个人介绍',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 待审 2 通过 3 拒绝',
  audit_remark VARCHAR(500) NOT NULL DEFAULT '' COMMENT '审核备注',
  audited_by BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '审核人 ID',
  audited_at DATETIME NULL DEFAULT NULL COMMENT '审核时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_applies_no (apply_no),
  KEY idx_applies_user (user_id, status),
  KEY idx_applies_status (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪玩入驻申请';


-- ----------------------------------------------------------------------------
-- 0026_seed_identity_companion_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 实名认证与陪玩审核权限点
--
-- 菜单节点 peiwan:companion + 实名审核、入驻审核按钮权限。
-- 超级管理员、管理员全部授予；运营专员只读列表。
--
-- 注意：不要写死主键 ID（分类管理已占用 71-75，会造成 INSERT IGNORE 静默跳过），
--       一律按 code 幂等插入，角色绑定按 code 反查。
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '陪玩管理', 'peiwan:companion', 1, '/peiwan/companion', 'ri:user-star-line', 21, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:companion');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看实名列表', 'identity:list', 2, '', '', 1, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'identity:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '审核实名认证', 'identity:audit', 2, '', '', 2, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'identity:audit');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看入驻申请', 'companion:list', 2, '', '', 3, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'companion:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '审核入驻申请', 'companion:audit', 2, '', '', 4, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'companion:audit');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN ('peiwan:companion', 'identity:list', 'identity:audit', 'companion:list', 'companion:audit');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions
WHERE code IN ('peiwan:companion', 'identity:list', 'identity:audit', 'companion:list', 'companion:audit');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions
WHERE code IN ('peiwan:companion', 'identity:list', 'companion:list');


-- ----------------------------------------------------------------------------
-- 0027_fix_identity_companion_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 修正实名认证 / 陪玩入驻权限点
--
-- 背景：0026 使用固定主键 71-75 插入权限点，但这几个 ID 已被
--       「商品分类」(71-75) 占用，INSERT IGNORE 命中主键冲突后静默跳过，
--       导致权限点实际未落库（超管因 is_super 绕过校验而未暴露问题）。
--
-- 修正策略：不再指定主键，全部按 code 幂等插入，角色绑定也按 code 反查。
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '陪玩管理', 'peiwan:companion', 1, '/peiwan/companion', 'ri:user-star-line', 21, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:companion');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看实名列表', 'identity:list', 2, '', '', 1, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'identity:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '审核实名认证', 'identity:audit', 2, '', '', 2, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'identity:audit');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看入驻申请', 'companion:list', 2, '', '', 3, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'companion:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '审核入驻申请', 'companion:audit', 2, '', '', 4, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'companion:audit');

-- 超级管理员 / 管理员：全部 5 个权限点
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN ('peiwan:companion', 'identity:list', 'identity:audit', 'companion:list', 'companion:audit');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions
WHERE code IN ('peiwan:companion', 'identity:list', 'identity:audit', 'companion:list', 'companion:audit');

-- 运营专员：只读列表
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions
WHERE code IN ('peiwan:companion', 'identity:list', 'companion:list');


-- ----------------------------------------------------------------------------
-- 0028_add_realname_switch_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 实名认证开关配置
--
-- 1. system.order_realname_required      下单是否需要实名（预留，供下单链路读取）
-- 2. system.companion_realname_required  入驻陪玩是否强制实名
--
-- 规则：下单不需要实名时，入驻也不强制实名（effective = 两者同时开启）。
-- 两个键均 is_public=1，前台可读取用于界面提示。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('system', 'system.order_realname_required',     '1', 'bool', 1, 1, 30, '下单是否需要实名'),
  ('system', 'system.companion_realname_required', '1', 'bool', 1, 1, 31, '入驻陪玩是否强制实名（下单实名关闭时不生效）')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0029_create_reviews.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 陪玩评价与评分
--
-- 评分采用贝叶斯平滑（与外卖/豆瓣同思路）：
--   score = (C * m + Σ加权评分) / (C + Σ权重)
--   C = 先验条数（system.rating_seed_count，默认 10）
--   m = 先验分（system.rating_base_score，默认 5.0）
--   权重：1-2 星记 2 倍，3-5 星记 1 倍（差评杀伤更大）
--
-- 效果：无评价时即为 5.00；差评拉低后，好评可持续回升但不会瞬间刷回满分。
-- ============================================================================

CREATE TABLE IF NOT EXISTS reviews (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id     BIGINT UNSIGNED NOT NULL DEFAULT 0     COMMENT '订单ID，0 表示后台补录或未关联订单',
  user_id      BIGINT UNSIGNED NOT NULL               COMMENT '评价用户ID',
  companion_id BIGINT UNSIGNED NOT NULL               COMMENT '被评价陪玩档案ID',
  score        TINYINT UNSIGNED NOT NULL DEFAULT 5    COMMENT '评分 1-5',
  tags         VARCHAR(255)    NOT NULL DEFAULT ''    COMMENT '标签，JSON 数组',
  content      VARCHAR(500)    NOT NULL DEFAULT ''    COMMENT '评价内容',
  images       VARCHAR(1000)   NOT NULL DEFAULT ''    COMMENT '晒图，JSON 数组',
  is_anonymous TINYINT         NOT NULL DEFAULT 0     COMMENT '1 匿名',
  source       TINYINT         NOT NULL DEFAULT 1     COMMENT '1 用户评价 2 后台补录',
  status       TINYINT         NOT NULL DEFAULT 1     COMMENT '1 显示 0 隐藏',
  created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_companion_status (companion_id, status),
  KEY idx_user (user_id),
  KEY idx_order (order_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '陪玩评价';

-- 评分统计冗余字段：避免每次展示都聚合全表，同时保证权重口径一致
ALTER TABLE companions
  ADD COLUMN rating_sum   INT NOT NULL DEFAULT 0 COMMENT '加权评分和',
  ADD COLUMN rating_count INT NOT NULL DEFAULT 0 COMMENT '加权评价数',
  ADD COLUMN review_count INT NOT NULL DEFAULT 0 COMMENT '真实评价条数';

-- 新建陪玩默认 5.00 分（未产生评价时即显示满分，与外卖平台一致）
ALTER TABLE companions
  MODIFY COLUMN star_rating DECIMAL(3, 2) NOT NULL DEFAULT 5.00 COMMENT '综合评分';

UPDATE companions SET star_rating = 5.00 WHERE star_rating = 0;


-- ----------------------------------------------------------------------------
-- 0030_add_rating_configs_and_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 评分配置项与评价管理权限点
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('system', 'system.rating_seed_count', '10',  'int',     1, 1, 32, '评分先验条数 C（越大新陪玩越难被单条差评拉低）'),
  ('system', 'system.rating_base_score', '5.0', 'decimal', 1, 1, 33, '评分先验分 m（无评价时展示的默认分）')
ON DUPLICATE KEY UPDATE config_key = config_key;

-- 评价管理权限点，挂在「陪玩管理」下，按 code 幂等插入
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看评价列表', 'review:list', 2, '', '', 5, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'review:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '补录评价', 'review:create', 2, '', '', 6, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'review:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '隐藏评价', 'review:audit', 2, '', '', 7, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'review:audit');

-- 超级管理员 / 管理员：全部权限
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN ('review:list', 'review:create', 'review:audit');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions
WHERE code IN ('review:list', 'review:create', 'review:audit');

-- 运营专员：只读
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions
WHERE code = 'review:list';


-- ----------------------------------------------------------------------------
-- 0031_create_companion_capabilities.sql
-- ----------------------------------------------------------------------------
-- 陪玩可接单能力（游戏 + 区服维度，支持单个开关）
CREATE TABLE IF NOT EXISTS companion_capabilities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  companion_id BIGINT UNSIGNED NOT NULL COMMENT '陪玩档案ID',
  game_id BIGINT UNSIGNED NOT NULL COMMENT '游戏ID',
  server_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '区服ID，0 表示该游戏全部区服',
  enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否接该游戏/区服的单：1 开启 0 关闭',
  source TINYINT NOT NULL DEFAULT 1 COMMENT '来源：1 审核通过 2 后台调整',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_companion_game_server (companion_id, game_id, server_id),
  KEY idx_companion (companion_id),
  KEY idx_game (game_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪玩可接单的游戏区服能力';

-- 能力变更日志：后台降级 / 审核升级 / 开关变动都会留痕，供陪玩查看与后续消息通知
CREATE TABLE IF NOT EXISTS companion_capability_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  companion_id BIGINT UNSIGNED NOT NULL COMMENT '陪玩档案ID',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '陪玩所属用户ID',
  capability_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '能力ID，删除后仍保留原ID',
  game_id BIGINT UNSIGNED NOT NULL COMMENT '游戏ID',
  server_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '区服ID，0 表示全部区服',
  action TINYINT NOT NULL COMMENT '1 升级新增 2 降级移除 3 开启接单 4 关闭接单',
  actor_type TINYINT NOT NULL DEFAULT 2 COMMENT '操作者：1 陪玩本人 2 管理员',
  actor_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作者ID',
  remark VARCHAR(200) NOT NULL DEFAULT '' COMMENT '备注/原因',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_companion (companion_id, id),
  KEY idx_user (user_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪玩能力变更日志';

-- 申请表补充区服选择：{"游戏ID":[区服ID]}，数组为空表示该游戏全部区服
ALTER TABLE companion_applies
  ADD COLUMN game_servers TEXT NULL COMMENT '区服选择JSON {"游戏ID":[区服ID]}，空数组表示全部区服' AFTER games;


-- ----------------------------------------------------------------------------
-- 0032_add_companion_voice.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 入驻申请语音介绍
-- 入驻申请可提交一段语音介绍（地址 + 时长），审核通过后写入陪玩档案
-- 各条语句均做列存在性判断，可重复执行
-- ============================================================================

SET @db_name = DATABASE();

-- companion_applies.voice_intro 语音介绍地址
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'companion_applies'
    AND COLUMN_NAME = 'voice_intro'
);
SET @ddl = IF(@col_exists = 0,
  "ALTER TABLE companion_applies ADD COLUMN voice_intro VARCHAR(255) NOT NULL DEFAULT '' COMMENT '语音介绍地址' AFTER bio",
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- companion_applies.voice_duration 语音时长（秒）
SET @col_exists = (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'companion_applies'
    AND COLUMN_NAME = 'voice_duration'
);
SET @ddl = IF(@col_exists = 0,
  "ALTER TABLE companion_applies ADD COLUMN voice_duration INT NOT NULL DEFAULT 0 COMMENT '语音时长（秒）' AFTER voice_intro",
  'DO 0');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- ----------------------------------------------------------------------------
-- 0033_companion_voice_audit.sql
-- ----------------------------------------------------------------------------
-- 陪玩语音介绍独立审核：陪玩单独录制提交，后台审核通过后才写入档案展示到前台
CREATE TABLE IF NOT EXISTS companion_voice_applies (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL COMMENT '提交用户ID',
  companion_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '陪玩档案ID',
  voice_intro VARCHAR(255) NOT NULL DEFAULT '' COMMENT '语音地址（本站相对路径）',
  voice_duration INT NOT NULL DEFAULT 0 COMMENT '语音时长（秒）',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 待审核 2 已通过 3 未通过',
  audit_remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '审核备注/拒绝原因',
  audited_by BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '审核管理员ID',
  audited_at DATETIME NULL DEFAULT NULL COMMENT '审核时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_status (user_id, status),
  KEY idx_status_id (status, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪玩语音介绍审核记录';

-- 历史数据：入驻申请里提交过、且档案还没有语音的，转成待审核记录，等后台重新审核后展示
INSERT INTO companion_voice_applies (user_id, companion_id, voice_intro, voice_duration, status, created_at)
SELECT a.user_id, IFNULL(c.id, 0), a.voice_intro, a.voice_duration, 1, a.created_at
FROM companion_applies a
LEFT JOIN companions c ON c.user_id = a.user_id
WHERE a.voice_intro <> ''
  AND a.status = 2
  AND (c.voice_intro IS NULL OR c.voice_intro = '');

-- 语音审核权限点（挂在陪玩管理菜单下）
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看语音审核', 'companion:voice:list', 2, '', '', 5, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'companion:voice:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '审核语音介绍', 'companion:voice:audit', 2, '', '', 6, 1
FROM permissions p
WHERE p.code = 'peiwan:companion'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'companion:voice:audit');

-- 超级管理员 / 管理员：可查看与审核
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE code IN ('companion:voice:list', 'companion:voice:audit');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE code IN ('companion:voice:list', 'companion:voice:audit');

-- 运营专员：只读列表
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE code = 'companion:voice:list';


-- ----------------------------------------------------------------------------
-- 0034_add_upload_cleanup.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 上传文件自动清理
--
-- 1. uploads 增加清理标记：只删物理文件并记录 deleted_at，保留记录便于追溯；
--    同一内容再次上传时命中 hash 会复用记录并清除标记，URL 保持不变。
-- 2. 系统配置新增三个键（后台「系统设置」可直接改）：
--      system.upload_cleanup_enabled     是否开启定时清理，默认 1（开启）
--      system.upload_cleanup_days        图片/视频/文档等保留天数，默认 7，0 表示永久保留
--      system.upload_cleanup_audio_days  音频（语音介绍）保留天数，默认 3，0 表示永久保留
--
-- 清理只针对「没有被任何业务表引用」的文件，正在使用的一律保留。
-- ============================================================================

ALTER TABLE uploads
  ADD COLUMN deleted_at DATETIME NULL DEFAULT NULL COMMENT '自动清理时间，NULL 表示未清理' AFTER updated_at,
  ADD COLUMN delete_reason VARCHAR(32) NOT NULL DEFAULT '' COMMENT '清理原因' AFTER deleted_at,
  ADD KEY idx_uploads_created (created_at),
  ADD KEY idx_uploads_deleted (deleted_at);

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('system', 'system.upload_cleanup_enabled',    '1', 'bool', 0, 1, 40, '自动清理未被使用的上传文件'),
  ('system', 'system.upload_cleanup_days',       '7', 'int',  0, 1, 41, '图片/视频/文档保留天数（0 表示永久保留）'),
  ('system', 'system.upload_cleanup_audio_days', '3', 'int',  0, 1, 42, '语音/音频保留天数（0 表示永久保留）')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0035_seed_user_create_permission.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 后台手动新增用户权限点
--
-- 在「用户管理」菜单下增加「新增用户」按钮权限（id=15），
-- 授予超级管理员（R_SUPER）与管理员（R_ADMIN）；运营专员不授予。
-- ============================================================================

INSERT IGNORE INTO permissions (id, parent_id, name, code, type, path, icon, sort, status) VALUES
  (15, 10, '新增用户', 'system:user:create', 2, '', '', 0, 1);

INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES
  (1, 15);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE id = 15;


-- ----------------------------------------------------------------------------
-- 0036_split_system_config_groups.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 系统配置分组拆分
--
-- 原先把 33 项配置塞在 basic / system 两个分组里，后台只能看到两个超长 Tab。
-- 这里按业务域重新归类，每类对应后台一个独立菜单页面：
--   site 站点设置 / contact 客服设置 / register 注册设置 / maintenance 维护设置
--   upload 上传设置 / realname 实名设置 / cleanup 清理设置
--   rating 评分设置 / general 通用设置
--
-- 只改 group_name，不动 config_key 与 config_value，
-- 前台通过 key 读取公开配置（site.name 等）不受影响。
-- ============================================================================

-- 站点信息（site.name / site.logo / site.icp ...）
UPDATE system_configs SET group_name = 'site' WHERE config_key LIKE 'site.%';

-- 客服联系方式（contact.service_qq / service_wechat / service_phone ...）
UPDATE system_configs SET group_name = 'contact' WHERE config_key LIKE 'contact.%';

-- 维护模式（system.maintenance / system.maintenance_notice）
UPDATE system_configs SET group_name = 'maintenance' WHERE config_key LIKE 'system.maintenance%';

-- 注册与登录（system.register_enabled / system.login_captcha）
UPDATE system_configs
SET group_name = 'register'
WHERE config_key IN ('system.register_enabled', 'system.login_captcha');

-- 文件上传（system.upload_max_mb / system.upload_extensions）
UPDATE system_configs
SET group_name = 'upload'
WHERE config_key IN ('system.upload_max_mb', 'system.upload_extensions');

-- 实名认证（system.order_realname_required / system.companion_realname_required）
UPDATE system_configs
SET group_name = 'realname'
WHERE config_key IN ('system.order_realname_required', 'system.companion_realname_required');

-- 上传文件清理（system.upload_cleanup_enabled / _days / _audio_days）
UPDATE system_configs
SET group_name = 'cleanup'
WHERE config_key IN (
  'system.upload_cleanup_enabled',
  'system.upload_cleanup_days',
  'system.upload_cleanup_audio_days'
);

-- 评分算法（system.rating_seed_count / system.rating_base_score）
UPDATE system_configs
SET group_name = 'rating'
WHERE config_key IN ('system.rating_seed_count', 'system.rating_base_score');

-- 其余 system.* 归入通用设置（时区、分页、货币）
UPDATE system_configs SET group_name = 'general' WHERE group_name = 'system';


-- ----------------------------------------------------------------------------
-- 0037_sync_companion_user_type.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 修复陪玩用户类型
--
-- 入驻审核通过时只写 companions / companion_capabilities，
-- 没有同步 users.user_type，而公开陪玩列表（GET /users?userType=2）
-- 与资料卡都按 user_type=2 过滤，导致新入驻陪玩在前台看不到。
--
-- 这里把已有陪玩档案的用户类型补齐；审核逻辑已在同一事务内修复。
-- ============================================================================

UPDATE users AS u
JOIN companions AS c ON c.user_id = u.id
SET u.user_type = 2
WHERE u.user_type <> 2;


-- ----------------------------------------------------------------------------
-- 0038_unify_signature.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 个人介绍统一到 users.signature
--
-- 原先存在两份「自我介绍」：
--   users.signature       个性签名，100 字，用户可自助编辑（我的-编辑资料）
--   companions.bio        陪玩个人介绍，500 字，只在入驻申请时提交，之后无法修改
-- 两者在资料卡上同时出现，语义重复且 bio 改不了。
--
-- 这里统一为一份：users.signature 作为唯一真源（上限放宽到 500 字），
-- 存量 bio 覆盖写入 signature（入驻时填写的介绍更完整），随后清空 bio。
-- companion_apply.bio 保留，作为入驻审核的历史存档。
-- ============================================================================

ALTER TABLE users
  MODIFY COLUMN signature VARCHAR(500) NOT NULL DEFAULT '' COMMENT '个人介绍（个性签名）' AFTER nickname;

UPDATE users AS u
INNER JOIN companions AS c ON c.user_id = u.id
SET u.signature = c.bio
WHERE c.bio <> '';

UPDATE companions SET bio = '' WHERE bio <> '';


-- ----------------------------------------------------------------------------
-- 0039_create_orders_wallets.sql
-- ----------------------------------------------------------------------------
-- 订单、订单日志、用户钱包与钱包流水
-- 本期订单流程：下单（待支付）→ 余额支付（待服务）→ 用户确认完成 / 取消退款
-- 派单与陪玩结算暂未启用：companion_id、companion_income 仅做事前留位。

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '订单号',
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '下单用户 ID',
  goods_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '商品 ID',
  sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '规格 ID，0 表示单规格商品',
  game_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '所属游戏 ID（快照）',
  title VARCHAR(200) NOT NULL DEFAULT '' COMMENT '商品标题（快照）',
  cover VARCHAR(255) NOT NULL DEFAULT '' COMMENT '商品封面（快照）',
  sku_name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '规格名（快照）',
  unit VARCHAR(20) NOT NULL DEFAULT '局' COMMENT '计价单位（快照）',
  quantity INT NOT NULL DEFAULT 1 COMMENT '数量',
  unit_price BIGINT NOT NULL DEFAULT 0 COMMENT '单价（分）',
  total_amount BIGINT NOT NULL DEFAULT 0 COMMENT '订单总额（分）',
  pay_amount BIGINT NOT NULL DEFAULT 0 COMMENT '实付金额（分）',
  companion_income BIGINT NOT NULL DEFAULT 0 COMMENT '陪玩应得（分，预留）',
  platform_income BIGINT NOT NULL DEFAULT 0 COMMENT '平台抽成（分，预留）',
  companion_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '接单陪玩档案 ID，0 未指派（预留）',
  status TINYINT NOT NULL DEFAULT 10 COMMENT '10 待支付 20 待服务 70 已完成 100 已退款 110 已取消',
  pay_type TINYINT NOT NULL DEFAULT 0 COMMENT '0 未支付 1 余额支付',
  pay_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '支付流水号',
  pay_time DATETIME NULL COMMENT '支付时间',
  game_nickname VARCHAR(50) NOT NULL DEFAULT '' COMMENT '游戏昵称',
  game_account VARCHAR(64) NOT NULL DEFAULT '' COMMENT '游戏账号 / ID',
  user_remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '用户备注',
  admin_remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '后台备注',
  cancel_reason VARCHAR(255) NOT NULL DEFAULT '' COMMENT '取消原因',
  cancel_at DATETIME NULL COMMENT '取消时间',
  refund_amount BIGINT NOT NULL DEFAULT 0 COMMENT '退款金额（分）',
  refund_at DATETIME NULL COMMENT '退款时间',
  completed_at DATETIME NULL COMMENT '完成时间',
  confirmed_at DATETIME NULL COMMENT '确认收货时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_orders_no (order_no),
  KEY idx_orders_user (user_id, status, id),
  KEY idx_orders_status (status, id),
  KEY idx_orders_goods (goods_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单';

CREATE TABLE IF NOT EXISTS order_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '订单 ID',
  action VARCHAR(32) NOT NULL DEFAULT '' COMMENT '动作标识：create/pay/cancel/complete/refund/remark',
  action_text VARCHAR(50) NOT NULL DEFAULT '' COMMENT '动作中文名',
  from_status TINYINT NOT NULL DEFAULT 0 COMMENT '变更前状态',
  to_status TINYINT NOT NULL DEFAULT 0 COMMENT '变更后状态',
  operator_type TINYINT NOT NULL DEFAULT 1 COMMENT '1 用户 2 管理员 3 系统',
  operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人 ID',
  operator_name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '操作人名称',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_order_logs_order (order_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单操作日志';

CREATE TABLE IF NOT EXISTS wallets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '用户 ID',
  balance BIGINT NOT NULL DEFAULT 0 COMMENT '可用余额（分）',
  total_income BIGINT NOT NULL DEFAULT 0 COMMENT '累计收入（分）',
  total_expense BIGINT NOT NULL DEFAULT 0 COMMENT '累计支出（分）',
  version INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_wallets_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户钱包';

CREATE TABLE IF NOT EXISTS wallet_ledgers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ledger_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '流水号',
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '用户 ID',
  biz_type VARCHAR(32) NOT NULL DEFAULT '' COMMENT 'recharge/order_pay/order_refund/admin_adjust',
  biz_no VARCHAR(64) NOT NULL DEFAULT '' COMMENT '业务单号（幂等键）',
  direction TINYINT NOT NULL DEFAULT 1 COMMENT '1 收入 -1 支出',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '金额（分，正数）',
  balance_before BIGINT NOT NULL DEFAULT 0 COMMENT '变动前余额（分）',
  balance_after BIGINT NOT NULL DEFAULT 0 COMMENT '变动后余额（分）',
  order_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联订单 ID',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  operator_type TINYINT NOT NULL DEFAULT 1 COMMENT '1 用户 2 管理员 3 系统',
  operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作人 ID',
  operator_name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '操作人名称',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_wallet_ledgers_no (ledger_no),
  UNIQUE KEY uk_wallet_ledgers_biz (biz_type, biz_no),
  KEY idx_wallet_ledgers_user (user_id, id),
  KEY idx_wallet_ledgers_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='钱包流水';


-- ----------------------------------------------------------------------------
-- 0040_seed_order_wallet_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 订单与钱包权限点
--
-- 菜单节点 peiwan:order + 订单操作按钮；peiwan:wallet + 钱包调账按钮。
-- 超级管理员、管理员全部授予；运营专员只读。
-- 一律按 code 幂等插入，不写死主键 ID。
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '订单管理', 'peiwan:order', 1, '/peiwan/order', 'ri:file-list-3-line', 23, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:order');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看订单', 'order:list', 2, '', '', 1, 1
FROM permissions p
WHERE p.code = 'peiwan:order'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'order:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '完成订单', 'order:complete', 2, '', '', 2, 1
FROM permissions p
WHERE p.code = 'peiwan:order'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'order:complete');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '取消/退款订单', 'order:cancel', 2, '', '', 3, 1
FROM permissions p
WHERE p.code = 'peiwan:order'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'order:cancel');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '订单备注', 'order:remark', 2, '', '', 4, 1
FROM permissions p
WHERE p.code = 'peiwan:order'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'order:remark');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '钱包管理', 'peiwan:wallet', 1, '/peiwan/wallet', 'ri:wallet-3-line', 24, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:wallet');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看钱包', 'wallet:list', 2, '', '', 1, 1
FROM permissions p
WHERE p.code = 'peiwan:wallet'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'wallet:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '调整余额', 'wallet:adjust', 2, '', '', 2, 1
FROM permissions p
WHERE p.code = 'peiwan:wallet'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'wallet:adjust');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看流水', 'wallet:ledger', 2, '', '', 3, 1
FROM permissions p
WHERE p.code = 'peiwan:wallet'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'wallet:ledger');

-- 超级管理员 / 管理员：全部
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN ('peiwan:order', 'order:list', 'order:complete', 'order:cancel', 'order:remark',
               'peiwan:wallet', 'wallet:list', 'wallet:adjust', 'wallet:ledger');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions
WHERE code IN ('peiwan:order', 'order:list', 'order:complete', 'order:cancel', 'order:remark',
               'peiwan:wallet', 'wallet:list', 'wallet:adjust', 'wallet:ledger');

-- 运营专员：只读
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions
WHERE code IN ('peiwan:order', 'order:list', 'peiwan:wallet', 'wallet:list', 'wallet:ledger');


-- ----------------------------------------------------------------------------
-- 0041_add_order_game_server.sql
-- ----------------------------------------------------------------------------
-- 订单增加游戏区服快照：下单时按商品所属游戏选择启用中的区服
ALTER TABLE `orders`
  ADD COLUMN `game_server_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '游戏区服ID（快照）' AFTER `game_id`,
  ADD COLUMN `game_server_name` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '游戏区服名（快照）' AFTER `game_server_id`;


-- ----------------------------------------------------------------------------
-- 0042_add_order_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 订单设置
--
-- 系统配置新增「订单设置」分组，控制新订单的单号格式：
--   order.prefix    订单号前缀，默认 SF（1-6 位字母或数字，保存时校验）
--   order.short_no  是否使用短订单号，默认 0
--                   0 = 前缀 + 14 位时间 + 5 位序号 + 3 位随机
--                   1 = 前缀 + 6 位序号 + 4 位随机（不含日期，单号更短）
--
-- 修改后只影响之后创建的新订单，历史订单号保持不变。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('order', 'order.prefix',   'SF', 'string', 0, 1, 1, '订单号前缀（1-6 位字母或数字，仅影响新订单）'),
  ('order', 'order.short_no', '0',  'bool',   0, 1, 2, '短订单号：不含日期段，格式为「前缀+序号+随机」')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0043_add_order_accept.sql
-- ----------------------------------------------------------------------------
-- 陪玩接单：订单记录接单时间；接单池按「状态 + 接单人 + 游戏/区服」检索。
ALTER TABLE orders
	ADD COLUMN accept_at DATETIME NULL COMMENT '接单时间' AFTER pay_time;

ALTER TABLE orders
	ADD INDEX idx_orders_pool (status, companion_id, game_id, game_server_id);


-- ----------------------------------------------------------------------------
-- 0044_create_member_levels.sql
-- ----------------------------------------------------------------------------
-- 会员等级：按累计消费（实付订单金额）自动升级
-- min_spend 单位为分，0 表示无门槛
CREATE TABLE IF NOT EXISTS member_levels (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
    level_no INT NOT NULL DEFAULT 1 COMMENT '等级序号',
    name VARCHAR(32) NOT NULL COMMENT '等级名称',
    badge VARCHAR(8) NOT NULL DEFAULT '' COMMENT '徽章字符',
    badge_name VARCHAR(32) NOT NULL DEFAULT '' COMMENT '徽章名称',
    badge_icon VARCHAR(255) NOT NULL DEFAULT '' COMMENT '徽章图片，空则用字符徽章',
    color_start VARCHAR(16) NOT NULL DEFAULT '#2f6bff' COMMENT '卡片渐变起始色',
    color_end VARCHAR(16) NOT NULL DEFAULT '#6aa8ff' COMMENT '卡片渐变结束色',
    min_spend BIGINT NOT NULL DEFAULT 0 COMMENT '累计消费门槛（分）',
    benefits TEXT COMMENT '权益列表，JSON 数组',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1 启用 0 停用',
    sort INT NOT NULL DEFAULT 0 COMMENT '排序',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_level_no (level_no),
    KEY idx_min_spend (min_spend)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '会员等级';

INSERT INTO member_levels (level_no, name, badge, badge_name, color_start, color_end, min_spend, benefits, status, sort)
SELECT 1, '启程会员', '启', '启程徽章', '#2f6bff', '#6aa8ff', 0, '["专属会员标识","会员专属客服通道"]', 1, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM member_levels WHERE level_no = 1);

INSERT INTO member_levels (level_no, name, badge, badge_name, color_start, color_end, min_spend, benefits, status, sort)
SELECT 2, '青铜会员', '青', '青铜徽章', '#9a5b34', '#d99a63', 10000, '["青铜专属徽章","订单优先展示","会员专属客服通道"]', 1, 2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM member_levels WHERE level_no = 2);

INSERT INTO member_levels (level_no, name, badge, badge_name, color_start, color_end, min_spend, benefits, status, sort)
SELECT 3, '白银会员', '银', '白银徽章', '#7e8b9c', '#cbd5e1', 50000, '["白银专属徽章","订单优先展示","专属客服通道"]', 1, 3 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM member_levels WHERE level_no = 3);

INSERT INTO member_levels (level_no, name, badge, badge_name, color_start, color_end, min_spend, benefits, status, sort)
SELECT 4, '黄金会员', '金', '黄金徽章', '#b8860b', '#f3d27a', 200000, '["黄金专属徽章","订单优先派单","生日礼包","专属客服通道"]', 1, 4 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM member_levels WHERE level_no = 4);

INSERT INTO member_levels (level_no, name, badge, badge_name, color_start, color_end, min_spend, benefits, status, sort)
SELECT 5, '铂金会员', '铂', '铂金徽章', '#3f7f8f', '#9fdfe5', 500000, '["铂金专属徽章","订单优先派单","每月专属优惠券","一对一客服"]', 1, 5 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM member_levels WHERE level_no = 5);

INSERT INTO member_levels (level_no, name, badge, badge_name, color_start, color_end, min_spend, benefits, status, sort)
SELECT 6, '钻石会员', '钻', '钻石徽章', '#5a3fd6', '#b394ff', 1000000, '["钻石专属徽章","最高派单优先级","每月专属优惠券","一对一客服","专属活动资格"]', 1, 6 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM member_levels WHERE level_no = 6);

INSERT INTO member_levels (level_no, name, badge, badge_name, color_start, color_end, min_spend, benefits, status, sort)
SELECT 7, '王者会员', '王', '王者徽章', '#6d1f22', '#d4a24a', 3000000, '["王者专属徽章","全站最高优先级","一对一专属管家","限定外观与身份展示","线下活动邀请"]', 1, 7 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM member_levels WHERE level_no = 7);

-- 权限点
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '会员等级', 'peiwan:member-level', 1, '/peiwan/member-level', 'ri:vip-crown-line', 26, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:member-level');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看会员等级', 'member-level:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'peiwan:member-level'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'member-level:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '新增会员等级', 'member-level:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'peiwan:member-level'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'member-level:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑会员等级', 'member-level:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'peiwan:member-level'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'member-level:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除会员等级', 'member-level:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'peiwan:member-level'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'member-level:delete');

-- 管理员与运营角色授权
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('peiwan:member-level', 'member-level:list', 'member-level:create', 'member-level:update', 'member-level:delete')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0045_fix_wallet_totals.sql
-- ----------------------------------------------------------------------------
-- 修正钱包累计收支口径：退款不属于收入，且应冲减累计支出
-- 历史上退款走 direction=1 入账，导致 total_income 被虚增（收入 100 消费 56 退款 56 后显示 156）
-- 这里按 wallet_ledgers 流水重算累计收支，余额（balance）与流水本身不做任何改动

UPDATE wallets w
LEFT JOIN (
  SELECT
    user_id,
    SUM(CASE WHEN direction = 1 AND biz_type <> 'order_refund' THEN amount ELSE 0 END) AS income,
    SUM(CASE WHEN direction = -1 THEN amount ELSE 0 END) AS expense,
    SUM(CASE WHEN direction = 1 AND biz_type = 'order_refund' THEN amount ELSE 0 END) AS refund
  FROM wallet_ledgers
  GROUP BY user_id
) l ON l.user_id = w.user_id
SET w.total_income = IFNULL(l.income, 0),
    w.total_expense = GREATEST(IFNULL(l.expense, 0) - IFNULL(l.refund, 0), 0);


-- ----------------------------------------------------------------------------
-- 0046_settle_completed_order_income.sql
-- ----------------------------------------------------------------------------
-- 历史补账：完成订单此前只改状态，没有给陪玩结算收入
-- 为每笔「已完成 + 有陪玩收益」且尚无 order_income 流水的订单补一条结算流水，并同步钱包余额
-- 说明：orders.companion_id 指向 companions.id，钱包按 companions.user_id 记账

-- 1) 补齐缺失的钱包行，保证后续 JOIN 不丢单
INSERT IGNORE INTO wallets (user_id, balance, total_income, total_expense, version)
SELECT DISTINCT c.user_id, 0, 0, 0, 0
FROM orders o
JOIN companions c ON c.id = o.companion_id
WHERE o.status = 70
  AND o.companion_income > 0
  AND c.user_id > 0;

-- 2) 补结算流水：同一陪玩的多笔补账按完成时间累加，balance_before/after 保持连续
--    重复执行时唯一键 (biz_type, biz_no) 会直接报错中止，不会产生重复入账
INSERT INTO wallet_ledgers (
  ledger_no, user_id, biz_type, biz_no, direction, amount,
  balance_before, balance_after, order_id, remark,
  operator_type, operator_id, operator_name, created_at
)
SELECT
  CONCAT('IN', LPAD(p.order_id, 18, '0')),
  p.user_id,
  'order_income',
  p.order_no,
  1,
  p.amount,
  w.balance + p.cum_amount - p.amount,
  w.balance + p.cum_amount,
  p.order_id,
  '订单完成结算（历史补账）',
  3,
  0,
  '系统',
  IFNULL(p.completed_at, NOW())
FROM (
  SELECT
    o.id AS order_id,
    o.order_no,
    o.companion_income AS amount,
    o.completed_at,
    c.user_id,
    (
      SELECT SUM(o2.companion_income)
      FROM orders o2
      JOIN companions c2 ON c2.id = o2.companion_id
      WHERE o2.status = 70
        AND o2.companion_income > 0
        AND c2.user_id = c.user_id
        AND (
          IFNULL(o2.completed_at, o2.created_at) < IFNULL(o.completed_at, o.created_at)
          OR (IFNULL(o2.completed_at, o2.created_at) = IFNULL(o.completed_at, o.created_at) AND o2.id <= o.id)
        )
    ) AS cum_amount
  FROM orders o
  JOIN companions c ON c.id = o.companion_id
  WHERE o.status = 70
    AND o.companion_income > 0
    AND c.user_id > 0
    AND NOT EXISTS (
      SELECT 1 FROM wallet_ledgers l
      WHERE l.biz_type = 'order_income' AND l.biz_no = o.order_no
    )
) p
JOIN wallets w ON w.user_id = p.user_id;

-- 3) 钱包余额与累计收入同步增加（口径与 applyWalletChange 一致：入账计入累计收入）
UPDATE wallets w
JOIN (
  SELECT user_id, SUM(amount) AS total
  FROM wallet_ledgers
  WHERE biz_type = 'order_income' AND remark = '订单完成结算（历史补账）'
  GROUP BY user_id
) t ON t.user_id = w.user_id
SET w.balance = w.balance + t.total,
    w.total_income = w.total_income + t.total;


-- ----------------------------------------------------------------------------
-- 0047_create_companion_levels.sql
-- ----------------------------------------------------------------------------
-- 陪玩等级：按累计接单收入（已完成订单的陪玩收益）自动升级
-- 与会员等级（member_levels，按累计消费）相互独立：
-- 会员等级面向买家消费，陪玩等级面向供给侧接单业绩。
-- min_income 单位为分，0 表示无门槛。
CREATE TABLE IF NOT EXISTS companion_levels (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
    level_no INT NOT NULL DEFAULT 1 COMMENT '等级序号',
    name VARCHAR(32) NOT NULL COMMENT '等级名称',
    badge VARCHAR(8) NOT NULL DEFAULT '' COMMENT '徽章字符',
    badge_name VARCHAR(32) NOT NULL DEFAULT '' COMMENT '徽章名称',
    badge_icon VARCHAR(255) NOT NULL DEFAULT '' COMMENT '徽章图片，空则用字符徽章',
    color_start VARCHAR(16) NOT NULL DEFAULT '#7b3ff2' COMMENT '卡片渐变起始色',
    color_end VARCHAR(16) NOT NULL DEFAULT '#b98bff' COMMENT '卡片渐变结束色',
    min_income BIGINT NOT NULL DEFAULT 0 COMMENT '累计收入门槛（分）',
    benefits TEXT COMMENT '权益列表，JSON 数组',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1 启用 0 停用',
    sort INT NOT NULL DEFAULT 0 COMMENT '排序',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_level_no (level_no),
    KEY idx_min_income (min_income)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '陪玩等级';

INSERT INTO companion_levels (level_no, name, badge, badge_name, color_start, color_end, min_income, benefits, status, sort)
SELECT 1, '新手陪玩', '新', '新手徽章', '#7b3ff2', '#b98bff', 0, '["陪玩身份标识","接单大厅正常展示"]', 1, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM companion_levels WHERE level_no = 1);

INSERT INTO companion_levels (level_no, name, badge, badge_name, color_start, color_end, min_income, benefits, status, sort)
SELECT 2, '星耀陪玩', '星', '星耀徽章', '#1f7ae0', '#6ec1ff', 10000, '["等级徽章展示","接单大厅优先展示"]', 1, 2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM companion_levels WHERE level_no = 2);

INSERT INTO companion_levels (level_no, name, badge, badge_name, color_start, color_end, min_income, benefits, status, sort)
SELECT 3, '王牌陪玩', '王', '王牌徽章', '#0f8f6f', '#5fd6a8', 50000, '["等级徽章展示","接单大厅优先展示","专属客服通道"]', 1, 3 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM companion_levels WHERE level_no = 3);

INSERT INTO companion_levels (level_no, name, badge, badge_name, color_start, color_end, min_income, benefits, status, sort)
SELECT 4, '荣耀陪玩', '荣', '荣耀徽章', '#b8860b', '#f3d27a', 150000, '["等级徽章展示","接单优先派单","专属客服通道"]', 1, 4 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM companion_levels WHERE level_no = 4);

INSERT INTO companion_levels (level_no, name, badge, badge_name, color_start, color_end, min_income, benefits, status, sort)
SELECT 5, '传奇陪玩', '传', '传奇徽章', '#c2410c', '#fb923c', 500000, '["等级徽章展示","接单优先派单","每月流量扶持","专属客服通道"]', 1, 5 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM companion_levels WHERE level_no = 5);

INSERT INTO companion_levels (level_no, name, badge, badge_name, color_start, color_end, min_income, benefits, status, sort)
SELECT 6, '巅峰陪玩', '峰', '巅峰徽章', '#7f1d3f', '#f472b6', 1500000, '["等级徽章展示","最高派单优先级","每月流量扶持","一对一客服"]', 1, 6 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM companion_levels WHERE level_no = 6);

INSERT INTO companion_levels (level_no, name, badge, badge_name, color_start, color_end, min_income, benefits, status, sort)
SELECT 7, '殿堂陪玩', '殿', '殿堂徽章', '#3b2f0b', '#d4a24a', 5000000, '["等级徽章展示","最高派单优先级","专属活动资格","一对一专属管家"]', 1, 7 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM companion_levels WHERE level_no = 7);

-- 权限点
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '陪玩等级', 'peiwan:companion-level', 1, '/peiwan/companion-level', 'ri:medal-line', 27, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:companion-level');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看陪玩等级', 'companion-level:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'peiwan:companion-level'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'companion-level:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '新增陪玩等级', 'companion-level:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'peiwan:companion-level'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'companion-level:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑陪玩等级', 'companion-level:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'peiwan:companion-level'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'companion-level:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除陪玩等级', 'companion-level:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'peiwan:companion-level'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'companion-level:delete');

-- 管理员与运营角色授权
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('peiwan:companion-level', 'companion-level:list', 'companion-level:create', 'companion-level:update', 'companion-level:delete')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0048_add_goods_owner_uid.sql
-- ----------------------------------------------------------------------------
-- 商品归属陪玩：owner_uid 存陪玩的对外用户编号，0 表示平台商品。
-- 归属后下单时按 owner_uid 拦截自购，也用于资料卡商品与陪玩的绑定关系。
ALTER TABLE goods ADD COLUMN owner_uid BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '归属陪玩用户UID，0=平台商品' AFTER companion_income;
ALTER TABLE goods ADD INDEX idx_goods_owner (owner_uid, status);


-- ----------------------------------------------------------------------------
-- 0049_add_order_designated.sql
-- ----------------------------------------------------------------------------
-- 指定单：从陪玩资料卡 / 下单时选择在线陪玩产生的订单，只有被指定的陪玩能接。
-- order_type：1=普通单（进公共接单池）2=指定单（仅指定陪玩可见可接）。
ALTER TABLE orders ADD COLUMN order_type TINYINT NOT NULL DEFAULT 1 COMMENT '1=普通单 2=指定单' AFTER platform_income;
ALTER TABLE orders ADD COLUMN designated_companion_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '指定陪玩 companions.id，0=未指定' AFTER order_type;
ALTER TABLE orders ADD COLUMN designated_at DATETIME NULL COMMENT '指定时间' AFTER designated_companion_id;
ALTER TABLE orders ADD INDEX idx_orders_designated (designated_companion_id, status);

-- 历史数据一律是普通单，显式回填一次，避免默认值语义变化带来的歧义。
UPDATE orders SET order_type = 1 WHERE order_type IS NULL OR order_type = 0;


-- ----------------------------------------------------------------------------
-- 0050_add_designated_ttl_config.sql
-- ----------------------------------------------------------------------------
-- 指定单等待时长：超时未接单或指定陪玩已失效时，自动转普通单进入公共接单池。
-- 0 表示只释放「指定陪玩已失效」的单，不做超时释放。
INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES ('order', 'order.designated_ttl_minutes', '30', 'int', 0, 1, 3,
        '指定单等待时长（分钟）：超时未接单自动转普通单进公共池，0 表示不自动转')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0051_add_order_service_flow.sql
-- ----------------------------------------------------------------------------
-- 订单状态升级：20 待接单 → 30 待服务 → 40 服务中 → 50 待确认 → 70 已完成。
-- 1) 开始服务时间、售后申请信息；
-- 2) 存量「已支付且已被接单」的订单归入 30 待服务；
-- 3) 订单留言板表；
-- 4) 订单超时兜底配置。
ALTER TABLE orders
    ADD COLUMN start_at DATETIME NULL COMMENT '开始服务时间' AFTER accept_at,
    ADD COLUMN refund_request_at DATETIME NULL COMMENT '用户申请退款时间' AFTER refund_at,
    ADD COLUMN refund_request_reason VARCHAR(255) NOT NULL DEFAULT '' COMMENT '用户申请退款原因' AFTER refund_request_at;

UPDATE orders SET status = 30 WHERE status = 20 AND companion_id > 0;

CREATE TABLE IF NOT EXISTS order_messages (
    id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id    BIGINT UNSIGNED NOT NULL,
    sender_type TINYINT NOT NULL DEFAULT 1 COMMENT '1 买家 2 陪玩 3 系统',
    sender_id   BIGINT UNSIGNED NOT NULL DEFAULT 0,
    sender_name VARCHAR(64) NOT NULL DEFAULT '',
    content     VARCHAR(1000) NOT NULL DEFAULT '',
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_order_messages_order (order_id, id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='订单留言板';

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES ('order', 'order.confirm_ttl_hours', '12', 'int', 0, 1, 4,
        '待确认自动确认时长（小时）：陪玩提交完成后超过该时长自动确认并结算，0 表示不自动确认'),
       ('order', 'order.start_ttl_minutes', '60', 'int', 0, 1, 5,
        '接单后未开始服务超时（分钟）：超时自动取消并退款，0 表示不自动处理'),
       ('order', 'order.accept_ttl_minutes', '0', 'int', 0, 1, 6,
        '支付后无人接单超时（分钟）：超时自动退款，0 表示不自动处理')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0052_add_order_coop.sql
-- ----------------------------------------------------------------------------
-- 协同订单：主陪（接单人）邀请其他陪玩共同服务，按分成瓜分本单 companion_income。
-- 1) orders 增加协同冗余列，列表页/详情页免 join；
-- 2) 三张表：成员实体、邀请过程、变更快照；
-- 3) 订单设置新增协同相关配置项。
ALTER TABLE orders
    ADD COLUMN co_escort_count INT NOT NULL DEFAULT 0 COMMENT '生效协同陪玩数（冗余）' AFTER designated_at,
    ADD COLUMN co_income_total BIGINT NOT NULL DEFAULT 0 COMMENT '已分配给协同的分成合计（分，冗余）' AFTER co_escort_count;

CREATE TABLE IF NOT EXISTS order_co_escorts (
    id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id          BIGINT UNSIGNED NOT NULL,
    companion_id      BIGINT UNSIGNED NOT NULL COMMENT '协同陪玩 companions.id',
    user_id           BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '冗余用户ID，结算与统计用',
    split_ratio       DECIMAL(5, 2) NOT NULL DEFAULT 0 COMMENT '分成百分比（仅展示）',
    income_amount     BIGINT NOT NULL DEFAULT 0 COMMENT '分成金额（分），结算依据',
    status            TINYINT NOT NULL DEFAULT 1 COMMENT '1在单 3主动退出 4待剔除确认 5协商剔除 7仲裁移除 9订单作废',
    invited_by        BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '邀请人 companions.id（主陪）',
    remove_reason     VARCHAR(255) NOT NULL DEFAULT '' COMMENT '剔除原因',
    remove_request_at DATETIME NULL COMMENT '剔除申请时间',
    remove_expire_at  DATETIME NULL COMMENT '剔除申请超时时间',
    joined_at         DATETIME NULL COMMENT '同意加入时间',
    settled_at        DATETIME NULL COMMENT '结算时间',
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_co_escort (order_id, companion_id),
    KEY idx_co_escort_companion (companion_id, status),
    KEY idx_co_escort_order (order_id, status)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='订单协同陪玩';

CREATE TABLE IF NOT EXISTS order_co_invitations (
    id                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id             BIGINT UNSIGNED NOT NULL,
    inviter_companion_id BIGINT UNSIGNED NOT NULL,
    invitee_companion_id BIGINT UNSIGNED NOT NULL,
    split_ratio          DECIMAL(5, 2) NOT NULL DEFAULT 0,
    income_amount        BIGINT NOT NULL DEFAULT 0,
    status               TINYINT NOT NULL DEFAULT 0 COMMENT '0待确认 1已同意 2已拒绝 3已撤销 6超时拒绝 9订单作废',
    expire_at            DATETIME NULL,
    responded_at         DATETIME NULL,
    reject_reason        VARCHAR(255) NOT NULL DEFAULT '',
    created_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_co_inv_order (order_id, status),
    KEY idx_co_inv_invitee (invitee_companion_id, status),
    KEY idx_co_inv_expire (status, expire_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='协同邀请';

CREATE TABLE IF NOT EXISTS order_co_logs (
    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id      BIGINT UNSIGNED NOT NULL,
    escort_id     BIGINT UNSIGNED NOT NULL DEFAULT 0,
    companion_id  BIGINT UNSIGNED NOT NULL DEFAULT 0,
    action        VARCHAR(32) NOT NULL,
    action_text   VARCHAR(64) NOT NULL DEFAULT '',
    before_amount BIGINT NOT NULL DEFAULT 0,
    after_amount  BIGINT NOT NULL DEFAULT 0,
    before_ratio  DECIMAL(5, 2) NOT NULL DEFAULT 0,
    after_ratio   DECIMAL(5, 2) NOT NULL DEFAULT 0,
    operator_type TINYINT NOT NULL DEFAULT 3 COMMENT '1买家 2管理员 3系统 4陪玩',
    operator_id   BIGINT UNSIGNED NOT NULL DEFAULT 0,
    operator_name VARCHAR(64) NOT NULL DEFAULT '',
    reason        VARCHAR(255) NOT NULL DEFAULT '',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_co_log_order (order_id, id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='协同变更快照';

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES ('order', 'order.coop_enabled', '1', 'bool', 0, 1, 10, '协同订单总开关'),
       ('order', 'order.coop_invite_ttl_minutes', '30', 'int', 0, 1, 11,
        '协同邀请超时（分钟）：建议小于「接单后未开始服务超时」，0 表示不自动过期'),
       ('order', 'order.coop_remove_ttl_minutes', '240', 'int', 0, 1, 12,
        '服务中剔除申请超时（分钟）：超时视为对方拒绝，0 表示不自动处理'),
       ('order', 'order.coop_max_members', '3', 'int', 0, 1, 13, '单笔订单最多协同人数（不含主陪）'),
       ('order', 'order.coop_main_min_ratio', '30', 'int', 0, 1, 14,
        '主陪最低分成比例（%）：所有协同分成之和不得超过本单陪玩收益的剩余部分'),
       ('order', 'order.coop_min_income', '0', 'int', 0, 1, 15, '允许发起协同的陪玩收益门槛（分，0 不限）')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0053_fix_coop_invitation_status.sql
-- ----------------------------------------------------------------------------
-- 协同邀请状态订正：历史数据里邀请表一旦被接受就永远停在 1（已同意），
-- 成员后续被剔除/退出/仲裁移除/订单作废都不会回写，导致后台与陪玩端
-- 「邀请记录」一直显示"协同中"。这里按成员表当前状态做一次性对齐。
UPDATE order_co_invitations AS i
JOIN order_co_escorts AS e
  ON e.order_id = i.order_id AND e.companion_id = i.invitee_companion_id
SET i.status = e.status, i.updated_at = CURRENT_TIMESTAMP
WHERE i.status = 1 AND e.status <> 1;

-- 订单已退款/已取消但邀请仍是"已同意"的，统一置为订单已关闭。
UPDATE order_co_invitations AS i
JOIN orders AS o ON o.id = i.order_id
SET i.status = 9, i.updated_at = CURRENT_TIMESTAMP
WHERE i.status = 1 AND o.status IN (100, 110);


-- ----------------------------------------------------------------------------
-- 0054_add_coop_invitation_closed_status.sql
-- ----------------------------------------------------------------------------
-- 同一陪玩被剔除/退出后重新邀请并复用成员行时，旧的"已同意"邀请无法再从
-- 成员状态推断结果（成员行已回到协同中），会与最新邀请一起显示"协同中"。
-- 这里保留最新一条"已同意"，其余统一标记为 8（历史邀请已失效）。
UPDATE order_co_invitations AS i
LEFT JOIN order_co_invitations AS i2
       ON i2.order_id = i.order_id
      AND i2.invitee_companion_id = i.invitee_companion_id
      AND i2.status = 1
      AND i2.id > i.id
SET i.status = 8, i.updated_at = CURRENT_TIMESTAMP
WHERE i.status = 1 AND i2.id IS NOT NULL;

ALTER TABLE order_co_invitations
    MODIFY COLUMN status TINYINT NOT NULL DEFAULT 0
        COMMENT '0待确认 1已同意 2已拒绝 3已撤销 5已剔除 6超时拒绝 7仲裁移除 8已失效 9订单作废';


-- ----------------------------------------------------------------------------
-- 0055_add_coop_game_limit_and_main_ratio.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 协同订单：按游戏配置协同人数上限 + 主陪可自调自留比例
--
-- 背景：
--   1. 不同游戏一队人数不同（王者 5 排需主陪 + 4 个协同，和平 4 人局只需 +3），
--      统一用全局上限会卡住组队；
--   2. 主陪自留比例固定 30% 在低价多排场景下无法凑齐人数，需要允许主陪
--      在平台硬底之上自行下调（少给自己、多分给协同）。
-- ============================================================================

ALTER TABLE orders
    ADD COLUMN coop_main_ratio TINYINT UNSIGNED NOT NULL DEFAULT 0
        COMMENT '主陪自留比例（%），0 表示使用系统默认值' AFTER co_income_total;

UPDATE system_configs
SET remark = '单笔订单最多协同人数（不含主陪），未在「按游戏协同上限」中单独配置的游戏使用该值'
WHERE config_key = 'order.coop_max_members';

UPDATE system_configs
SET remark = '主陪默认自留比例（%）：未单独设置的订单使用该值，主陪可在平台允许区间内自行调整'
WHERE config_key = 'order.coop_main_min_ratio';

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES ('order', 'order.coop_max_members_by_game', '{"王者荣耀":4,"英雄联盟":4,"无畏契约":4}', 'json', 0, 1, 16,
        '按游戏配置协同人数上限（不含主陪）：JSON 键可为游戏名或游戏 ID，未配置的游戏使用「最多协同人数」'),
       ('order', 'order.coop_main_ratio_floor', '10', 'int', 0, 1, 17,
        '主陪自留比例下限（%）：主陪自调时不得低于该值，0 表示不设下限'),
       ('order', 'order.coop_main_ratio_max', '90', 'int', 0, 1, 18,
        '主陪自留比例上限（%）：留出至少 10% 给协同，避免出现无法分配的订单')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0056_move_coop_limit_to_games.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 协同人数上限由「系统配置 JSON」迁移到游戏表
--
-- 原因：人数上限本质是游戏的属性（这个游戏最多几个人开黑），放在游戏行上可以
-- 在后台游戏编辑里直接设置，避免手写 JSON、键名与游戏名不一致、游戏改名后失效。
-- 兼容：把旧 JSON 配置里的值按游戏名/游戏 ID 回填，随后删除该配置项；
-- 全局配置 order.coop_max_members 保留，作为游戏未设置（0）时的默认值。
-- ============================================================================

ALTER TABLE games
  ADD COLUMN coop_max_members TINYINT NOT NULL DEFAULT 0
  COMMENT '协同人数上限（不含主陪），0 表示跟随系统默认' AFTER status;

-- 按游戏名回填
UPDATE games g
JOIN system_configs c ON c.config_key = 'order.coop_max_members_by_game'
SET g.coop_max_members = CAST(JSON_UNQUOTE(JSON_EXTRACT(c.config_value, CONCAT('$."', g.name, '"'))) AS UNSIGNED)
WHERE JSON_VALID(c.config_value)
  AND JSON_EXTRACT(c.config_value, CONCAT('$."', g.name, '"')) IS NOT NULL
  AND CAST(JSON_UNQUOTE(JSON_EXTRACT(c.config_value, CONCAT('$."', g.name, '"'))) AS UNSIGNED) BETWEEN 1 AND 20;

-- 按游戏 ID 回填（仅补齐上一步没覆盖到的游戏）
UPDATE games g
JOIN system_configs c ON c.config_key = 'order.coop_max_members_by_game'
SET g.coop_max_members = CAST(JSON_UNQUOTE(JSON_EXTRACT(c.config_value, CONCAT('$."', g.id, '"'))) AS UNSIGNED)
WHERE g.coop_max_members = 0
  AND JSON_VALID(c.config_value)
  AND JSON_EXTRACT(c.config_value, CONCAT('$."', g.id, '"')) IS NOT NULL
  AND CAST(JSON_UNQUOTE(JSON_EXTRACT(c.config_value, CONCAT('$."', g.id, '"'))) AS UNSIGNED) BETWEEN 1 AND 20;

DELETE FROM system_configs WHERE config_key = 'order.coop_max_members_by_game';

UPDATE system_configs
SET remark = '默认协同人数上限（不含主陪）：游戏未单独设置时使用该值'
WHERE config_key = 'order.coop_max_members';


-- ----------------------------------------------------------------------------
-- 0057_create_notices.sql
-- ----------------------------------------------------------------------------
-- 公告中心：官方公告与活动公告共用一张表，type 区分。
-- 客户端只读 status=1（已发布）的记录；cover 为空时列表只显示纯标题卡片。
CREATE TABLE IF NOT EXISTS notices (
    id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    type         TINYINT NOT NULL DEFAULT 1 COMMENT '1 官方公告 2 活动公告',
    title        VARCHAR(120) NOT NULL DEFAULT '' COMMENT '标题',
    summary      VARCHAR(255) NOT NULL DEFAULT '' COMMENT '摘要，列表副标题',
    cover        VARCHAR(255) NOT NULL DEFAULT '' COMMENT '封面图地址，为空则列表不显示封面',
    content      MEDIUMTEXT NOT NULL COMMENT '正文（富文本 HTML）',
    status       TINYINT NOT NULL DEFAULT 1 COMMENT '0 草稿 1 已发布',
    is_top       TINYINT NOT NULL DEFAULT 0 COMMENT '1 置顶',
    sort         INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
    published_at DATETIME NULL COMMENT '发布时间',
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_notices_type (type, status, published_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT ='公告（官方 / 活动）';

-- 演示数据：官方公告 3 条、活动公告 3 条，均先不带封面，验证纯标题卡片形态。
INSERT INTO notices (type, title, summary, cover, content, status, is_top, sort, published_at)
VALUES (1, '平台服务规范更新', '接单响应、服务沟通与私自交易的处理规则有调整', '',
        '<p>为了给大家更好的服务体验，平台对服务规范做了以下调整：</p><p>1. 接单后请在 10 分钟内与用户确认服务时间。<br>2. 服务期间请保持沟通顺畅，如需取消请提前说明。<br>3. 严禁私下交易与额外收费。</p><p>以上规则自发布之日起执行。</p>',
        1, 1, 0, DATE_SUB(NOW(), INTERVAL 1 DAY)),
       (1, '陪玩入驻审核流程说明', '提交资料后 1 至 3 个工作日内完成审核', '',
        '<p>入驻审核按以下顺序进行：</p><p>1. 资料完整性与真实性核验。<br>2. 语音介绍内容审核。<br>3. 擅长游戏与区服资质确认。</p><p>审核结果会通过系统通知发出，请留意消息页。</p>',
        1, 0, 0, DATE_SUB(NOW(), INTERVAL 3 DAY)),
       (1, '账号安全提醒', '请勿向任何人透露验证码与登录密码', '',
        '<p>近期出现冒充客服索要验证码的情况，请注意：</p><p>1. 平台客服不会索要密码或短信验证码。<br>2. 请勿在非官方页面输入账号信息。<br>3. 发现异常登录请及时修改密码。</p>',
        1, 0, 0, DATE_SUB(NOW(), INTERVAL 7 DAY)),
       (2, '新人首单立减 10 元', '首次下单自动抵扣，无需领券', '',
        '<p>活动期间新用户完成首单，结算时自动立减 10 元。</p><p>活动规则：<br>1. 仅限账号首笔已完成订单。<br>2. 单笔订单仅可使用一次优惠。<br>3. 与其它优惠不叠加。</p>',
        1, 1, 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
       (2, '周末双倍成长值', '周六周日完成的订单成长值翻倍', '',
        '<p>每周六、周日 00:00 至 23:59 完成的订单，成长值按双倍计算。</p><p>成长值用于提升会员等级，等级越高可解锁的权益越多。</p>',
        1, 0, 0, DATE_SUB(NOW(), INTERVAL 5 DAY)),
       (2, '邀请好友得红包', '好友完成首单后双方各得 5 元', '',
        '<p>把邀请链接发给好友，好友注册并完成首单后：</p><p>1. 你获得 5 元余额红包。<br>2. 好友获得 5 元下单抵扣。</p><p>红包可在钱包余额中查看。</p>',
        1, 0, 0, DATE_SUB(NOW(), INTERVAL 9 DAY));


-- ----------------------------------------------------------------------------
-- 0058_create_notice_permissions.sql
-- ----------------------------------------------------------------------------
-- 公告管理后台权限点：菜单 + 查看 / 新增 / 编辑 / 删除，按 code 幂等插入。
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '公告管理', 'peiwan:notice', 1, '/peiwan/notice', 'ri:megaphone-line', 28, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:notice');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看公告', 'notice:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'peiwan:notice'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'notice:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '发布公告', 'notice:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'peiwan:notice'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'notice:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑公告', 'notice:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'peiwan:notice'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'notice:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除公告', 'notice:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'peiwan:notice'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'notice:delete');

-- 管理员与运营角色授权
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('peiwan:notice', 'notice:list', 'notice:create', 'notice:update', 'notice:delete')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0059_create_user_notices.sql
-- ----------------------------------------------------------------------------
-- 系统通知（站内信）：订单动态 / 钱包收入 / 审核结果 / 账号安全，按用户维度存储。
-- biz_type + biz_no 组成幂等键（配合 user_id 唯一），避免同一事件重复推送。
CREATE TABLE IF NOT EXISTS `user_notices` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '接收人用户 ID',
  `category` TINYINT NOT NULL DEFAULT 1 COMMENT '1 订单动态 2 钱包收入 3 审核结果 4 账号安全',
  `title` VARCHAR(120) NOT NULL DEFAULT '' COMMENT '通知标题',
  `content` VARCHAR(500) NOT NULL DEFAULT '' COMMENT '通知正文（纯文本）',
  `link` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '客户端跳转路径，空表示不跳转',
  `order_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联订单 ID',
  `biz_type` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '业务类型，如 order_accept',
  `biz_no` VARCHAR(64) NOT NULL DEFAULT '' COMMENT '业务单据号，如订单号',
  `is_read` TINYINT NOT NULL DEFAULT 0 COMMENT '0 未读 1 已读',
  `read_at` DATETIME NULL DEFAULT NULL COMMENT '读取时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_notice_biz` (`user_id`, `biz_type`, `biz_no`),
  KEY `idx_user_notice_category` (`user_id`, `category`, `id`),
  KEY `idx_user_notice_read` (`user_id`, `is_read`),
  KEY `idx_user_notice_order` (`order_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '系统通知（站内信）';

-- 后台系统通知管理权限点：菜单 + 查看 / 发送 / 删除，按 code 幂等插入。
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '系统通知', 'peiwan:inbox', 1, '/peiwan/inbox', 'ri:notification-3-line', 29, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:inbox');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看通知', 'inbox:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'peiwan:inbox'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'inbox:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '发送通知', 'inbox:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'peiwan:inbox'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'inbox:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除通知', 'inbox:delete', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'peiwan:inbox'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'inbox:delete');

-- 管理员与运营角色授权
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('peiwan:inbox', 'inbox:list', 'inbox:create', 'inbox:delete')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0060_create_chat.sql
-- ----------------------------------------------------------------------------
-- 聊天底座：会话 / 成员 / 消息 / 用户会话读模型。
-- 结构对齐 im 项目（chat_index + group_members + user_conversations + 消息集合），
-- 存储折算为 MySQL：消息不落 Mongo，用 (session_id, id) 单调递增支撑增量拉取。
--
-- 生命周期：陪玩接单时由订单派生「订单临时群聊」，成员 = 买家 + 主陪（协同成员随后增量加入）；
-- 订单进入终态（完成 / 取消 / 退款）后会话转已归档，成员仍可查看历史，但不能发送新消息。

CREATE TABLE IF NOT EXISTS `chat_sessions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_type` TINYINT NOT NULL DEFAULT 1 COMMENT '1 私聊 2 订单临时群聊 3 群聊',
  `order_id` BIGINT UNSIGNED NULL DEFAULT NULL COMMENT '订单会话关联订单 ID，私聊/群聊为 NULL',
  `title` VARCHAR(64) NOT NULL DEFAULT '' COMMENT '会话标题',
  `avatar` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '会话头像',
  `member_count` INT NOT NULL DEFAULT 0 COMMENT '成员数（冗余计数）',
  `last_msg_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '最后一条消息 ID（冗余，会话列表免回查）',
  `last_msg_at` DATETIME NULL DEFAULT NULL COMMENT '最后一条消息时间',
  `last_msg_preview` VARCHAR(120) NOT NULL DEFAULT '' COMMENT '最后一条消息摘要',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '1 进行中 2 已归档（只读）',
  `archived_at` DATETIME NULL DEFAULT NULL COMMENT '归档时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_chat_session_order` (`session_type`, `order_id`),
  KEY `idx_chat_session_last` (`last_msg_at`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '聊天会话';

CREATE TABLE IF NOT EXISTS `chat_session_members` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '成员用户 ID',
  `role` TINYINT NOT NULL DEFAULT 1 COMMENT '1 买家 2 主陪 3 协同陪玩 4 系统',
  `last_read_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已读游标：该 ID 及之前均已读',
  `muted` TINYINT NOT NULL DEFAULT 0 COMMENT '0 正常 1 免打扰',
  `joined_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `left_at` DATETIME NULL DEFAULT NULL COMMENT '退出时间，NULL 表示在群',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_chat_member` (`session_id`, `user_id`),
  KEY `idx_chat_member_user` (`user_id`, `session_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '聊天会话成员';

CREATE TABLE IF NOT EXISTS `chat_messages` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_id` BIGINT UNSIGNED NOT NULL,
  `sender_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '发送人用户 ID，系统消息为 0',
  `sender_name` VARCHAR(64) NOT NULL DEFAULT '' COMMENT '发送人昵称（冗余，免回查）',
  `sender_role` TINYINT NOT NULL DEFAULT 1 COMMENT '发送人会话角色，同成员 role',
  `msg_type` TINYINT NOT NULL DEFAULT 1 COMMENT '1 文本 2 图片 3 系统',
  `content` VARCHAR(2000) NOT NULL DEFAULT '' COMMENT '文本内容；图片存相对路径',
  `extra` VARCHAR(500) NOT NULL DEFAULT '' COMMENT '扩展 JSON，如图片宽高',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '1 正常 2 已撤回',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_message_session` (`session_id`, `id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '聊天消息';

CREATE TABLE IF NOT EXISTS `chat_user_conversations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `session_id` BIGINT UNSIGNED NOT NULL,
  `session_type` TINYINT NOT NULL DEFAULT 1,
  `unread` INT NOT NULL DEFAULT 0 COMMENT '未读条数（冗余，写消息时累加）',
  `last_read_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '已读游标',
  `last_msg_id` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `last_msg_at` DATETIME NULL DEFAULT NULL,
  `last_msg_preview` VARCHAR(120) NOT NULL DEFAULT '',
  `title` VARCHAR(64) NOT NULL DEFAULT '' COMMENT '会话标题（冗余，避免列表 JOIN 会话表）',
  `avatar` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '对方头像（冗余）',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '会话状态快照，用于列表区分归档',
  `pinned` TINYINT NOT NULL DEFAULT 0,
  `muted` TINYINT NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_chat_conv` (`user_id`, `session_id`),
  KEY `idx_chat_conv_list` (`user_id`, `last_msg_at`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '用户会话读模型（每用户每会话一行，会话列表只查此表）';


-- ----------------------------------------------------------------------------
-- 0061_drop_order_messages.sql
-- ----------------------------------------------------------------------------
-- 订单留言板已由订单临时会话（chat_sessions / chat_messages）替代，移除历史留言表
DROP TABLE IF EXISTS `order_messages`;


-- ----------------------------------------------------------------------------
-- 0062_add_chat_cleanup_and_revoke.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 聊天记录定期清理 + 消息撤回
--
-- 1. 订单临时群聊归档后不再是「永久保留」：归档满 N 天由 ChatCleanupService
--    清空该会话的消息，会话壳保留，列表摘要改为「聊天记录已清理」。
--    purged_at 记录清理时间，同时作为幂等标记（NULL 才参与清理）。
-- 2. 消息撤回：status=2 已有定义但从未使用，这次补 revoked_at 记录撤回时间。
-- 3. uploads.url 加索引：聊天清理/撤回按 URL 定向回收媒体文件时按 url 查记录。
-- 4. 系统配置新增「聊天设置」分组三个键（后台可直接改）：
--      chat.cleanup_enabled        是否开启已结束会话的聊天记录清理，默认 1
--      chat.archive_retain_days    订单会话归档后保留天数，默认 30，0 表示永久
--      chat.revoke_window_minutes  消息可撤回时间窗（分钟），默认 2，0 表示不限制
-- ============================================================================

ALTER TABLE chat_sessions
  ADD COLUMN purged_at DATETIME NULL DEFAULT NULL COMMENT '聊天记录清理时间，NULL 表示未清理' AFTER archived_at,
  ADD KEY idx_chat_session_cleanup (status, archived_at);

ALTER TABLE chat_messages
  ADD COLUMN revoked_at DATETIME NULL DEFAULT NULL COMMENT '撤回时间' AFTER status;

ALTER TABLE uploads
  ADD KEY idx_uploads_url (url);

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('chat', 'chat.cleanup_enabled',        '1',  'bool', 0, 1, 10, '自动清理已结束订单会话的聊天记录'),
  ('chat', 'chat.archive_retain_days',    '30', 'int',  0, 1, 11, '订单会话归档后聊天记录保留天数（0 表示永久保留）'),
  ('chat', 'chat.revoke_window_minutes',  '2',  'int',  0, 1, 12, '消息可撤回时间窗（分钟，0 表示不限制）')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0063_add_chat_message_quote.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 聊天消息引用（回复）
--
-- 设计：引用采用「发送时快照」，不靠运行时 JOIN 原消息：
--   1. 原消息可能被撤回（content 已清空），也可能随归档清理被整会话删除；
--   2. 快照让历史记录的引用块始终可读，列表查询也无需额外回表。
-- 原消息撤回时，把它被引用的快照统一改成「该消息已撤回」，避免撤回后内容
-- 仍通过别人的引用泄漏。
--
-- 字段：
--   quote_id           被引用消息 ID，0 表示普通消息
--   quote_sender_name  被引用消息发送人昵称快照
--   quote_type         被引用消息类型快照（0 表示无引用）
--   quote_text         被引用消息摘要快照（文本截断 60 字，媒体为 [图片] 等）
-- ============================================================================

ALTER TABLE chat_messages
  ADD COLUMN quote_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '被引用消息 ID，0 表示非引用消息' AFTER msg_type,
  ADD COLUMN quote_sender_name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '被引用消息发送人昵称快照' AFTER quote_id,
  ADD COLUMN quote_type TINYINT NOT NULL DEFAULT 0 COMMENT '被引用消息类型快照，0 表示无引用' AFTER quote_sender_name,
  ADD COLUMN quote_text VARCHAR(255) NOT NULL DEFAULT '' COMMENT '被引用消息摘要快照' AFTER quote_type,
  ADD KEY idx_chat_message_quote (quote_id);


-- ----------------------------------------------------------------------------
-- 0064_add_user_follow_and_direct_chat.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 关注关系 + 私聊（陌生人消息限额）
--
-- 1. user_follows：单向关注关系，粉丝/关注数按索引实时统计（不冗余到 users，
--    避免取关/封号等路径漏更新）。互关 = 双向记录都存在。
-- 2. chat_sessions.direct_key：私聊会话唯一键 minUserId:maxUserId（users.id），
--    保证任意两人只有一条私聊会话；订单群聊为 NULL（唯一索引允许多个 NULL）。
-- 3. chat_sessions.stranger_unlocked：陌生人限制是否已解除。互相关注或对方已回复
--    后置 1，之后取关也不回到受限状态，避免历史会话突然不能发。
-- 4. 系统配置新增「聊天设置」键：
--      chat.stranger_msg_limit  未互关时单方向最多可发消息条数，默认 3，0 表示不限制
-- ============================================================================

CREATE TABLE IF NOT EXISTS `user_follows` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `follower_id` BIGINT UNSIGNED NOT NULL COMMENT '关注者 users.id',
  `followee_id` BIGINT UNSIGNED NOT NULL COMMENT '被关注者 users.id',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_follows` (`follower_id`, `followee_id`),
  KEY `idx_user_follows_followee` (`followee_id`, `id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户关注关系（单向）';

ALTER TABLE chat_sessions
  ADD COLUMN direct_key VARCHAR(40) NULL DEFAULT NULL COMMENT '私聊唯一键 minUserId:maxUserId，订单会话为 NULL' AFTER order_id,
  ADD COLUMN stranger_unlocked TINYINT NOT NULL DEFAULT 0 COMMENT '0 未互关受限 1 已解除（互关或对方已回复）' AFTER status,
  ADD UNIQUE KEY uk_chat_session_direct (direct_key);

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('chat', 'chat.stranger_msg_limit', '3', 'int', 0, 1, 13, '未互相关注时单方向最多可发送的消息条数（0 表示不限制）')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0065_add_nickname_config.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 昵称自动生成配置
--
-- 后台「系统配置 - 昵称设置」维护词库与规则：创建账号（后台建号 / 首次登录补名）
-- 时自动生成一个昵称，避免新用户一直显示脱敏手机号或「用户UID」。
--
--   nickname.style     生成规则：random 前缀+后缀（默认），uid 前缀+用户UID
--   nickname.prefixes  前缀词，一行一个
--   nickname.suffixes  后缀词，一行一个
--
-- 词库清空时后端回退到代码内置的默认词库。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('nickname', 'nickname.style', 'random', 'string', 0, 1, 1, '生成规则：random 前缀+后缀，uid 前缀+用户UID'),
  ('nickname', 'nickname.prefixes',
   '温柔的\n爱笑的\n安静的\n闪闪的\n凌晨的\n夏天的\n月下的\n银河里的\n会飞的\n打盹的\n发呆的\n慢半拍的\n橘色的\n薄荷味的\n柠檬味的\n星尘做的\n云朵做的\n会发光的\n偷偷的\n甜甜的\n酷酷的\n暖暖的\n清风的\n夜航的\n梦里的\n迷路的\n认真的\n赖床的\n追光的\n听海的\n拾光的\n不困的\n有猫的\n爱吃糖的\n披着月光的\n揣着星星的\n会撒娇的\n社恐的\n笑点低的\n手感好的\n开局就冲的\n不投降的\n爱喝奶茶的\n会讲冷笑话的\n刚睡醒的\n有点困的\n超能打的\n运气爆棚的',
   'text', 0, 1, 2, '昵称前缀词，一行一个，可自行增删'),
  ('nickname', 'nickname.suffixes',
   '橘猫\n鲸鱼\n小鹿\n萤火虫\n月亮\n星星\n海豚\n企鹅\n柴犬\n柚子\n布丁\n奶糖\n云朵\n小行星\n晚风\n潮汐\n雪糕\n棉花糖\n小饼干\n山茶花\n蓝莓\n柠檬\n樱桃\n北极熊\n柯基\n水母\n考拉\n小柿子\n橘子汽水\n小台灯\n旧唱片\n纸飞机\n风筝\n小宇宙\n小火车\n猫薄荷\n小夜灯\n海盐\n芝士\n热可可\n麦芽糖\n风铃\n蒲公英\n小星球\n银河\n糖果罐\n小旅人\n宇航员',
   'text', 0, 1, 3, '昵称后缀词，一行一个，可自行增删')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0066_add_nickname_uid_prefix.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 昵称「前缀+UID」规则的独立前缀
--
-- 之前 uid 规则复用随机词库的前缀，语义不对。现在拆开：
--   nickname.prefixes    随机模式（random）用，前缀 + 后缀
--   nickname.uid_prefix  UID 模式（uid）用，前缀 + 用户UID，如「软风100001」
--
-- 留空时后端回退品牌名「软风」。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('nickname', 'nickname.uid_prefix', '软风', 'string', 0, 1, 4, 'UID 规则专用前缀，生成「前缀+用户UID」，如：软风100001')
ON DUPLICATE KEY UPDATE config_key = config_key;

-- 规则说明同步：uid 模式不再复用随机词库前缀
UPDATE system_configs
SET remark = '生成规则：random 随机前缀+后缀，uid 品牌前缀+用户UID'
WHERE config_key = 'nickname.style';


-- ----------------------------------------------------------------------------
-- 0067_create_official_groups.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 官方群聊
--
-- 1. official_groups：只有后台能建群，面向全部用户引流，不做私人建群。
--    join_mode 控制谁能进群：1 所有用户、2 仅普通用户、3 仅陪玩。
--    session_id 指向对应的 chat_sessions（session_type=3 官方群），
--    群消息、未读、撤回等全部复用现有聊天链路。
-- 2. official_group_members：群成员，与 chat_session_members 双写，
--    这样会话列表、消息可见范围不需要额外判断。
-- 3. 后台权限点：菜单 + 查看/新增/编辑/删除/成员管理。
-- ============================================================================

CREATE TABLE IF NOT EXISTS `official_groups` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(60) NOT NULL COMMENT '群名称',
  `avatar` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '群头像',
  `announcement` TEXT NULL COMMENT '群公告',
  `join_mode` TINYINT NOT NULL DEFAULT 1 COMMENT '1 所有用户可进 2 仅普通用户 3 仅陪玩',
  `session_id` BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '对应 chat_sessions.id',
  `member_count` INT NOT NULL DEFAULT 0 COMMENT '成员数（含后台拉入，不含管理员）',
  `sort` INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '1 正常 0 停用（停用后不在前台展示）',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_official_groups_session` (`session_id`),
  KEY `idx_official_groups_status` (`status`, `sort`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '官方群聊';

CREATE TABLE IF NOT EXISTS `official_group_members` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'users.id',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_official_group_member` (`group_id`, `user_id`),
  KEY `idx_official_group_member_user` (`user_id`, `id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '官方群聊成员';

-- 后台菜单 + 权限点
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '群聊管理', 'peiwan:group', 1, '/peiwan/group', 'ri:group-line', 29, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:group');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看群聊', 'group:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'peiwan:group'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'group:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '新建群聊', 'group:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'peiwan:group'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'group:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑群聊', 'group:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'peiwan:group'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'group:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '解散群聊', 'group:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'peiwan:group'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'group:delete');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '群成员管理', 'group:member', 2, '', '', 5, 1 FROM permissions p
WHERE p.code = 'peiwan:group'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'group:member');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('peiwan:group', 'group:list', 'group:create', 'group:update', 'group:delete', 'group:member')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0068_add_order_confirm_remind.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 待确认订单的系统提醒
--
-- 背景：陪玩提交完成后要等用户点「确认完成」才结算（默认超时自动确认）。
-- 用户可能压根没注意到，所以提交完成一段时间后由系统代发一条提醒，
-- 每单只提醒一次（confirm_remind_at 记录提醒时间，避免重复打扰）。
--
-- 同时把自动确认时长的默认值从 12 小时调成 8 小时（仅当仍是默认 12 时才改，
-- 不影响运营已经手工调整过的值）。
-- ============================================================================

ALTER TABLE orders
  ADD COLUMN confirm_remind_at DATETIME NULL COMMENT '系统提醒用户确认的时间（每单只提醒一次）';

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('order', 'order.confirm_remind_minutes', '60', 'int', 0, 1, 19,
   '待确认提醒时机（分钟）：陪玩提交完成后超过该时长由系统提醒用户确认，每单只提醒一次，0 表示不提醒')
ON DUPLICATE KEY UPDATE config_key = config_key;

UPDATE system_configs
SET config_value = '8'
WHERE config_key = 'order.confirm_ttl_hours' AND config_value = '12';

UPDATE system_configs
SET remark = '待确认自动确认时长（小时）：陪玩提交完成后超过该时长自动确认并结算，0 表示不自动确认'
WHERE config_key = 'order.confirm_ttl_hours';


-- ----------------------------------------------------------------------------
-- 0069_create_circle.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 圈子（帖子）
--
-- 定位：单条信息流 + 标签，不做板块。帖子可选关联一个游戏（game_id），
--       列表既能按标签筛，也能按游戏筛。
--
-- 媒体：一条帖子只能是「图文」或「视频」二选一
--   图文 —— images 存 JSON 数组，最多 9 张
--   视频 —— video_url 单条（复用 /user/uploads/video），images 必须为空
--
-- 审核：audit_status 与 status 分开
--   audit_status 0 待审核 / 1 通过 / 2 未通过（机审或人工）
--   status       1 正常   / 2 已下架 / 3 作者删除
--   前台只展示 audit_status = 1 且 status = 1 的帖子；
--   作者本人能在自己的资料卡里看到待审与被拒的帖子（含原因）。
-- ============================================================================

CREATE TABLE IF NOT EXISTS posts (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id        BIGINT UNSIGNED NOT NULL DEFAULT 0  COMMENT '作者 users.id',
  content        VARCHAR(1000)   NOT NULL DEFAULT '' COMMENT '正文，最多 500 字',
  images         VARCHAR(1000)   NOT NULL DEFAULT '' COMMENT '图片 JSON 数组，最多 9 张',
  video_url      VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '视频地址，与 images 互斥',
  video_cover    VARCHAR(255)    NOT NULL DEFAULT '' COMMENT '视频封面地址',
  video_duration INT             NOT NULL DEFAULT 0  COMMENT '视频时长（秒）',
  game_id        BIGINT UNSIGNED NOT NULL DEFAULT 0  COMMENT '归属游戏，0 表示未指定',
  tag            VARCHAR(20)     NOT NULL DEFAULT '' COMMENT '标签：找搭子/攻略/晒单/闲聊',
  is_top         TINYINT         NOT NULL DEFAULT 0  COMMENT '1 置顶',
  top_at         DATETIME        NULL                COMMENT '置顶时间，置顶帖按此倒序',
  audit_status   TINYINT         NOT NULL DEFAULT 1  COMMENT '0 待审核 1 通过 2 未通过',
  audit_remark   VARCHAR(200)    NOT NULL DEFAULT '' COMMENT '审核备注 / 拒绝原因',
  audit_source   TINYINT         NOT NULL DEFAULT 1  COMMENT '1 机审 2 人工',
  audit_at       DATETIME        NULL                COMMENT '审核时间',
  status         TINYINT         NOT NULL DEFAULT 1  COMMENT '1 正常 2 已下架 3 作者删除',
  like_count     INT             NOT NULL DEFAULT 0  COMMENT '点赞数（冗余）',
  comment_count  INT             NOT NULL DEFAULT 0  COMMENT '评论数（冗余）',
  view_count     INT             NOT NULL DEFAULT 0  COMMENT '浏览数（冗余）',
  report_count   INT             NOT NULL DEFAULT 0  COMMENT '被举报次数（冗余）',
  created_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_posts_stream (status, audit_status, is_top, created_at),
  KEY idx_posts_user (user_id, status, created_at),
  KEY idx_posts_tag (tag, status, created_at),
  KEY idx_posts_game (game_id, status, created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '圈子帖子';

-- 点赞：uk 保证同一用户对同一帖子只能赞一次（先删后插实现取消/再赞）
CREATE TABLE IF NOT EXISTS post_likes (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  post_id    BIGINT UNSIGNED NOT NULL,
  user_id    BIGINT UNSIGNED NOT NULL,
  created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_post_like (post_id, user_id),
  KEY idx_post_likes_user (user_id, created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子点赞';

-- 评论：只支持纯文本，status 2 表示已删除（保留行，评论数已单独扣减）
CREATE TABLE IF NOT EXISTS post_comments (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  post_id    BIGINT UNSIGNED NOT NULL,
  user_id    BIGINT UNSIGNED NOT NULL,
  content    VARCHAR(500)    NOT NULL DEFAULT '',
  status     TINYINT         NOT NULL DEFAULT 1 COMMENT '1 正常 2 已删除',
  created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_post_comments_post (post_id, status, created_at),
  KEY idx_post_comments_user (user_id, created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子评论';

-- 举报：同一用户对同一帖子只记一次，重复举报忽略
CREATE TABLE IF NOT EXISTS post_reports (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  post_id       BIGINT UNSIGNED NOT NULL,
  user_id       BIGINT UNSIGNED NOT NULL,
  reason        VARCHAR(20)     NOT NULL DEFAULT '' COMMENT '举报理由：广告/色情/辱骂/诈骗/其他',
  detail        VARCHAR(200)    NOT NULL DEFAULT '',
  status        TINYINT         NOT NULL DEFAULT 0 COMMENT '0 待处理 1 已处理',
  handle_action TINYINT         NOT NULL DEFAULT 0 COMMENT '1 已下架 2 已忽略',
  handle_remark VARCHAR(200)    NOT NULL DEFAULT '',
  handled_at    DATETIME        NULL,
  created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_post_report (post_id, user_id),
  KEY idx_post_reports_status (status, created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子举报';


-- ----------------------------------------------------------------------------
-- 0070_seed_circle_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 圈子：后台菜单权限点 + 审核相关系统配置
-- ============================================================================

-- 一级菜单：圈子管理
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '圈子管理', 'peiwan:circle', 1, '/peiwan/circle', 'ri:chat-smile-2-line', 29, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:circle');

-- 帖子查看
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看帖子', 'post:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'peiwan:circle'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'post:list');

-- 帖子审核
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '审核帖子', 'post:audit', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'peiwan:circle'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'post:audit');

-- 帖子运营（置顶 / 下架 / 恢复）
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '帖子运营', 'post:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'peiwan:circle'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'post:update');

-- 帖子删除
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除帖子', 'post:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'peiwan:circle'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'post:delete');

-- 举报处理复用 post:audit
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('peiwan:circle', 'post:list', 'post:audit', 'post:update', 'post:delete')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);

-- ============================================================================
-- 审核相关配置（后台「系统配置 - 圈子设置」可改，改完立即生效）
--   audit_mode        1 机审即发（默认，机审通过直接展示） 2 先审后发
--   video_review      1 视频帖一律人工审核（默认，视频无法文本机审） 0 否
--   block_contact     1 拦截联系方式（微信/QQ/手机号） 0 只记录不拦截
--   sensitive_words   敏感词库，英文逗号分隔，命中即拒绝
--   daily_limit       单用户每日发帖上限，0 不限
--   report_hide       被举报达到该次数自动下架，0 关闭
-- ============================================================================

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.audit_mode', '1', 'int', 0, 1, 1, '审核模式：1 机审即发 2 先审后发'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.audit_mode');

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.video_review', '1', 'bool', 0, 1, 2, '视频帖是否先审后发'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.video_review');

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.block_contact', '1', 'bool', 0, 1, 3, '是否拦截帖子里的联系方式'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.block_contact');

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.sensitive_words',
       '加微信,加vx,加v信,代练接单,私聊下单,刷单,返利,博彩,赌博,色情,约炮,裸聊,传销,洗钱,枪支,毒品',
       'text', 0, 1, 4, '敏感词库，英文逗号分隔'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.sensitive_words');

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.daily_limit', '20', 'int', 0, 1, 5, '单用户每日发帖上限，0 表示不限'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.daily_limit');

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.report_hide', '5', 'int', 0, 1, 6, '被举报多少次自动下架，0 表示关闭'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.report_hide');

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.video_max_duration', '60', 'int', 0, 1, 7, '发布视频的最长时长（秒）'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.video_max_duration');

-- 前台发帖页需要知道标签白名单与内容上限，随 /configs/public 下发
INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.tags', '["找搭子","攻略","晒单","闲聊"]', 'json', 1, 1, 8, '可选标签（前台公开）'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.tags');


-- ----------------------------------------------------------------------------
-- 0071_add_post_title.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 圈子帖子补充标题
--
-- 发帖页改为「标题 + 正文」的笔记式布局（参考小红书），标题独立成字段，
-- 便于列表里用粗体标题做阅读锚点。正文仍放在 content，标题可为空，
-- 老数据 title = '' 时前端回退为纯正文展示。
-- ============================================================================

ALTER TABLE posts
  ADD COLUMN title VARCHAR(60) NOT NULL DEFAULT '' COMMENT '标题，最多 30 字' AFTER user_id;


-- ----------------------------------------------------------------------------
-- 0072_create_post_favorites.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 帖子收藏：与点赞（post_likes）对称
--   post_favorites 记录「谁收藏了哪条帖子」，uk 保证同一用户对同一帖子只收藏一次；
--   posts.favorite_count 为冗余计数，收藏 / 取消收藏时在同一事务里增减。
--   前台只展示「我的收藏」，不做管理端统计，因此不需要额外权限点。
-- ============================================================================

ALTER TABLE posts
  ADD COLUMN favorite_count INT NOT NULL DEFAULT 0 COMMENT '收藏数（冗余）' AFTER comment_count;

CREATE TABLE IF NOT EXISTS post_favorites (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  post_id    BIGINT UNSIGNED NOT NULL,
  user_id    BIGINT UNSIGNED NOT NULL,
  created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_post_favorite (post_id, user_id),
  KEY idx_post_favorites_user (user_id, created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子收藏';


-- ----------------------------------------------------------------------------
-- 0073_create_post_views.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 帖子浏览记录：资料卡/详情页查看别人帖子时留下记录，供「我的浏览记录」使用
--   uk(post_id, user_id) 保证同一用户同一帖子只留一行，重复浏览只更新 last_view_at，
--   列表按 last_view_at 倒序，天然就是「最近看过」的顺序。
--   只记录登录用户浏览别人的帖子（作者看自己的不记），不参与任何计数统计。
-- ============================================================================

CREATE TABLE IF NOT EXISTS post_views (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  post_id      BIGINT UNSIGNED NOT NULL,
  user_id      BIGINT UNSIGNED NOT NULL,
  last_view_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最近一次浏览时间',
  created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次浏览时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_post_view (post_id, user_id),
  KEY idx_post_views_user (user_id, last_view_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '帖子浏览记录';


-- ----------------------------------------------------------------------------
-- 0074_add_comment_reply_and_like.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 圈子评论升级：评论回复 + 评论点赞
--   root_id       顶层评论 id（0 表示本身是顶层评论）。所有回复都挂到顶层评论下，只做两级，
--                 避免无限层级导致前端渲染和分页复杂化；
--   parent_id     直接回复的那条评论 id（0 表示直接评论帖子），用于「回复 @某人」定位；
--   reply_user_id 被回复用户 users.id，列表直接 JOIN 出来展示昵称，不必递归查父评论；
--   like_count    评论点赞数（冗余计数，与 post_comment_likes 在同一事务里增减）；
--   删除顶层评论时连同它下面的回复一起软删，posts.comment_count 按实际删除条数扣减。
-- ============================================================================

ALTER TABLE post_comments
  ADD COLUMN root_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '顶层评论 id，0 表示本身是顶层' AFTER post_id,
  ADD COLUMN parent_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '直接回复的评论 id，0 表示直接评论帖子' AFTER root_id,
  ADD COLUMN reply_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '被回复用户 users.id' AFTER user_id,
  ADD COLUMN like_count INT NOT NULL DEFAULT 0 COMMENT '点赞数（冗余）' AFTER content,
  ADD KEY idx_post_comments_root (post_id, root_id, status, id);

CREATE TABLE IF NOT EXISTS post_comment_likes (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  comment_id BIGINT UNSIGNED NOT NULL,
  user_id    BIGINT UNSIGNED NOT NULL,
  created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_post_comment_like (comment_id, user_id),
  KEY idx_post_comment_likes_user (user_id, created_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '评论点赞';


-- ----------------------------------------------------------------------------
-- 0075_add_post_comment_moderation.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 评论人工治理：后台可在帖子抽屉里查看全部评论并手动屏蔽（防广告刷评）
--   status=3 表示后台屏蔽：前台所有评论查询只看 status=1，因此立即不可见；
--   与作者删除（status=2）区分开，屏蔽可在后台恢复，删除不可恢复；
--   hide_reason / hidden_by / hidden_at 只服务于后台审计，前台永远不下发。
--   屏蔽顶层评论时连同其下回复一起屏蔽，posts.comment_count 按实际条数增减。
-- ============================================================================

ALTER TABLE post_comments
  MODIFY COLUMN status TINYINT NOT NULL DEFAULT 1 COMMENT '1 正常 2 已删除 3 已屏蔽',
  ADD COLUMN hide_reason VARCHAR(200) NOT NULL DEFAULT '' COMMENT '屏蔽原因（仅后台可见）' AFTER status,
  ADD COLUMN hidden_by BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '执行屏蔽的管理员 admins.id' AFTER hide_reason,
  ADD COLUMN hidden_at DATETIME NULL COMMENT '屏蔽时间' AFTER hidden_by,
  ADD KEY idx_post_comments_post_status (post_id, status, id);


-- ----------------------------------------------------------------------------
-- 0076_add_circle_comment_notice_config.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 圈子：新增「新评论提醒」开关
--   comment_notice 1 开启（评论 / 回复时给作者发站内通知） 0 关闭（默认）
-- 默认关闭：热门帖一条评论一条通知会刷屏，需要时在「系统配置 - 圈子设置」里打开。
-- ============================================================================

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'circle', 'circle.comment_notice', '0', 'bool', 0, 1, 9, '新评论 / 新回复是否给作者发站内通知'
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'circle.comment_notice');


-- ----------------------------------------------------------------------------
-- 0077_add_rank_indexes.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 排行榜：聚合查询索引
--   消费榜按支付时间、接单榜按完成时间、好评榜按评价时间、活跃榜按行为时间
--   做区间扫描，再按人分组。数据量小的时候也能避免全表扫描。
-- ============================================================================

ALTER TABLE orders ADD INDEX idx_orders_rank_pay (pay_time, status, user_id);
ALTER TABLE orders ADD INDEX idx_orders_rank_complete (completed_at, status, companion_id);
ALTER TABLE reviews ADD INDEX idx_reviews_rank_time (created_at, status, companion_id);
ALTER TABLE posts ADD INDEX idx_posts_rank_time (created_at, status, user_id);
ALTER TABLE post_comments ADD INDEX idx_post_comments_rank_time (created_at, status, user_id);
ALTER TABLE post_likes ADD INDEX idx_post_likes_rank_time (created_at, post_id);


-- ----------------------------------------------------------------------------
-- 0078_create_withdrawals.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 提现功能
--
-- 收款账户（陪玩自行维护，可保存多个）+ 提现申请（提交后扣余额，审核拒绝退回）。
-- 提现方式：1 微信 2 支付宝；金额以分存储。
-- ============================================================================

CREATE TABLE IF NOT EXISTS withdraw_accounts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '用户 ID',
  type TINYINT NOT NULL DEFAULT 1 COMMENT '1 微信 2 支付宝',
  account_name VARCHAR(50) NOT NULL DEFAULT '' COMMENT '收款人姓名',
  account_no VARCHAR(64) NOT NULL DEFAULT '' COMMENT '收款账号 / 手机号',
  qrcode VARCHAR(255) NOT NULL DEFAULT '' COMMENT '收款码图片',
  is_default TINYINT NOT NULL DEFAULT 0 COMMENT '1 默认 0 非默认',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_withdraw_accounts_user (user_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='提现收款账户';

CREATE TABLE IF NOT EXISTS withdrawals (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  withdraw_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '提现单号',
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '申请用户 ID',
  account_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '收款账户 ID',
  type TINYINT NOT NULL DEFAULT 1 COMMENT '1 微信 2 支付宝',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '提现金额（分）',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '0 待审核 1 已打款 2 已拒绝',
  account_snapshot VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '收款信息快照 JSON',
  reject_reason VARCHAR(255) NOT NULL DEFAULT '' COMMENT '拒绝原因',
  audited_by BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '审核管理员 ID',
  audited_at DATETIME NULL COMMENT '审核时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_withdrawals_no (withdraw_no),
  KEY idx_withdrawals_user (user_id, id),
  KEY idx_withdrawals_status (status, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='提现申请';

-- 权限点：菜单 + 查看 + 审核
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '提现管理', 'peiwan:withdraw', 1, '/peiwan/withdraw', 'ri:bank-card-line', 25, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'peiwan:withdraw');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看提现', 'withdraw:list', 2, '', '', 1, 1
FROM permissions p
WHERE p.code = 'peiwan:withdraw'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'withdraw:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '审核提现', 'withdraw:audit', 2, '', '', 2, 1
FROM permissions p
WHERE p.code = 'peiwan:withdraw'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'withdraw:audit');

-- 超级管理员 / 管理员：全部
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
WHERE code IN ('peiwan:withdraw', 'withdraw:list', 'withdraw:audit');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions
WHERE code IN ('peiwan:withdraw', 'withdraw:list', 'withdraw:audit');

-- 运营专员：只读
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions
WHERE code IN ('peiwan:withdraw', 'withdraw:list');


-- ----------------------------------------------------------------------------
-- 0079_seed_online_chat_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 在线状态与聊天记录权限点
--
-- 补齐此前「只有 AdminAuth、无 AdminPerm」的管理端只读接口权限：
--   online 在线状态 → 挂靠用户管理（system:user）
--   chat   聊天记录 → 挂靠订单管理（peiwan:order）
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看在线状态', 'online:list', 2, '', '', 5, 1
FROM permissions p
WHERE p.code = 'system:user'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'online:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看聊天记录', 'chat:view', 2, '', '', 5, 1
FROM permissions p
WHERE p.code = 'peiwan:order'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'chat:view');

-- 管理员：全部（超级管理员 is_super 直接放行，无需 role_permissions）
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions
WHERE code IN ('online:list', 'chat:view');

-- 运营专员：仅在线状态（聊天记录属隐私敏感，不下发）
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions
WHERE code IN ('online:list');


-- ----------------------------------------------------------------------------
-- 0080_seed_fine_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 细粒度权限点拆分
--
-- 5.1 权限粒度问题：notice 的上下架/置顶复用 notice:update、
-- companion 的启停/能力管理复用 companion:audit、circle 的下架/置顶复用
-- post:update、评论屏蔽复用 post:audit。拆成独立权限点后，各动作可单独授权，
-- 不必把「编辑内容」与「运营动作」绑在一起。
--
-- 授权策略：新权限点继承「原粗粒度权限点」的授权对象（INSERT ... SELECT），
-- 保证本次拆分对现有管理员/运营的可见能力零影响，之后可再逐角色收紧。
-- ============================================================================

INSERT IGNORE INTO permissions (id, parent_id, name, code, type, path, icon, sort, status) VALUES
  (135, 110, '上下架公告', 'notice:status',     2, '', '', 5, 1),
  (136, 110, '置顶公告',   'notice:top',        2, '', '', 6, 1),
  (137, 81,  '启停陪玩',   'companion:status',   2, '', '', 7, 1),
  (138, 81,  '能力管理',   'companion:capability', 2, '', '', 8, 1),
  (139, 125, '置顶帖子',   'post:top',          2, '', '', 5, 1),
  (140, 125, '下架帖子',   'post:status',       2, '', '', 6, 1),
  (141, 125, '评论屏蔽',   'post:comment-audit', 2, '', '', 7, 1);

-- notice:status / notice:top 继承 notice:update 的授权对象
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT rp.role_id, p.id
FROM role_permissions rp
JOIN permissions old ON old.id = rp.permission_id AND old.code = 'notice:update'
JOIN permissions p ON p.code IN ('notice:status', 'notice:top');

-- companion:status / companion:capability 继承 companion:audit 的授权对象
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT rp.role_id, p.id
FROM role_permissions rp
JOIN permissions old ON old.id = rp.permission_id AND old.code = 'companion:audit'
JOIN permissions p ON p.code IN ('companion:status', 'companion:capability');

-- post:top / post:status 继承 post:update 的授权对象
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT rp.role_id, p.id
FROM role_permissions rp
JOIN permissions old ON old.id = rp.permission_id AND old.code = 'post:update'
JOIN permissions p ON p.code IN ('post:top', 'post:status');

-- post:comment-audit 继承 post:audit 的授权对象
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT rp.role_id, p.id
FROM role_permissions rp
JOIN permissions old ON old.id = rp.permission_id AND old.code = 'post:audit'
JOIN permissions p ON p.code = 'post:comment-audit';


-- ----------------------------------------------------------------------------
-- 0081_add_level_snapshot_columns.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 等级固化字段
--
-- 5.2.1 等级固化：会员/陪玩等级此前完全实时计算（按累计消费/收入匹配门槛），
-- 没有落到 users / companions 行上，无法按等级做筛选、榜单与列表展示。
-- 增加快照列后，在「订单支付」刷新会员等级、「订单结算」刷新陪玩等级。
-- 快照可能因后台改门槛而短暂滞后，属可接受的读模型，下次相关事件会校正。
-- ============================================================================

ALTER TABLE users
  ADD COLUMN member_level_id BIGINT UNSIGNED NULL DEFAULT NULL COMMENT '会员等级快照 ID（随消费累计刷新）' AFTER status;

ALTER TABLE companions
  ADD COLUMN companion_level_id BIGINT UNSIGNED NULL DEFAULT NULL COMMENT '陪玩等级快照 ID（随收入结算刷新）' AFTER deposit_amount;


-- ----------------------------------------------------------------------------
-- 0082_add_review_reply.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 评价回复
--
-- 5.2.2 评价无回复：陪玩无法回复评价，售后 / 口碑运营闭环缺失。
-- 增加回复字段后，被评价陪玩可对自己的评价回复一次（可覆盖），公开列表展示。
-- ============================================================================

ALTER TABLE reviews
  ADD COLUMN reply VARCHAR(500) NOT NULL DEFAULT '' COMMENT '陪玩回复' AFTER content,
  ADD COLUMN reply_at DATETIME NULL DEFAULT NULL COMMENT '回复时间' AFTER reply;


-- ----------------------------------------------------------------------------
-- 0083_add_user_last_active.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 用户活跃字段
--
-- 5.2.5 在线状态：用户侧只有 last_login_at，活跃口径与陪玩侧
-- （companions.last_active_at）不一致，活跃榜 / 后台列表无法按用户活跃排序。
-- 增加 last_active_at 后，登录与 WebSocket 上线时回写，口径与陪玩统一。
-- ============================================================================

ALTER TABLE users
  ADD COLUMN last_active_at DATETIME NULL DEFAULT NULL COMMENT '最近活跃时间（登录/上线时刷新）' AFTER last_login_at;


-- ----------------------------------------------------------------------------
-- 0084_reviews_order_unique.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 评价「一单一条」唯一约束
--
-- D8：reviews 对带 order_id 的评价防重目前只靠应用层（CreateGuarded 锁用户行 +
-- order_id 计数），后台补录（CreateByAdmin）已补同样校验，但 DB 层仍无兜底。
-- order_id = 0 表示后台补录或未关联订单，允许多条。
--
-- 方案：用 STORED 生成列把 order_id=0 归一为 NULL（NULL 不参与唯一约束），
-- 从而做到「带单号的评价全局唯一、不带单号的可多条」。
-- ============================================================================

-- 兜底去重：保留同一订单最早一条评价，清理历史重复（正常情况应为 0 行）。
DELETE r1
FROM reviews r1
JOIN reviews r2
  ON r1.order_id = r2.order_id
 AND r1.id > r2.id
WHERE r1.order_id > 0;

ALTER TABLE reviews
  ADD COLUMN order_uniq BIGINT UNSIGNED
    GENERATED ALWAYS AS (IF(order_id = 0, NULL, order_id)) STORED,
  ADD UNIQUE KEY uk_reviews_order (order_uniq);


-- ----------------------------------------------------------------------------
-- 0085_create_recharge_orders.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 充值功能
--
-- A2：此前用户加钱只能靠后台 admin_adjust 调账，无客户端自助充值入口。
-- 新增充值申请单：用户在线提交充值申请（金额 + 备注），管理端确认到账后
-- 余额入账（写 recharge 流水，幂等）。充值方式 provider 预留 balance/wechat/alipay，
-- 首期走「线下代充 + 后台确认」闭环，第三方支付渠道后续接入时复用该表。
-- ============================================================================

CREATE TABLE IF NOT EXISTS recharge_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  recharge_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '充值单号',
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '充值用户 ID',
  provider VARCHAR(20) NOT NULL DEFAULT 'balance' COMMENT '充值方式 balance/wechat/alipay',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '充值金额（分）',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '0 待确认 1 已到账 2 已拒绝',
  remark VARCHAR(200) NOT NULL DEFAULT '' COMMENT '用户备注 / 打款渠道说明',
  reject_reason VARCHAR(255) NOT NULL DEFAULT '' COMMENT '拒绝原因',
  audited_by BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '审核管理员 ID',
  audited_at DATETIME NULL COMMENT '审核时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_recharge_no (recharge_no),
  KEY idx_recharge_user (user_id, id),
  KEY idx_recharge_status (status, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值申请单';

-- 权限点：挂在钱包管理菜单下
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看充值', 'recharge:list', 2, '', '', 4, 1
FROM permissions p
WHERE p.code = 'peiwan:wallet'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'recharge:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '确认充值', 'recharge:audit', 2, '', '', 5, 1
FROM permissions p
WHERE p.code = 'peiwan:wallet'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'recharge:audit');

-- 超级管理员 / 管理员：全部
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE code IN ('recharge:list', 'recharge:audit');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE code IN ('recharge:list', 'recharge:audit');

-- 运营专员：只读
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE code IN ('recharge:list');

-- 完成后退款权限点（高风险资金操作：冲正陪玩/协同收入、可能负余额），挂在订单管理菜单下。
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '完成后退款', 'order:refund-completed', 2, '', '', 5, 1
FROM permissions p
WHERE p.code = 'peiwan:order'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'order:refund-completed');

-- 仅超级管理员 / 管理员授予，运营专员不授予。
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE code = 'order:refund-completed';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE code = 'order:refund-completed';


-- ----------------------------------------------------------------------------
-- 0086_add_uniqueness_guards.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 并发唯一性兜底
--
-- D1：升级申请「一用户一个待审」此前靠事务外 HasPendingApply 先查后插，
--     并发下可穿透产生多个待审申请。
-- D2：收款账户「一用户一个默认」与「上限」此前靠事务外 CountAccounts 先查后插。
-- D9：协同邀请「同一订单同一被邀请人一个待确认」此前靠 lockOrder 串行化，无 DB 兜底。
-- 统一用 STORED 生成列把「仅特定状态才唯一」归一为 NULL（NULL 不参与唯一约束）。
-- ============================================================================

-- 兜底去重（正常情况应为 0 行）：保留最早一条。
DELETE a1
FROM companion_applies a1
JOIN companion_applies a2
  ON a1.user_id = a2.user_id
 AND a1.status = a2.status
 AND a1.status = 1
 AND a1.id > a2.id;

ALTER TABLE companion_applies
  ADD COLUMN pending_user BIGINT UNSIGNED
    GENERATED ALWAYS AS (IF(status = 1, user_id, NULL)) STORED,
  ADD UNIQUE KEY uk_applies_pending (pending_user);

-- D2：默认账户唯一
DELETE d1
FROM withdraw_accounts d1
JOIN withdraw_accounts d2
  ON d1.user_id = d2.user_id
 AND d1.is_default = d2.is_default
 AND d1.is_default = 1
 AND d1.id > d2.id;

ALTER TABLE withdraw_accounts
  ADD COLUMN default_user BIGINT UNSIGNED
    GENERATED ALWAYS AS (IF(is_default = 1, user_id, NULL)) STORED,
  ADD UNIQUE KEY uk_accounts_default (default_user);

-- D9：待确认邀请唯一
DELETE i1
FROM order_co_invitations i1
JOIN order_co_invitations i2
  ON i1.order_id = i2.order_id
 AND i1.invitee_companion_id = i2.invitee_companion_id
 AND i1.status = i2.status
 AND i1.status = 0
 AND i1.id > i2.id;

ALTER TABLE order_co_invitations
  ADD COLUMN pending_invitee BIGINT UNSIGNED
    GENERATED ALWAYS AS (IF(status = 0, invitee_companion_id, NULL)) STORED,
  ADD UNIQUE KEY uk_co_inv_pending (order_id, pending_invitee);


-- ----------------------------------------------------------------------------
-- 0087_add_pay_sms_configs.sql
-- ----------------------------------------------------------------------------
-- 支付配置（group=pay）与短信配置（group=sms）
-- 后台「系统设置 → 支付配置 / 短信配置」两个菜单读取的分组数据。
-- 当前业务仍为线下代充 + 人工打款，这些配置项先落库占位，接入渠道后即可生效。
-- 密钥类字段统一 is_public=0，前台不可读。

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  -- ===== 支付配置 =====
  ('pay', 'pay.enabled', '0', 'bool', 0, 1, 1,
   '启用在线支付：关闭时仅支持后台代充，用户端不显示在线支付入口'),
  ('pay', 'pay.channel', 'manual', 'string', 0, 1, 2,
   '默认支付渠道：manual 线下代充 / alipay 支付宝 / wechat 微信支付'),
  ('pay', 'pay.notify_url', '', 'string', 0, 1, 3,
   '支付回调地址：留空则使用系统默认回调，需公网可访问'),
  ('pay', 'pay.order_timeout_minutes', '15', 'int', 0, 1, 4,
   '支付超时（分钟）：下单后超过该时长未支付自动关闭订单'),
  ('pay', 'pay.alipay_app_id', '', 'string', 0, 1, 5,
   '支付宝 AppID：开放平台应用的唯一标识'),
  ('pay', 'pay.alipay_private_key', '', 'text', 0, 1, 6,
   '支付宝应用私钥：用于请求签名，请勿泄露'),
  ('pay', 'pay.alipay_public_key', '', 'text', 0, 1, 7,
   '支付宝公钥：用于验证异步通知签名'),
  ('pay', 'pay.wechat_app_id', '', 'string', 0, 1, 8,
   '微信 AppID：公众号或开放平台应用 ID'),
  ('pay', 'pay.wechat_mch_id', '', 'string', 0, 1, 9,
   '微信商户号：微信支付分配的 mchid'),
  ('pay', 'pay.wechat_api_v3_key', '', 'text', 0, 1, 10,
   '微信 APIv3 密钥：用于回调报文解密，请勿泄露'),

  -- ===== 短信配置 =====
  ('sms', 'sms.enabled', '0', 'bool', 0, 1, 1,
   '启用短信：关闭时不发送任何短信，验证码能力不可用'),
  ('sms', 'sms.provider', 'none', 'select', 0, 1, 2,
   '短信服务商：验证码短信通过哪家服务商下发，可选值随已接入的厂商自动增加'),
  ('sms', 'sms.access_key_id', '', 'string', 0, 1, 3,
   'AccessKeyId：服务商控制台获取'),
  ('sms', 'sms.access_key_secret', '', 'text', 0, 1, 4,
   'AccessKeySecret：服务商控制台获取的密钥，严禁泄露或提交到代码仓库'),
  ('sms', 'sms.sign_name', '', 'string', 0, 1, 5,
   '短信签名：已审核通过的签名内容'),
  ('sms', 'sms.template_code', '', 'string', 0, 1, 6,
   '模板 Code：已审核通过的验证码模板标识'),
  ('sms', 'sms.code_ttl_seconds', '300', 'int', 0, 1, 7,
   '验证码有效期（秒）：超时后需重新获取'),
  ('sms', 'sms.daily_limit', '1000', 'int', 0, 1, 8,
   '单日发送上限（条）：超过后当日不再发送，防止刷量')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0088_create_banners.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 首页轮播图
--
-- A3：首页轮播此前是前端写死的随机图片 API（api.elaina.cat），既不能换图也不能
-- 做投放。改为后台可配置：
--   link_type 决定点击行为：0 纯展示 / 1 外链 / 2 商品详情 / 3 帖子详情 / 4 站内页面
--   link_value 存对应目标：URL、商品 ID、帖子 ID、页面路径（如 /pages/member/index）
--   position 预留多位置，首期只有 home（首页顶部）
--   start_at / end_at 做投放时间窗，留空表示立即生效 / 长期有效
--   click_count 记录点击量，后台可看效果
-- ============================================================================

CREATE TABLE IF NOT EXISTS banners (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  position VARCHAR(20) NOT NULL DEFAULT 'home' COMMENT '展示位置 home=首页顶部',
  title VARCHAR(80) NOT NULL DEFAULT '' COMMENT '标题，后台备注兼客户端无障碍描述',
  image VARCHAR(255) NOT NULL DEFAULT '' COMMENT '图片地址（/uploads/... 或完整 URL）',
  link_type TINYINT NOT NULL DEFAULT 0 COMMENT '0 不跳转 1 外链 2 商品 3 帖子 4 站内页面',
  link_value VARCHAR(255) NOT NULL DEFAULT '' COMMENT '跳转目标：URL / 商品ID / 帖子ID / 页面路径',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，越小越靠前',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '0 停用 1 启用',
  start_at DATETIME NULL COMMENT '生效开始时间，空表示立即生效',
  end_at DATETIME NULL COMMENT '生效结束时间，空表示长期有效',
  click_count BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '点击次数',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_banners_position (position, status, sort)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='轮播图';


-- ----------------------------------------------------------------------------
-- 0089_seed_banner_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 轮播图管理后台权限点：菜单 + 查看 / 新增 / 编辑 / 删除，按 code 幂等插入。
-- 菜单挂在「内容管理」下，与公告、群聊同级。
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '轮播图管理', 'banner', 1, '/content/banner', 'ri:image-line', 29, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'banner');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看轮播图', 'banner:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'banner'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'banner:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '新增轮播图', 'banner:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'banner'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'banner:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑轮播图', 'banner:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'banner'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'banner:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除轮播图', 'banner:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'banner'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'banner:delete');

-- 管理员与运营角色授权
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('banner', 'banner:list', 'banner:create', 'banner:update', 'banner:delete')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0090_add_register_switch_configs.sql
-- ----------------------------------------------------------------------------
-- 注册设置（group=register）补充两个开关
-- 1) 一键登录：开启后客户端可用「手机号 + 短信验证码」直接登录，手机号未注册时自动创建账号
-- 2) 强制验证码：开启后注册（含验证码登录自动建号）必须校验短信验证码，此时密码为选填；
--    关闭后注册只需手机号和密码，不校验验证码
-- 两项均为 is_public=1，随 GET /api/v1/configs/public 下发给客户端控制表单展示。

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('register', 'system.one_click_login', '0', 'bool', 1, 1, 5,
   '一键登录：手机号 + 短信验证码登录，未注册的手机号自动创建账号'),
  ('register', 'system.force_captcha', '1', 'bool', 1, 1, 6,
   '强制验证码：注册必须填写短信验证码，密码选填，关闭后仅需手机号与密码')
ON DUPLICATE KEY UPDATE remark = VALUES(remark), sort = VALUES(sort);


-- ----------------------------------------------------------------------------
-- 0091_create_sms_logs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 短信发送记录：每次下发验证码留痕，便于排查「收不到验证码」、核对短信费用。
-- 不存储验证码明文，只记录号码、场景、服务商、结果与耗时。
-- ============================================================================

CREATE TABLE IF NOT EXISTS sms_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  phone VARCHAR(20) NOT NULL DEFAULT '' COMMENT '接收手机号',
  scene VARCHAR(16) NOT NULL DEFAULT '' COMMENT '场景：register 注册 / login 登录',
  provider VARCHAR(16) NOT NULL DEFAULT '' COMMENT '服务商：aliyun / debug',
  sign_name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '短信签名',
  template_code VARCHAR(64) NOT NULL DEFAULT '' COMMENT '模板 Code',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '1 成功 0 失败',
  biz_code VARCHAR(64) NOT NULL DEFAULT '' COMMENT '服务商返回码，OK 表示成功',
  error_msg VARCHAR(500) NOT NULL DEFAULT '' COMMENT '失败原因',
  client_ip VARCHAR(64) NOT NULL DEFAULT '' COMMENT '请求 IP',
  cost_ms INT NOT NULL DEFAULT 0 COMMENT '调用耗时（毫秒）',
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联用户 ID，未注册为 0',
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_sms_logs_phone (phone),
  KEY idx_sms_logs_created (created_at),
  KEY idx_sms_logs_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='短信发送记录';

-- 权限点：系统设置 → 短信记录
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '短信记录', 'sms:log', 1, '/settings/sms-log', 'ri:message-2-line', 30, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'sms:log');

-- 三个内置角色均授予（超管同样入库，便于权限页统一展示）
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code = 'sms:log'
WHERE r.code IN ('R_SUPER', 'R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0092_sms_provider_select.sql
-- ----------------------------------------------------------------------------
-- 「短信服务商」改为下拉选择，避免手填 aliyun / tencent 拼错。
-- 可选值由后端 internal/sms 注册表下发：目前为「不启用 / 阿里云」，
-- 后续接入腾讯云等厂商后会自动出现在下拉里，无需再改这里。

UPDATE system_configs
SET value_type = 'select',
    remark = '短信服务商：验证码短信通过哪家服务商下发，可选值随已接入的厂商自动增加'
WHERE config_key = 'sms.provider';


-- ----------------------------------------------------------------------------
-- 0093_harden_auth_security.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 账号安全加固：
--   1. users.token_version：改密 / 重置密码 / 后台封禁时 +1，让旧令牌立即失效
--      （存量用户为 0，存量令牌不带版本号也按 0 处理，升级后不会掉登录态）
--   2. 短信 IP 维度日配额：防止单 IP 轮询大量号码刷验证码
--   3. 单号码日上限从 1000 收紧到 10（1000 等同未限制）
-- ============================================================================

ALTER TABLE users
  ADD COLUMN token_version INT UNSIGNED NOT NULL DEFAULT 0
  COMMENT '令牌版本号：改密/重置密码/封禁时 +1，旧令牌随之失效'
  AFTER password_hash;

-- 单 IP 单日短信上限（group=sms，后台「系统设置 → 短信配置」可直接修改）
INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'sms', 'sms.ip_daily_limit', '50', 'int', 0, 1, 9,
       '单 IP 单日发送上限（条）：防止同一网络批量刷验证码'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'sms.ip_daily_limit');

-- 仅当仍是初始值时才收紧，避免覆盖运维已手工调整的配置
UPDATE system_configs
SET config_value = '10'
WHERE config_key = 'sms.daily_limit' AND config_value = '1000';


-- ----------------------------------------------------------------------------
-- 0094_add_platform_mode.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 平台运行模式开关
--
-- 一套系统同时支持「H5」与「微信小程序」两个端，交付给不同客户时由客户自行选择：
--   h5   仅开放 H5（浏览器 / 微信内网页）
--   mp   仅开放微信小程序
--   both 双端同时开放（默认）
--
-- 这是运行期开关，不改变构建产物：H5 与小程序包都照常发布，
-- 由该配置决定入口是否开放，以及未开放端展示「请使用另一端访问」的引导页。
-- 切换只影响新入口与登录准入，已登录用户不会被踢下线。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('platform', 'platform.mode', 'both', 'select', 1, 1, 1,
   '平台运行模式：h5=仅 H5；mp=仅微信小程序；both=双端同时开放。切换后各端入口按此展示，已登录用户不受影响')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0095_add_platform_login_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- H5 登录配置 / 小程序登录配置
--
-- 分组 h5：platform.mode = h5 或 both 时在后台显示
-- 分组 mp：platform.mode = mp 或 both 时在后台显示
--
-- 只存放「各端自己的登录方式与凭据」，平台开放哪些端仍由 platform.mode 决定。
-- 密钥类配置 is_public=0，不随 /configs/public 下发到前端；
-- 登录方式开关 is_public=1，前端据此决定登录页展示哪些入口。
--
-- 注意：mp.app_id 必须与小程序 manifest.json 的 mp-weixin.appid 完全一致，
--       否则 wx.login 拿到的 code 换不了 openid。默认值与当前 manifest 保持一致（开发测试号）。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  -- ===== H5 登录配置 =====
  ('h5', 'h5.login_password', '1', 'bool', 1, 1, 1,
   'H5 登录方式：手机号 + 密码登录。关闭后登录页不展示密码入口'),
  ('h5', 'h5.login_sms', '1', 'bool', 1, 1, 2,
   'H5 登录方式：手机号 + 短信验证码登录。需先在「短信配置」中启用短信通道'),
  ('h5', 'h5.login_wechat', '0', 'bool', 1, 1, 3,
   'H5 登录方式：微信公众号网页授权一键登录。仅微信内浏览器可用，需先填写公众号 AppID 与 AppSecret'),
  ('h5', 'h5.wechat_app_id', '', 'string', 0, 1, 4,
   '公众号 AppID：网页授权登录使用，需已认证服务号，并在公众号后台配置网页授权域名'),
  ('h5', 'h5.wechat_app_secret', '', 'text', 0, 1, 5,
   '公众号 AppSecret：用于换取网页授权 access_token，严禁泄露'),
  ('h5', 'h5.wechat_scope', 'snsapi_base', 'select', 0, 1, 6,
   '公众号授权方式：snsapi_base 静默授权（只取 openid，无弹窗）；snsapi_userinfo 弹窗授权（可同时取昵称头像）'),

  -- ===== 小程序登录配置 =====
  ('mp', 'mp.login_wechat', '1', 'bool', 1, 1, 1,
   '小程序登录方式：wx.login 静默登录，无需用户操作。关闭后只能走手机号或密码登录'),
  ('mp', 'mp.login_phone', '1', 'bool', 1, 1, 2,
   '小程序登录方式：手机号快速验证组件，可直接获取用户手机号。需企业主体并在微信后台开通该能力'),
  ('mp', 'mp.login_password', '1', 'bool', 1, 1, 3,
   '小程序登录方式：手机号 + 密码兜底。用于用户拒绝手机号授权时仍能登录'),
  ('mp', 'mp.require_phone', '0', 'bool', 1, 1, 4,
   '是否强制绑定手机号：开启后未绑定手机号的用户不能下单、申请陪玩等核心操作'),
  ('mp', 'mp.app_id', 'wx4fea40caf7e4cc60', 'string', 0, 1, 5,
   '小程序 AppID：必须与 manifest.json 的 mp-weixin.appid 完全一致，否则 code2session 会失败。正式运营请替换为你自己的小程序'),
  ('mp', 'mp.app_secret', '', 'text', 0, 1, 6,
   '小程序 AppSecret：用于 code2session 换取 openid，严禁泄露。正式运营请替换为你自己的小程序密钥')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0096_add_h5_wechat_require_phone.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- H5 微信网页授权：是否强制绑定手机号
--
-- 小程序有 getPhoneNumber，能直接拿到手机号；公众号网页授权没有这个能力，
-- 所以 H5 端需要一个独立策略：
--   1（默认，强制）：网页授权后必须用短信验证码补充手机号；手机号已有账号时
--                   合并到原账号（与小程序、密码登录共用同一个账号体系）。
--   0（不强制）：直接创建无手机号账号，流程最短，但账号只能靠该微信号登录，
--              换微信号即无法找回，仅在接受该风险时关闭。
--
-- is_public=1：前端登录页据此决定「首次登录需绑定手机号」的提示文案。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('h5', 'h5.wechat_require_phone', '1', 'bool', 1, 1, 7,
   'H5 微信网页授权登录是否强制绑定手机号：开启时新用户必须用短信验证码补手机号，可合并已有账号；关闭时直接创建无手机号账号');


-- ----------------------------------------------------------------------------
-- 0096_add_wechat_notify_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 微信提醒（小程序订阅消息 / 公众号提醒）配置
--
-- 分组 notify：与 h5 / mp 登录配置分开，因为提醒属于「消息触达」而不是登录方式。
-- 小程序两项 is_public=1：前端需要模板 ID 才能调 wx.requestSubscribeMessage
-- 拉起授权，模板 ID 不属于敏感信息。公众号两项不公开，前端用不到。
--
-- 事件配置是一段 JSON（value_type=json，后台保存时会校验格式），
-- key 为站内通知的 biz_type，这样换模板只改后台配置，不用改代码。示例：
--
--   {
--     "order_accept": {
--       "template_id": "小程序后台选用的模板ID",
--       "page": "{link}",
--       "data": {
--         "character_string1": "{bizNo}",
--         "thing2": "{title}",
--         "amount3": "{amount}",
--         "time4": "{time}"
--       }
--     }
--   }
--
-- 公众号侧结构相同，额外支持：
--   "mode": "template"  模板消息（用户关注公众号即可发，默认）
--   "mode": "subscribe" 订阅通知（用户需先在公众号订阅该模板）
--   "url":  "https://你的域名/#{link}"
--
-- 可用占位符：{title} {content} {link} {orderId} {bizNo} {bizType}
--            {time} {userId}，以及业务侧传入的自定义变量（如 {amount}）。
--
-- 已接入通知的事件（biz_type）：
--   order_accept      陪玩已接单
--   order_finish      服务完成待确认
--   order_complete    订单已完成
--   withdraw_approved 提现审核通过（手动打款）
--   withdraw_paid     提现到账（商家转账回调确认）
--   withdraw_reject   提现被驳回
--   withdraw_fail     提现打款失败
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('notify', 'notify.mp_enabled', '0', 'bool', 1, 1, 1,
   '小程序订阅消息：开启后按事件配置向用户推送微信「服务通知」。需先在微信后台选用模板并填写模板 ID'),
  ('notify', 'notify.h5_enabled', '0', 'bool', 0, 1, 2,
   '公众号提醒：开启后按事件配置给已关注公众号的用户发送提醒。需已认证服务号并配置公众号 AppID/AppSecret'),
  ('notify', 'notify.mp_events', '{}', 'json', 1, 1, 3,
   '小程序事件配置（JSON）：key 为通知 biz_type，value 含 template_id / page / data 字段映射'),
  ('notify', 'notify.h5_events', '{}', 'json', 0, 1, 4,
   '公众号事件配置（JSON）：结构同小程序，额外支持 mode（template/subscribe）与 url')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0097_update_h5_wechat_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- H5 微信网页授权配置：关闭开关 + 文案优化
--
-- 当前账号是订阅号（后台账号类型显示为「公众号」，即原订阅号）：
--   订阅号无论是否认证都没有网页授权权限，后台不会出现「网页授权域名」入口，
--   调用 open.weixin.qq.com/connect/oauth2/authorize 会被微信拒绝。
--   为避免用户在微信里点到一个必然失败的按钮，默认关闭该登录方式。
--   换成已认证服务号后，在后台重新打开并填 AppID/AppSecret 即可。
--
-- remark 文案按「标题：说明」书写：管理端会把冒号左侧（<=14 字）渲染成标题，
-- 右侧作为灰色说明，避免整段文字挤在标题里。
-- ============================================================================

UPDATE system_configs
SET config_value = '0',
    remark = '微信网页授权登录：仅「已认证服务号」支持，订阅号与未认证账号后台没有「网页授权域名」入口'
WHERE config_key = 'h5.login_wechat';

UPDATE system_configs
SET remark = '公众号 AppID：网页授权专用，必须是已认证服务号；与小程序 AppID 是两个不同的号，不能混用'
WHERE config_key = 'h5.wechat_app_id';

UPDATE system_configs
SET remark = '公众号 AppSecret：用于换取网页授权 openid，与小程序 AppSecret 不通用，严禁泄露'
WHERE config_key = 'h5.wechat_app_secret';

UPDATE system_configs
SET remark = '公众号授权方式：snsapi_base 静默只取 openid；snsapi_userinfo 会弹窗，可同时取昵称头像'
WHERE config_key = 'h5.wechat_scope';

UPDATE system_configs
SET remark = '强制绑定手机号：网页授权拿不到手机号，开启时新用户必须用短信验证码补齐（可合并已有账号）'
WHERE config_key = 'h5.wechat_require_phone';


-- ----------------------------------------------------------------------------
-- 0098_add_h5_subscribe_templates.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 公众号订阅通知：前端订阅按钮用的模板 ID 清单
--
-- 与 notify.h5_events（服务端发送配置）分开的原因：
--   h5_events 含字段映射，且 is_public=0 不下发前端；
--   前端渲染 wx-open-subscribe 只需要模板 ID，单独开一个公开键更安全也更轻。
-- 结构：{ "withdraw_paid": "模板ID", "order_accept": "模板ID" }
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('notify', 'notify.h5_subscribe_templates', '{}', 'json', 1, 1, 5,
   '订阅通知模板：key 为通知 biz_type，value 为模板 ID。前端订阅按钮用，不含字段映射')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0098_create_payment_channels.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 支付渠道列表化
--
-- 背景：此前支付方式只有 system_configs 里一个标量 pay.channel（manual/alipay/wechat），
-- 既不能同时存在多个渠道，也没有任何运行时代码读取它。
-- 本次改为独立实体表 payment_channels：一个渠道一行，各自带通道类型、配置 JSON、
-- 适用场景（充值 / 订单）、排序与启用状态，为后续接入真实支付留出结构。
--
-- 说明：本轮只做配置层，支付执行仍走「余额支付 + 线下代充人工审核」。
-- ============================================================================

CREATE TABLE IF NOT EXISTS payment_channels (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(32) NOT NULL DEFAULT '' COMMENT '渠道标识（唯一），如 manual / wechat_native',
  name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '展示名称',
  provider VARCHAR(16) NOT NULL DEFAULT 'manual' COMMENT '通道类型 manual/wechat/alipay',
  icon VARCHAR(255) NOT NULL DEFAULT '' COMMENT '图标地址，客户端展示用',
  description VARCHAR(255) NOT NULL DEFAULT '' COMMENT '客户端提示文案',
  config TEXT NULL COMMENT '通道配置 JSON（appId/商户号/密钥/收款信息），按 provider 不同',
  recharge_enabled TINYINT NOT NULL DEFAULT 0 COMMENT '是否用于充值场景',
  order_enabled TINYINT NOT NULL DEFAULT 0 COMMENT '是否用于订单支付场景',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，小的在前',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '0 停用 1 启用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_payment_channel_code (code),
  KEY idx_payment_channel_status (status, sort)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付渠道';

-- 充值单的 provider 由固定枚举改为渠道 code，放开长度
ALTER TABLE recharge_orders
  MODIFY COLUMN provider VARCHAR(32) NOT NULL DEFAULT 'manual'
  COMMENT '充值渠道 code，对应 payment_channels.code；历史数据 balance 表示线下代充';

-- 默认渠道：线下代充保持可用；微信 / 支付宝先以停用状态建好，后台填完密钥再启用
INSERT INTO payment_channels (code, name, provider, icon, description, config, recharge_enabled, order_enabled, sort, status)
SELECT 'manual', '线下代充', 'manual', '',
       '联系客服完成转账，后台核对到账后入账', '{}', 1, 0, 10, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM payment_channels WHERE code = 'manual');

INSERT INTO payment_channels (code, name, provider, icon, description, config, recharge_enabled, order_enabled, sort, status)
SELECT 'wechat', '微信支付', 'wechat', '',
       '微信扫码 / 公众号支付', '{}', 1, 1, 20, 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM payment_channels WHERE code = 'wechat');

INSERT INTO payment_channels (code, name, provider, icon, description, config, recharge_enabled, order_enabled, sort, status)
SELECT 'alipay', '支付宝', 'alipay', '',
       '支付宝扫码 / 手机网站支付', '{}', 1, 1, 30, 0
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM payment_channels WHERE code = 'alipay');

-- 权限点：支付渠道维护
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '支付配置', 'payment', 1, '/system/pay', 'ri:bank-card-line', 30, 1
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'payment');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看支付渠道', 'payment:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'payment'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'payment:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '新增支付渠道', 'payment:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'payment'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'payment:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑支付渠道', 'payment:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'payment'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'payment:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除支付渠道', 'payment:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'payment'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'payment:delete');

-- 管理员与运营角色授权（支付配置属于系统设置，运营也需要查看与维护）
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('payment', 'payment:list', 'payment:create', 'payment:update', 'payment:delete')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0099_drop_legacy_pay_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 清理旧的单值支付配置
--
-- 0098 已把支付方式改为 payment_channels 渠道列表（一渠道一行，各自配置与启停）。
-- system_configs 里 group_name='pay' 的 10 个键从未被 Go 代码读取，留在后台只会
-- 让管理员误以为改了会生效，这里统一删除；「系统设置 → 支付配置」改为维护渠道列表。
-- ============================================================================

DELETE FROM system_configs WHERE group_name = 'pay';


-- ----------------------------------------------------------------------------
-- 0100_add_payment_channel_plugin.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 支付渠道增加「支付插件」维度
--
-- 通道类型（provider）只描述品牌：微信 / 支付宝 / 线下。
-- 同为微信，实际网关可能是官方 APIv3、易支付、或其它第三方，配置字段与下单
-- 实现都不同，因此新增 plugin 列绑定插件编码（见 internal/payment/plugin.go）。
--
-- 回填规则：微信 → 官方直连，支付宝 → 官方直连，其余 → 线下代充。
-- ============================================================================

ALTER TABLE payment_channels
  ADD COLUMN plugin VARCHAR(32) NOT NULL DEFAULT '' COMMENT '支付插件编码，对应 internal/payment 插件注册表' AFTER provider;

UPDATE payment_channels
SET plugin = CASE provider
    WHEN 'wechat' THEN 'wechat_official'
    WHEN 'alipay' THEN 'alipay_official'
    ELSE 'manual'
  END
WHERE plugin = '';

ALTER TABLE payment_channels ADD KEY idx_payment_channel_plugin (plugin);


-- ----------------------------------------------------------------------------
-- 0101_create_decorations.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 个性装扮：定义 / 规格 / 用户拥有与穿戴
--
-- 售卖形态：
--   1) 余额购买：规格 price > 0，走钱包事务扣款
--   2) 免费领取：规格 price = 0，直接发放，不写钱包流水
--   3) 限时 / 永久：sku.duration_days = 0 表示永久（user_decorations.expire_at 为 NULL）
--   4) 默认装扮：is_default = 1，用户首次进商城时懒发放（幂等）
--
-- 一个用户对同一装扮只保留一条 user_decorations 记录：
--   限时到期后可再次购买续期（更新 expire_at），永久则拒绝重复购买。
-- ============================================================================

CREATE TABLE IF NOT EXISTS decorations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '装扮名称',
  type TINYINT NOT NULL DEFAULT 1 COMMENT '1 头像框 2 聊天气泡 3 进场特效 4 铭牌 5 主页皮肤',
  icon VARCHAR(255) NOT NULL DEFAULT '' COMMENT '列表小图',
  preview_url VARCHAR(255) NOT NULL DEFAULT '' COMMENT '预览图',
  resource_url VARCHAR(255) NOT NULL DEFAULT '' COMMENT '生效资源地址（图片/CSS 类名等）',
  description VARCHAR(255) NOT NULL DEFAULT '' COMMENT '说明文案',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，小的在前',
  is_default TINYINT NOT NULL DEFAULT 0 COMMENT '是否默认装扮，自动发放',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '0 下架 1 上架',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_decorations_type (type, status, sort)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='装扮定义';

CREATE TABLE IF NOT EXISTS decoration_skus (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  decoration_id BIGINT UNSIGNED NOT NULL COMMENT '所属装扮',
  name VARCHAR(32) NOT NULL DEFAULT '' COMMENT '规格名，如 7 天 / 30 天 / 永久',
  duration_days INT NOT NULL DEFAULT 0 COMMENT '有效天数，0 表示永久',
  price BIGINT NOT NULL DEFAULT 0 COMMENT '价格（分），0 表示免费领取',
  sort INT NOT NULL DEFAULT 0,
  status TINYINT NOT NULL DEFAULT 1 COMMENT '0 停用 1 启用',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_decoration_skus_decoration (decoration_id, sort, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='装扮时长规格';

CREATE TABLE IF NOT EXISTS user_decorations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  decoration_id BIGINT UNSIGNED NOT NULL,
  sku_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '最近一次购买/领取的规格',
  is_equipped TINYINT NOT NULL DEFAULT 0 COMMENT '是否穿戴中',
  purchase_type TINYINT NOT NULL DEFAULT 1 COMMENT '1 购买 2 领取 3 赠送 4 默认',
  purchased_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次获得时间',
  expire_at DATETIME NULL DEFAULT NULL COMMENT '到期时间，NULL 表示永久',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_decoration (user_id, decoration_id),
  KEY idx_user_decorations_user (user_id, is_equipped),
  KEY idx_user_decorations_decoration (decoration_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户装扮拥有与穿戴';

-- ---------------------------------------------------------------------------
-- 默认装扮：免费、永久、自动发放。资源为空表示走客户端内置样式。
-- ---------------------------------------------------------------------------
INSERT INTO decorations (name, type, icon, preview_url, resource_url, description, sort, is_default, status)
SELECT '默认头像框', 1, '', '', '', '系统默认头像框', 100, 1, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM decorations WHERE name = '默认头像框' AND is_default = 1);

INSERT INTO decorations (name, type, icon, preview_url, resource_url, description, sort, is_default, status)
SELECT '默认气泡', 2, '', '', '', '系统默认聊天气泡', 100, 1, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM decorations WHERE name = '默认气泡' AND is_default = 1);

INSERT INTO decorations (name, type, icon, preview_url, resource_url, description, sort, is_default, status)
SELECT '新人铭牌', 4, '', '', '', '默认称号', 100, 1, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM decorations WHERE name = '新人铭牌' AND is_default = 1);

INSERT INTO decorations (name, type, icon, preview_url, resource_url, description, sort, is_default, status)
SELECT '默认主页皮肤', 5, '', '', '', '系统默认主页背景', 100, 1, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM decorations WHERE name = '默认主页皮肤' AND is_default = 1);

-- 每个默认装扮补一条 0 元永久规格（重复执行安全）
INSERT INTO decoration_skus (decoration_id, name, duration_days, price, sort, status)
SELECT d.id, '永久', 0, 0, 100, 1 FROM decorations d
WHERE d.is_default = 1
  AND NOT EXISTS (SELECT 1 FROM decoration_skus s WHERE s.decoration_id = d.id);


-- ----------------------------------------------------------------------------
-- 0102_seed_decoration_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 个性装扮后台权限点
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '个性装扮', 'decoration', 1, '/content/decoration', 'ri:palette-line', 31, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'decoration');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看装扮', 'decoration:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'decoration'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'decoration:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '新增装扮', 'decoration:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'decoration'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'decoration:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑装扮', 'decoration:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'decoration'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'decoration:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除装扮', 'decoration:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'decoration'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'decoration:delete');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '赠送装扮', 'decoration:grant', 2, '', '', 5, 1 FROM permissions p
WHERE p.code = 'decoration'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'decoration:grant');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN (
  'decoration', 'decoration:list', 'decoration:create', 'decoration:update', 'decoration:delete', 'decoration:grant'
)
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0103_add_decoration_companion_flag.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 陪玩专享装扮
--
-- require_companion = 1 表示「陪玩专享」：
--   1) 不可购买、不可领取，用户点按钮时客户端提示「入住陪玩后自动获得」
--   2) 陪玩入驻审核通过时自动发放永久拥有（purchase_type = 5 入住陪玩）
--   3) 老陪玩在进商城 / 我的装扮时懒补发放，保证存量陪玩也能拿到
--
-- 规格仍然要用：自动发放取每个装扮排序第一的启用规格，时长按该规格计算。
-- ============================================================================

ALTER TABLE decorations
  ADD COLUMN require_companion TINYINT NOT NULL DEFAULT 0 COMMENT '1=陪玩专享，入住陪玩后自动发放' AFTER is_default;

ALTER TABLE decorations
  ADD KEY idx_decorations_companion (require_companion, status, sort);


-- ----------------------------------------------------------------------------
-- 0104_add_user_decorations_expire_index.sql
-- ----------------------------------------------------------------------------
-- 装扮到期提醒扫描：按 expire_at 范围捞即将到期 / 刚过期的记录
ALTER TABLE user_decorations ADD KEY idx_user_decorations_expire (expire_at);

-- 通知分类新增 5 = 装扮提醒（category 为 TINYINT，无需改表结构，仅更新注释）
ALTER TABLE user_notices MODIFY COLUMN category TINYINT NOT NULL DEFAULT 1
  COMMENT '分类：1订单动态 2钱包与收入 3审核结果 4账号与安全 5装扮提醒';


-- ----------------------------------------------------------------------------
-- 0105_add_decoration_unlock_rules.sql
-- ----------------------------------------------------------------------------
-- 装扮获得条件：把「只能花钱买」扩展为消费赠送 / 接单赠送 / 限时活动赠送。
-- unlock_type: 0 不限（正常售卖、默认、陪玩专享）1 累计消费 2 累计接单 3 限时活动
-- unlock_value: 累计消费门槛（单位：分）/ 累计接单门槛（单数）
ALTER TABLE decorations
  ADD COLUMN unlock_type TINYINT NOT NULL DEFAULT 0
    COMMENT '获得条件：0不限 1累计消费 2累计接单 3限时活动' AFTER is_default,
  ADD COLUMN unlock_value BIGINT NOT NULL DEFAULT 0
    COMMENT '门槛：累计消费（分）或累计接单（单数）' AFTER unlock_type,
  ADD COLUMN unlock_start_at DATETIME NULL
    COMMENT '活动开始时间（unlock_type=3 有效）' AFTER unlock_value,
  ADD COLUMN unlock_end_at DATETIME NULL
    COMMENT '活动结束时间（unlock_type=3 有效）' AFTER unlock_start_at,
  ADD KEY idx_decorations_unlock (unlock_type, status);

-- 获得方式补充 6 消费赠送 / 7 接单赠送 / 8 活动领取
ALTER TABLE user_decorations MODIFY COLUMN purchase_type TINYINT NOT NULL DEFAULT 1
  COMMENT '1购买 2领取 3赠送 4默认 5陪玩专享 6消费赠送 7接单赠送 8活动领取';


-- ----------------------------------------------------------------------------
-- 0106_add_notice_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 通知设置：把装扮相关的站内信（到期提醒 / 解锁提醒）接入系统配置开关
--
-- 背景：
--   装扮到期提醒此前把「提前 3 天」「过期补 1 天」「每 6 小时扫一次」写死在代码里，
--   运营无法关闭或调整；装扮解锁提醒同样是硬发。上线后如果出现误配（例如把活动装扮
--   配成消费门槛）或用户投诉打扰，只能改代码发版。
--
-- 本次改动：
--   1. 新增「通知设置」配置分组 notice，后台「系统配置 → 通知设置」可直接开关。
--   2. 关闭装扮到期提醒后，后台扫描与后台「立即扫描」都不再推送，已推送记录保留；
--      用户已收到的站内信不会消失，重新打开开关后按原有幂等键继续提醒未提醒过的记录。
--   3. 提前 / 过期天数可调，0 表示该类型不提醒（两个都为 0 等于只保留开关）。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('notice', 'notice.decoration_expiry_enabled',    '1', 'bool', 0, 1, 10, '装扮到期提醒：提前若干天与过期后各推一条站内信'),
  ('notice', 'notice.decoration_expiry_ahead_days', '3', 'int',  0, 1, 11, '装扮到期提前提醒天数（0 表示不提前提醒）'),
  ('notice', 'notice.decoration_expiry_back_days',  '1', 'int',  0, 1, 12, '装扮过期后补提醒天数（0 表示不补提醒）'),
  ('notice', 'notice.decoration_unlock_enabled',    '1', 'bool', 0, 1, 13, '装扮解锁提醒：达标发放或领取活动装扮后推站内信')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0107_add_user_birthday_emotion.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 用户资料扩展：生日 + 情感状态
--
-- 设计口径（重要）：
--   1. 生日是「用户自填资料」，只用于年龄/星座展示与生日关怀，
--      不参与实名认证、不参与 18+ 等年龄门槛判定。
--      原因：实名是可关闭的运营开关（system.order_realname_required /
--      system.companion_realname_required），把生日挂靠实名会导致关闭实名后
--      整套资料能力失效；且实名的 birth_date 在 user_identities 表，
--      属于证件数据，不能让用户自填值覆盖。
--   2. 不存年龄，由 birthday 实时计算。存年龄需要每年跑一次全表更新，
--      且必然出现一批过期数据。
--   3. 情感状态是自愿披露的社交标签，0 保密 / 1 单身 / 2 恋爱中，
--      不使用「婚姻状况」口径，也不开放前台按单身筛选。
--   4. 出参收敛：本人可见完整生日，他人资料卡只返回年龄与星座。
-- ============================================================================

ALTER TABLE users
  ADD COLUMN birthday DATE NULL DEFAULT NULL
    COMMENT '生日（用户自填，仅用于年龄/星座展示与生日关怀，不参与实名校验）' AFTER gender,
  ADD COLUMN emotion_status TINYINT NOT NULL DEFAULT 0
    COMMENT '情感状态：0保密 1单身 2恋爱中' AFTER birthday;


-- ----------------------------------------------------------------------------
-- 0108_create_gifts.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 送礼物：礼物定义 / 赠送记录 / 抽成配置
--
-- 形态：
--   1) 礼物素材只支持图片（PNG / JPG / GIF / WebP），GIF 即为动图；
--      全屏闪光、射线、粒子由客户端 CSS 合成，H5 与微信小程序共用一套代码。
--   2) 价格按「分」存储，与钱包口径一致；送礼金额 = price * count。
--   3) 收益全额进收款人余额（默认），平台抽成比例由 gift.platform_rate 配置
--      （百分比整数 0-100，默认 0），抽成只记账到 gift_records.platform_income，
--      不建平台账户、不动任何用户余额。
--   4) 记录冗余礼物名 / 图标 / 单价快照：礼物改名、下架或删除后历史记录仍可展示。
-- ============================================================================

CREATE TABLE IF NOT EXISTS gifts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '礼物名称',
  icon VARCHAR(255) NOT NULL DEFAULT '' COMMENT '礼物图（支持 GIF 动图）',
  price BIGINT NOT NULL DEFAULT 0 COMMENT '单价（分）',
  description VARCHAR(255) NOT NULL DEFAULT '' COMMENT '礼物说明',
  sort INT NOT NULL DEFAULT 0 COMMENT '排序，小的在前',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '0 下架 1 上架',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_gifts_status (status, sort, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='礼物定义';

CREATE TABLE IF NOT EXISTS gift_records (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  gift_id BIGINT UNSIGNED NOT NULL COMMENT '礼物 ID',
  gift_name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '礼物名快照',
  gift_icon VARCHAR(255) NOT NULL DEFAULT '' COMMENT '礼物图快照',
  from_user_id BIGINT UNSIGNED NOT NULL COMMENT '送礼人 users.id',
  to_user_id BIGINT UNSIGNED NOT NULL COMMENT '收礼人 users.id',
  count INT NOT NULL DEFAULT 1 COMMENT '数量',
  price BIGINT NOT NULL DEFAULT 0 COMMENT '单价快照（分）',
  total_price BIGINT NOT NULL DEFAULT 0 COMMENT '总价（分）',
  income BIGINT NOT NULL DEFAULT 0 COMMENT '收款人实收（分）',
  platform_income BIGINT NOT NULL DEFAULT 0 COMMENT '平台抽成（分），默认 0',
  client_token VARCHAR(64) NOT NULL DEFAULT '' COMMENT '客户端幂等令牌，同一次确认重试不会重复扣款',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_gift_records_from_token (from_user_id, client_token),
  KEY idx_gift_records_to (to_user_id, created_at),
  KEY idx_gift_records_from (from_user_id, created_at),
  KEY idx_gift_records_gift (gift_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='礼物赠送记录';

-- ---------------------------------------------------------------------------
-- 礼物设置：平台抽成比例（百分比整数，0 表示全额给收款人）
-- ---------------------------------------------------------------------------
INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('gift', 'gift.platform_rate', '0', 'int', 0, 1, 1,
   '礼物平台抽成比例（百分比 0-50，0 表示全额给收款人；抽成只记账，不影响收款人以外的余额）')
ON DUPLICATE KEY UPDATE remark = VALUES(remark), sort = VALUES(sort);


-- ----------------------------------------------------------------------------
-- 0109_seed_gift_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 送礼物后台权限点
--   gift               礼物管理（菜单）
--   gift:list          查看礼物 / 查看赠送记录
--   gift:create        新增礼物
--   gift:update        编辑 / 上下架
--   gift:delete        删除礼物
--   gift:record        赠送记录（菜单，同时作为记录查询接口的权限点）
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '礼物管理', 'gift', 1, '/content/gift', 'ri:gift-line', 32, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'gift');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看礼物', 'gift:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'gift'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'gift:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '新增礼物', 'gift:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'gift'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'gift:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑礼物', 'gift:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'gift'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'gift:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除礼物', 'gift:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'gift'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'gift:delete');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '赠送记录', 'gift:record', 1, '/content/gift-record', 'ri:file-list-3-line', 33, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'gift:record');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN (
  'gift', 'gift:list', 'gift:create', 'gift:update', 'gift:delete', 'gift:record'
)
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0110_grant_operator_upload_permission.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 运营角色补「素材上传」权限
--   背景：运营已被授予商品 / 礼物 / 装扮等新增编辑权限，这些页面都用
--   ArtMediaUpload 直传 /api/v1/admin/uploads，但 R_OPERATOR 只有
--   system:file:list 而没有 system:file:upload，导致点上传直接 403。
--   这里只补 upload，不放开删除，保持素材删除仍由管理员执行。
-- ============================================================================

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code = 'system:file:upload'
WHERE r.code = 'R_OPERATOR'
  AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id
  );


-- ----------------------------------------------------------------------------
-- 0111_create_user_photos.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 用户相册
--
-- 独立于帖子的个人相册：用户自己上传的图片，只存图片，不聚合帖子内容。
-- 落地顺序由 id 决定（新的在前），status=0 可用于后台隐藏而不删图。
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_photos (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '相册所属用户',
  url VARCHAR(500) NOT NULL DEFAULT '' COMMENT '图片地址，取自 uploads 表',
  width INT NOT NULL DEFAULT 0 COMMENT '图片宽度',
  height INT NOT NULL DEFAULT 0 COMMENT '图片高度',
  size BIGINT NOT NULL DEFAULT 0 COMMENT '字节数',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 正常 0 隐藏',
  created_at DATETIME DEFAULT NULL,
  updated_at DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  -- 资料卡相册只按「某人 + 正常 + 时间倒序」查，这个组合索引足够
  KEY idx_user_photos_user (user_id, status, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户相册照片';


-- ----------------------------------------------------------------------------
-- 0112_create_coupons.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 优惠券：券模板 + 用户领取记录 + 订单优惠字段
--
-- 形态：
--   1) 券类型：满减券（type=1，amount 为减免金额）/ 折扣券（type=2，discount 为折扣，
--      实付 = 原价 × discount ÷ 100，如 85 表示付 85%）。
--   2) 金额一律按「分」存储，与钱包、订单口径一致。
--   3) 适用范围 scope：1 全场、2 指定商品（goods_id）。
--   4) 领取：上架且未领满的用户可领取；发放总量 total=0 表示不限。
--   5) 使用：下单时核销（原子占券，防并发重复使用），未支付取消时退回；
--      已支付订单退款不退回（券已消耗）。优惠只减用户实付 pay_amount，
--      陪玩收入 companion_income 不变，差额由平台承担（discount_amount 记账）。
--   6) user_coupons 冗余券名 / 类型 / 面额 / 折扣 / 门槛 / 范围快照：
--      券模板改动或下架后，已领取的券仍按领取时口径判定。
-- ============================================================================

CREATE TABLE IF NOT EXISTS coupons (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '券名称',
  type TINYINT NOT NULL DEFAULT 1 COMMENT '1 满减券 2 折扣券',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '满减券减免金额（分）',
  discount TINYINT NOT NULL DEFAULT 0 COMMENT '折扣券折扣（1-99，实付=原价*discount/100）',
  min_amount BIGINT NOT NULL DEFAULT 0 COMMENT '使用门槛（分），0=无门槛',
  scope TINYINT NOT NULL DEFAULT 1 COMMENT '适用范围 1 全场 2 指定商品',
  goods_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '指定商品 ID（scope=2 时）',
  total BIGINT NOT NULL DEFAULT 0 COMMENT '发行总量，0=不限',
  issued BIGINT NOT NULL DEFAULT 0 COMMENT '已发放数量',
  per_user_limit INT NOT NULL DEFAULT 0 COMMENT '每人限领，0=不限',
  start_at DATETIME NULL DEFAULT NULL COMMENT '领取/使用开始时间',
  end_at DATETIME NULL DEFAULT NULL COMMENT '使用截止时间，NULL 表示不过期',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '0 下架 1 上架',
  description VARCHAR(255) NOT NULL DEFAULT '' COMMENT '说明',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_coupons_status (status, start_at, end_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='优惠券模板';

CREATE TABLE IF NOT EXISTS user_coupons (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'users.id',
  coupon_id BIGINT UNSIGNED NOT NULL COMMENT 'coupons.id',
  coupon_name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '券名快照',
  type TINYINT NOT NULL DEFAULT 1 COMMENT '快照 1 满减 2 折扣',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '快照 减免金额（分）',
  discount TINYINT NOT NULL DEFAULT 0 COMMENT '快照 折扣',
  min_amount BIGINT NOT NULL DEFAULT 0 COMMENT '快照 门槛（分）',
  scope TINYINT NOT NULL DEFAULT 1 COMMENT '快照 适用范围',
  goods_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '快照 指定商品',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '0 未使用 1 已使用',
  expire_at DATETIME NULL DEFAULT NULL COMMENT '到期时间，NULL 不过期',
  order_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '占用/使用的订单 ID',
  used_at DATETIME NULL DEFAULT NULL COMMENT '使用时间',
  receive_source TINYINT NOT NULL DEFAULT 1 COMMENT '1 用户领取 2 后台发放',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_coupons_user_status (user_id, status, expire_at),
  KEY idx_user_coupons_coupon (coupon_id),
  KEY idx_user_coupons_order (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户优惠券';

-- ---------------------------------------------------------------------------
-- 订单优惠字段：discount_amount 优惠金额（分），user_coupon_id 使用的用户券，
-- coupon_name 券名快照（券删除后订单仍可展示）。
-- ---------------------------------------------------------------------------
ALTER TABLE orders
  ADD COLUMN discount_amount BIGINT NOT NULL DEFAULT 0 COMMENT '优惠金额（分）' AFTER pay_amount,
  ADD COLUMN user_coupon_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '使用的用户优惠券 ID' AFTER discount_amount,
  ADD COLUMN coupon_name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '优惠券名快照' AFTER user_coupon_id;


-- ----------------------------------------------------------------------------
-- 0113_seed_coupon_permissions.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 优惠券后台权限点
--   coupon               优惠券管理（菜单）
--   coupon:list          查看优惠券 / 领取记录
--   coupon:create        新增优惠券
--   coupon:update        编辑 / 上下架
--   coupon:delete        删除优惠券
--   coupon:grant         发放优惠券
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '优惠券', 'coupon', 1, '/content/coupon', 'ri:coupon-3-line', 34, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'coupon');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看优惠券', 'coupon:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'coupon'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'coupon:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '新增优惠券', 'coupon:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'coupon'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'coupon:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '编辑优惠券', 'coupon:update', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'coupon'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'coupon:update');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '删除优惠券', 'coupon:delete', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'coupon'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'coupon:delete');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '发放优惠券', 'coupon:grant', 2, '', '', 5, 1 FROM permissions p
WHERE p.code = 'coupon'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'coupon:grant');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN (
  'coupon', 'coupon:list', 'coupon:create', 'coupon:update', 'coupon:delete', 'coupon:grant'
)
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0114_create_companion_deposits.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 陪玩保证金：缴纳 / 退还 / 扣罚
--
-- 资金语义（金额一律按「分」，与钱包口径一致）：
--   1) 缴纳：从陪玩本人钱包余额扣款，转入保证金池（companions.deposit_amount 累加），
--      钱包流水 biz_type=deposit_pay（出账）。
--   2) 退还：保证金池减少，退回陪玩钱包，钱包流水 biz_type=deposit_refund（入账，
--      冲减累计支出而非虚增收入）。
--   3) 扣罚：保证金池减少，钱被平台没收、不退钱包，不写钱包流水（缴纳时已离账），
--      仅在 companion_deposits 记录一条扣罚流水。
--
-- companions.deposit_amount 已存在（当前保证金余额快照），本迁移只建流水表。
-- 配置项：
--   companion.deposit_amount   应缴保证金金额（分），0 表示不要求
--   companion.deposit_required 是否强制缴足后才能接单
-- ============================================================================

CREATE TABLE IF NOT EXISTS companion_deposits (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  deposit_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '单号 DP...',
  companion_id BIGINT UNSIGNED NOT NULL COMMENT 'companions.id',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'users.id',
  type TINYINT NOT NULL DEFAULT 1 COMMENT '1 缴纳 2 退还 3 扣罚',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '金额（分），始终为正',
  balance_after BIGINT NOT NULL DEFAULT 0 COMMENT '操作后保证金余额快照（分）',
  order_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '扣罚关联订单 ID',
  remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '备注 / 扣罚原因',
  operator_type TINYINT NOT NULL DEFAULT 1 COMMENT '1 用户 2 管理员 3 系统',
  operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
  operator_name VARCHAR(64) NOT NULL DEFAULT '',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_companion_deposits_no (deposit_no),
  KEY idx_companion_deposits_companion (companion_id, id),
  KEY idx_companion_deposits_user (user_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪玩保证金流水';

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('companion', 'companion.deposit_amount',   '0', 'int',  0, 1, 1, '陪玩保证金金额（分），0 表示不要求保证金'),
  ('companion', 'companion.deposit_required', '0', 'bool', 0, 1, 2, '强制陪玩缴足保证金后才能接单')
ON DUPLICATE KEY UPDATE config_key = config_key;

-- ---------------------------------------------------------------------------
-- 后台权限点：保证金管理（菜单）+ 查看 / 退还 / 扣罚
-- ---------------------------------------------------------------------------
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '保证金', 'deposit', 1, '/content/deposit', 'ri:shield-check-line', 35, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'deposit');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看保证金', 'deposit:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'deposit'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'deposit:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '退还保证金', 'deposit:refund', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'deposit'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'deposit:refund');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '扣罚保证金', 'deposit:fine', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'deposit'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'deposit:fine');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN ('deposit', 'deposit:list', 'deposit:refund', 'deposit:fine')
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0115_create_penalties_and_deposit_refunds.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 陪玩罚款单 + 保证金退还申请
--
-- 1) companion_penalties 罚款单（有状态机）：
--      后台开单 → 1 待缴（立即生效限制）→ 陪玩从钱包余额缴纳 → 2 已缴
--      后台可撤销 → 3 已撤销
--      punish_type：1 禁接单 + 禁提现 / 2 仅禁提现
--      限制只在「待缴」状态生效，缴纳或撤销后自动解除。
-- 2) companion_deposit_refunds 保证金退还申请：
--      陪玩申请 → 1 待审核 → 后台通过（退回钱包 + 减保证金）→ 2 已通过
--                        → 后台拒绝 → 3 已拒绝
--      申请前置：保证金余额 > 0、无待审核申请、无进行中订单（30/40/50）、无待缴罚款。
-- 3) 新增配置 companion.deposit_refund_enabled：是否允许陪玩自主申请退还（默认关闭）。
-- ============================================================================

CREATE TABLE IF NOT EXISTS companion_penalties (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  penalty_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '罚款单号 PN...',
  companion_id BIGINT UNSIGNED NOT NULL COMMENT 'companions.id',
  order_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '关联订单，0 无',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '罚款金额（分）',
  reason VARCHAR(500) NOT NULL DEFAULT '' COMMENT '罚款原因',
  punish_type TINYINT NOT NULL DEFAULT 1 COMMENT '1 禁接单+禁提现 2 仅禁提现',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 待缴 2 已缴 3 已撤销',
  paid_at DATETIME NULL DEFAULT NULL COMMENT '缴纳时间',
  pay_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '缴纳钱包流水单号',
  operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '开单人（管理员）',
  operator_name VARCHAR(64) NOT NULL DEFAULT '',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_companion_penalties_no (penalty_no),
  KEY idx_companion_penalties_companion (companion_id, status),
  KEY idx_companion_penalties_status (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪玩罚款单';

CREATE TABLE IF NOT EXISTS companion_deposit_refunds (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  refund_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '退还申请单号 DR...',
  companion_id BIGINT UNSIGNED NOT NULL COMMENT 'companions.id',
  user_id BIGINT UNSIGNED NOT NULL COMMENT 'users.id',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '申请退还金额（分）',
  status TINYINT NOT NULL DEFAULT 1 COMMENT '1 待审核 2 已通过 3 已拒绝',
  reason VARCHAR(255) NOT NULL DEFAULT '' COMMENT '申请理由',
  audit_remark VARCHAR(255) NOT NULL DEFAULT '' COMMENT '审核备注 / 拒绝原因',
  audited_by BIGINT UNSIGNED NOT NULL DEFAULT 0,
  audited_at DATETIME NULL DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_companion_deposit_refunds_no (refund_no),
  KEY idx_companion_deposit_refunds_companion (companion_id, status),
  KEY idx_companion_deposit_refunds_status (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='陪玩保证金退还申请';

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('companion', 'companion.deposit_refund_enabled', '0', 'bool', 0, 1, 3, '允许陪玩申请退还保证金（需后台审核通过）')
ON DUPLICATE KEY UPDATE config_key = config_key;

-- ---------------------------------------------------------------------------
-- 权限点：罚款管理 + 保证金退还审核
-- ---------------------------------------------------------------------------
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '罚款管理', 'penalty', 1, '/content/penalty', 'ri:error-warning-line', 36, 1
FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'penalty');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看罚款', 'penalty:list', 2, '', '', 1, 1 FROM permissions p
WHERE p.code = 'penalty'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'penalty:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '开具罚款', 'penalty:create', 2, '', '', 2, 1 FROM permissions p
WHERE p.code = 'penalty'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'penalty:create');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '撤销罚款', 'penalty:revoke', 2, '', '', 3, 1 FROM permissions p
WHERE p.code = 'penalty'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'penalty:revoke');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '审核保证金退还', 'deposit:audit', 2, '', '', 4, 1 FROM permissions p
WHERE p.code = 'deposit'
  AND NOT EXISTS (SELECT 1 FROM permissions c WHERE c.code = 'deposit:audit');

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r
JOIN permissions p ON p.code IN (
  'penalty', 'penalty:list', 'penalty:create', 'penalty:revoke', 'deposit:audit'
)
WHERE r.code IN ('R_ADMIN', 'R_OPERATOR')
  AND NOT EXISTS (SELECT 1 FROM role_permissions rp WHERE rp.role_id = r.id AND rp.permission_id = p.id);


-- ----------------------------------------------------------------------------
-- 0116_create_user_wechat_openids.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 用户微信身份表：一个账号可绑定多个微信应用
--
-- 背景：openid 是「应用级」唯一 —— 小程序与公众号是两个应用，同一个微信在两边
--       拿到的 openid 不同，只有 unionid 相同。users 表原先只有一个 wx_openid 列，
--       于是「小程序注册过 → H5 再登录」会被当成陌生微信号，走到手机号合并时又
--       因为「该手机号已绑定其他微信账号」被拒绝，同一个微信无法跨端登录。
-- 方案：身份单独一张表，按 openid 精确匹配，按 unionid 跨端识别；
--       一个 openid 只能属于一个账号，一个账号可以同时挂小程序与 H5 的 openid。
-- 回填：升级前 users.wx_openid 存的是「首次绑定的那个 openid」，app_type 记为
--       空串（当时不区分端），登录时会自动按实际端补写。
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_wechat_openids (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '所属用户 ID',
  app_type VARCHAR(16) NOT NULL DEFAULT '' COMMENT '微信应用：mp=小程序 h5=公众号网页，空=升级前的历史数据',
  openid VARCHAR(64) NOT NULL COMMENT '该应用下的 openid',
  unionid VARCHAR(64) NULL DEFAULT NULL COMMENT '微信开放平台 unionid，未绑定开放平台时为空',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_wx_openid (openid),
  KEY idx_user_wx_user (user_id),
  KEY idx_user_wx_unionid (unionid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='用户微信身份（一个账号可绑定小程序与 H5 两个应用）';

-- 回填历史数据；NOT EXISTS 保证重复执行也不会报错。
INSERT INTO user_wechat_openids (user_id, app_type, openid, unionid)
SELECT u.id, '', u.wx_openid, u.wx_unionid
FROM users u
WHERE u.wx_openid IS NOT NULL
  AND u.wx_openid <> ''
  AND NOT EXISTS (SELECT 1 FROM user_wechat_openids w WHERE w.openid = u.wx_openid);


-- ----------------------------------------------------------------------------
-- 0117_users_wechat_openid_columns.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 微信身份落回 users 表：wx_mp_openid（小程序）/ wx_h5_openid（公众号）
--
-- 0116 把微信身份放进了独立的 user_wechat_openids 表；在只有两个端的前提下，
-- 多一张表就多一次查询、多一层概念，这里改回「一个端一列」，登录判定也更直白：
--   小程序登录 → wx_mp_openid；H5 登录 → wx_h5_openid；跨端识别 → wx_unionid。
-- 说明：
--   1. 两列各自唯一且允许 NULL（MySQL 唯一索引允许多个 NULL，未绑定时互不冲突）；
--   2. 0116 里 app_type 为空的历史身份不迁到这两列 —— 升级前无法判断那条 openid
--      属于哪个端，它们仍留在 users.wx_openid（只读历史列），该用户下次从某端登录时
--      按实际端认领到对应列，不靠猜测归属；
--   3. 迁完即删 user_wechat_openids，避免两套并行的身份数据。
-- ============================================================================

ALTER TABLE users
  ADD COLUMN wx_mp_openid VARCHAR(64) NULL DEFAULT NULL COMMENT '微信小程序 openid' AFTER wx_openid,
  ADD COLUMN wx_h5_openid VARCHAR(64) NULL DEFAULT NULL COMMENT '公众号网页授权 openid' AFTER wx_mp_openid,
  ADD UNIQUE KEY uk_users_wx_mp_openid (wx_mp_openid),
  ADD UNIQUE KEY uk_users_wx_h5_openid (wx_h5_openid);

-- 历史列改注释：升级后不再写入，只用于「老账号首次登录时认领到正确的端」
ALTER TABLE users
  MODIFY COLUMN wx_openid VARCHAR(64) NULL DEFAULT NULL
  COMMENT '微信 openid（历史列，只读：升级前只存首次绑定的那个应用，不区分端）';

-- 回填 0116 里已经明确端别的身份
UPDATE users u
JOIN user_wechat_openids w ON w.user_id = u.id AND w.app_type = 'mp'
SET u.wx_mp_openid = w.openid;

UPDATE users u
JOIN user_wechat_openids w ON w.user_id = u.id AND w.app_type = 'h5'
SET u.wx_h5_openid = w.openid;

-- app_type 为空的历史身份判断不出端别：按首发登录方式（小程序）先归到 wx_mp_openid。
-- 万一某个账号其实是 H5 建的号也不会丢身份：H5 登录走 wx_openid 兜底时会补写到 wx_h5_openid，
-- 反之真正的小程序登录会把 wx_mp_openid 纠正成小程序的 openid。
UPDATE users u
JOIN user_wechat_openids w ON w.user_id = u.id AND w.app_type = ''
SET u.wx_mp_openid = w.openid
WHERE u.wx_mp_openid IS NULL;

-- app_type 为空的行与 users.wx_openid 内容一致，随表一起删除不会丢数据
DROP TABLE IF EXISTS user_wechat_openids;


-- ----------------------------------------------------------------------------
-- 0118_create_payment_orders.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 在线支付单（微信 JSAPI 一二期）
--
-- 充值单 / 订单本身不带支付渠道流水，微信回调只给 out_trade_no，
-- 必须有一张「我方支付单」把 微信订单号 ↔ 业务单 对上，并承担幂等与审计：
--   1. 同一笔业务单可以多次发起支付（关单后重试），每次一条 payment_orders；
--   2. out_trade_no 全表唯一，回调重复到达时靠状态流转只结算一次；
--   3. 记录下单时的插件与模式（v2/v3）快照，后台换配置后老单仍可对账。
-- ============================================================================

CREATE TABLE IF NOT EXISTS payment_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  out_trade_no VARCHAR(32) NOT NULL COMMENT '我方支付单号（PAY...，回调按它对账）',
  scene VARCHAR(16) NOT NULL COMMENT '业务场景：recharge=充值 order=订单',
  biz_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '业务主键（充值单 / 订单 ID）',
  biz_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '业务单号（充值单号 / 订单号）',
  user_id BIGINT UNSIGNED NOT NULL COMMENT '付款用户',
  channel_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'payment_channels.id',
  channel_code VARCHAR(32) NOT NULL DEFAULT '' COMMENT '渠道编码（回调路径里带的就是它）',
  plugin VARCHAR(32) NOT NULL DEFAULT '' COMMENT '支付插件编码',
  mode VARCHAR(8) NOT NULL DEFAULT '' COMMENT '接口模式：v2 / v3',
  app_type VARCHAR(8) NOT NULL DEFAULT '' COMMENT '支付发起端：mp=小程序 h5=公众号',
  openid VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'payer.openid',
  amount BIGINT NOT NULL DEFAULT 0 COMMENT '支付金额（分）',
  description VARCHAR(127) NOT NULL DEFAULT '' COMMENT '商品描述（微信账单展示）',
  prepay_id VARCHAR(64) NOT NULL DEFAULT '' COMMENT '预支付会话标识',
  transaction_id VARCHAR(64) NOT NULL DEFAULT '' COMMENT '微信支付订单号',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '0待支付 1已支付 2已关闭 3支付失败',
  paid_at DATETIME NULL DEFAULT NULL COMMENT '支付成功时间',
  expire_at DATETIME NULL DEFAULT NULL COMMENT '支付单过期时间',
  notify_raw TEXT NULL COMMENT '回调原文（排障用，敏感字段已脱敏）',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_pay_out_trade_no (out_trade_no),
  KEY idx_pay_biz (scene, biz_id, id),
  KEY idx_pay_user (user_id, id),
  KEY idx_pay_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='在线支付单';


-- ----------------------------------------------------------------------------
-- 0119_create_recharge_refunds.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 充值退款
--
-- 在线支付（微信 v2/v3）充值到账后，后台可发起「原路退款」：
--   1) 创建退款单并置充值单为「退款中」；
--   2) 调微信退款 API（v2 用商户 API 证书 / v3 用商户私钥）；
--   3) 微信退款回调确认成功 → 扣回用户余额（允许负余额）并冲正充值流水。
-- 线下代充不走微信，仍由客服线下转账 + 拒绝处理，不参与本表。
-- ============================================================================

CREATE TABLE IF NOT EXISTS recharge_refunds (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  recharge_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '充值单 ID',
  recharge_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '充值单号',
  user_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '充值用户 ID',
  out_refund_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '商户退款单号 RF...',
  out_trade_no VARCHAR(32) NOT NULL DEFAULT '' COMMENT '原微信支付单号',
  refund_id VARCHAR(64) NOT NULL DEFAULT '' COMMENT '微信退款单号',
  refund_amount BIGINT NOT NULL DEFAULT 0 COMMENT '退款金额（分）',
  mode VARCHAR(8) NOT NULL DEFAULT '' COMMENT '退款接口模式 v2/v3',
  status TINYINT NOT NULL DEFAULT 0 COMMENT '0 退款中 1 成功 2 失败',
  reason VARCHAR(255) NOT NULL DEFAULT '' COMMENT '退款原因',
  operator_id BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '操作管理员 ID',
  operator_name VARCHAR(64) NOT NULL DEFAULT '' COMMENT '操作管理员名称',
  refunded_at DATETIME NULL COMMENT '退款成功时间',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_out_refund_no (out_refund_no),
  KEY idx_recharge (recharge_id),
  KEY idx_user (user_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值退款单';

-- 充值退款权限点（高风险资金操作），挂在钱包管理菜单下，仅超管 / 管理员授予。
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '充值退款', 'recharge:refund', 2, '', '', 6, 1
FROM permissions p
WHERE p.code = 'peiwan:wallet'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'recharge:refund');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE code = 'recharge:refund';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE code = 'recharge:refund';


-- ----------------------------------------------------------------------------
-- 0120_add_withdraw_transfer_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 提现商家转账到零钱
--
-- 在「手动打款」基础上增加「商家转账到零钱」：
--   审核通过 + 开关开启 + 微信账户且有 openid + 未超限额 → 自动打款到用户本人微信零钱；
--   否则回落手动打款，并在后台/前台给「超出限额建议手动」的提示。
-- 三档限额默认值与微信商户平台一致，商户提额后需同步修改这里。
-- ============================================================================

-- 提现单增加商家转账标记：transfer_mode 区分手动/商家转账，
-- transfer_bill_no 记录微信转账单号（非空即已发起商家转账，用于限额统计与回调定位）。
ALTER TABLE withdrawals
  ADD COLUMN transfer_mode TINYINT NOT NULL DEFAULT 0 COMMENT '0 手动打款 1 商家转账' AFTER status,
  ADD COLUMN transfer_bill_no VARCHAR(64) NOT NULL DEFAULT '' COMMENT '微信转账单号' AFTER transfer_mode;

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('withdraw', 'withdraw.transfer_enabled', '0', 'bool', 1, 1, 1,
   '商家转账到零钱开关：开启后，审核通过的微信提现将自动打款到本人微信零钱（需配置场景 ID 与微信支付 v3 商户材料）'),
  ('withdraw', 'withdraw.transfer_scene_id', '', 'string', 0, 1, 2,
   '商家转账场景 ID：商户平台 → 产品中心 → 商家转账 → 申请场景后下发'),
  ('withdraw', 'withdraw.transfer_single_limit', '20000', 'int', 1, 1, 3,
   '商家转账单笔限额（分），默认 200 元，超出该金额的提现建议手动打款'),
  ('withdraw', 'withdraw.transfer_user_daily_limit', '200000', 'int', 1, 1, 4,
   '单用户单日商家转账限额（分），默认 2000 元，超出建议手动打款'),
  ('withdraw', 'withdraw.transfer_daily_limit', '5000000', 'int', 1, 1, 5,
   '商户单日商家转账总额（分），默认 5 万元（个体户 5000 元），超出建议手动打款'),
  ('withdraw', 'withdraw.transfer_scene_reports', '[]', 'json', 0, 1, 6,
   '商家转账场景报备信息（JSON 数组 [{info_type,info_content}]），按商户平台所选场景的要求填写');


-- ----------------------------------------------------------------------------
-- 0121_add_recharge_withdraw_amount_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 充值 / 提现金额上下限后台可配置
--
-- 把原来硬编码在 service 里的金额上下限迁到 system_configs，
-- 后台「系统配置」改完立即生效，无需重新编译。
--   recharge.min_amount / recharge.max_amount：充值最低 / 最高（分）
--   withdraw.min_amount / withdraw.max_amount：提现最低 / 最高（分，0 表示不限制）
-- 金额单位统一为「分」。is_public=1 随 /configs/public 下发，前端可动态展示。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('recharge', 'recharge.min_amount', '100', 'int', 1, 1, 1,
   '最低充值金额（分），默认 100 分 = 1 元'),
  ('recharge', 'recharge.max_amount', '100000000', 'int', 1, 1, 2,
   '单次充值金额上限（分），默认 100000000 分 = 100 万元'),
  ('withdraw', 'withdraw.min_amount', '100', 'int', 1, 1, 7,
   '最低提现金额（分），默认 100 分 = 1 元'),
  ('withdraw', 'withdraw.max_amount', '0', 'int', 1, 1, 8,
   '最高提现金额（分），0 表示不限制')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0122_add_withdraw_transfer_channel_and_site_info.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 软风游戏陪玩系统 · 提现转账通道选择 + 系统信息补充
--
-- 1) withdraw.transfer_channel：商家转账使用哪个支付渠道（payment_channels.code）。
--    留空 = 自动取第一个启用的「微信官方直连」渠道（保持原有行为）。
--    配了具体渠道后，只会用该渠道的商户号 / AppID / 私钥 / 微信支付公钥发起转账，
--    避免同时存在多个微信渠道时选中了错误的商户。
--
-- 2) 系统信息补充（site 组，运营展示用，不参与接口校验）：
--    site.business_scope：业务范围（如「游戏陪玩、代练、语音开黑」）
--    site.server_ip    ：服务器 / 系统对外 IP（微信商户平台申请商家转账时要填）
--    系统名称已存在：site.name / site.short_name。
-- ============================================================================

INSERT INTO system_configs
  (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
VALUES
  ('withdraw', 'withdraw.transfer_channel', '', 'string', 0, 1, 9,
   '商家转账使用的支付渠道编码：填「支付渠道」里的编码如 wechat，留空则自动选择第一个启用的微信官方直连渠道'),
  ('site', 'site.business_scope', '', 'string', 1, 1, 90,
   '业务范围（展示 / 商户平台申请资料用，如：游戏陪玩、代练、语音开黑）'),
  ('site', 'site.server_ip', '', 'string', 0, 1, 91,
   '服务器 / 系统对外 IP（微信商户平台申请商家转账时填写，仅后台可见）')
ON DUPLICATE KEY UPDATE config_key = config_key;


-- ----------------------------------------------------------------------------
-- 0123_clear_mp_openid_after_appid_change.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 更换小程序 AppID 后，清空旧的小程序 openid
--
-- openid 是「应用级」的：同一个微信在不同小程序下拿到的 openid 完全不同。
-- 换了 AppID（wx9bd6c470721acf59 → wx4fea40caf7e4cc60）之后，users.wx_mp_openid
-- 里存的都是旧应用的失效值，留着只会让「按 openid 找账号」命中一堆永远匹配不上的记录。
--
-- 只清小程序这一列，其余保持不动：
--   - wx_h5_openid（公众号）与本问题无关，H5 登录照常；
--   - wx_unionid 保留：若新旧小程序在同一个微信开放平台下，unionid 不变，
--     用户重新登录时会被自动认回原账号，不会重复建号；若不在同一开放平台，
--     新登录拿不到 unionid，也不会误匹配到别人。
--   - wx_openid 是升级前的历史列，只做兜底认领，旧值不会与新 openid 冲突。
--
-- 影响：清空后小程序用户下次打开会重新走 wx.login 换 openid 并写回
-- （按 unionid 或手机号并回原账号）；在此之前他们仍可用手机号 + 密码登录。
-- ============================================================================

UPDATE users SET wx_mp_openid = NULL WHERE wx_mp_openid IS NOT NULL;


-- ----------------------------------------------------------------------------
-- 0123_withdraw_transfer_channel_select.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 把 withdraw.transfer_channel 从「手填渠道编码」改成下拉选择
--
-- 下拉选项由后端按 payment_channels 表里 plugin=wechat_official 的渠道动态生成，
-- 第一项固定为 auto（自动 = 第一个启用的微信官方直连渠道）。
-- 已存的空值统一写成 auto，保证后台回显能选中「自动」而不是显示占位符。
-- ============================================================================

UPDATE system_configs
SET value_type   = 'select',
    config_value = IF(config_value = '', 'auto', config_value),
    remark       = '商家转账使用的支付渠道：选「自动」则取第一个启用的微信官方直连渠道'
WHERE config_key = 'withdraw.transfer_channel';


-- ----------------------------------------------------------------------------
-- 0124_add_withdraw_transfer_confirm.sql
-- ----------------------------------------------------------------------------
-- 商家转账「用户确认收款」所需信息。
-- 发起转账返回 state=WAIT_USER_CONFIRM 时会给出 package_info，只有它才能拉起确认收款页；
-- 商户号与 AppID 必须与发起转账时完全一致（微信 JSAPI 调起确认收款的要求），所以一并落库。
ALTER TABLE `withdrawals`
    ADD COLUMN `transfer_package_info` VARCHAR(1024) NOT NULL DEFAULT '' COMMENT '商家转账确认收款 package_info' AFTER `transfer_bill_no`,
    ADD COLUMN `transfer_mch_id` VARCHAR(64) NOT NULL DEFAULT '' COMMENT '发起转账所用商户号' AFTER `transfer_package_info`,
    ADD COLUMN `transfer_app_id` VARCHAR(64) NOT NULL DEFAULT '' COMMENT '发起转账所用 AppID' AFTER `transfer_mch_id`;


-- ----------------------------------------------------------------------------
-- 0125_add_withdraw_client_type.sql
-- ----------------------------------------------------------------------------
-- 提现提交端：决定商家转账用哪个 AppID 发起。
-- 微信要求「确认收款」的 AppID 与「发起转账」的 AppID 完全一致：
-- 用小程序 AppID 发起，用户只能在小程序里拉起确认页；用公众号 AppID 发起，只能在微信内网页确认。
-- 因此按用户实际提交提现的那一端来选择，而不是按「哪个 openid 优先」来猜。
ALTER TABLE `withdrawals`
    ADD COLUMN `client_type` VARCHAR(8) NOT NULL DEFAULT '' COMMENT '提交提现的客户端：mp 小程序 / h5 公众号 / 空=历史数据，按已绑定 openid 优先公众号' AFTER `type`;


-- ----------------------------------------------------------------------------
-- 0125_withdraw_user_daily_limit_remark.sql
-- ----------------------------------------------------------------------------
-- withdraw.transfer_user_daily_limit 语义扩展：
-- 现在同时作为「单用户单日提现上限」，在用户提交提现时就校验（待审核 + 转账中 + 已打款都算占用，
-- 所有提现方式合计），不再只是微信商家转账侧的额度限制。更新备注避免运营误解。
UPDATE `system_configs`
SET `remark` = '单用户单日提现上限（分）：该用户当天所有提现方式合计，待审核/转账中/已打款均占用额度，默认 2000 元，0 = 不限制'
WHERE `config_key` = 'withdraw.transfer_user_daily_limit';


-- ----------------------------------------------------------------------------
-- 0126_config_money_unit.sql
-- ----------------------------------------------------------------------------
-- 金额类配置项统一改成 value_type='money'：
-- 数据库依然存「分」，后台按「元」显示与录入（前端自动 ×100 / ÷100），
-- 运营不必再把 20000 心算成 200 元。remark 同步去掉「分」字样，避免误读。
UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '陪玩保证金金额（元），0 表示不要求保证金'
WHERE `config_key` = 'companion.deposit_amount';

UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '允许发起协同的陪玩收益门槛（元，0 不限）'
WHERE `config_key` = 'order.coop_min_income';

UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '单次充值金额上限（元），默认 100 万元'
WHERE `config_key` = 'recharge.max_amount';

UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '最低充值金额（元），默认 1 元'
WHERE `config_key` = 'recharge.min_amount';

UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '最高提现金额（元），0 表示不限制'
WHERE `config_key` = 'withdraw.max_amount';

UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '最低提现金额（元），默认 1 元'
WHERE `config_key` = 'withdraw.min_amount';

UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '商户单日商家转账总额（元），默认 5 万元（个体户 5000 元），超出建议手动打款'
WHERE `config_key` = 'withdraw.transfer_daily_limit';

UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '商家转账单笔限额（元），默认 200 元，超出该金额的提现建议手动打款'
WHERE `config_key` = 'withdraw.transfer_single_limit';

UPDATE `system_configs`
SET `value_type` = 'money',
    `remark` = '单用户单日提现上限（元）：该用户当天所有提现方式合计，待审核/转账中/已打款均占用额度，默认 2000 元，0 = 不限制'
WHERE `config_key` = 'withdraw.transfer_user_daily_limit';


-- ----------------------------------------------------------------------------
-- 0127_drop_wechat_notify_configs.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 下线微信提醒配置
--
-- 通知统一走站内信（user_notices + 长连接推送），不再向小程序订阅消息 /
-- 公众号模板消息派发。对应配置项与订阅模板清单一并删除，避免后台留下无法生效的开关。
--
-- 后续若重新接入，按当时的微信规则重新设计模板配置，不要复用这份结构。
-- ============================================================================

DELETE FROM system_configs WHERE group_name = 'notify';


-- ----------------------------------------------------------------------------
-- 0128_add_capability_match_index.sql
-- ----------------------------------------------------------------------------
-- 新单推送反查 + 接单资质判定：按「游戏 + 开关 + 区服」过滤能力表。
-- 原 idx_game 只能按游戏裁剪，热门游戏能力行上万时仍要逐行回表判断 enabled / server_id。
-- 列序按等值在前、范围（IN）在后：(game_id, enabled, server_id)。
ALTER TABLE `companion_capabilities`
    ADD KEY `idx_game_enabled_server` (`game_id`, `enabled`, `server_id`);


-- ----------------------------------------------------------------------------
-- 0129_add_perf_indexes.sql
-- ----------------------------------------------------------------------------
-- 性能优化：补高频查询缺失的索引（MySQL 5.7，在线加索引不锁表）
-- 1) 陪玩「我的接单」列表：WHERE companion_id = ? AND status IN (...) ORDER BY id DESC
--    池子已有 idx_orders_pool(status, companion_id, ...)，但列表以 companion_id 为前导更贴合，
--    避免先按 status 扫全表待接单再回表过滤。
-- 2) 用户评价列表：WHERE user_id = ? AND status = ? AND is_anonymous = 0
--    原 idx_user(user_id) 选择性不足。
-- 3) 历史视频封面回填任务：WHERE status = ? AND video_cover = ''（后台低频，但避免全表扫）。
-- 4) 会话列表排序：ORDER BY pinned DESC, last_msg_at DESC（用户维度行数少，覆盖索引消除 filesort）。

ALTER TABLE `orders`
    ADD KEY `idx_orders_companion` (`companion_id`, `status`, `id`),
    ALGORITHM = INPLACE, LOCK = NONE;

ALTER TABLE `reviews`
    ADD KEY `idx_reviews_user_status` (`user_id`, `status`),
    ALGORITHM = INPLACE, LOCK = NONE;

ALTER TABLE `posts`
    ADD KEY `idx_posts_cover_backfill` (`status`, `video_cover`),
    ALGORITHM = INPLACE, LOCK = NONE;

ALTER TABLE `chat_user_conversations`
    ADD KEY `idx_chat_conv_pinned` (`user_id`, `pinned`, `last_msg_at`),
    ALGORITHM = INPLACE, LOCK = NONE;


-- ----------------------------------------------------------------------------
-- 0130_create_support.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 在线客服：坐席表 + 客服会话表 + 权限点
--
-- 会话本体复用 chat_sessions（session_type = 4），消息/未读/推送/图片全部沿用聊天底座；
-- support_sessions 只保存「这条用户会话由哪个客服接待、状态如何」的业务信息。
-- 一个用户只保留一条客服会话：chat_sessions.direct_key = 'support:{userID}' 唯一。
-- ============================================================================

CREATE TABLE IF NOT EXISTS `support_agents` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_id`      BIGINT UNSIGNED NOT NULL COMMENT 'admins.id',
  `nickname`      VARCHAR(50)  NOT NULL DEFAULT '' COMMENT '对外展示的客服昵称',
  `avatar`        VARCHAR(255) NOT NULL DEFAULT '' COMMENT '对外展示的头像',
  `status`        TINYINT      NOT NULL DEFAULT 0  COMMENT '0 离线 1 在线 2 忙碌（满接待）',
  `max_sessions`  INT          NOT NULL DEFAULT 20 COMMENT '最大同时接待数，0 不限',
  `heartbeat_at`  DATETIME     NULL DEFAULT NULL COMMENT '工作台心跳，超过 90 秒视为离线',
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_support_agent_admin` (`admin_id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '客服坐席';

CREATE TABLE IF NOT EXISTS `support_sessions` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_id`  BIGINT UNSIGNED NOT NULL COMMENT 'chat_sessions.id',
  `user_id`     BIGINT UNSIGNED NOT NULL COMMENT 'users.id',
  `agent_id`    BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '当前接待客服 admins.id，0 待接入',
  `status`      TINYINT         NOT NULL DEFAULT 1 COMMENT '1 待接入 2 服务中 3 已结束',
  `source`      VARCHAR(20)     NOT NULL DEFAULT '' COMMENT '入口来源：mine/message/order',
  `order_id`    BIGINT UNSIGNED NULL DEFAULT NULL COMMENT '从订单页进入时带上的订单 ID',
  `last_msg_at` DATETIME        NULL DEFAULT NULL,
  `closed_at`   DATETIME        NULL DEFAULT NULL,
  `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_support_session` (`session_id`),
  KEY `idx_support_user` (`user_id`),
  KEY `idx_support_status` (`status`, `updated_at`),
  KEY `idx_support_agent` (`agent_id`, `status`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '客服会话';

-- 权限点：一个菜单 + 四个按钮，挂给后台管理员（role 2）与运营（role 3）。
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT 0, '客服中心', 'support', 1, '/support', 'ri:headphone-line', 60, 1
WHERE NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'support');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '客服会话列表', 'support:list', 2, '', '', 1, 1
FROM permissions p
WHERE p.code = 'support'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'support:list');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '回复用户', 'support:reply', 2, '', '', 2, 1
FROM permissions p
WHERE p.code = 'support'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'support:reply');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '转接会话', 'support:transfer', 2, '', '', 3, 1
FROM permissions p
WHERE p.code = 'support'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'support:transfer');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '坐席管理', 'support:manage', 2, '', '', 4, 1
FROM permissions p
WHERE p.code = 'support'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'support:manage');

-- 管理员：全部
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions
WHERE code IN ('support', 'support:list', 'support:reply', 'support:transfer', 'support:manage');

-- 运营：接入与回复，不含坐席管理
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions
WHERE code IN ('support', 'support:list', 'support:reply', 'support:transfer');


-- ----------------------------------------------------------------------------
-- 0131_add_support_display_name.sql
-- ----------------------------------------------------------------------------
-- 客服自定义昵称：客服在工作台里给自己起一个对外名字（如「小柔」），
-- 未设置时回落 support_agents.nickname（即后台账号昵称），避免用户端看到「超级管理员」。
--
-- 为什么不复用 nickname：nickname 是上线时由后台账号昵称同步过来的快照，
-- 每次上线都会覆盖，无法区分「没设置」与「设置成了同名」。

ALTER TABLE `support_agents`
    ADD COLUMN `display_name` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '客服自定义昵称，空则回落后台昵称',
    ALGORITHM = INPLACE, LOCK = NONE;


-- ----------------------------------------------------------------------------
-- 0132_create_zk_license.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 授权中心：保存本实例与中控（peiwan-zk）的授权关系。
--
-- 单行表（id 恒为 1）：一个部署实例只对应一个授权码。
-- license 的 payload / signature 原样存下来，每次读取都在本地用内置公钥验签，
-- 因此中控挂掉也不影响「是否正版」的判定，更不会把客户业务拖死。
-- 迁移服务器时把这张表一起带走，否则会被判定为换机需要重新激活。
-- ============================================================================

CREATE TABLE IF NOT EXISTS `zk_license` (
  `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `install_id`        VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '实例标识，首次使用自动生成',
  `license_code`      VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '授权码（后台展示时脱敏）',
  `instance_token`    VARCHAR(128) NOT NULL DEFAULT '' COMMENT '中控下发的心跳令牌',
  `payload`           TEXT         COMMENT 'license 原文 JSON（验签用，必须原样保存）',
  `signature`         VARCHAR(256) NOT NULL DEFAULT '' COMMENT 'Ed25519 签名（hex）',
  `key_id`            VARCHAR(32)  NOT NULL DEFAULT '' COMMENT '签名密钥标识',
  `edition_name`      VARCHAR(64)  NOT NULL DEFAULT '' COMMENT '套餐名',
  `modules`           VARCHAR(512) NOT NULL DEFAULT '' COMMENT '已购模块（JSON 数组）',
  `limits`            VARCHAR(512) NOT NULL DEFAULT '' COMMENT '用量上限（JSON 对象）',
  `expire_at`         DATETIME     NULL DEFAULT NULL COMMENT '到期时间',
  `grace_days`        INT          NOT NULL DEFAULT 0  COMMENT '到期后宽限天数',
  `activated_at`      DATETIME     NULL DEFAULT NULL,
  `last_heartbeat_at` DATETIME     NULL DEFAULT NULL,
  `last_checked_at`   DATETIME     NULL DEFAULT NULL COMMENT '最近一次检查更新',
  `latest_version`    VARCHAR(32)  NOT NULL DEFAULT '' COMMENT '中控上架的最新版本',
  `last_update_at`    DATETIME     NULL DEFAULT NULL COMMENT '最近一次执行在线更新',
  `last_error`        VARCHAR(512) NOT NULL DEFAULT '' COMMENT '最近一次调用中控的失败原因',
  `created_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '实例授权状态（单行）';

-- 权限点：挂在「系统配置」节点下，只加按钮点（菜单由前端静态路由渲染）
INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '查看授权', 'license:view', 2, '', '', 21, 1
FROM permissions p
WHERE p.code = 'system:config'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'license:view');

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '授权管理', 'license:manage', 2, '', '', 22, 1
FROM permissions p
WHERE p.code = 'system:config'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'license:manage');

-- 管理员全部；运营只给查看（激活与更新属于敏感操作）
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE code IN ('license:view', 'license:manage');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 3, id FROM permissions WHERE code = 'license:view';


-- ----------------------------------------------------------------------------
-- 0133_widen_payment_orders_mode.sql
-- ----------------------------------------------------------------------------
-- 支付单 mode 加宽：原 VARCHAR(8) 只够存 v2 / v3，
-- 接入易支付后新增 epay_v1 / epay_v2（7 位），后续若再带上端类型就会溢出（严格模式下直接报错）。
-- 同时把注释改成真实语义：记录「下单时的协议模式快照」，用于对账与退款时判定走的哪套接口。

ALTER TABLE `payment_orders`
    MODIFY COLUMN `mode` VARCHAR(16) NOT NULL DEFAULT '' COMMENT '接口模式快照：v2 / v3 / epay_v1 / epay_v2',
    ALGORITHM = INPLACE, LOCK = NONE;

-- 渠道编码最长 32（payment_channels.code），充值单原先只留 20 位，
-- 自定义渠道编码偏长时会写入失败（1406 Data too long），一并放宽。
ALTER TABLE `recharge_orders`
    MODIFY COLUMN `provider` VARCHAR(32) NOT NULL DEFAULT 'balance' COMMENT '支付渠道编码（wechat_official / wechat_epay / alipay_epay / manual 等）';


-- ----------------------------------------------------------------------------
-- 0134_transfer_standalone_config.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 商家转账（提现打款到微信零钱）配置从「提现设置」抽离为独立分组 transfer
--
-- 背景：
--   原先商家转账复用「支付渠道」里 wechat_official 渠道的商户号 / 私钥 / 公钥，
--   并用 withdraw.transfer_channel 指定用哪个渠道，由此带来两个问题：
--   1) 只开易支付收款、没开微信直连支付的站点，根本没法用商家转账；
--   2) 该配置项校验要求「必须是启用的微信官方直连渠道编码」，
--      历史值（如 wechat）在新环境里不存在时，保存系统配置会整页报错，
--      连其它分组的配置也保存不了。
--
-- 本次改动：
--   1) 把 withdraw.transfer_* 全部迁到 transfer 分组，后台独立成「商家转账」菜单；
--   2) 新增商家转账自己的商户号 / 证书序列号 / 私钥 / 微信支付公钥 / APIv3 密钥 /
--      小程序与公众号 AppID / 回调地址，不再依赖支付渠道；
--   3) 删除已废弃的 withdraw.transfer_channel（不再按支付渠道选择）。
-- ============================================================================

-- 1) 迁移已有配置项到 transfer 分组，并重排 sort
UPDATE `system_configs` SET `group_name` = 'transfer', `sort` = 1,
  `remark` = '商家转账到零钱开关：开启后，审核通过的微信提现将自动打款到本人微信零钱（需填完本页商户材料）'
WHERE `config_key` = 'withdraw.transfer_enabled';

UPDATE `system_configs` SET `group_name` = 'transfer', `sort` = 10,
  `remark` = '商家转账场景 ID：商户平台 → 产品中心 → 商家转账 → 申请场景后下发（佣金报酬选 1005）'
WHERE `config_key` = 'withdraw.transfer_scene_id';

UPDATE `system_configs` SET `group_name` = 'transfer', `sort` = 12,
  `remark` = '商家转账单笔限额（元），默认 200 元，超出该金额的提现建议手动打款'
WHERE `config_key` = 'withdraw.transfer_single_limit';

UPDATE `system_configs` SET `group_name` = 'transfer', `sort` = 13,
  `remark` = '单用户单日提现上限（元）：该用户当天所有提现方式合计，待审核/转账中/已打款均占用额度，默认 2000 元，0 = 不限制'
WHERE `config_key` = 'withdraw.transfer_user_daily_limit';

UPDATE `system_configs` SET `group_name` = 'transfer', `sort` = 14,
  `remark` = '商户单日商家转账总额（元），默认 5 万元（个体户 5000 元），超出建议手动打款'
WHERE `config_key` = 'withdraw.transfer_daily_limit';

UPDATE `system_configs` SET `group_name` = 'transfer', `sort` = 11,
  `remark` = '商家转账场景报备信息（JSON 数组 [{"info_type":"岗位类型","info_content":"陪玩"}]），留空按场景默认文案'
WHERE `config_key` = 'withdraw.transfer_scene_reports';

-- 2) 转账渠道选择已废弃：商家转账改为独立商户配置，不再关联支付渠道
DELETE FROM `system_configs` WHERE `config_key` = 'withdraw.transfer_channel';

-- 3) 新增商家转账独立商户材料（已存在则跳过，便于重复执行）
INSERT INTO `system_configs`
  (`group_name`, `config_key`, `config_value`, `value_type`, `is_public`, `is_system`, `sort`, `remark`)
VALUES
  ('transfer', 'transfer.mch_id', '', 'string', 0, 1, 2,
   '商家转账商户号：与收款支付渠道可以不同，但必须是已开通「商家转账到零钱」的微信支付商户'),
  ('transfer', 'transfer.serial_no', '', 'string', 0, 1, 3,
   '商户 API 证书序列号：微信商户平台 → 账户中心 → API 安全 → 申请 API 证书后可见'),
  ('transfer', 'transfer.api_v3_key', '', 'string', 0, 1, 4,
   'APIv3 密钥（32 位）：用于解密转账结果回调，需与商户号对应'),
  ('transfer', 'transfer.private_key', '', 'text', 0, 1, 5,
   '商户 API 私钥（PEM）：apiclient_key.pem 的完整内容，含 BEGIN/END 行'),
  ('transfer', 'transfer.platform_public_key', '', 'text', 0, 1, 6,
   '微信支付公钥（PEM）：用于校验转账回调签名，微信商户平台 → API 安全 → 微信支付公钥'),
  ('transfer', 'transfer.platform_public_key_id', '', 'string', 0, 1, 7,
   '微信支付公钥 ID：形如 PUB_KEY_ID_xxx，与公钥成对填写'),
  ('transfer', 'transfer.mp_app_id', '', 'string', 0, 1, 8,
   '小程序 AppID：小程序端提交的提现用该 AppID 发起转账，必须与商户号绑定'),
  ('transfer', 'transfer.h5_app_id', '', 'string', 0, 1, 9,
   '公众号 AppID：微信内 H5 提交的提现用该 AppID 发起转账，必须与商户号绑定'),
  ('transfer', 'transfer.notify_url', '', 'string', 0, 1, 15,
   '转账结果回调地址：留空按系统对外地址自动生成 /api/v1/withdraw/transfer-notify/transfer')
ON DUPLICATE KEY UPDATE `config_key` = `config_key`;


-- ----------------------------------------------------------------------------
-- 0135_transfer_config_backfill.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 商家转账独立配置：key 改名 + 存量材料回填
--
-- 0134 把商家转账从「支付渠道」抽离成独立配置后，原本靠 wechat_official
-- 渠道打款的站点会变成「材料全空」，升级后自动打款会失败。
-- 这里先把仍带 withdraw. 前缀的 key 统一改成 transfer.*，
-- 再从第一个启用的微信官方直连渠道里把商户材料抄一份过来，
-- 让这些站点升级后无需重新填一遍；已经有值的不覆盖。
-- 没有微信官方直连渠道的站点（只开易支付收款）不受影响，全部保持为空。
-- ============================================================================

-- 1) key 与分组名对齐（0134 只改了分组，key 还是旧前缀）
UPDATE `system_configs` SET `config_key` = 'transfer.enabled'
WHERE `config_key` = 'withdraw.transfer_enabled';
UPDATE `system_configs` SET `config_key` = 'transfer.scene_id'
WHERE `config_key` = 'withdraw.transfer_scene_id';
UPDATE `system_configs` SET `config_key` = 'transfer.scene_reports'
WHERE `config_key` = 'withdraw.transfer_scene_reports';
UPDATE `system_configs` SET `config_key` = 'transfer.single_limit'
WHERE `config_key` = 'withdraw.transfer_single_limit';
UPDATE `system_configs` SET `config_key` = 'transfer.user_daily_limit'
WHERE `config_key` = 'withdraw.transfer_user_daily_limit';
UPDATE `system_configs` SET `config_key` = 'transfer.daily_limit'
WHERE `config_key` = 'withdraw.transfer_daily_limit';

-- 2) 商户材料回填（只填空值）

UPDATE `system_configs`
SET `config_value` = COALESCE((
  SELECT NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(`pc`.`config`, '$.mchId'))), '')
  FROM `payment_channels` `pc`
  WHERE `pc`.`plugin` = 'wechat_official' AND `pc`.`status` = 1
  ORDER BY `pc`.`id` LIMIT 1
), '')
WHERE `config_key` = 'transfer.mch_id' AND TRIM(`config_value`) = '';

UPDATE `system_configs`
SET `config_value` = COALESCE((
  SELECT NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(`pc`.`config`, '$.serialNo'))), '')
  FROM `payment_channels` `pc`
  WHERE `pc`.`plugin` = 'wechat_official' AND `pc`.`status` = 1
  ORDER BY `pc`.`id` LIMIT 1
), '')
WHERE `config_key` = 'transfer.serial_no' AND TRIM(`config_value`) = '';

UPDATE `system_configs`
SET `config_value` = COALESCE((
  SELECT NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(`pc`.`config`, '$.apiV3Key'))), '')
  FROM `payment_channels` `pc`
  WHERE `pc`.`plugin` = 'wechat_official' AND `pc`.`status` = 1
  ORDER BY `pc`.`id` LIMIT 1
), '')
WHERE `config_key` = 'transfer.api_v3_key' AND TRIM(`config_value`) = '';

UPDATE `system_configs`
SET `config_value` = COALESCE((
  SELECT NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(`pc`.`config`, '$.privateKey'))), '')
  FROM `payment_channels` `pc`
  WHERE `pc`.`plugin` = 'wechat_official' AND `pc`.`status` = 1
  ORDER BY `pc`.`id` LIMIT 1
), '')
WHERE `config_key` = 'transfer.private_key' AND TRIM(`config_value`) = '';

UPDATE `system_configs`
SET `config_value` = COALESCE((
  SELECT NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(`pc`.`config`, '$.platformPublicKey'))), '')
  FROM `payment_channels` `pc`
  WHERE `pc`.`plugin` = 'wechat_official' AND `pc`.`status` = 1
  ORDER BY `pc`.`id` LIMIT 1
), '')
WHERE `config_key` = 'transfer.platform_public_key' AND TRIM(`config_value`) = '';

UPDATE `system_configs`
SET `config_value` = COALESCE((
  SELECT NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(`pc`.`config`, '$.platformPublicKeyId'))), '')
  FROM `payment_channels` `pc`
  WHERE `pc`.`plugin` = 'wechat_official' AND `pc`.`status` = 1
  ORDER BY `pc`.`id` LIMIT 1
), '')
WHERE `config_key` = 'transfer.platform_public_key_id' AND TRIM(`config_value`) = '';

UPDATE `system_configs`
SET `config_value` = COALESCE((
  SELECT NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(`pc`.`config`, '$.appId'))), '')
  FROM `payment_channels` `pc`
  WHERE `pc`.`plugin` = 'wechat_official' AND `pc`.`status` = 1
  ORDER BY `pc`.`id` LIMIT 1
), '')
WHERE `config_key` = 'transfer.mp_app_id' AND TRIM(`config_value`) = '';

UPDATE `system_configs`
SET `config_value` = COALESCE((
  SELECT NULLIF(TRIM(JSON_UNQUOTE(JSON_EXTRACT(`pc`.`config`, '$.h5AppId'))), '')
  FROM `payment_channels` `pc`
  WHERE `pc`.`plugin` = 'wechat_official' AND `pc`.`status` = 1
  ORDER BY `pc`.`id` LIMIT 1
), '')
WHERE `config_key` = 'transfer.h5_app_id' AND TRIM(`config_value`) = '';

-- 场景 ID 只在没有配过时沿用旧值（0134 已把 withdraw.transfer_scene_id 迁到 transfer 分组）
UPDATE `system_configs`
SET `config_value` = '1005'
WHERE `config_key` = 'transfer.scene_id' AND TRIM(`config_value`) = '';


-- ----------------------------------------------------------------------------
-- 0136_add_recharge_cancel_permission.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 充值单取消权限点
--
-- 在线支付单（易支付/微信）在网关不回调或用户放弃付款时会一直挂在「待支付」，
-- 客户端可以自助取消，后台也需要一个「关闭待支付单」的入口做人工收尾。
-- 关闭只是本地状态收敛，不影响后续成功回调的入账（见 payment_order_repo.SettleRecharge）。
-- ============================================================================

INSERT INTO permissions (parent_id, name, code, type, path, icon, sort, status)
SELECT p.id, '关闭充值单', 'recharge:cancel', 2, '', '', 7, 1
FROM permissions p
WHERE p.code = 'peiwan:wallet'
  AND NOT EXISTS (SELECT 1 FROM permissions WHERE code = 'recharge:cancel');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions WHERE code = 'recharge:cancel';

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE code = 'recharge:cancel';


-- ----------------------------------------------------------------------------
-- 0137_add_site_h5_url_config.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 站点设置：H5 前端地址（site.h5_url）
--
-- 支付网关付款完成后会把浏览器带回 return_url。API 域名本身不托管 H5，
-- 直接跳到 {public_url}/#/pages/... 只会是 404，所以需要一个真正的前端地址：
--   1. 这里配置了 → 同步跳转直接回 H5 页面，/payment/return 落地页也会自动跳转；
--   2. 没配置 → 回落到配置文件 server.h5_url，仍为空则展示「支付已提交」提示页。
-- 后台「系统配置 - 站点设置」可改，保存即生效，不用改文件也不用重启。
-- ============================================================================

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'site', 'site.h5_url', '', 'string', 1, 1, 92,
       'H5 前端地址（如 https://h5.example.com）：支付完成后跳回前端页面用，留空则只展示后端提示页'
WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'site.h5_url');


-- ----------------------------------------------------------------------------
-- 0138_add_admin_token_version.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 管理端令牌版本号
--
-- C 端用户令牌有 users.token_version（改密/重置/封禁即时吊销旧令牌），
-- 管理端此前没有：重置管理员密码后，旧令牌会一直用到自然过期。
-- 本次补上 admins.token_version，重置密码时 +1，旧令牌随之失效。
-- 存量管理员为 0，存量令牌不带版本号也按 0 处理，升级后不会掉登录态。
-- ============================================================================

ALTER TABLE admins
  ADD COLUMN token_version INT UNSIGNED NOT NULL DEFAULT 0
  COMMENT '令牌版本号：重置密码时 +1，旧令牌随之失效'
  AFTER password_hash;


-- ----------------------------------------------------------------------------
-- 0139_drop_zk_license_modules_limits.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 去掉实例授权表的「模块白名单」与「用量上限」两列。
--
-- 产品决定：一个有效授权即全功能开放，授权只按到期时间判定，
-- modules / limits 从未参与业务判定（历史实现仅用于落库展示）。
-- 字段已从 model.ZKLicense 与 license payload 中移除，这里把存量列清掉。
--
-- 注意：DROP COLUMN 不可回滚。新建库同样会先由 0132 建出这两列再被本文件删除，
-- 保证「全新安装」与「已有库升级」走同一条路径。
-- ============================================================================

ALTER TABLE `zk_license`
  DROP COLUMN `modules`,
  DROP COLUMN `limits`;


-- ----------------------------------------------------------------------------
-- 0140_add_pull_refresh_brand_config.sql
-- ----------------------------------------------------------------------------
-- ============================================================================
-- 站点设置：下拉刷新品牌文字（site.pull_refresh_text）
--
-- 背景：
--   下拉刷新动画里的品牌字母一直写死为 SOFTFENG（PullRefresh.vue 的 LETTERS）。
--   客户拿去做自己的品牌时无法修改，只能改代码重新编译。
--
-- 本次改动：
--   新增公开配置 site.pull_refresh_text，默认值仍为 SOFTFENG，行为保持不变；
--   后台「系统配置 - 站点设置」可改成任意品牌名（中英文皆可），客户端下次启动生效。
--   留空时前端自动回退 SOFTFENG，不会出现刷新头空白。
-- ============================================================================

INSERT INTO system_configs (group_name, config_key, config_value, value_type, is_public, is_system, sort, remark)
SELECT 'site', 'site.pull_refresh_text', 'SOFTFENG', 'string', 1, 1, 93,
       '下拉刷新品牌文字：下拉刷新动画中逐字点亮的品牌名，默认 SOFTFENG，建议 2-12 个字符'
WHERE NOT EXISTS (SELECT 1 FROM system_configs WHERE config_key = 'site.pull_refresh_text');


-- ----------------------------------------------------------------------------
-- 迁移记账：让 -migrate 认为这些版本已执行过
-- ----------------------------------------------------------------------------
INSERT INTO schema_migrations (version) VALUES
  ('0001_create_system_configs.sql'),
  ('0002_seed_system_configs.sql'),
  ('0003_create_admins.sql'),
  ('0004_seed_admin.sql'),
  ('0005_create_users.sql'),
  ('0006_seed_users.sql'),
  ('0007_create_roles_permissions.sql'),
  ('0008_seed_roles_permissions.sql'),
  ('0009_seed_admin_permissions.sql'),
  ('0010_create_uploads.sql'),
  ('0011_seed_upload_permissions.sql'),
  ('0012_create_games_servers.sql'),
  ('0013_seed_games_servers.sql'),
  ('0014_seed_game_permissions.sql'),
  ('0015_create_categories.sql'),
  ('0016_seed_categories.sql'),
  ('0017_seed_category_permissions.sql'),
  ('0018_create_goods.sql'),
  ('0019_seed_goods.sql'),
  ('0020_seed_goods_permissions.sql'),
  ('0021_add_goods_virtual_sold.sql'),
  ('0022_add_users_uid.sql'),
  ('0023_add_users_signature.sql'),
  ('0024_add_users_covers.sql'),
  ('0025_create_identities_companions.sql'),
  ('0026_seed_identity_companion_permissions.sql'),
  ('0027_fix_identity_companion_permissions.sql'),
  ('0028_add_realname_switch_configs.sql'),
  ('0029_create_reviews.sql'),
  ('0030_add_rating_configs_and_permissions.sql'),
  ('0031_create_companion_capabilities.sql'),
  ('0032_add_companion_voice.sql'),
  ('0033_companion_voice_audit.sql'),
  ('0034_add_upload_cleanup.sql'),
  ('0035_seed_user_create_permission.sql'),
  ('0036_split_system_config_groups.sql'),
  ('0037_sync_companion_user_type.sql'),
  ('0038_unify_signature.sql'),
  ('0039_create_orders_wallets.sql'),
  ('0040_seed_order_wallet_permissions.sql'),
  ('0041_add_order_game_server.sql'),
  ('0042_add_order_configs.sql'),
  ('0043_add_order_accept.sql'),
  ('0044_create_member_levels.sql'),
  ('0045_fix_wallet_totals.sql'),
  ('0046_settle_completed_order_income.sql'),
  ('0047_create_companion_levels.sql'),
  ('0048_add_goods_owner_uid.sql'),
  ('0049_add_order_designated.sql'),
  ('0050_add_designated_ttl_config.sql'),
  ('0051_add_order_service_flow.sql'),
  ('0052_add_order_coop.sql'),
  ('0053_fix_coop_invitation_status.sql'),
  ('0054_add_coop_invitation_closed_status.sql'),
  ('0055_add_coop_game_limit_and_main_ratio.sql'),
  ('0056_move_coop_limit_to_games.sql'),
  ('0057_create_notices.sql'),
  ('0058_create_notice_permissions.sql'),
  ('0059_create_user_notices.sql'),
  ('0060_create_chat.sql'),
  ('0061_drop_order_messages.sql'),
  ('0062_add_chat_cleanup_and_revoke.sql'),
  ('0063_add_chat_message_quote.sql'),
  ('0064_add_user_follow_and_direct_chat.sql'),
  ('0065_add_nickname_config.sql'),
  ('0066_add_nickname_uid_prefix.sql'),
  ('0067_create_official_groups.sql'),
  ('0068_add_order_confirm_remind.sql'),
  ('0069_create_circle.sql'),
  ('0070_seed_circle_permissions.sql'),
  ('0071_add_post_title.sql'),
  ('0072_create_post_favorites.sql'),
  ('0073_create_post_views.sql'),
  ('0074_add_comment_reply_and_like.sql'),
  ('0075_add_post_comment_moderation.sql'),
  ('0076_add_circle_comment_notice_config.sql'),
  ('0077_add_rank_indexes.sql'),
  ('0078_create_withdrawals.sql'),
  ('0079_seed_online_chat_permissions.sql'),
  ('0080_seed_fine_permissions.sql'),
  ('0081_add_level_snapshot_columns.sql'),
  ('0082_add_review_reply.sql'),
  ('0083_add_user_last_active.sql'),
  ('0084_reviews_order_unique.sql'),
  ('0085_create_recharge_orders.sql'),
  ('0086_add_uniqueness_guards.sql'),
  ('0087_add_pay_sms_configs.sql'),
  ('0088_create_banners.sql'),
  ('0089_seed_banner_permissions.sql'),
  ('0090_add_register_switch_configs.sql'),
  ('0091_create_sms_logs.sql'),
  ('0092_sms_provider_select.sql'),
  ('0093_harden_auth_security.sql'),
  ('0094_add_platform_mode.sql'),
  ('0095_add_platform_login_configs.sql'),
  ('0096_add_h5_wechat_require_phone.sql'),
  ('0096_add_wechat_notify_configs.sql'),
  ('0097_update_h5_wechat_configs.sql'),
  ('0098_add_h5_subscribe_templates.sql'),
  ('0098_create_payment_channels.sql'),
  ('0099_drop_legacy_pay_configs.sql'),
  ('0100_add_payment_channel_plugin.sql'),
  ('0101_create_decorations.sql'),
  ('0102_seed_decoration_permissions.sql'),
  ('0103_add_decoration_companion_flag.sql'),
  ('0104_add_user_decorations_expire_index.sql'),
  ('0105_add_decoration_unlock_rules.sql'),
  ('0106_add_notice_configs.sql'),
  ('0107_add_user_birthday_emotion.sql'),
  ('0108_create_gifts.sql'),
  ('0109_seed_gift_permissions.sql'),
  ('0110_grant_operator_upload_permission.sql'),
  ('0111_create_user_photos.sql'),
  ('0112_create_coupons.sql'),
  ('0113_seed_coupon_permissions.sql'),
  ('0114_create_companion_deposits.sql'),
  ('0115_create_penalties_and_deposit_refunds.sql'),
  ('0116_create_user_wechat_openids.sql'),
  ('0117_users_wechat_openid_columns.sql'),
  ('0118_create_payment_orders.sql'),
  ('0119_create_recharge_refunds.sql'),
  ('0120_add_withdraw_transfer_configs.sql'),
  ('0121_add_recharge_withdraw_amount_configs.sql'),
  ('0122_add_withdraw_transfer_channel_and_site_info.sql'),
  ('0123_clear_mp_openid_after_appid_change.sql'),
  ('0123_withdraw_transfer_channel_select.sql'),
  ('0124_add_withdraw_transfer_confirm.sql'),
  ('0125_add_withdraw_client_type.sql'),
  ('0125_withdraw_user_daily_limit_remark.sql'),
  ('0126_config_money_unit.sql'),
  ('0127_drop_wechat_notify_configs.sql'),
  ('0128_add_capability_match_index.sql'),
  ('0129_add_perf_indexes.sql'),
  ('0130_create_support.sql'),
  ('0131_add_support_display_name.sql'),
  ('0132_create_zk_license.sql'),
  ('0133_widen_payment_orders_mode.sql'),
  ('0134_transfer_standalone_config.sql'),
  ('0135_transfer_config_backfill.sql'),
  ('0136_add_recharge_cancel_permission.sql'),
  ('0137_add_site_h5_url_config.sql'),
  ('0138_add_admin_token_version.sql'),
  ('0139_drop_zk_license_modules_limits.sql'),
  ('0140_add_pull_refresh_brand_config.sql')
ON DUPLICATE KEY UPDATE version = VALUES(version);

-- 单文件初始化 SQL 结束（144 个迁移）
