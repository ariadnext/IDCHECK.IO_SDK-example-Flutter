import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'idcheckio_api.dart';
import 'idcheckio_method_channel.dart';


abstract class IdcheckioPlatform extends PlatformInterface {
  /// Constructs a IdcheckioPlatform.
  IdcheckioPlatform() : super(token: _token);

  static final Object _token = Object();

  static IdcheckioPlatform _instance = MethodChannelIdcheckio();

  /// The default instance of [IdcheckioPlatform] to use.
  ///
  /// Defaults to [MethodChannelIdcheckio].
  static IdcheckioPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IdcheckioPlatform] when
  /// they register themselves.
  static set instance(IdcheckioPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> activate({required String idToken, bool? extractData}) {
    throw UnimplementedError('activate() has not been implemented.');
  }

  Future<IDCheckioResult> start(IDCheckioParams params) {
    throw UnimplementedError('start() has not been implemented.');
  }

  Future<IDCheckioResult> startIps(String folderUid) {
    throw UnimplementedError('startIps() has not been implemented.');
  }

  Future<IDCheckioResult> startOnline(IDCheckioParams params, OnlineContext? onlineContext) {
    throw UnimplementedError('startOnline() has not been implemented.');
  }

  Future<IDCheckioResult> analyze({required IDCheckioParams params, required String side1Uri, String? side2uri, bool? isOnline, OnlineContext? onlineContext}) {
    throw UnimplementedError('analyze() has not been implemented.');
  }
}
