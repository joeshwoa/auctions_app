import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'create_auction_page.dart' show CreateAuctionPage;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CreateAuctionPageModel extends FlutterFlowModel<CreateAuctionPage> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  // State field(s) for DropDown widget.
  String? dropDownValueCategory;
  FormFieldController<String>? dropDownValueController1;
  DateTime? datePicked;
  // State field(s) for DropDown widget.
  String? dropDownValueSupCategory;
  String? dropDownValueShape;
  String? dropDownValueCarCategory;
  String? dropDownValueCarModel;
  String? dropDownValueBrand;

  String? dropDownValueCategoryID;
  String? dropDownValueSupCategoryID;
  String? dropDownValueShapeID;
  String? dropDownValueCarCategoryID;
  String? dropDownValueCarModelID;
  String? dropDownValueBrandID;

  FormFieldController<String>? dropDownValueController2;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;
  // State field(s) for Carousel widget.
  CarouselController? carouselController;

  int carouselCurrentIndex = 1;

  String type = 'مستعملة';
  String gaz = 'بنزين';
  bool auto = true;
  bool sell = true;
  int walkFrom = 0;
  int walkTo = 0;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    textFieldFocusNode4?.dispose();
    textController4?.dispose();
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
