import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idcheckio/idcheckio.dart';
import 'package:idcheckio_flutter_sample/params.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _sdkActivated = false;
  IDCheckioResult? _captureResult;
  late ParamsListItem _selectedItem;
  late List<DropdownMenuItem<ParamsListItem>> _dropdownMenuItems;
  List<ParamsListItem> _dropdownItems = [
    ParamsListItem("ID Offline", paramsID, false),
    ParamsListItem("ID Online", paramsID, true),
    ParamsListItem("Liveness Online", paramsLiveness, true),
    ParamsListItem("French health card Online", paramsFrenchHealthCard, true),
    ParamsListItem("Selfie Online", paramsSelfie, true),
    ParamsListItem("Address proof Online", paramsAddressProof, true),
    ParamsListItem("Vehicle registration Online", paramsVehicleRegistration, true),
    ParamsListItem("Iban Online", paramsIban, true),
    ParamsListItem("ID Analyze", paramsIDAnalyze, true)..upload = true,
    ParamsListItem("Attachment", paramsAttachment, true)
  ];

  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value!;
  }

  Future<void> activateSDK() async {
    bool activationStatus = false;
    try {
      await IDCheckio.activate(
          licenceFilename: "license",
          environment: Environment.DEMO,
          disableAudioForLiveness: true,
          disableImeiForActivation: true,
          extractData: true);
      activationStatus = true;
    } on PlatformException catch (e) {
      activationStatus = false;
      debugPrint("Sdk activation failed : ${e.code} - ${e.message}");
    }
    if (!mounted) return;
    setState(() {
      _sdkActivated = activationStatus;
    });
  }

  Future<void> capture() async {
    IDCheckioResult? result;
    try {
      if (_selectedItem.upload) {
        // Analyze mode
        ImagePicker imagePicker = ImagePicker();
        PickedFile pickedFile = await (imagePicker.getImage(source: ImageSource.gallery) as FutureOr<PickedFile>);
        result = await IDCheckio.analyze(
            params: _selectedItem.params,
            side1Uri: pickedFile.path,
            side2uri: null,
            isOnline: _selectedItem.isOnline,
            onlineContext: _captureResult?.onlineContext);
      } else {
        // Capture mode
        if (_selectedItem.isOnline) {
          result = await IDCheckio.startOnline(_selectedItem.params, _captureResult?.onlineContext);
        } else {
          result = await IDCheckio.start(_selectedItem.params);
        }
      }
      debugPrint('ID Capture Successful : ${result.toJson()}', wrapWidth: 500);
    } on PlatformException catch (e) {
      debugPrint("An error happened during the capture : ${e.code} - ${e.message}");
    }
    if (!mounted) return;
    setState(() {
      _captureResult = result;
    });
  }

  List<DropdownMenuItem<ParamsListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ParamsListItem>> items = [];
    for (ParamsListItem listItem in listItems as Iterable<ParamsListItem>) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('IDCheck.io SDK Flutter Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_sdkActivated ? "SDK activated! 🎉" : "SDK not activated", style: TextStyle(fontSize: 24.0)),
              SizedBox(height: 60),
              DropdownButton(
                items: _dropdownMenuItems,
                value: _selectedItem,
                onChanged: (dynamic value) {
                  setState(() {
                    _selectedItem = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: new Text(_sdkActivated ? "SDK already activated" : "Activate SDK"),
                onPressed: _sdkActivated ? null : activateSDK,
              ),
              ElevatedButton(
                child: new Text(_sdkActivated ? "Capture Document" : "SDK not activated"),
                onPressed: _sdkActivated ? capture : null,
              ),
              SizedBox(height: 40),
              Text(
                  _captureResult != null
                      ? _captureResult!.document != null && _captureResult!.document is IdentityDocument
                          ? "Howdy ${(_captureResult!.document as IdentityDocument).fields[IdentityDocumentField.firstNames]!.value!.split(" ").first}"
                                  " "
                                  "${(_captureResult!.document as IdentityDocument).fields[IdentityDocumentField.lastNames]!.value}! 🤓"
                          : "Capture OK 👍"
                      : "Please first scan an ID",
                  style: TextStyle(fontSize: 20.0)),
            ],
          ),
        ),
      ),
    );
  }
}
