import 'dart:developer';
import 'dart:io';

import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mazad/api/api_methods/get.dart';
import 'package:mazad/api/api_methods/put.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/api/send_and_resive_image_methods/encode.dart';
import 'package:mazad/create_models/create_area_model.dart';
import 'package:mazad/create_models/create_city_model.dart';
import 'package:mazad/model/area_model.dart';
import 'package:mazad/model/city_model.dart';

import 'personal_information_model.dart';
export 'personal_information_model.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() =>
      _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  late PersonalInformationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  File? image;

  final List<String> areaValues = [];
  List<String> cityValues = [];

  final List<Area> areaList = [];
  List<City> cityList = [];

  bool loadAreas = false;
  bool loadCities = false;

  bool sending = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source,imageQuality: 20);

    setState(() {
      if (pickedImage != null) {
        image = File(pickedImage.path);
      } else {
        image = null;
      }
    });
  }

  void getAreaCompoBoxValues() {
    setState(() {
      loadAreas = true;
    });

    get(ApiPaths.getAreas).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      if(value['code']>=200 && value['code']<300){
        for(int i=0; i<value['body']['data'].length; i++) {
          areaList.add(createArea(value['body']['data'][i]));
          areaValues.add(areaList[i].name);
        }

        if(areaList.isNotEmpty) {
          _model.dropDownValueArea = areaValues[0];
          _model.dropDownValueAreaID = areaList[0].id;
        }

        setState(() {
          loadAreas = false;
        });

        getCityCompoBoxValues();
      } else {
        getAreaCompoBoxValues();
      }
    });
  }

  void getCityCompoBoxValues() {
    setState(() {
      loadCities = true;
    });

    get(ApiPaths.getCities+_model.dropDownValueAreaID!).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      if(value['code']>=200 && value['code']<300){
        cityValues.clear();
        cityList.clear();
        for(int i=0; i<value['body']['data'].length; i++) {
          cityList.add(createCity(value['body']['data'][i]));
          cityValues.add(cityList[i].name);
        }

        if(cityList.isNotEmpty) {
          _model.dropDownValueCity = cityValues[0];
          _model.dropDownValueCityID = cityList[0].id;
        }

        setState(() {
          loadCities = false;
        });
      } else {
        getCityCompoBoxValues();
      }
    });
  }

  Future<void> saveAreaAndCity() async {
    setState(() {
      sending = true;
    });

    Map<String,dynamic> data = {
      "area":_model.dropDownValueArea,
      "city":_model.dropDownValueCity
    };

    Map responseMap = await put(ApiPaths.updateProfile,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });

    setState(() {
      sending = false;
    });

    if(responseMap['code']>=200 && responseMap['code']<300) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              'تم تحديث العنوان',
              style: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),),
            backgroundColor: const Color(0xff1c6166),
            showCloseIcon: true,
          ),
        );
      }
    } else {
      if (mounted) {
        log(responseMap.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              responseMap.toString(),
              style: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),),
            backgroundColor: const Color(0xff1c6166),
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  Future<void> saveImage() async {
    setState(() {
      sending = true;
    });

    Map<String,dynamic> data = {
      if(image != null)"profileImg":await encode(image!),
      if(image == null)"profileImg":'',
    };

    Map responseMap = await put(ApiPaths.updateProfile,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });

    setState(() {
      sending = false;
    });

    if(responseMap['code']>=200 && responseMap['code']<300) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              'تم تحديث الصورة',
              style: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),),
            backgroundColor: const Color(0xff1c6166),
            showCloseIcon: true,
          ),
        );
      }
    } else {
      if (mounted) {
        log(responseMap.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              responseMap.toString(),
              style: FlutterFlowTheme.of(context)
                  .bodyMedium
                  .override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),),
            backgroundColor: const Color(0xff1c6166),
            showCloseIcon: true,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PersonalInformationModel());

    getAreaCompoBoxValues();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isiOS) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
          systemStatusBarContrastEnforced: true,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C6166),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: const Color(0x00FFFFFF),
            borderRadius: 20,
            borderWidth: 1,
            buttonSize: 40,
            fillColor: const Color(0x00FFFFFF),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Align(
            alignment: const AlignmentDirectional(1.00, 0.00),
            child: Text(
              'المعلومات الشخصية',
              textAlign: TextAlign.end,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            FlutterFlowIconButton(
              borderColor: const Color(0x00FFFFFF),
              borderRadius: 20,
              borderWidth: 1,
              buttonSize: 40,
              fillColor: const Color(0x00FFFFFF),
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                print('IconButton pressed ...');
              },
            ),
          ],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: const AlignmentDirectional(0.00, 0.00),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.85,
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF1C6166),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'صورة الملف الشخصي',
                          style: FlutterFlowTheme.of(context).bodyMedium,
                        ),
                        Builder(
                          builder: (context) {
                            if (image != null) {
                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 0.25,
                                  height: MediaQuery.sizeOf(context).width * 0.25,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 0.25,
                                  height: MediaQuery.sizeOf(context).width * 0.25,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/images/man.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FFButtonWidget(
                                onPressed: () {
                                  _pickImage(ImageSource.camera);
                                },
                                text: 'الكاميرا',
                                options: FFButtonOptions(
                                  height:
                                  MediaQuery.sizeOf(context).height * 0.04,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      24, 0, 24, 0),
                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 0),
                                  color: const Color(0xFF1C6166),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                  ),
                                  elevation: 3,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              FFButtonWidget(
                                onPressed: () {
                                  _pickImage(ImageSource.gallery);
                                },
                                text: 'المعرض',
                                options: FFButtonOptions(
                                  height:
                                  MediaQuery.sizeOf(context).height * 0.04,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      24, 0, 24, 0),
                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, 0),
                                  color: const Color(0xFF1C6166),
                                  textStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                  ),
                                  elevation: 3,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(1.00, 0.00),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                            child: FFButtonWidget(
                              onPressed: () {
                                if(!sending) {
                                  saveImage();
                                }
                              },
                              text: sending?'':'حفظ صورة الملف الشخصي',
                              icon: sending?SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.03,
                                  width: MediaQuery.sizeOf(context).height * 0.03,
                                  child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                              ):null,
                              options: FFButtonOptions(
                                height: MediaQuery.sizeOf(context).height * 0.05,
                                width: sending?MediaQuery.sizeOf(context).height * 0.05:MediaQuery.sizeOf(context).width * 0.5,
                                padding: sending?const EdgeInsetsDirectional.fromSTEB(9, 0, 0, 0):const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                iconPadding:
                                const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: const Color(0xFF1C6166),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                elevation: 3,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.00, 0.00),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.85,
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF1C6166),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'قم باختيار اسم المنطقة و المدينة',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                              Padding(
                                padding:
                                const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                                child: Text(
                                  ':',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsetsDirectional.fromSTEB(2, 0, 0, 0),
                                child: Text(
                                  'العنوان',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              loadCities||loadAreas?SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.3,
                                height: MediaQuery.sizeOf(context).height * 0.06,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xff1c6166),
                                  ),
                                ),
                              ):FlutterFlowDropDown(
                                options: cityValues,
                                onChanged: (val) {
                                  setState(() {
                                    _model.dropDownValueCity = val;
                                    _model.dropDownValueCityID = cityList[cityValues.indexOf(val!)].id;
                                  });
                                },
                                width: MediaQuery.sizeOf(context).width * 0.3,
                                height: MediaQuery.sizeOf(context).height * 0.06,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 10,
                                ),
                                hintText: 'المدينة',
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color:
                                  FlutterFlowTheme.of(context).secondaryText,
                                  size: 20,
                                ),
                                fillColor: const Color(0xFFFFFFFF),
                                elevation: 2,
                                borderColor: const Color(0xFF719C9F),
                                borderWidth: 2,
                                borderRadius: 8,
                                margin:
                                const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                                hidesUnderline: true,
                              ),
                              loadAreas?SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.3,
                                height: MediaQuery.sizeOf(context).height * 0.06,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xff1c6166),
                                  ),
                                ),
                              ):FlutterFlowDropDown(
                                options: areaValues,
                                onChanged: (val) {
                                  setState(() {
                                    _model.dropDownValueArea = val;
                                    _model.dropDownValueAreaID =
                                        areaList[areaValues.indexOf(val!)].id;
                                  });
                                  getCityCompoBoxValues();
                                },
                                width: MediaQuery.sizeOf(context).width * 0.3,
                                height: MediaQuery.sizeOf(context).height * 0.06,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 10,
                                ),
                                hintText: 'المنطقة',
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color:
                                  FlutterFlowTheme.of(context).secondaryText,
                                  size: 20,
                                ),
                                fillColor: const Color(0xFFFFFFFF),
                                elevation: 2,
                                borderColor: const Color(0xFF719C9F),
                                borderWidth: 2,
                                borderRadius: 8,
                                margin:
                                const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                                hidesUnderline: true,
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(1.00, 0.00),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                            child: FFButtonWidget(
                              onPressed: () {
                                if(!sending) {
                                  saveImage();
                                }
                              },
                              text: sending?'':'حفظ تعديلات العنوان',
                              icon: sending?SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.03,
                                  width: MediaQuery.sizeOf(context).height * 0.03,
                                  child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                              ):null,
                              options: FFButtonOptions(
                                height: MediaQuery.sizeOf(context).height * 0.05,
                                width: sending?MediaQuery.sizeOf(context).height * 0.05:MediaQuery.sizeOf(context).width * 0.5,
                                padding: sending?const EdgeInsetsDirectional.fromSTEB(9, 0, 0, 0):const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                iconPadding:
                                const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: const Color(0xFF1C6166),
                                textStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                elevation: 3,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
