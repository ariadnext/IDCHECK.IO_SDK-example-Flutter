# IDCheckio Sdk - Flutter plugin

## Getting started

#### Add the flutter plugin to your dependencies

Open your pubspec.yaml, go to the `dependencies:` section and add a path to the plugin folder :
- Relative path
```
idcheckio:
  path: ../idcheckio
```
- Or absolute path :
```
idcheckio:
  path: /ABSOLUTE_PATH_TO_PLUGIN_FOLDER/idcheckio
```

Then do a `flutter pub get` to install the dependency.

## Platform specific configuration

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

3. Add the licence file to your iOS project.

4. In your project, open the `*.plist` file and the following entry :
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

3. Put the licence file in  `android/app/src/main/assets/`
- ⚠️  &nbsp; Don't forget to change your `signingConfig` with the certificate you give us to create the licence. &nbsp;⚠️

## Usage

1. Import the following file :
```
import 'package:idcheckio/idcheckio.dart';
```

2. Before capturing any document, you need to activate the licence. To do so, you have to use the `activate()` method.
```java  
Future<void> activate() async {
    String activationStatus;
    try {
      await IDCheckio.activate(licenceFilename: "license", environment: Environment.DEMO, disableAudioForLiveness: true, extractData: true);
      activationStatus = "The sdk is activated !";
    } on PlatformException catch (e){
      activationStatus = "Sdk activation failed : ${e.code} - ${e.message}";
    }
    if (!mounted) return;
    setState(() {
      _activationStatus = activationStatus;
    });
  }
```

3. To start the capture of a document, you have to call the `start()` method with an `IdcheckioParams` object. You will receive the result in an `IdcheckioResult` object.
```java
  final IDCheckioParams paramsID = IDCheckioParams(
    IDCheckioParamsBuilder()
      ..docType = DocumentType.ID
      ..orientation = IDCheckioOrientation.PORTRAIT
      ..integrityCheck = IntegrityCheck(readEmrtd: true)
      ..useHd = false
      ..confirmationType = ConfirmationType.DATA_OR_PICTURE
      ..scanBothSides = ScanBothSides.ENABLED
      ..sideOneExtraction = Extraction(Codeline.VALID, FaceDetection.ENABLED)
      ..sideTwoExtraction = Extraction(Codeline.REJECT, FaceDetection.DISABLED)
      ..language = Language.fr
      ..manualButtonTimer = 10
      ..maxPictureFilesize = FileSize.TWO_MEGA_BYTES
      ..feedbackLevel = FeedbackLevel.ALL
      ..adjustCrop = false
      ..confirmAbort = false
      ..onlineConfig = OnlineConfig(checkType: CheckType.CHECK_FAST, isReferenceDocument: true));

  Future<void> capture(IDCheckioParams params) async{
    String capture;
    try {
      _idCheckioResult = await IDCheckio.start(params);
      capture = 'OK !';
    } on PlatformException catch(e) {
      capture = 'An error happened during the capture : ${e.message}';
    }
    if (!mounted) return;
    setState(() {
      _capture = capture;
    });
  }
```

4. To start an online capture of a document, use the `startOnline()` method. You will receive the result in an `IdcheckioResult` object.
```java
  final IDCheckioParams paramsLiveness = IDCheckioParams(
      IDCheckioParamsBuilder()
            ..docType = DocumentType.LIVENESS
            ..orientation = IDCheckioOrientation.PORTRAIT
            ..confirmAbort = true
  );

  Future<void> capture(IDCheckioParams params, IDCheckioResult? result) async{
    String capture;
    try {
      _idCheckioResult = await IDCheckio.startOnline(params, result?.onlineContext);
      capture = 'OK !';
    } on PlatformException catch(e) {
      capture = 'An error happened during the capture : ${e.message}';
    }
    if (!mounted) return;
    setState(() {
      _capture = capture;
    });
  }
```

5. If you don't want to capture but just analyze a document, you can use the `analyze()` method. You will receive the result in an `IdcheckioResult` object.
```java  
Future<void> analyze(IDCheckioParams params, IDCheckioResult? result) async{
    String capture;
    try {
      ImagePicker imagePicker = ImagePicker();
      inal pickedFile = await (imagePicker.getImage(source: ImageSource.gallery));
      if (pickedFile != null) {
        result = await IDCheckio.analyze(
          params: params,
          side1Uri: pickedFile.path,
          side2uri: null,
          isOnline: true,
          onlineContext: result?.onlineContext);
      }
      capture = 'OK !';
    } on PlatformException catch(e) {
      capture = 'An error happened during the capture : ${e.message}';
    }
    if (!mounted) return;
    setState(() {
      _capture = capture;
    });
  }
```

You're now good to go! ✅  \
To learn more about those methods and their parameters, please refer to the official IDCheck.io Mobile SDK documentation.
