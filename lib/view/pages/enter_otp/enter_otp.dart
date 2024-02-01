import 'dart:developer';

import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mazad/api/api_methods/put.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/variable/shared_preferences.dart';
import 'package:mazad/view/pages/reset_password/reset_password.dart';
import 'package:mazad/view/pages/sign_in/sign_in.dart';

import 'enter_otp_model.dart';
export 'enter_otp_model.dart';

class EnterOTP extends StatefulWidget {
  const EnterOTP({super.key,this.openedForResetPassword = false});
  final bool openedForResetPassword;

  @override
  State<EnterOTP> createState() => _EnterOTPState();
}

class _EnterOTPState extends State<EnterOTP> {
  late EnterOTPModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool sending = false;

  Future<bool> checkOTP() async {
    setState(() {
      sending = true;
    });

    Map<String,dynamic> data = {
      "otp":_model.controllers[0].text+_model.controllers[1].text+_model.controllers[2].text+_model.controllers[3].text+_model.controllers[4].text+_model.controllers[5].text,
      "token":sharedPreferences.getString('token'),
    };

    Map responseMap = await put(ApiPaths.checkOTP,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });

    setState(() {
      sending = false;
    });

    if (responseMap['code']>=200 && responseMap['code']<300) {
      return true;
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
              ),
            ),),
            backgroundColor: const Color(0xff1c6166),
            showCloseIcon: true,
          ),
        );
      }
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EnterOTPModel());

    for(int i=0; i<_model.controllers.length; i++) {
      _model.controllers[i] = TextEditingController();
    }

    _model.textController1Validator ??= (context,value){
      if(value == null || value.isEmpty)
      {
        return 'فارغ';
      }
      return null;
    };
    _model.textController2Validator ??= (context,value){
      if(value == null || value.isEmpty)
      {
        return 'فارغ';
      }
      return null;
    };
    _model.textController3Validator ??= (context,value){
      if(value == null || value.isEmpty)
      {
        return 'فارغ';
      }
      return null;
    };
    _model.textController4Validator ??= (context,value){
      if(value == null || value.isEmpty)
      {
        return 'فارغ';
      }
      return null;
    };
    _model.textController5Validator ??= (context,value){
      if(value == null || value.isEmpty)
      {
        return 'فارغ';
      }
      return null;
    };
    _model.textController6Validator ??= (context,value){
      if(value == null || value.isEmpty)
      {
        return 'فارغ';
      }
      return null;
    };

    _model.textFieldFocusNode ??= FocusNode();
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
          body: SafeArea(
            top: true,
            child: Center(
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
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 36),
                                  child: Text(
                                    'ادخال الرمز المرسل علي البريد الالكتروني',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 18),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < 6; i++)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: TextFormField(
                                          controller: _model.controllers[i],
                                          textCapitalization: TextCapitalization.none,
                                          textInputAction: TextInputAction.none,
                                          obscureText: false,
                                          maxLength: 1,
                                          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                                            return ;
                                          },
                                          maxLengthEnforcement: MaxLengthEnforcement.none,
                                          decoration: InputDecoration(
                                              labelStyle: FlutterFlowTheme.of(context).labelMedium,
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
                                            ),
                                          onChanged: (text) {
                                            if (text.length == 1) {
                                              // Move focus to the next TextFormField
                                              if (i < 5) {
                                                FocusScope.of(context).nextFocus();
                                              } else {
                                                // If this is the last TextFormField, hide the keyboard
                                                FocusScope.of(context).unfocus();
                                              }
                                            } else {
                                              if (i > 0) {
                                                FocusScope.of(context).previousFocus();
                                              } else {
                                                // If this is the last TextFormField, hide the keyboard
                                                FocusScope.of(context).unfocus();
                                              }
                                            }
                                          },
                                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                            fontFamily: 'Readex Pro',
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.end,
                                          keyboardType: TextInputType.phone,
                                          validator: _model.textController2Validator
                                              .asValidator(context),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                            child: FFButtonWidget(
                              onPressed: () async {
                                if(_model.formKey.currentState!.validate() && !widget.openedForResetPassword && await checkOTP() && !sending) {
                                  if(mounted) {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignIn(),));
                                  }
                                } else if(_model.formKey.currentState!.validate() && widget.openedForResetPassword && await checkOTP() && !sending) {
                                  if(mounted) {
                                    while(Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ResetPassword(),));
                                  }
                                }
                              },
                              text: sending?'':'تسجيل دخول',
                              icon: sending?SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.03,
                                  width: MediaQuery.sizeOf(context).height * 0.03,
                                  child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                              ):const Icon(
                                Icons.person_rounded,
                                size: 15,
                              ),
                              options: FFButtonOptions(
                                width: sending?MediaQuery.sizeOf(context).height * 0.05:MediaQuery.sizeOf(context).width * 0.7,
                                height: MediaQuery.sizeOf(context).height * 0.05,
                                padding: sending?const EdgeInsetsDirectional.fromSTEB(9, 0, 0, 0):const EdgeInsetsDirectional.fromSTEB(14, 0, 14, 0),
                                iconPadding:
                                const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                color: sending?Colors.grey:const Color(0xFF1C6166),
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
      ),
    );
  }
}
