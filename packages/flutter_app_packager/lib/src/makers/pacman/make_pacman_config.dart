import 'dart:io';

import 'package:flutter_app_packager/src/api/app_package_maker.dart';

// format of make_config for deb
/*
# the name used to display in the OS. Specifically desktop
# entry name
display_name: Hola Amigos

# package name for debian/apt repository
# the name should be all lowercase with -+.
package_name: hola-amigos

maintainer:
  name: Gamer Boy 69
  email: rickastley@gmail.lol

co_authors:
  - name: Mir Jafar
    email: contributor@gmail.com

# enum options -> required, important, standard, optional, extra
# refer: https://www.debian.org/doc/debian-policy/ch-archive.html#s-priorities
priority: optional

# enum options: admin, cli-mono, comm, database, debug, devel, doc, editors, education, electronics, embedded, fonts, games, gnome, gnu-r, gnustep, graphics, hamradio, haskell, httpd, interpreters, introspection, java, javascript, kde, kernel, libdevel, libs, lisp, localization, mail, math, metapackages, misc, net, news, ocaml, oldlibs, otherosfs, perl, php, python, ruby, rust, science, shells, sound, tasks, tex, text, utils, vcs, video, web, x11, xfce, zope
# refer: https://www.debian.org/doc/debian-policy/ch-archive.html#s-subsections
section: x11

# the size of binary in kilobyte
installed_size: 24400

# direct dependencies required by the application
# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
dependencies:
  - libkeybinder-3.0-0 (>= 0.3.2)

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
build_dependencies_indep:
  - texinfo

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
build_dependencies:
  - kernel-headers-2.2.10 [!hurd-i386]
  - gnumach-dev [hurd-i386]
  - libluajit5.1-dev [i386 amd64 kfreebsd-i386 armel armhf powerpc mips]

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
recommended_dependencies:
  - neofetch

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
suggested_dependencies:
  - libkeybinder-3.0-0 (>= 0.3.2)

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
enhances:
  - spotube

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html
pre_dependencies:
  - libc6

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html#packages-which-break-other-packages-breaks
breaks:
  - libspotify (<< 3.0.0)

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html#conflicting-binary-packages-conflicts
conflicts:
  - spotify

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html#virtual-packages-provides
provides:
  - libx11

# refer: https://www.debian.org/doc/debian-policy/ch-relationships.html#overwriting-files-and-replacing-packages-replaces
replaces:
  - spotify

essential: false

postinstall_scripts:
  - echo `Installed my awesome app`
postuninstall_scripts:
  - echo `Surprised Pickachu face`


# application icon path relative to project url
icon: assets/logo.png

keywords:
  - Hello
  - World
  - Test
  - Application

# a name to categorize the app into a section of application
generic_name: Hobby Application

# supported mime types that can be opened using this application
supported_mime_type:
  - audio/mpeg

# shown when right clicked the desktop entry icons
actions:
  - Gallery
  - Create

# the categories the application belong to
# refer: https://specifications.freedesktop.org/menu-spec/latest/
categories:
  - Music
  - Media

# let OS know if the application can be run on start_up. If it's false 
# the application will deny to the OS if it was added as a start_up 
# application
startup_notify: true  
*/

class MakePacmanConfig extends MakeLinuxPackageConfig {
  MakePacmanConfig({
    required this.displayName,
    required this.packageName,
    this.installedSize,
    required this.maintainer,
    this.packageRelease = 1,
    List<String>? postinstallScripts,
    List<String>? postupgradeScripts,
    List<String>? postuninstallScripts,
    this.actions,
    this.categories,
    this.dependencies,
    this.genericName,
    this.optDependencies,
    this.options,
    this.startupNotify = false,
    this.groups = const ['default'],
    this.licenses = const ['unknown'],
    this.icon,
    this.metainfo,
    this.keywords,
    this.provides,
    this.conflicts,
    this.replaces,
    this.supportedMimeType,
  })  : _postinstallScripts = postinstallScripts ?? [],
        _postupgradeScripts = postupgradeScripts ?? [],
        _postremoveScripts = postuninstallScripts ?? [];

  factory MakePacmanConfig.fromJson(Map<String, dynamic> map) {
    return MakePacmanConfig(
      displayName: map['display_name'],
      packageName: map['package_name'], //
      packageRelease: int.tryParse(map['package_release'] ?? '1') ?? 1,
      maintainer:
          "${map['maintainer']['name']} <${map['maintainer']['email']}>",
      dependencies: map['dependencies'] != null
          ? List.castFrom<dynamic, String>(map['dependencies'])
          : null,
      conflicts: map['conflicts'] != null
          ? List.castFrom<dynamic, String>(map['conflicts'])
          : null,
      replaces: map['replaces'] != null
          ? List.castFrom<dynamic, String>(map['replaces'])
          : null,
      options: map['options'] != null
          ? List.castFrom<dynamic, String>(map['options'])
          : null,
      optDependencies: map['optional_dependencies'] != null
          ? List.castFrom<dynamic, String>(map['optional_dependencies'])
          : null,
      licenses: map['licenses'] != null
          ? List.castFrom<dynamic, String>(map['licenses'])
          : ["unknown"],
      groups: map['groups'] != null
          ? List.castFrom<dynamic, String>(map['groups'])
          : ["default"],
      provides: map['provides'] != null
          ? List.castFrom<dynamic, String>(map['provides'])
          : null,
      postinstallScripts: map['postinstall_scripts'] != null
          ? List.castFrom<dynamic, String>(map['postinstall_scripts'])
          : null,
      postuninstallScripts: map['postuninstall_scripts'] != null
          ? List.castFrom<dynamic, String>(map['postuninstall_scripts'])
          : null,
      keywords: map['keywords'] != null
          ? List.castFrom<dynamic, String>(map['keywords'])
          : null,
      supportedMimeType: map['supported_mime_type'] != null
          ? List.castFrom<dynamic, String>(map['supported_mime_type'])
          : null,
      actions: map['actions'] != null
          ? List.castFrom<dynamic, String>(map['actions'])
          : null,
      categories: map['categories'] != null
          ? List.castFrom<dynamic, String>(map['categories'])
          : null,
      startupNotify: map['startup_notify'],
      genericName: map['generic_name'],
      installedSize: map['installed_size'],
      icon: map['icon'],
      metainfo: map['metainfo'],
    );
  }

