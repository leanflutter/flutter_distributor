// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:app_package_maker/app_package_maker.dart';

class MakeMsixConfig extends MakeConfig {
  MakeMsixConfig({
    this.display_name,
    this.publisher_display_name,
    this.identity_name,
    this.msix_version,
    this.logo_path,
    this.trim_logo,
    this.capabilities,
    this.languages,
    this.file_extension,
    this.protocol_activation,
    this.add_execution_alias,
    this.enable_at_startup,
    this.store,
    this.debug,
    this.output_path,
    this.output_name,
    this.architecture,
    this.build_windows,
    this.certificate_path,
    this.certificate_password,
    this.publisher,
    this.signtool_options,
    this.sign_msix,
    this.install_certificate,
  });

  factory MakeMsixConfig.fromJson(Map<String, dynamic> json) {
    return MakeMsixConfig(
      display_name: json['display_name'],
      publisher_display_name: json['publisher_display_name'],
      identity_name: json['identity_name'],
      msix_version: json['msix_version'],
      logo_path: json['logo_path'],
      trim_logo: json['trim_logo'],
      capabilities: json['capabilities'],
      languages: json['languages'],
      file_extension: json['file_extension'],
      protocol_activation: json['protocol_activation'],
      add_execution_alias: json['add_execution_alias'],
      enable_at_startup: json['enable_at_startup'],
      store: json['store'],
      debug: json['debug'],
      output_path: json['output_path'],
      output_name: json['output_name'],
      architecture: json['architecture'],
      build_windows: json['build_windows'],
      certificate_path: json['certificate_path'],
      certificate_password: json['certificate_password'],
      publisher: json['publisher'],
      signtool_options: json['signtool_options'],
      sign_msix: json['sign_msix'],
      install_certificate: json['install_certificate'],
    );
  }
  // MSIX configuration

  /// A friendly app name that can be displayed to users.
  String? display_name;

  /// A friendly name for the publisher that can be displayed to users.
  String? publisher_display_name;

  /// Defines the unique identifier for the app.
  String? identity_name;

  /// The version number of the package, in `a.b.c.d` format.
  String? msix_version;

  /// Path to an [image file] for use as the app icon (size recommended at least 400x400px).
  String? logo_path;

  /// If `false`, don't trim the logo image, default is `true`.
  String? trim_logo;

  /// List of the [capabilities][windows capabilities] the app requires.
  String? capabilities;

  /// Declares the language resources contained in the package.
  String? languages;

  /// File extensions that the app may be registered to open.
  String? file_extension;

  /// [Protocol activation] that will open the app.
  String? protocol_activation;

  /// Add an alias to active the app, use the `pubspec.yaml` `name:` value, so if your app calls 'Flutter_App', user can activate the app using `flutterapp` command.
  String? add_execution_alias;

  /// App start at startup or user log-in.
  String? enable_at_startup;

  /// Generate a MSIX file for publishing to the Microsoft Store.                                                                                         |
  String? store;

  // Build configuration

  /// Create MSIX from the **debug** or **release** build files (`\build\windows\runner\<Debug/Release>`), **release** is the default.                                 | `true`                                                                                          |
  String? debug;

  /// The directory where the output MSIX file should be stored.                                                                                            | `C:\src\some\folder`                                                                             |
  String? output_path;

  /// The filename that should be given to the created MSIX file.                                                                                           | `flutterApp_dev`                                                                                     |
  String? output_name;

  /// Describes the architecture of the code in the package, `x64` or `x86`, `x64` is default.                                                                                               | `x64`                                                                                           |
  String? architecture;

  /// If `false`, don't run the build command `flutter build windows`, default is `true`.                                                                   | `true`                                                                                          |
  String? build_windows;

  /// Path to the certificate content to place in the store.                                                                                                | `C:\certs\signcert.pfx`                                                                         |
  String? certificate_path;

  /// Password for the certificate.                                                                                                                         | `1234`                                                                                          |
  String? certificate_password;

  /// The `Subject` value in the certificate.                                                                                                               | `CN=BF212345-5644-46DF-8668-014043C1B138` or `CN=Contoso Software, O=Contoso Corporation, C=US` |
  String? publisher;

  /// Options to be provided to the `signtool` for app signing (see below.)                                                                                 | `/v /fd SHA256 /f C:/Users/me/Desktop/my.cer`                                                   |
  String? signtool_options;

  /// If `false`, don't sign the msix file, default is `true`.                                                                                         | `true`                                                                                          |
  String? sign_msix;

  /// If `false`, don't try to install the certificate, default is `true`.                                                                                         | `true`                                                                                          |
  String? install_certificate;

  @override
  Map<String, dynamic> toJson() {
    return {
      'display_name': display_name,
      'publisher_display_name': publisher_display_name,
      'identity_name': identity_name,
      'msix_version': msix_version,
      'logo_path': logo_path,
      'trim_logo': trim_logo,
      'capabilities': capabilities,
      'languages': languages,
      'file_extension': file_extension,
      'protocol_activation': protocol_activation,
      'add_execution_alias': add_execution_alias,
      'enable_at_startup': enable_at_startup,
      'store': store,
      'debug': debug,
      'output_path': output_path,
      'output_name': output_name,
      'architecture': architecture,
      'build_windows': build_windows,
      'certificate_path': certificate_path,
      'certificate_password': certificate_password,
      'publisher': publisher,
      'signtool_options': signtool_options,
      'sign_msix': sign_msix,
      'install_certificate': install_certificate,
    }..removeWhere((key, value) => value == null);
  }
}

class MakeMsixConfigLoader extends DefaultMakeConfigLoader {
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
    return MakeMsixConfig.fromJson(map).copyWith(baseMakeConfig);
  }
}
