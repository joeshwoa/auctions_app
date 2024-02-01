import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'my_points.dart' show MyPoints;
import 'package:flutter/material.dart';

class MyPointsModel extends FlutterFlowModel<MyPoints> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
