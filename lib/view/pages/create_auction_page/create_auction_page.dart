import 'dart:developer';
import 'dart:io';

import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mazad/api/api_methods/get.dart';
import 'package:mazad/api/api_methods/post.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/api/send_and_resive_image_methods/encode.dart';
import 'package:mazad/create_models/create_brand_model.dart';
import 'package:mazad/create_models/create_car_category_model.dart';
import 'package:mazad/create_models/create_category_model.dart';
import 'package:mazad/create_models/create_shape_model.dart';
import 'package:mazad/create_models/create_sup_category_model.dart';
import 'package:mazad/create_models/create_model_model.dart';
import 'package:mazad/model/brand_model.dart';
import 'package:mazad/model/car_category_model.dart';
import 'package:mazad/model/category_model.dart';
import 'package:mazad/model/car_model_model.dart';
import 'package:mazad/model/shape_model.dart';
import 'package:mazad/model/sup_category_model.dart';
import 'package:mazad/variable/account_details.dart';
import 'package:mazad/view/componants/addition_information_dialog/addition_information_dialog_widget.dart';

import 'create_auction_page_model.dart';
export 'create_auction_page_model.dart';

class CreateAuctionPage extends StatefulWidget {
  const CreateAuctionPage({super.key});

  @override
  State<CreateAuctionPage> createState() =>
      _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  late CreateAuctionPageModel _model;

  bool carAuctions = false;
  bool cancelOptions = false;

  List<File?> images = [null, null, null, null, null];
  int numberOfImages = 0;

  final List<String> categoriesValues = [];
  List<String> supCategoriesValues = [];

  final List<String> shapeValues = [];
  List<String> carCategoriesValues = [];
  List<String> brandValues = [];
  List<String> carModelValues = [];

  final List<Category> categoriesList = [];
  List<SupCategory> supCategoriesList = [];

  final List<Shape> shapeList = [];
  final List<CarCategory> carCategoriesList = [];
  List<Brand> brandList = [];
  final List<CarModel> carModelList = [];

  bool loadCategories = false;
  bool loadSupCategories = false;

  bool loadShape = false;
  bool loadCarCategories = false;
  bool loadBrand = false;
  bool loadCarModel = false;

