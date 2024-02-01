import 'dart:io';

import 'package:flutter_clickpay_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_clickpay_bridge/IOSThemeConfiguration.dart';
import 'package:flutter_clickpay_bridge/PaymentSdkApms.dart';
import 'package:flutter_clickpay_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_clickpay_bridge/PaymentSdkTokeniseType.dart';
import 'package:flutter_clickpay_bridge/flutter_clickpay_bridge.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mazad/api/api_methods/get.dart';
import 'package:mazad/api/api_methods/post.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/variable/account_details.dart';
import 'package:mazad/variable/shared_preferences.dart';

import 'my_wallet_model.dart';
export 'my_wallet_model.dart';

class MyWallet extends StatefulWidget {
  const MyWallet({super.key});

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  late MyWalletModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int method = 1;

  bool sending = false;
  
  bool loadAmount = false;
  
  double amount = 0;

  void getWalletAmount() {
    setState(() {
      loadAmount = true;
    });

    get(ApiPaths.getWalletAmount+id).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      if(value['code']>=200 && value['code']<300){
        setState(() {
          amount = value['body']['data']*1.0;
          loadAmount = false;
        });
      } else {
        getWalletAmount();
      }
    });
  }

  PaymentSdkConfigurationDetails generateConfig(String id,int method) {

    var billingDetails = BillingDetails(name, email, phone, 'القطيف', "SA", 'القطيف', 'القطيف', "32614");

    var shippingDetails = ShippingDetails(name, email, phone, 'القطيف', "SA", 'القطيف', 'القطيف', "32614");

    List<PaymentSdkAPms> apms = [];
    apms.add(PaymentSdkAPms.STC_PAY);
    apms.add(PaymentSdkAPms.APPLE_PAY);

    String cartProducts = 'شحن محفظة التطبيق';

    var configuration = PaymentSdkConfigurationDetails(
        profileId: "42593",
        serverKey: "SLJNLLTNHR-JGWWHDWTLG-LJTRHLRGK2",
        clientKey: "CDKMDM-6BKQ6T-VVHDV7-99GGHH",
        cartId: id,
        cartDescription: cartProducts,
        merchantName: 'كلنا خادم',
        screentTitle: method==2?"الدفع ببطاقة mada":method==1?"الدفع ب STC Pay":"الدفع ب Apple Pay",
        amount: double.parse(_model.textController.text),
        showBillingInfo: true,
        forceShippingInfo: false,
        currencyCode: "SAR",
        merchantCountryCode: "SA",
        billingDetails: billingDetails,
        shippingDetails: shippingDetails,
        alternativePaymentMethods: apms,
        linkBillingNameWithCardHolderName: true);

    var theme = IOSThemeConfigurations();
    configuration.iOSThemeConfigurations = theme;
    configuration.tokeniseType = PaymentSdkTokeniseType.MERCHANT_MANDATORY;
    return configuration;
  }

  Future<void> verifyPayment() async {
    setState(() {
      sending = true;
    });
    Map<String,dynamic> data = {
      'amount' : int.parse(_model.textController.text),
      'method': method==0?'apple':method==1?'stc':'mada'
    };
    Map responseMap = await post(ApiPaths.verifyPayment+id,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });

    setState(() {
      sending = false;
    });

    if((responseMap['code']>=200 && responseMap['code']<300)) {
      if (context.mounted){
        _model.textController!.clear();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              'تم شحن المحفظة بنجاح',
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
      if(mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              'فشل شحن المحفظة. رجاء تواصل مع الدعم الفني',
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
      verifyPayment();
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyWalletModel());

    _model.textController ??= TextEditingController();
    _model.textControllerValidator ??= (context,value){
      if(value == null || value.isEmpty || value.characters == Characters(' '))
      {
        return 'الرقم فارغ';
      } else if(double.parse(_model.textController.text) <= 0){
        return 'رقم اقل او يساوي صفر';
      }
      return null;
    };
    _model.textFieldFocusNode ??= FocusNode();

    getWalletAmount();
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
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C6166),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: const Color(0x00FFFFFF),
            borderRadius: 20,
            borderWidth: 1,
            buttonSize: 40,
            fillColor: const Color(0x00FFFFFF),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Align(
            alignment: const AlignmentDirectional(1.00, 0.00),
            child: Text(
              'محفظتي',
              textAlign: TextAlign.end,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Readex Pro',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            FlutterFlowIconButton(
              borderColor: const Color(0x00FFFFFF),
              borderRadius: 20,
              borderWidth: 1,
              buttonSize: 40,
              fillColor: const Color(0x00FFFFFF),
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                print('IconButton pressed ...');
              },
            ),
          ],
          centerTitle: false,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0.00, 0.00),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      height: MediaQuery.sizeOf(context).height * 0.07,
                      decoration: BoxDecoration(
                        color: const Color(0xFFeeeeee),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'SAR',
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.3,
                            height: MediaQuery.sizeOf(context).height * 0.04,
                            decoration: BoxDecoration(
                              color: const Color(0x00FFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Align(
                              alignment: const AlignmentDirectional(0.00, 0.00),
                              child: Text(
                                amount.toStringAsFixed(2),
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ),
                          ),
                          Text(
                            'رصيد المحفظة',
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      height: MediaQuery.sizeOf(context).height * 0.4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFeeeeee),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.payment_outlined,
                            color: Colors.black,
                            size: 100,
                          ),
                          Text(
                            'Patment Method',
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.88,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding:
                                const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: const AlignmentDirectional(1.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            5, 5, 5, 5),
                                        child: Text(
                                          'شحن المحفظة',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment:
                                      const AlignmentDirectional(-1.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            5, 5, 5, 5),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            MaterialButton(
                                              onPressed: () {
                                                if(Platform.isIOS) {
                                                  setState(() {
                                                    method = 0;
                                                  });
                                                }
                                              },
                                              padding: EdgeInsets.zero,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisSize:
                                                      MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                3, 3, 3, 3),
                                                            child: Container(
                                                              width:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.25,
                                                              height:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .height *
                                                                  0.05,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: FlutterFlowTheme
                                                                    .of(context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    6),
                                                                border: Border.all(
                                                                  color: const Color(
                                                                      0xFF1C6166),
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    6),
                                                                child:
                                                                Image.network(
                                                                  'https://picsum.photos/seed/260/600',
                                                                  width: MediaQuery
                                                                      .sizeOf(
                                                                      context)
                                                                      .width *
                                                                      0.25,
                                                                  height: MediaQuery
                                                                      .sizeOf(
                                                                      context)
                                                                      .height *
                                                                      0.05,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(0, 0, 10, 0),
                                                    child: Text(
                                                      'Apple Pay',
                                                      style: FlutterFlowTheme.of(
                                                          context)
                                                          .bodyMedium
                                                          .override(
                                                        fontFamily:
                                                        'Readex Pro',
                                                        color:
                                                        method == 0?const Color(0xFF35E917):Platform.isIOS?const Color(0xFF1C6166):Colors.grey,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(3, 3, 3, 3),
                                                    child: Container(
                                                      width:
                                                      MediaQuery.sizeOf(context)
                                                          .width *
                                                          0.06,
                                                      height:
                                                      MediaQuery.sizeOf(context)
                                                          .width *
                                                          0.06,
                                                      decoration: BoxDecoration(
                                                        color: method == 0?const Color(0xFF35E917):Platform.isIOS?const Color(0xFF1C6166):Colors.grey,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                        const AlignmentDirectional(
                                                            0.00, 0.00),
                                                        child: Container(
                                                          width: MediaQuery.sizeOf(
                                                              context)
                                                              .width *
                                                              0.04,
                                                          height: MediaQuery.sizeOf(
                                                              context)
                                                              .width *
                                                              0.04,
                                                          decoration: BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                .of(context)
                                                                .secondaryBackground,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                            const AlignmentDirectional(
                                                                0.00, 0.00),
                                                            child: Container(
                                                              width:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.02,
                                                              height:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.02,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: method == 0?const Color(0xFF35E917):Platform.isIOS?const Color(0xFF1C6166):Colors.grey,
                                                                shape:
                                                                BoxShape.circle,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            MaterialButton(
                                              onPressed: () {
                                                setState(() {
                                                  method = 1;
                                                });
                                              },
                                              padding: EdgeInsets.zero,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisSize:
                                                      MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                3, 3, 3, 3),
                                                            child: Container(
                                                              width:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.25,
                                                              height:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .height *
                                                                  0.05,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: FlutterFlowTheme
                                                                    .of(context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    6),
                                                                border: Border.all(
                                                                  color: const Color(0xFF1C6166),
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    6),
                                                                child:
                                                                Image.network(
                                                                  'https://picsum.photos/seed/480/600',
                                                                  width: MediaQuery
                                                                      .sizeOf(
                                                                      context)
                                                                      .width *
                                                                      0.25,
                                                                  height: MediaQuery
                                                                      .sizeOf(
                                                                      context)
                                                                      .height *
                                                                      0.05,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(0, 0, 10, 0),
                                                    child: Text(
                                                      'STC Pay',
                                                      style: FlutterFlowTheme.of(
                                                          context)
                                                          .bodyMedium
                                                          .override(
                                                        fontFamily:
                                                        'Readex Pro',
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: method == 1?const Color(0xFF35E917):const Color(0xFF1C6166)
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(3, 3, 3, 3),
                                                    child: Container(
                                                      width:
                                                      MediaQuery.sizeOf(context)
                                                          .width *
                                                          0.06,
                                                      height:
                                                      MediaQuery.sizeOf(context)
                                                          .width *
                                                          0.06,
                                                      decoration: BoxDecoration(
                                                        color: method == 1?const Color(0xFF35E917):const Color(0xFF1C6166),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                        const AlignmentDirectional(
                                                            0.00, 0.00),
                                                        child: Container(
                                                          width: MediaQuery.sizeOf(
                                                              context)
                                                              .width *
                                                              0.04,
                                                          height: MediaQuery.sizeOf(
                                                              context)
                                                              .width *
                                                              0.04,
                                                          decoration: BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                .of(context)
                                                                .secondaryBackground,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                            const AlignmentDirectional(
                                                                0.00, 0.00),
                                                            child: Container(
                                                              width:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.02,
                                                              height:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.02,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: method == 1?const Color(0xFF35E917):const Color(0xFF1C6166),
                                                                shape:
                                                                BoxShape.circle,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            MaterialButton(
                                              onPressed: () {
                                                setState(() {
                                                  method = 2;
                                                });
                                              },
                                              padding: EdgeInsets.zero,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      mainAxisSize:
                                                      MainAxisSize.max,
                                                      children: [
                                                        Flexible(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                                3, 3, 3, 3),
                                                            child: Container(
                                                              width:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.25,
                                                              height:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .height *
                                                                  0.05,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: FlutterFlowTheme
                                                                    .of(context)
                                                                    .secondaryBackground,
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    6),
                                                                border: Border.all(
                                                                  color: const Color(
                                                                      0xFF1C6166),
                                                                ),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    6),
                                                                child:
                                                                Image.network(
                                                                  'https://picsum.photos/seed/360/600',
                                                                  width: MediaQuery
                                                                      .sizeOf(
                                                                      context)
                                                                      .width *
                                                                      0.25,
                                                                  height: MediaQuery
                                                                      .sizeOf(
                                                                      context)
                                                                      .height *
                                                                      0.05,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(0, 0, 10, 0),
                                                    child: Text(
                                                      'بطاقة ائتمان',
                                                      style: FlutterFlowTheme.of(
                                                          context)
                                                          .bodyMedium
                                                          .override(
                                                        fontFamily:
                                                        'Readex Pro',
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: method == 2?const Color(0xFF35E917):const Color(0xFF1C6166)
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(3, 3, 3, 3),
                                                    child: Container(
                                                      width:
                                                      MediaQuery.sizeOf(context)
                                                          .width *
                                                          0.06,
                                                      height:
                                                      MediaQuery.sizeOf(context)
                                                          .width *
                                                          0.06,
                                                      decoration: BoxDecoration(
                                                        color: method == 2?const Color(0xFF35E917):const Color(0xFF1C6166),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                        const AlignmentDirectional(
                                                            0.00, 0.00),
                                                        child: Container(
                                                          width: MediaQuery.sizeOf(
                                                              context)
                                                              .width *
                                                              0.04,
                                                          height: MediaQuery.sizeOf(
                                                              context)
                                                              .width *
                                                              0.04,
                                                          decoration: BoxDecoration(
                                                            color: FlutterFlowTheme
                                                                .of(context)
                                                                .secondaryBackground,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                            const AlignmentDirectional(
                                                                0.00, 0.00),
                                                            child: Container(
                                                              width:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.02,
                                                              height:
                                                              MediaQuery.sizeOf(
                                                                  context)
                                                                  .width *
                                                                  0.02,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: method == 2?const Color(0xFF35E917):const Color(0xFF1C6166),
                                                                shape:
                                                                BoxShape.circle,
                                                              ),
                                                            ),
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                    child: Form(
                      key: _model.formKey,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.9,
                        decoration: BoxDecoration(
                          color: const Color(0xFFeeeeee),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(1.00, 0.00),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                                child: Text(
                                  'اضف الرصيد',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(1.00, 0.00),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                                child: Text(
                                  'طريقة السداد',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    color: const Color(0xFF888888),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                                    child: Text(
                                      'Apple Pay',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          3, 3, 3, 3),
                                      child: Container(
                                        width:
                                        MediaQuery.sizeOf(context).width * 0.2,
                                        height: MediaQuery.sizeOf(context).height *
                                            0.04,
                                        decoration: BoxDecoration(
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: const Color(0xFF1C6166),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(
                                            'https://picsum.photos/seed/360/600',
                                            width:
                                            MediaQuery.sizeOf(context).width *
                                                0.2,
                                            height:
                                            MediaQuery.sizeOf(context).height *
                                                0.04,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(1.00, 0.00),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                                child: Text(
                                  'ادخل المبلغ المراد اضافته الي رصيدك',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                              child: TextFormField(
                                controller: _model.textController,
                                focusNode: _model.textFieldFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: InputDecoration(
                                  labelStyle:
                                  FlutterFlowTheme.of(context).labelMedium,
                                  hintStyle:
                                  FlutterFlowTheme.of(context).labelMedium,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1C6166),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1C6166),
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
                                style: FlutterFlowTheme.of(context).bodyMedium,
                                validator: _model.textControllerValidator
                                    .asValidator(context),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 5),
                              child: MaterialButton(
                                onPressed: () async {
                                  if(!sending) {
                                    bool success = false;
                                    if(Platform.isIOS && _model.formKey.currentState!.validate() && method==0) {
                                      String cartProducts = 'شحن محفظة التطبيق';

                                      var configuration = PaymentSdkConfigurationDetails(
                                          profileId: "42593",
                                          serverKey: "SLJNLLTNHR-JGWWHDWTLG-LJTRHLRGK2",
                                          clientKey: "CDKMDM-6BKQ6T-VVHDV7-99GGHH",
                                          cartId: sharedPreferences.getString('token'),
                                          cartDescription: cartProducts,
                                          merchantName: 'كلنا خادم',
                                          amount: double.parse(_model.textController.text),
                                          currencyCode: "SAR",
                                          merchantCountryCode: "SA",
                                          merchantApplePayIndentifier: "merchant.clickpay.com",
                                          simplifyApplePayValidation: true);

                                      await FlutterPaymentSdkBridge.startApplePayPayment(configuration, (event) async {
                                        setState(() {
                                          if (event["status"] == "success") {
                                            success = true;
                                          } else if (event["status"] == "error") {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Center(child: Text(
                                                  event.toString(),
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
                                          } else if (event["status"] == "event") {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Center(child: Text(
                                                  event.toString(),
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
                                        });

                                        if(success) {
                                          verifyPayment();
                                        }
                                      });

                                    } else if(_model.formKey.currentState!.validate()) {
                                      await FlutterPaymentSdkBridge.startAlternativePaymentMethod(generateConfig(sharedPreferences.getString('token')!,method), (event) async {
                                        setState(() {
                                          if (event["status"] == "success") {
                                            success = true;
                                          } else if (event["status"] == "error") {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Center(child: Text(
                                                  event.toString(),
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
                                          } else if (event["status"] == "event") {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Center(child: Text(
                                                  event.toString(),
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
                                        });
                                        if(success) {
                                          verifyPayment();
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 0.5,
                                  height: MediaQuery.sizeOf(context).height * 0.05,
                                  decoration: BoxDecoration(
                                    color: method == 0?Colors.black:Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                                    child: sending?SizedBox(
                                        height: MediaQuery.sizeOf(context).height * 0.03,
                                        width: MediaQuery.sizeOf(context).height * 0.03,
                                        child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                    ):Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            'https://picsum.photos/seed/9/600',
                                            width: MediaQuery.sizeOf(context).width *
                                                0.18,
                                            height:
                                            MediaQuery.sizeOf(context).height *
                                                0.04,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Text(
                                          'اشحن عن طريق',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: method == 0? Colors.white: const Color(0xFF1C6166),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
