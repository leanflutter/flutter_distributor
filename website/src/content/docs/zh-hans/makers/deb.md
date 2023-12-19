---
title: deb
---

将 `make_config.yaml` 添加到您的项目 `linux/packaging/deb` 目录。

```yaml
display_name: Hello World
package_name: hello-world
maintainer:
  name: LiJianying
  email: lijy91@foxmail.com
co_authors:
  - name: Kingkor Roy Tirtho
    email: krtirtho@gmail.com
priority: optional
section: x11
installed_size: 6604
essential: false
icon: assets/logo.png

postinstall_scripts:
  - echo "Installed my awesome app"
postuninstall_scripts:
  - echo "Surprised Pickachu face"

keywords:
  - Hello
  - World
  - Test
  - Application

generic_name: Music Application

categories:
  - Music
  - Media

startup_notify: true
```

运行：

```
flutter_distributor package --platform linux --targets deb
```

- [构建和发布 Linux 应用程序](https://docs.flutter.dev/deployment/linux)
- [打包 Debian 软件包，它是如何工作的](https://www.debian.org/doc/manuals/packaging-tutorial/packaging-tutorial.en.pdf)