  String displayName;
  String packageName;
  String maintainer;
  int packageRelease;
  int? installedSize;
  List<String> licenses;
  List<String> groups;
  String? icon;
  String? metainfo;
  String? genericName;
  bool startupNotify;
  List<String>? options;
  List<String>? dependencies;
  List<String>? optDependencies;
  List<String>? conflicts;
  List<String>? replaces;
  List<String>? provides;
  List<String> _postinstallScripts;
  List<String> _postupgradeScripts;
  List<String> _postremoveScripts;
  List<String>? keywords;
  List<String>? supportedMimeType;
  List<String>? actions;
  List<String>? categories;

  List<String> get postinstallScripts => [
        'ln -s /usr/share/$appBinaryName/$appBinaryName /usr/bin/$appBinaryName',
        'chmod +x /usr/bin/$appBinaryName',
        ..._postinstallScripts,
      ];

  List<String> get postuninstallScripts => [
        'rm /usr/bin/$appBinaryName',
        ..._postremoveScripts,
      ];

  List<String>? get postupgradeScripts => _postupgradeScripts;

  @override
  Map<String, dynamic> toJson() {
    return {
      'PKGINFO': {
        'pkgname': packageName,
        'pkgver': appVersion.toString(),
        'pkgdesc': pubspec.description,
        'packager': maintainer,
        'size': installedSize,
        'license': '(${licenses.join(', ')})',
        'groups': '(${groups.join(', ')})',
        'arch': '(${_getArchitecture()})',
        'url': pubspec.homepage,
        'options': "(${options?.join(', ')})",
        'depends': "(${dependencies?.join(', ')})",
        'optdepends': "(${optDependencies?.join(', ')})",
        'conflicts': "(${conflicts?.join(', ')})",
        'replaces': "(${replaces?.join(', ')})",
        'provides': "(${provides?.join(', ')})",
      }..removeWhere((key, value) => value == null),
      'DESKTOP': {
        'Type': 'Application',
        'Version': appVersion.toString(),
        'Name': displayName,
        'GenericName': genericName,
        'Icon': appBinaryName,
        'Exec': '$appBinaryName %U',
        'Actions': actions != null && actions!.isNotEmpty
            ? '${actions!.join(';')};'
            : null,
        'MimeType': supportedMimeType != null && supportedMimeType!.isNotEmpty
            ? '${supportedMimeType!.join(';')};'
            : null,
        'Categories': categories != null && categories!.isNotEmpty
            ? '${categories!.join(';')};'
            : null,
        'Keywords': keywords != null && keywords!.isNotEmpty
            ? '${keywords!.join(';')};'
            : null,
        'StartupNotify': startupNotify,
      }..removeWhere((key, value) => value == null),
    };
  }

  Map<String, String> toFilesString() {
    final json = toJson();
    final pkginfoFile =
        '${(json['PKGINFO'] as Map<String, dynamic>).entries.map(
              (e) => '${e.key}= ${e.value}',
            ).join('\n')}\n';
    final installFileMap = {
      "post_install": postinstallScripts.join('\n'),
      "post_upgrade": postupgradeScripts?.join('\n'),
      "post_remove": postuninstallScripts.join('\n'),
    }..removeWhere((key, value) => value == null);

    final installFile = installFileMap.entries
        .map(
          (e) => '${e.key}() {\n${e.value}\n}',
        )
        .join('\n');

    final desktopFile = [
      '[Desktop Entry]',
      ...(json['DESKTOP'] as Map<String, dynamic>).entries.map(
            (e) => '${e.key}=${e.value}',
          ),
    ].join('\n');
    final map = {
      'PKGINFO': pkginfoFile,
      'DESKTOP': desktopFile,
      'INSTALL': installFile,
    };
    return map;
  }
}

class MakePacmanConfigLoader extends DefaultMakeConfigLoader {
  @override
  MakeConfig load(
    Map<String, dynamic>? arguments,
    Directory outputDirectory, {
    required Directory buildOutputDirectory,
    required List<File> buildOutputFiles,
  }) {
    final baseMakeConfig = super.load(
      arguments,
      outputDirectory,
      buildOutputDirectory: buildOutputDirectory,
      buildOutputFiles: buildOutputFiles,
    );
    final map = loadMakeConfigYaml(
      '$platform/packaging/$packageFormat/make_config.yaml',
    );
    return MakePacmanConfig.fromJson(map).copyWith(baseMakeConfig);
  }
}

String _getArchitecture() {
  final result = Process.runSync('uname', ['-m']);
  if ('${result.stdout}'.trim() == 'aarch64') {
    return 'i686';
  } else {
    return 'x86_64';
  }
}
