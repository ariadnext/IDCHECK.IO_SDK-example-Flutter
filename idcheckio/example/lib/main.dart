import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:idcheckio/idcheckio.dart';
import 'package:idcheckio/idcheckio_api.dart';
import 'package:image_picker/image_picker.dart';
import 'params.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _activationToken = "Set your token here.";
  final _idcheckioPlugin = IDCheckio();
  bool _sdkActivated = false;
  IDCheckioResult? _captureResult;
  late ParamsListItem _selectedItem;
  String _ipsFolderUid = "";
  late Function() _ipsListener;
  late List<DropdownMenuItem<ParamsListItem>> _dropdownMenuItems;
  TextEditingController ipsController = new TextEditingController();
  List<ParamsListItem> _dropdownItems = [
    ParamsListItem("ID Online", paramsIDOnline, true),
    ParamsListItem("Liveness Online", paramsLiveness, true),
    ParamsListItem("Start Ips", null, true)..isIps = true,
    ParamsListItem("ID Offline", paramsIDOffline, false),
    ParamsListItem("French health card Online", paramsFrenchHealthCard, true),
    ParamsListItem("Selfie Online", paramsSelfie, true),
    ParamsListItem("Address proof Online", paramsAddressProof, true),
    ParamsListItem("Vehicle registration Online", paramsVehicleRegistration, true),
    ParamsListItem("Iban Online", paramsIban, true),
    ParamsListItem("ID Analyze", paramsIDAnalyze, true)..upload = true,
    ParamsListItem("Attachment", paramsAttachment, true)
  ];

  void listener() {
    setState(() {
      _ipsFolderUid = ipsController.text;
    });
  }

  @override
  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value!;
    _ipsListener = listener;
    ipsController.addListener(_ipsListener);
  }

  void dispose() {
    ipsController.removeListener(_ipsListener);
    super.dispose();
  }

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

  Future<void> capture() async {
    IDCheckioResult? result;
    try {
      if (_selectedItem.upload) {
        // Analyze mode
        ImagePicker imagePicker = ImagePicker();
        final pickedFile = await (imagePicker.pickImage(source: ImageSource.gallery));
        if (pickedFile != null) {
          result = await _idcheckioPlugin.analyze(
              params: _selectedItem.params!,
              side1Uri: pickedFile.path,
              side2uri: null,
              isOnline: _selectedItem.isOnline,
              onlineContext: _captureResult?.onlineContext);
        }
      } else {
        // Capture mode
        if (_selectedItem.isOnline) {
          result = await _idcheckioPlugin.startOnline(_selectedItem.params!, _captureResult?.onlineContext);
        } else {
          result = await _idcheckioPlugin.start(_selectedItem.params!);
        }
      }
      debugPrint('ID Capture Successful : ${result!.toJson()}', wrapWidth: 500);
    } on PlatformException catch (e) {
      ErrorMsg errorMsg = ErrorMsg.fromJson(jsonDecode(e.message!));
      debugPrint("An error happened during the capture : ${errorMsg.cause} - ${errorMsg.message} - ${errorMsg.subCause}");
    }
    if (!mounted) return;
    setState(() {
      _captureResult = result;
    });
  }

  Future<void> startIps() async {
    IDCheckioResult? result;
    try {
      result = await _idcheckioPlugin.startIps(ipsController.text);
    } on PlatformException catch (e) {
      ErrorMsg errorMsg = ErrorMsg.fromJson(jsonDecode(e.message!));
      debugPrint("An error happened during the ips session : ${errorMsg.cause} - ${errorMsg.message} - ${errorMsg.subCause}");
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
              Text(
                  getTitle(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0)
              ),
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
              Column(
                children: buildChildren(),
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

  String getTitle() {
    String title;
    if(_sdkActivated && _selectedItem.isIps && _ipsFolderUid.isEmpty) {
      title = "You need to provide a folder uid to start an ips session.";
    } else if(_sdkActivated ) {
      title = "SDK activated! 🎉";
    } else {
      title = "SDK not activated";
    }
    return title;
  }

  List<Widget> buildChildren() {
    List<Widget> builder = [];
    if(_selectedItem.isIps){
      builder.add(
          Padding(
            child: TextField(
              controller: ipsController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your ips folder uid.',
              ),
            ),
            padding: EdgeInsets.only(left: 32.0, right: 32.0),
          )
      );
    }
    String buttonText;
    Function()? onClick;
    if(_sdkActivated && _selectedItem.isIps) {
      buttonText = "Start ips session";
      onClick = _ipsFolderUid.isEmpty ? null : startIps;
    } else if(_sdkActivated) {
      buttonText = "Capture Document";
      onClick = capture;
    } else {
      buttonText = "SDK not activated";
      onClick = null;
    }
    builder.add(
        ElevatedButton(
          child: new Text(buttonText),
          onPressed: onClick,
        )
    );
    return builder;
  }
}
