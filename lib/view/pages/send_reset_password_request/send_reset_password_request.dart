import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mazad/api/api_methods/post.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/view/pages/enter_otp/enter_otp.dart';

import 'send_reset_password_request_model.dart';
export 'send_reset_password_request_model.dart';

class SendResetPasswordRequest extends StatefulWidget {
  const SendResetPasswordRequest({super.key});

  @override
  State<SendResetPasswordRequest> createState() =>
      _SendResetPasswordRequestState();
}

class _SendResetPasswordRequestState
    extends State<SendResetPasswordRequest> {
  late SendResetPasswordRequestModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool sending = false;

  Future<void> sendResetPasswordRequest() async {
    setState(() {
      sending = true;
    });

    Map<String,dynamic> data = {
      "email":_model.textController.text,
    };

    Map responseMap = await post(ApiPaths.sendResetPasswordRequest,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });

    setState(() {
      sending = false;
    });

    if(responseMap['code']>=200 && responseMap['code']<300) {
      if(mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const EnterOTP(openedForResetPassword: true),));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              responseMap['body'].toString(),
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
    _model = createModel(context, () => SendResetPasswordRequestModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    _model.textControllerValidator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'البريد الالكتروني فارغ';
      } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)){
        return 'البريد الالكتروني خطا';
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
                    Center(
                      child: IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios,color: Colors.white),
                      ),
                    )
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
                                Container(
                                  width: MediaQuery.sizeOf(context).width * 0.7,
                                  alignment: const AlignmentDirectional(1.00, -1.00),
                                  child: Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(6, 6, 6, 36),
                                    child: Text(
                                      'استعادة كلمة المرور',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 18),
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.7,
                              child: TextFormField(
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
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
                                validator: _model.textControllerValidator
                                    .asValidator(context),
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(RegExp(r'[\u0600-\u06FF\u0750-\u077F]+'))
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                            child: FFButtonWidget(
                              onPressed: () {
                                if(_model.formKey.currentState!.validate() && !sending) {
                                  sendResetPasswordRequest();
                                }
                              },
                              text: sending?'':'ارسال رمز التحقق',
                              icon: sending?SizedBox(
                                  height: MediaQuery.sizeOf(context).height * 0.03,
                                  width: MediaQuery.sizeOf(context).height * 0.03,
                                  child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                              ):const Icon(
                                Icons.lock_open_rounded,
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
