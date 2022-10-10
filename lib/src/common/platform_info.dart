// import 'dart:io';
// import 'devic';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:platform_info/platform_info.dart' as platforminfo;

import 'package:package_info_plus/package_info_plus.dart';
// import 'package:flutter/services.dart';

// /// Holds data that's different on Android and iOS
class PlatformInfo {
  // ignore: unused_field
  final String userAgent;
  // ignore: unused_field
  final String paystackBuild;
  // ignore: unused_field
  final String deviceId;

  static Future<PlatformInfo?> test() async {
    return PlatformInfo._(
      userAgent: 'test',
      paystackBuild: 'test',
      deviceId: 'test',
    );
  }
  
  static Future<PlatformInfo?> getinfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final platform = platforminfo.Platform.instance.operatingSystem;
    // ignore: prefer_typing_uninitialized_variables
    var mobilephoneinfo;

    if (!kIsWeb) {
      Platform.isIOS
          ? mobilephoneinfo = await DeviceInfoPlugin().iosInfo
          : !Platform.isLinux
              ? mobilephoneinfo = await DeviceInfoPlugin().androidInfo
              : mobilephoneinfo = await DeviceInfoPlugin().deviceInfo;
    }

    String pluginVersion = packageInfo.version;
    // : Platform.instance.isIOS
    //     ? DeviceInfoPlugin().iosInfo
    //     : "NOT MOBILE";
    String deviceId = !kIsWeb
        ? (Platform.isIOS || Platform.isAndroid)
            ? mobilephoneinfo.toString()
            : "FLUTTER_CLIENT_MOBILE"
        : "FLUTTER_CLIENT_WEB";
    String userAgent = "${platform}_Paystack_$pluginVersion";
    return PlatformInfo._(
      userAgent: userAgent,
      paystackBuild: pluginVersion,
      deviceId: deviceId,
    );
  }

  PlatformInfo._({
    required String userAgent,
    required String paystackBuild,
    required String deviceId,
    // ignore: prefer_initializing_formals
  })  : userAgent = userAgent,
        // ignore: prefer_initializing_formals
        paystackBuild = paystackBuild,
        // ignore: prefer_initializing_formals
        deviceId = deviceId;

  @override
  String toString() {
    return '[userAgent = $userAgent, paystackBuild = $paystackBuild, deviceId = $deviceId]';
  }
}
