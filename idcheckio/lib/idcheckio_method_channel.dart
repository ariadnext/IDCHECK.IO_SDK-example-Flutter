import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'idcheckio_api.dart';
import 'idcheckio_platform_interface.dart';

/// An implementation of [IdcheckioPlatform] that uses method channels.
class MethodChannelIdcheckio extends IdcheckioPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('idcheckio');

  @override
  Future<void> activate({required String idToken, bool? extractData}) async {
    try {
      await methodChannel.invokeMethod('activate', <String, dynamic>{
        'idToken': idToken,
        'extractData': extractData
      });
    } on PlatformException catch (e) {
      throw PlatformException(code: "INIT_FAILED", message: e.message);
    }
  }

  @override
  Future<IDCheckioResult> start(IDCheckioParams params) async {
    try {
      String json = await (methodChannel.invokeMethod('start', params.toJson()));
      IDCheckioResult result = IDCheckioResult.fromJson(jsonDecode(json));
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(code: "CAPTURE_FAILED", message: e.message);
    }
  }

  @override
  Future<IDCheckioResult> startIps(String folderUid) async {
    try {
      String json = await (methodChannel.invokeMethod('startIps', <String, dynamic>{
        'folderUid': folderUid
      }));
      IDCheckioResult result = IDCheckioResult.fromJson(jsonDecode(json));
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(code: "CAPTURE_FAILED", message: e.message);
    }
  }

  @override
  Future<IDCheckioResult> startOnline(IDCheckioParams params, OnlineContext? onlineContext) async {
    try {
      String json = await (methodChannel.invokeMethod('startOnline', <String, dynamic>{
        'params': params.toJson(),
        if (onlineContext != null) 'onlineContext': "${onlineContext.toJson()}" else 'onlineContext': null,
      }));
      IDCheckioResult result = IDCheckioResult.fromJson(jsonDecode(json));
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(code: "CAPTURE_FAILED", message: e.message);
    }
  }

  @override
  Future<IDCheckioResult> analyze({required IDCheckioParams params, required String side1Uri, String? side2uri, bool? isOnline, OnlineContext? onlineContext}) async {
    try {
      String json = await (methodChannel.invokeMethod('analyze', <String, dynamic>{
        'params': params.toJson(),
        'side1Uri': side1Uri,
        'side2Uri': side2uri,
        'isOnline': isOnline,
        if (onlineContext != null) 'onlineContext': "${onlineContext.toJson()}" else 'onlineContext': null,
      }));
      IDCheckioResult result = IDCheckioResult.fromJson(jsonDecode(json));
      return result;
    } on PlatformException catch (e) {
      throw PlatformException(code: "ANALYZE_FAILED", message: e.message);
    }
  }
}
