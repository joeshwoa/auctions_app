import 'dart:developer';
import 'dart:io';

import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mazad/api/api_methods/get.dart';
import 'package:mazad/api/api_methods/post.dart';
import 'package:mazad/api/api_methods/put.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/api/send_and_resive_image_methods/encode.dart';
import 'package:mazad/create_models/create_area_model.dart';
import 'package:mazad/create_models/create_city_model.dart';
import 'package:mazad/model/area_model.dart';
import 'package:mazad/model/city_model.dart';
import 'package:mazad/variable/shared_preferences.dart';
import 'package:mazad/view/pages/enter_otp/enter_otp.dart';
import 'package:mazad/view/pages/privacy/privacy.dart';
import 'package:mazad/view/pages/sign_in/sign_in.dart';

import 'sign_up_model.dart';
export 'sign_up_model.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key,});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  File? image;
  late SignUpModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

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

  Future<void> signUp() async {
    setState(() {
      sending = true;
    });

    Map<String,dynamic> data = {
      "name":_model.textController1.text,
      "email":_model.textController2.text,
      "phone":_model.textController3.text,
      "password":_model.textController4.text,
      "passwordConfirm":_model.textController5.text,
      if(image != null)"profileImg":await encode(image!),
      "area":_model.dropDownValueArea,
      "city":_model.dropDownValueCity
    };

    Map responseMap = await post(ApiPaths.signUp,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });

    setState(() {
      sending = false;
    });

    if(responseMap['code']>=200 && responseMap['code']<300) {
      sharedPreferences.setString('token', responseMap['body']['token']);

      Map<String,dynamic> data = {
        "token":sharedPreferences.getString('token'),
      };

      await put(ApiPaths.sendOTPToEmail,data).onError((error, stackTrace) {
        return {
          'code':0,
        'error':error
        };
      });

      if(mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EnterOTP(),));
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
    _model = createModel(context, () => SignUpModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

    _model.textController1Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'الاسم فارغ';
      }
      return null;
    };
    _model.textController2Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'البريد الالكتروني فارغ';
      } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)){
        return 'البريد الالكتروني خطا';
      }
      return null;
    };
    _model.textController3Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'رقم الجوال فارغ';
      }
      return null;
    };
    _model.textController4Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' ') || value.length<8)
      {
        return 'كلمة المرور قصيرة';
      }
      return null;
    };
    _model.textController5Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' ') || value.length<8)
      {
        return 'كلمة المرور قصيرة';
      } else if (value != _model.textController4.text) {
        return 'غير متطابقة';
      }
      return null;
    };

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
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          appBar: PreferredSize(
            preferredSize:
            Size.fromHeight(MediaQuery.sizeOf(context).height * 0.07),
            child: AppBar(
              backgroundColor: const Color(0xFF1C6166),
              automaticallyImplyLeading: false,
              actions: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.08,
                  width: MediaQuery.sizeOf(context).height * 0.08,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Opacity(
                          opacity: 0.2,
                          child: Container(
                            width: MediaQuery.sizeOf(context).height * 0.08,
                            height: MediaQuery.sizeOf(context).height * 0.08,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Opacity(
                          opacity: 0.2,
                          child: Container(
                            width: MediaQuery.sizeOf(context).height * 0.05,
                            height: MediaQuery.sizeOf(context).height * 0.05,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondaryBackground,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
              leading: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.08,
                width: MediaQuery.sizeOf(context).height * 0.08,
                child: Stack(
                  children: [
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Opacity(
                        opacity: 0.2,
                        child: Container(
                          width: MediaQuery.sizeOf(context).height * 0.08,
                          height: MediaQuery.sizeOf(context).height * 0.08,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.2,
                        child: Container(
                          width: MediaQuery.sizeOf(context).height * 0.05,
                          height: MediaQuery.sizeOf(context).height * 0.05,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              elevation: 2,
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                                child: Icon(
                                  Icons.person,
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  size: 24,
                                ),
                              ),
                              Text(
                                'انشاء حساب',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            height: MediaQuery.sizeOf(context).height * 0.2,
                            decoration: BoxDecoration(
                              color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF719C9F),
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'صورة الملف الشخصي',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 12,
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (image != null) {
                                        return Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              6, 6, 6, 6),
                                          child: Container(
                                            width: 70,
                                            height: 70,
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
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              6, 6, 6, 6),
                                          child: Container(
                                            width:
                                            MediaQuery.sizeOf(context).width *
                                                0.2,
                                            height:
                                            MediaQuery.sizeOf(context).width *
                                                0.2,
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
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FFButtonWidget(
                                        onPressed: () {
                                          _pickImage(ImageSource.camera);
                                        },
                                        text: 'الكاميرا',
                                        options: FFButtonOptions(
                                          height:
                                          MediaQuery.sizeOf(context).height *
                                              0.04,
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              24, 0, 24, 0),
                                          iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
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
                                      FFButtonWidget(
                                        onPressed: () {
                                          _pickImage(ImageSource.gallery);
                                        },
                                        text: 'المعرض',
                                        options: FFButtonOptions(
                                          height:
                                          MediaQuery.sizeOf(context).height *
                                              0.04,
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              24, 0, 24, 0),
                                          iconPadding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              0, 0, 0, 0),
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            child: TextFormField(
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode1,
                              autofillHints: const [AutofillHints.username],
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.next,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'الاسم المختصر',
                                labelStyle:
                                FlutterFlowTheme.of(context).labelMedium,
                                hintText: 'ادخل الاسم المختصر ',
                                hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.drive_file_rename_outline_rounded,
                                ),
                              ),
                              style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.end,
                              keyboardType: TextInputType.name,
                              validator: _model.textController1Validator
                                  .asValidator(context),
                              inputFormatters: [
                                /*FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z0-9]')),*/
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[\u0600-\u06FF\u0750-\u077F\u0041-\u007A\s]+'))
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            child: TextFormField(
                              controller: _model.textController2,
                              focusNode: _model.textFieldFocusNode2,
                              autofillHints: const [AutofillHints.email],
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.next,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'البريد الالكتروني',
                                labelStyle:
                                FlutterFlowTheme.of(context).labelMedium,
                                hintText: 'ادخل البريد الالكتروني ',
                                hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.alternate_email_rounded,
                                ),
                              ),
                              style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.end,
                              keyboardType: TextInputType.emailAddress,
                              validator: _model.textController2Validator
                                  .asValidator(context),
                              inputFormatters: [
                                /*FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'))*/
                                FilteringTextInputFormatter.deny(RegExp(r'[\u0600-\u06FF\u0750-\u077F]+'))
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            child: TextFormField(
                              controller: _model.textController3,
                              focusNode: _model.textFieldFocusNode3,
                              autofillHints: const [AutofillHints.telephoneNumber],
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.next,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: 'رقم الجوال',
                                labelStyle:
                                FlutterFlowTheme.of(context).labelMedium,
                                hintText: 'ادخل رقم الجوال ',
                                hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.phone_rounded,
                                ),
                              ),
                              style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.end,
                              keyboardType: TextInputType.phone,
                              validator: _model.textController3Validator
                                  .asValidator(context),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            child: TextFormField(
                              controller: _model.textController4,
                              focusNode: _model.textFieldFocusNode4,
                              obscureText: !_model.passwordVisibility1,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                labelStyle:
                                FlutterFlowTheme.of(context).labelMedium,
                                hintText: 'ادخل كلمة المرور ',
                                hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_rounded,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () => setState(
                                        () => _model.passwordVisibility1 =
                                    !_model.passwordVisibility1,
                                  ),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    _model.passwordVisibility1
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 22,
                                  ),
                                ),
                              ),
                              style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.end,
                              validator: _model.textController4Validator
                                  .asValidator(context),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),

                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            child: TextFormField(
                              controller: _model.textController5,
                              focusNode: _model.textFieldFocusNode5,
                              obscureText: !_model.passwordVisibility2,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                labelStyle:
                                FlutterFlowTheme.of(context).labelMedium,
                                hintText: 'اعد ادخل كلمة المرور ',
                                hintStyle: FlutterFlowTheme.of(context).labelMedium,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFF719C9F),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_rounded,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () => setState(
                                        () => _model.passwordVisibility2 =
                                    !_model.passwordVisibility2,
                                  ),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    _model.passwordVisibility2
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 22,
                                  ),
                                ),
                              ),
                              style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.end,
                              validator: _model.textController5Validator
                                  .asValidator(context),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),

                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          decoration: const BoxDecoration(
                            color: Color(0x00FFFFFF),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'قم باختيار اسم المنطقة و المدينة',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  ' : ',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'العنوان',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            decoration: const BoxDecoration(
                              color: Color(0x00FFFFFF),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: FFButtonWidget(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const Privacy(),));
                            },
                            text: 'معاينة سياسة  الخصوصية و الاستخدام',
                            icon: const Icon(
                              Icons.description,
                              size: 15,
                            ),
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 0.7,
                              height: MediaQuery.sizeOf(context).height * 0.05,
                              padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                              iconPadding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: const Color(0xFF1C6166),
                              textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.normal,
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
                        Container(
                          width: MediaQuery.sizeOf(context).width * 0.7,
                          decoration: const BoxDecoration(
                            color: Color(0x00FFFFFF),
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'اوافق علي سياية الخصوصية',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Theme(
                                  data: ThemeData(
                                    checkboxTheme: CheckboxThemeData(
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    unselectedWidgetColor: const Color(0xFF719C9F),
                                  ),
                                  child: Checkbox(
                                    value: _model.checkboxValue ??= false,
                                    onChanged: (newValue) async {
                                      setState(
                                              () => _model.checkboxValue = newValue!);
                                    },
                                    activeColor: const Color(0xFF1C6166),
                                    checkColor: FlutterFlowTheme.of(context).info,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: FFButtonWidget(
                            onPressed: () {
                              if(_model.formKey.currentState!.validate() && _model.checkboxValue! && !sending) {
                                signUp();
                              }
                            },
                            text: sending?'':'انشاء حساب',
                            icon: sending?SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.03,
                                width: MediaQuery.sizeOf(context).height * 0.03,
                                child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                            ):const Icon(
                              Icons.done_rounded,
                              size: 15,
                            ),
                            options: FFButtonOptions(
                              width: sending?MediaQuery.sizeOf(context).height * 0.05:MediaQuery.sizeOf(context).width * 0.7,
                              height: MediaQuery.sizeOf(context).height * 0.05,
                              padding: sending?const EdgeInsetsDirectional.fromSTEB(9, 0, 0, 0):const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                              iconPadding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: !(_model.checkboxValue! && !sending)||sending?Colors.grey:const Color(0xFF1C6166),
                              textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                          child: FFButtonWidget(
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignIn(),));
                            },
                            text: 'تسجيل دخول',
                            icon: const Icon(
                              Icons.done_rounded,
                              size: 15,
                            ),
                            options: FFButtonOptions(
                              width: MediaQuery.sizeOf(context).width * 0.7,
                              height: MediaQuery.sizeOf(context).height * 0.05,
                              padding: const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                              iconPadding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: const Color(0xFF1C6166),
                              textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Deny sequential numbers or letters
    if (_hasSequentialChars(newValue.text)) {
      // You can choose to handle or modify the value here
      // For example, you can replace the sequential characters with a different character
      return oldValue;
    }
    return newValue;
  }

  bool _hasSequentialChars(String value) {
    for (int i = 0; i < value.length - 2; i++) {
      if (value.codeUnitAt(i) + 1 == value.codeUnitAt(i + 1) &&
          value.codeUnitAt(i) + 2 == value.codeUnitAt(i + 2)) {
        return true;
      }
    }
    return false;
  }
}

