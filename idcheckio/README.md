# IDCheckio Sdk - Flutter plugin

## Getting started

#### Add the flutter plugin to your dependencies

Open your pubspec.yaml, go to the `dependencies:` section and add a path to the plugin folder :
- Relative path
```yaml
idcheckio:
  path: ../idcheckio
```
- Or absolute path :
```yaml
idcheckio:
  path: /ABSOLUTE_PATH_TO_PLUGIN_FOLDER/idcheckio
```

Then do a `flutter pub get` to install the dependency.

## Platform specific configuration

#### Dart

1. You need to set your token in the main.dart file to be able to activate the sdk.
```dart
final _activationToken = "Set your token here.";
```

#### iOS

1. In your project folder, go to your iOS directory and open the Podfile :
 - Change the minimum version to at least '10.0' on the top of the file
```
# Uncomment this line to define a global platform for your project
platform :ios, '10.0'
```
 - Add the following lines above the `target`section :
```
source 'https://github.com/CocoaPods/Specs.git'
source 'https://git-externe.rennes.ariadnext.com/idcheckio/axt-podspecs.git'
```

2. Retrieve the sdk using `pod install --repo-update`
- ⚠️⚠️  &nbsp; You will need to have a `.netrc` file on your `$HOME` folder setup with our credentials. Check the official documentation for more informations. &nbsp;⚠️⚠️

3. In your project, open the `*.plist` file and the following entry :
- "Privacy - Camera Usage Description" : "Camera is being used to scan documents"

#### Android

1. Open your build file `android/app/build.gradle` :- In the `android` block, add the following lines :
```groovy
packagingOptions {
    pickFirst 'META-INF/NOTICE'
    pickFirst 'META-INF/LICENSE'
    pickFirst 'META-INF/license.txt'
    pickFirst 'META-INF/notice.txt'
    pickFirst 'META-INF/DEPENDENCIES'
}
```

2. In order to access our external nexus for retrieving the latest version of the IDCheck.io SDK, you have to update the gradle file from the **plugin** project `PATH_TO_PLUGIN_FOLDER/android/build.gradle`, and replace `$YOUR_USERNAME` and `$YOUR_PASSWORD` with the credentials given by our support team.

## Usage

1. Import the following file :
```dart
import 'package:idcheckio/idcheckio.dart';
```

2. Before capturing any document, you need to activate the licence. you have to use the `activate()` method with your activation token.
```dart
  Future<void> activateSDK() async {
    bool activationStatus = false;
    try {
      await _idcheckioPlugin.activate(
          idToken: _activationToken,
          extractData: true);
      activationStatus = true;
    } on PlatformException catch (e) {
      activationStatus = false;
      ErrorMsg errorMsg = ErrorMsg.fromJson(jsonDecode(e.message!));
      debugPrint("An error happened during the activation : ${errorMsg.cause} - ${errorMsg.details} - ${errorMsg.message}");
    }
    if (!mounted) return;
    setState(() {
      _sdkActivated = activationStatus;
    });
  }
```

3. To start the capture of a document, you have to call the `start()` method with an `IdcheckioParams` object. You will receive the result in an `IdcheckioResult` object.
```dart
final IDCheckioParams paramsIDOnline = IDCheckioParams(IDCheckioParamsBuilder()
  ..docType = DocumentType.ID
  ..orientation = IDCheckioOrientation.PORTRAIT
  ..integrityCheck = IntegrityCheck(readEmrtd: true, docLiveness: false)
  ..onlineConfig = OnlineConfig(isReferenceDocument: true));

  Future<void> capture() async{
    IDCheckioResult? result;
    try {
      result = await _idcheckioPlugin.start(_selectedItem.params!);
      debugPrint('ID Capture Successful : ${result!.toJson()}', wrapWidth: 500);
    } on PlatformException catch(e) {
      ErrorMsg errorMsg = ErrorMsg.fromJson(jsonDecode(e.message!));
      debugPrint("An error happened during the capture : ${errorMsg.cause} - ${errorMsg.message} - ${errorMsg.subCause}");
    }
    if (!mounted) return;
    setState(() {
      _captureResult = result;
    });
  }
```

4. To start an online capture of a document, use the `startOnline()` method. You will receive the result in an `IdcheckioResult` object.
```dart
  final IDCheckioParams paramsLiveness = IDCheckioParams(
      IDCheckioParamsBuilder()
            ..docType = DocumentType.LIVENESS
            ..orientation = IDCheckioOrientation.PORTRAIT
            ..confirmAbort = true
  );

  Future<void> capture() async{
    IDCheckioResult? result;
    try {
      result = await _idcheckioPlugin.startOnline(_selectedItem.params!, _captureResult?.onlineContext);
      debugPrint('ID Capture Successful : ${result!.toJson()}', wrapWidth: 500);
    } on PlatformException catch(e) {
      ErrorMsg errorMsg = ErrorMsg.fromJson(jsonDecode(e.message!));
      debugPrint("An error happened during the capture : ${errorMsg.cause} - ${errorMsg.message} - ${errorMsg.subCause}");
    }
    if (!mounted) return;
    setState(() {
      _captureResult = result;
    });
  }
```

5. If you don't want to capture but just analyze a document, you can use the `analyze()` method. You will receive the result in an `IdcheckioResult` object.
```dart
Future<void> analyze() async{
    IDCheckioResult? result;
    try {
      ImagePicker imagePicker = ImagePicker();
      inal pickedFile = await (imagePicker.getImage(source: ImageSource.gallery));
      if (pickedFile != null) {
        result = await _idcheckioPlugin.analyze(
          params: _selectedItem.params!,
          side1Uri: pickedFile.path,
          side2uri: null,
          isOnline: true,
          onlineContext: _captureResult?.onlineContext);
      }
      debugPrint('ID Capture Successful : ${result!.toJson()}', wrapWidth: 500);
    } on PlatformException catch(e) {
      ErrorMsg errorMsg = ErrorMsg.fromJson(jsonDecode(e.message!));
      debugPrint("An error happened during the capture : ${errorMsg.cause} - ${errorMsg.message} - ${errorMsg.subCause}");
    }
    if (!mounted) return;
    setState(() {
      _captureResult = result;
    });
  }
```

6. If you want to start an ips session, you first need to create a new ips session by following the IPS documentation and then call the startIps method with the retrieved token. The result is empty when the capture is succesful and an error is send otherwise. If you want to retrieve your data you need to check on ips the result of the capture.
If you want the customize the colors of the ips session, you can update the IpsCustomization() object for Android or ipsTheme for iOS inside the IdcheckioPlugin with your colors (For Android take a look at IDCheckioActivity).
```dart
  Future<void> startIps() async {
    IDCheckioResult? result;
    try {
      result = await IDCheckio.startIps(ipsController.text);
    } on PlatformException catch (e) {
      ErrorMsg errorMsg = ErrorMsg.fromJson(jsonDecode(e.message!));
      debugPrint("An error happened during the ips session : ${errorMsg.cause} - ${errorMsg.message} - ${errorMsg.subCause}");
    }
    if (!mounted) return;
    setState(() {
      _captureResult = result;
    });
  }
```

You're now good to go! ✅  \
To learn more about those methods and their parameters, please refer to the official IDCheck.io Mobile SDK documentation.
