import 'idcheckio_api.dart';
import 'idcheckio_platform_interface.dart';

class IDCheckio {
  Future<void> activate({required String idToken, bool? extractData}) {
    return IdcheckioPlatform.instance.activate(idToken: idToken, extractData: extractData);
  }

  Future<IDCheckioResult> start(IDCheckioParams params) {
    return IdcheckioPlatform.instance.start(params);
  }

  Future<IDCheckioResult> startIps(String folderUid) {
    return IdcheckioPlatform.instance.startIps(folderUid);
  }

  Future<IDCheckioResult> startOnline(IDCheckioParams params, OnlineContext? onlineContext) {
    return IdcheckioPlatform.instance.startOnline(params, onlineContext);
  }

  Future<IDCheckioResult> analyze({required IDCheckioParams params, required String side1Uri, String? side2uri, bool? isOnline, OnlineContext? onlineContext}) {
    return IdcheckioPlatform.instance.analyze(params: params, side1Uri: side1Uri, side2uri: side2uri, isOnline: isOnline, onlineContext: onlineContext);
  }
}