  bool sending = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source,imageQuality: 20);

    setState(() {
      if (pickedImage != null) {
        images[numberOfImages] = File(pickedImage.path);
        numberOfImages+=1;
      } else {
        images[numberOfImages] = null;
      }
    });
  }

  void removeImage(int index) {
    for(int i=index; i<images.length-1; i++) {
      images[i] = images[i+1];
    }
    images[4] = null;
    setState(() {
      numberOfImages -= 1;
    });
  }

  void getCategoriesCompoBoxValues() {
    if(mounted) {
      setState(() {
        loadCategories = true;
      });
    }

    get(ApiPaths.getCategories).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      log(value.toString());
      if(value['code']>=200 && value['code']<300){
        if(value['body'] != null) {
          for(int i=0; i<value['body']['data'].length; i++) {
            categoriesList.add(createCategory(value['body']['data'][i]));
            categoriesValues.add(categoriesList[i].name);
          }
        }

        if(categoriesList.isNotEmpty) {
          _model.dropDownValueCategory = categoriesValues[0];
          _model.dropDownValueCategoryID = categoriesList[0].id;
        }

        if(mounted) {
          setState(() {
            loadCategories = false;
          });
        }

        getSupCategoriesCompoBoxValues();
      } else {
        getCategoriesCompoBoxValues();
      }
    });
  }

  void getSupCategoriesCompoBoxValues() {
    if(mounted) {
      setState(() {
        loadSupCategories = true;
      });
    }


    get(ApiPaths.getSupCategories+_model.dropDownValueCategoryID!).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      log(value.toString());
      if(value['code']>=200 && value['code']<300){
        supCategoriesValues.clear();
        supCategoriesList.clear();
        if(value['body'] != null) {
          for(int i=0; i<value['body']['data'].length; i++) {
            supCategoriesList.add(createSupCategory(value['body']['data'][i]));
            supCategoriesValues.add(supCategoriesList[i].name);
          }
        }

        if(supCategoriesValues.isNotEmpty) {
          _model.dropDownValueCategory = supCategoriesValues[0];
          _model.dropDownValueCategoryID = supCategoriesList[0].id;
        }

        if(mounted) {
          setState(() {
            loadSupCategories = false;
          });
        }
      } else {
        getSupCategoriesCompoBoxValues();
      }
    });
  }

  void getShapeCompoBoxValues() {
    if(mounted) {
      setState(() {
        loadShape = true;
      });
    }

    get(ApiPaths.getShape).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      log(value.toString());
      if(value['code']>=200 && value['code']<300){
        if(value['body'] != null) {
          for(int i=0; i<value['body']['data'].length; i++) {
            shapeList.add(createShape(value['body']['data'][i]));
            shapeValues.add(shapeList[i].name);
          }
        }

        if(shapeList.isNotEmpty) {
          _model.dropDownValueShape = shapeValues[0];
          _model.dropDownValueShapeID = shapeList[0].id;
        }

        if(mounted) {
          setState(() {
            loadShape = false;
          });
        }

        getCarModelCompoBoxValues();
      } else {
        getShapeCompoBoxValues();
      }
    });
  }

  void getCarCategoriesCompoBoxValues() {
    if(mounted) {
      setState(() {
        loadCarCategories = true;
      });
    }

    get(ApiPaths.getCarCategories).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      log(value.toString());
      if(value['body'] != null) {
        if(value['code']>=200 && value['code']<300){
          for(int i=0; i<value['body']['data'].length; i++) {
            carCategoriesList.add(createCarCategory(value['body']['data'][i]));
            carCategoriesValues.add(carCategoriesList[i].name);
          }

          if(carCategoriesList.isNotEmpty) {
            _model.dropDownValueCarCategory = carCategoriesValues[0];
            _model.dropDownValueCarCategoryID = carCategoriesList[0].id;
          }

          if(mounted) {
            setState(() {
              loadCarCategories = false;
            });
          }

          getBrandCompoBoxValues();
        } else {
          getCarCategoriesCompoBoxValues();
        }
      }
    });
  }

  void getBrandCompoBoxValues() {
    if(mounted) {
      setState(() {
        loadBrand = true;
      });
    }

    get(ApiPaths.getBrand+_model.dropDownValueCarCategoryID!).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      log(value.toString());
      if(value['code']>=200 && value['code']<300){
        brandValues.clear();
        brandList.clear();
        if(value['body'] != null) {
          for(int i=0; i<value['body']['data'].length; i++) {
            brandList.add(createBrand(value['body']['data'][i]));
            brandValues.add(brandList[i].name);
          }
        }

        if(brandList.isNotEmpty) {
          _model.dropDownValueBrand = brandValues[0];
          _model.dropDownValueBrandID = brandList[0].id;
        }

        if(mounted) {
          setState(() {
            loadBrand = false;
          });
        }
      } else {
        getBrandCompoBoxValues();
      }
    });
  }

  void getCarModelCompoBoxValues() {
    if(mounted) {
      setState(() {
        loadCarModel = true;
      });
    }

    get(ApiPaths.getCarModel).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      log(value.toString());
      if(value['code']>=200 && value['code']<300){
        if(value['body'] != null) {
          for(int i=0; i<value['body']['data'].length; i++) {
            carModelList.add(createCarModel(value['body']['data'][i]));
            carModelValues.add(carModelList[i].year);
          }
        }

        if(carModelList.isNotEmpty) {
          _model.dropDownValueCarModel = carModelValues[0];
          _model.dropDownValueCarModelID = carModelList[0].id;
        }

        if(mounted) {
          setState(() {
            loadCarModel = false;
          });
        }

        getCarCategoriesCompoBoxValues();
      } else {
        getCarModelCompoBoxValues();
      }
    });
  }

  Future<void> createAuction() async {
    if(mounted) {
      setState(() {
        sending = true;
      });
    }

    final List<String> encodedImages = [];

    for(int i = 1; i<numberOfImages ; i++) {
      encodedImages.add(await encode(images[i]!));
    }

    Map<String,dynamic> data = {
      "title":_model.textController3.text,
      "description":_model.textController4.text,
      "price":double.parse(_model.textController2.text),
      "numberOfDays":int.parse(_model.textController1.text),
      "time":_model.datePicked.toString(),
      "user":id,
      "imageCover":await encode(images[0]!),
      "images":encodedImages,
      if(!carAuctions)"category":_model.dropDownValueCategoryID,
      if(!carAuctions)"subCategory":_model.dropDownValueSupCategoryID,
      "isCar":carAuctions,
      if(carAuctions)"carBrand":_model.dropDownValueCarCategoryID,
      if(carAuctions)"carSubBrand":_model.dropDownValueBrandID,
      if(carAuctions)"shape":_model.dropDownValueShapeID,
      if(carAuctions)"model":_model.dropDownValueCarModelID,
      if(carAuctions)"type" : _model.type,
      if(carAuctions)"gaz" : _model.gaz,
      if(carAuctions)"auto" : _model.auto,
      if(carAuctions)"sell" : _model.sell,
      if(carAuctions)"walkFrom" : _model.walkFrom,
      if(carAuctions)"walkTo" : _model.walkTo,
      "return" : cancelOptions
    };

    log(data.toString());

    Map responseMap = await post(ApiPaths.createAuction,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });

    if(mounted) {
      setState(() {
        sending = false;
      });
    }

    if(responseMap['code']>=200 && responseMap['code']<300) {
      _model.textController3!.clear();
      _model.textController4!.clear();
      _model.textController2!.clear();
      _model.textController1!.clear();
      _model.datePicked = getCurrentTimestamp;
      for(int i=0; i<images.length; i++) {
        images[i] = null;
      }
      numberOfImages = 0;
      if(carAuctions) {
        setState(() {
          _model.dropDownValueShapeID = shapeList[0].id;
          _model.dropDownValueCarModelID = carModelList[0].id;
          _model.dropDownValueCarCategoryID = carCategoriesList[0].id;
        });
        getBrandCompoBoxValues();
      } else {
        setState(() {
          _model.dropDownValueCategoryID = categoriesList[0].id;
        });
        getSupCategoriesCompoBoxValues();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              'تم نشر المزاد',
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
    _model = createModel(context, () => CreateAuctionPageModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController1Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'عدد الايام فارغة';
      }
      return null;
    };
    _model.textController2Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'السعر فارغ';
      }
      return null;
    };
    _model.textController3Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'الاسم فارغ';
      }
      return null;
    };
    _model.textController4Validator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'العنوان فارغ';
      }
      return null;
    };

    _model.datePicked = getCurrentTimestamp;

    if(carAuctions) {
      getShapeCompoBoxValues();
      getCarCategoriesCompoBoxValues();
      getCarModelCompoBoxValues();
    } else {
      getCategoriesCompoBoxValues();
    }
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
      child: SafeArea(
        top: true,
        child: Form(
          key: _model.formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      height: MediaQuery.sizeOf(context).height * 0.06,
                      decoration: BoxDecoration(
                        color:
                        FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF1C6166),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          MaterialButton(
                            onPressed: (){
                              setState(() {
                                carAuctions = true;
                              });

                              loadCategories = false;
                              loadSupCategories = false;

                              shapeValues.clear();
                              shapeList.clear();
                              carCategoriesValues.clear();
                              carCategoriesList.clear();
                              carModelValues.clear();
                              carModelList.clear();

                              getShapeCompoBoxValues();

                            },
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.4-2,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              decoration: carAuctions?BoxDecoration(
                                color: const Color(0xFF1C6166),
                                borderRadius: BorderRadius.circular(8),
                              ):BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Text(
                                  'مزادات سيارات',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color: carAuctions?Colors.white:const Color(0xFF1C6166),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: (){
                              setState(() {
                                carAuctions = false;
                              });

                              loadShape = false;
                              loadCarModel = false;
                              loadBrand = false;
                              loadCarModel = false;

                              categoriesValues.clear();
                              categoriesList.clear();

                              getCategoriesCompoBoxValues();
                            },
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.4-2,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              decoration: !carAuctions?BoxDecoration(
                                color: const Color(0xFF1C6166),
                                borderRadius: BorderRadius.circular(8),
                              ):BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Text(
                                  'مزادات متنوعة',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color: !carAuctions?Colors.white:const Color(0xFF1C6166),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      carAuctions?Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            loadCarModel?SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xff1c6166),
                                ),
                              ),
                            ):FlutterFlowDropDown(
                              options: carModelValues,
                              onChanged: (val) {
                                setState(() {
                                  _model.dropDownValueCarModel = val;
                                  _model.dropDownValueCarModelID = carModelList[carModelValues.indexOf(val!)].id;
                                });
                              },
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height:
                              MediaQuery.sizeOf(context).height * 0.06,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 10,
                              ),
                              hintText: 'الموديل',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                                size: 20,
                              ),
                              fillColor: const Color(0xFFFFFFFF),
                              elevation: 2,
                              borderColor: const Color(0xFF719C9F),
                              borderWidth: 2,
                              borderRadius: 8,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12, 4, 12, 4),
                              hidesUnderline: true,
                            ),
                            loadCarCategories||loadBrand?SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xff1c6166),
                                ),
                              ),
                            ):brandList.isEmpty?SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                            ):FlutterFlowDropDown(
                              options: brandValues,
                              onChanged: (val) {
                                setState(() {
                                  _model.dropDownValueBrand = val;
                                  _model.dropDownValueBrandID = brandList[brandValues.indexOf(val!)].id;
                                });
                              },
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height:
                              MediaQuery.sizeOf(context).height * 0.06,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 10,
                              ),
                              hintText: 'الماركة',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                                size: 20,
                              ),
                              fillColor: const Color(0xFFFFFFFF),
                              elevation: 2,
                              borderColor: const Color(0xFF719C9F),
                              borderWidth: 2,
                              borderRadius: 8,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12, 4, 12, 4),
                              hidesUnderline: true,
                            ),
                            loadCarCategories?SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xff1c6166),
                                ),
                              ),
                            ):FlutterFlowDropDown(
                              options: carCategoriesValues,
                              onChanged: (val) {
                                setState(() {
                                  _model.dropDownValueCarCategory = val;
                                  _model.dropDownValueCarCategoryID =
                                      carCategoriesList[carCategoriesValues.indexOf(val!)].id;
                                });
                                getBrandCompoBoxValues();
                              },
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height:
                              MediaQuery.sizeOf(context).height * 0.06,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 10,
                              ),
                              hintText: 'الفئة',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                                size: 20,
                              ),
                              fillColor: const Color(0xFFFFFFFF),
                              elevation: 2,
                              borderColor: const Color(0xFF719C9F),
                              borderWidth: 2,
                              borderRadius: 8,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12, 4, 12, 4),
                              hidesUnderline: true,
                            ),
                            loadShape?SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xff1c6166),
                                ),
                              ),
                            ):FlutterFlowDropDown(
                              options: shapeValues,
                              onChanged: (val) {
                                setState(() {
                                  _model.dropDownValueShape = val;
                                  _model.dropDownValueShapeID = shapeList[shapeValues.indexOf(val!)].id;
                                });
                              },
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height:
                              MediaQuery.sizeOf(context).height * 0.06,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 10,
                              ),
                              hintText: 'الشكل',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                                size: 20,
                              ),
                              fillColor: const Color(0xFFFFFFFF),
                              elevation: 2,
                              borderColor: const Color(0xFF719C9F),
                              borderWidth: 2,
                              borderRadius: 8,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12, 4, 12, 4),
                              hidesUnderline: true,
                            ),
                          ],
                        ),
                      ):Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            loadCategories||loadSupCategories?SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.3,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xff1c6166),
                                ),
                              ),
                            ):supCategoriesList.isEmpty?SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.23,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                            ):FlutterFlowDropDown(
                              options: supCategoriesValues,
                              onChanged: (val) {
                                setState(() {
                                  _model.dropDownValueSupCategory = val;
                                  _model.dropDownValueSupCategoryID = supCategoriesList[supCategoriesValues.indexOf(val!)].id;
                                });
                              },
                              width: MediaQuery.sizeOf(context).width * 0.4,
                              height:
                              MediaQuery.sizeOf(context).height * 0.06,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 10,
                              ),
                              hintText: 'الفرعية',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                                size: 20,
                              ),
                              fillColor: const Color(0xFFFFFFFF),
                              elevation: 2,
                              borderColor: const Color(0xFF719C9F),
                              borderWidth: 2,
                              borderRadius: 8,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12, 4, 12, 4),
                              hidesUnderline: true,
                            ),
                            loadCategories?SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.3,
                              height: MediaQuery.sizeOf(context).height * 0.06,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xff1c6166),
                                ),
                              ),
                            ):FlutterFlowDropDown(
                              options: categoriesValues,
                              onChanged: (val) {
                                setState(() {
                                  _model.dropDownValueCategory = val;
                                  _model.dropDownValueCategoryID =
                                      categoriesList[categoriesValues.indexOf(val!)].id;
                                });
                                getSupCategoriesCompoBoxValues();
                              },
                              width: MediaQuery.sizeOf(context).width * 0.4,
                              height:
                              MediaQuery.sizeOf(context).height * 0.06,
                              textStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 10,
                              ),
                              hintText: 'الفئة',
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: FlutterFlowTheme.of(context)
                                    .secondaryText,
                                size: 20,
                              ),
                              fillColor: const Color(0xFFFFFFFF),
                              elevation: 2,
                              borderColor: const Color(0xFF719C9F),
                              borderWidth: 2,
                              borderRadius: 8,
                              margin: const EdgeInsetsDirectional.fromSTEB(
                                  12, 4, 12, 4),
                              hidesUnderline: true,
                            ),
                          ],
                        ),
                      ),
                      if(carAuctions)Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: FFButtonWidget(
                          onPressed: () async {
                            await showAlignedDialog(
                              context: context,
                              isGlobal: true,
                              avoidOverflow: false,
                              targetAnchor:
                              const AlignmentDirectional(0, 0).resolve(Directionality.of(context)),
                              followerAnchor:
                              const AlignmentDirectional(0, 0).resolve(Directionality.of(context)),
                              builder: (dialogContext) {
                                return Material(
                                  color: Colors.transparent,
                                  child: GestureDetector(
                                    onTap: () => _model.unfocusNode.canRequestFocus
                                        ? FocusScope.of(context).requestFocus(_model.unfocusNode)
                                        : FocusScope.of(context).unfocus(),
                                    child: AdditionInformationDialogWidget(createAuctionModel: _model),
                                  ),
                                );
                              },
                            ).then((value) => setState(() {}));
                          },
                          text: 'تصنيفات اضافية',
                          icon: const Icon(
                            Icons.car_repair_rounded,
                            size: 15,
                          ),
                          options: FFButtonOptions(
                            height: 40,
                            padding:
                            const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                            iconPadding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'يبدا من ',
                                  textAlign: TextAlign.end,
                                  style:
                                  FlutterFlowTheme.of(context).bodyMedium,
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      4, 4, 4, 4),
                                  child: FFButtonWidget(
                                    onPressed: () async {
                                      if(!sending) {
                                        final datePickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: getCurrentTimestamp,
                                          firstDate: getCurrentTimestamp,
                                          lastDate: DateTime(getCurrentTimestamp.year,getCurrentTimestamp.month,getCurrentTimestamp.day+7),
                                          cancelText: 'الغاء',
                                          confirmText: 'تم',
                                          helpText: 'اختر اليوم',
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                datePickerTheme: DatePickerThemeData(
                                                  headerBackgroundColor: const Color(0xFF1C6166),
                                                  headerForegroundColor: FlutterFlowTheme.of(context).info,
                                                  rangePickerSurfaceTintColor:  FlutterFlowTheme.of(context).primaryText,
                                                  headerHeadlineStyle: FlutterFlowTheme.of(context).headlineLarge.override(
                                                    fontFamily: 'Outfit',
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                  rangeSelectionBackgroundColor: const Color(0xFF1C6166),
                                                  rangePickerHeaderForegroundColor: FlutterFlowTheme.of(context).info,
                                                ),
                                                textButtonTheme: TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: FlutterFlowTheme.of(context).primaryText,
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        TimeOfDay? datePickedTime;
                                        if (datePickedDate != null && context.mounted) {
                                          datePickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.fromDateTime(getCurrentTimestamp),
                                            helpText: 'اختر الساعة',
                                            cancelText: 'الغاء',
                                            confirmText: 'تم',
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(context).copyWith(
                                                  timePickerTheme: TimePickerThemeData(
                                                    dialBackgroundColor: const Color(0xFF1C6166),
                                                    dialHandColor: FlutterFlowTheme.of(context).info,
                                                    dialTextColor: FlutterFlowTheme.of(context).primaryText,
                                                    dialTextStyle: FlutterFlowTheme.of(context).headlineLarge.override(
                                                      fontFamily: 'Outfit',
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                                                    hourMinuteColor: const Color(0xFF1C6166),
                                                    dayPeriodColor: const Color(0xFF1C6166),
                                                    dayPeriodTextColor: FlutterFlowTheme.of(context).info,
                                                    hourMinuteTextColor: FlutterFlowTheme.of(context).info,
                                                  ),
                                                  textButtonTheme: TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: FlutterFlowTheme.of(context).primaryText,
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                        }
                                        if (datePickedDate != null && datePickedTime != null) {
                                          safeSetState(() {
                                            _model.datePicked = DateTime(
                                              datePickedDate.year,
                                              datePickedDate.month,
                                              datePickedDate.day,
                                              datePickedTime!.hour,
                                              datePickedTime.minute,
                                            );
                                          });
                                        }
                                      }
                                    },
                                    text: '${_model.datePicked!.day}/${_model.datePicked!.month}/${_model.datePicked!.year}',
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      size: 15,
                                    ),
                                    options: FFButtonOptions(
                                      width:
                                      MediaQuery.sizeOf(context).width *
                                          0.48,
                                      height: 40,
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
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    4, 4, 4, 4),
                                child: SizedBox(
                                  width:
                                  MediaQuery.sizeOf(context).width * 0.24,
                                  child: TextFormField(
                                    controller: _model.textController1,
                                    focusNode: _model.textFieldFocusNode1,
                                    textInputAction: TextInputAction.done,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'المزاد باليوم',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 10,
                                      ),
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 10,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFF719C9F),
                                          width: 2,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFF719C9F),
                                          width: 2,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 2,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 2,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      enabled: !sending
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.end,
                                    validator: _model.textController1Validator
                                        .asValidator(context),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9]'))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    4, 4, 4, 4),
                                child: SizedBox(
                                  width:
                                  MediaQuery.sizeOf(context).width * 0.24,
                                  child: TextFormField(
                                    controller: _model.textController2,
                                    focusNode: _model.textFieldFocusNode2,
                                    textInputAction: TextInputAction.done,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'حد السوم',
                                      labelStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 10,
                                      ),
                                      hintStyle: FlutterFlowTheme.of(context)
                                          .labelMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 10,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFF719C9F),
                                          width: 2,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFF719C9F),
                                          width: 2,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 2,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: FlutterFlowTheme.of(context)
                                              .error,
                                          width: 2,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                        enabled: !sending
                                    ),
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.end,
                                    validator: _model.textController2Validator
                                        .asValidator(context),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9]'))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: TextFormField(
                            controller: _model.textController3,
                            focusNode: _model.textFieldFocusNode3,
                            textInputAction: TextInputAction.done,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'اسم المنتج',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
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
                              enabled: !sending
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              fontFamily: 'Readex Pro',
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.end,
                            validator: _model.textController3Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                          child: TextFormField(
                            controller: _model.textController4,
                            focusNode: _model.textFieldFocusNode4,
                            textInputAction: TextInputAction.done,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'وصف المنتج',
                              labelStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
                              alignLabelWithHint: true,
                              hintStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                fontFamily: 'Readex Pro',
                                fontSize: 12,
                              ),
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
                              enabled: !sending
                            ),
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                              fontFamily: 'Readex Pro',
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.end,
                            maxLines: 8,
                            validator: _model.textController4Validator
                                .asValidator(context),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FFButtonWidget(
                              onPressed: () {
                                if(numberOfImages <5 && !sending){
                                  _pickImage(ImageSource.camera);
                                }
                              },
                              text: 'الكاميرا',
                              icon: const Icon(
                                Icons.photo_camera,
                                size: 15,
                              ),
                              options: FFButtonOptions(
                                height:
                                MediaQuery.sizeOf(context).height * 0.05,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24, 0, 24, 0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 0),
                                color: numberOfImages <5 && !sending?const Color(0xFF1C6166):const Color(0x80FFFFFF),
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
                                if(numberOfImages <5 && !sending){
                                  _pickImage(ImageSource.gallery);
                                }
                              },
                              text: 'المعرض',
                              icon: const Icon(
                                Icons.photo_library,
                                size: 15,
                              ),
                              options: FFButtonOptions(
                                height:
                                MediaQuery.sizeOf(context).height * 0.05,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24, 0, 24, 0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 0),
                                color: numberOfImages <5 && !sending?const Color(0xFF1C6166):const Color(0x80FFFFFF),
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 180,
                          child: CarouselSlider(
                            items: [
                              for(int i = 0; i < numberOfImages; i++)...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      Image.file(
                                        images[i]!,
                                        width: 300,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            5, 5, 5, 5),
                                        child: IconButton(
                                          onPressed: () async {
                                            removeImage(i);
                                          },
                                          icon: sending?SizedBox(
                                              height: MediaQuery.sizeOf(context).height * 0.01,
                                              width: MediaQuery.sizeOf(context).height * 0.01,
                                              child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                          ):const Icon(
                                            Icons.close_rounded,
                                            color: Colors.red,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ],
                            carouselController: _model.carouselController ??=
                                CarouselController(),
                            options: CarouselOptions(
                              initialPage: 1,
                              viewportFraction: 0.5,
                              disableCenter: true,
                              enlargeCenterPage: true,
                              enlargeFactor: 0.25,
                              enableInfiniteScroll: true,
                              scrollDirection: Axis.horizontal,
                              autoPlay: false,
                              onPageChanged: (index, _) =>
                              _model.carouselCurrentIndex = index,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).error,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8, 8, 8, 8),
                                child: Text(
                                  'هل تريد اتاحة خاصية التراجع عن البيع قبل انتهاء مدة المزاد ؟',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    8, 8, 8, 8),
                                child: Text(
                                  'تنبيه : باخيارك (نعم) سوف يظهر للمزايدين اختيارك لتلك الخاصية',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FFButtonWidget(
                              onPressed: () {
                                setState(() {
                                  cancelOptions = false;
                                });
                              },
                              text: 'لا',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 0.2,
                                height: 40,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24, 0, 24, 0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 0),
                                color: !cancelOptions?const Color(0xFF1C6166):const Color(0x80FFFFFF),
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
                                setState(() {
                                  cancelOptions = true;
                                });
                              },
                              text: 'نعم',
                              options: FFButtonOptions(
                                width: MediaQuery.sizeOf(context).width * 0.2,
                                height: 40,
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    24, 0, 24, 0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 0, 0),
                                color: cancelOptions?const Color(0xFF1C6166):const Color(0x80FFFFFF),
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
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                        child: FFButtonWidget(
                          onPressed: () async {
                            if(_model.formKey.currentState!.validate() && !loadSupCategories && !loadCarCategories && !loadBrand && !loadCarModel && !loadCategories && !loadShape && !sending && numberOfImages > 0 && _model.datePicked != null) {
                              createAuction();
                            }
                          },
                          text: sending?'':'انشاء مزاد',
                          icon: sending?SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.03,
                              width: MediaQuery.sizeOf(context).height * 0.03,
                              child: const CircularProgressIndicator(color: Color(0xFF1C6166),)
                          ):const Icon(
                            Icons.done_all_rounded,
                            size: 15,
                          ),
                          options: FFButtonOptions(
                            height: MediaQuery.sizeOf(context).height * 0.05,
                            width: sending?MediaQuery.sizeOf(context).height * 0.05:MediaQuery.sizeOf(context).width * 0.7,
                            padding: sending?const EdgeInsetsDirectional.fromSTEB(9, 0, 0, 0):const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                            iconPadding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: !(!loadSupCategories && !loadCarCategories && !loadBrand && !loadCarModel && !loadCategories && !loadShape && !sending && numberOfImages > 0 && _model.datePicked != null)||sending?Colors.grey:const Color(0xFF1C6166),
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
                      ),
                    ],
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
