import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'addition_information_dialog_widget.dart'
    show AdditionInformationDialogWidget;
import 'package:flutter/material.dart';

class AdditionInformationDialogModel
    extends FlutterFlowModel<AdditionInformationDialogWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
