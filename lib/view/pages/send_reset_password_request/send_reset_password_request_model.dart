import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'send_reset_password_request.dart'
    show SendResetPasswordRequest;
import 'package:flutter/material.dart';

class SendResetPasswordRequestModel
    extends FlutterFlowModel<SendResetPasswordRequest> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
