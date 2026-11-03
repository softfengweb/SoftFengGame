# 权利归属与第三方组件声明

## 一、产品归属

| 项目 | 内容 |
| --- | --- |
| 产品名称 | 软风游戏陪玩系统 |
| 英文名称 | SoftFeng Game Companion System |
| 著作权人 | 陇南市软风科技有限公司（Longnan SoftFeng Technology Co., Ltd.） |
| 商标 | 软风 / SoftFeng |
| 授权与合作 | xunuowl@qq.com |

本仓库中的服务端可执行程序、管理后台静态资源、数据库初始化脚本、部署脚本与文档，
其著作权及相关知识产权均归陇南市软风科技有限公司所有，受《中华人民共和国著作权法》
《计算机软件保护条例》《中华人民共和国商标法》等法律法规保护。

「软风」「SoftFeng」为陇南市软风科技有限公司的商标。未经书面许可，不得在商业活动中
使用上述商标、标识或与其近似的名称进行宣传。

**本仓库不是开源仓库。** 公开发布二进制与部署文件，仅为便于已获授权的客户下载与安装，
不构成对任何人的使用授权。使用前请先取得有效授权码，详见 [LICENSE](./LICENSE)。

## 二、第三方开源组件

本软件在开发与运行中使用下列开源组件，其著作权归各自作者所有，并按对应许可证授权。
本软件整体仍为商业授权软件，下述许可证不构成对本软件源代码或整体的开源许可。

### 服务端（Go，静态链接进二进制）

| 组件 | 许可证 |
| --- | --- |
| Go 标准库 (golang.org) | BSD-3-Clause |
| Gin Web Framework | MIT |
| GORM / gorm.io/driver/mysql | MIT |
| go-redis/redis | BSD-2-Clause |
| gorilla/websocket | BSD-2-Clause |
| golang-jwt/jwt | MIT |
| 其他 golang.org/x 依赖 | BSD-3-Clause |

### 管理后台

| 组件 | 许可证 |
| --- | --- |
| Vue.js / Vue Router / Pinia | MIT |
| Element Plus | MIT |
| Vite / TypeScript / Axios | MIT |
| Art Design Pro（界面框架） | MIT |
| 其他 npm 依赖 | 见各依赖包内 LICENSE |

### 运行时与基础设施（以容器镜像方式使用，未修改）

| 组件 | 许可证 |
| --- | --- |
| Alpine Linux | MIT 等（见镜像内 LICENSE） |
| nginx | BSD-2-Clause |
| MySQL Community Server | GPL-2.0（独立进程，未与本公司代码链接） |
| Redis | BSD-3-Clause |
| FFmpeg | LGPL-2.1 / GPL-2.0（按发行版编译选项，独立可执行文件调用） |

如对上述清单有异议，请联系 xunuowl@qq.com，我们将在核实后更新。
