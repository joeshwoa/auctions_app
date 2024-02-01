import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'enter_otp.dart' show EnterOTP;
import 'package:flutter/material.dart';

class EnterOTPModel extends FlutterFlowModel<EnterOTP> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  List<TextEditingController> controllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  String? Function(BuildContext, String?)? textController1Validator;
  String? Function(BuildContext, String?)? textController2Validator;
  String? Function(BuildContext, String?)? textController3Validator;
  String? Function(BuildContext, String?)? textController4Validator;
  String? Function(BuildContext, String?)? textController5Validator;
  String? Function(BuildContext, String?)? textController6Validator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    for(int i=0; i<controllers.length; i++) {
      controllers[i].dispose();
    }
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
