import 'dart:developer';

import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mazad/api/api_methods/post.dart';
import 'package:mazad/api/api_methods/put.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/api/send_and_resive_image_methods/decode.dart';
import 'package:mazad/variable/account_details.dart';
import 'package:mazad/variable/shared_preferences.dart';
import 'package:mazad/view/pages/enter_otp/enter_otp.dart';
import 'package:mazad/view/pages/layout/layout.dart';
import 'package:mazad/view/pages/send_reset_password_request/send_reset_password_request.dart';
import 'package:mazad/view/pages/sign_up/sign_up.dart';

import 'sign_in_model.dart';
export 'sign_in_model.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late SignInModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool sending = false;

  Future<void> signIn() async {
    setState(() {
      sending = true;
    });

    Map<String,dynamic> data = {
      "email":_model.textController1.text,
      "password":_model.textController2.text,
    };

    Map responseMap = await post(ApiPaths.signIn,data).onError((error, stackTrace) {
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

      id = responseMap['body']['data']['_id'];
      name = responseMap['body']['data']['name'];
      email = responseMap['body']['data']['email'];
      phone = responseMap['body']['data']['phone'];
      active = responseMap['body']['data']['active'];
      if(responseMap['body']['data']['profileImg'] != null) profileImg = decode(responseMap['body']['data']['profileImg']);

      if(mounted) {
        if(active){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Layout(),));
        }else {
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
        }
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
    _model = createModel(context, () => SignInModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController1Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'البريد الالكتروني فارغ';
      } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)){
        return 'البريد الالكتروني خطا';
      }
      return null;
    };
    _model.textController2Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' ') || value.length<8)
      {
        return 'كلمة المرور قصيرة';
      }
      return null;
    };
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
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 6),
                                child: Text(
                                  'اهلا بك في صفحة تسجيل الدخول',
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
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            child: TextFormField(
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode1,
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
                              validator: _model.textController1Validator
                                  .asValidator(context),
                              inputFormatters: [
                                /*FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'))*/
                                FilteringTextInputFormatter.deny(RegExp(r'[\u0600-\u06FF\u0750-\u077F]+'))
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.7,
                            child: TextFormField(
                              controller: _model.textController2,
                              focusNode: _model.textFieldFocusNode2,
                              obscureText: !_model.passwordVisibility,
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
                                  Icons.remove_red_eye,
                                ),
                                suffixIcon: InkWell(
                                  onTap: () => setState(
                                        () => _model.passwordVisibility =
                                    !_model.passwordVisibility,
                                  ),
                                  focusNode: FocusNode(skipTraversal: true),
                                  child: Icon(
                                    _model.passwordVisibility
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
                              validator: _model.textController2Validator
                                  .asValidator(context),
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: FFButtonWidget(
                            onPressed: () {
                              if(_model.formKey.currentState!.validate() && !sending) {
                                signIn();
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
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                              child: Text(
                                'هل نسيت كلمة المرور ؟',
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
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 58),
                          child: FFButtonWidget(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SendResetPasswordRequest(),));
                            },
                            text: 'نسيت كلمة المرور',
                            icon: const Icon(
                              Icons.password_rounded,
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
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: FFButtonWidget(
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp(),));
                            },
                            text: 'انشاء حساب',
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
