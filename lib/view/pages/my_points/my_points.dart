import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mazad/api/api_methods/get.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/variable/account_details.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_points_model.dart';
export 'my_points_model.dart';

class MyPoints extends StatefulWidget {
  const MyPoints({super.key});

  @override
  State<MyPoints> createState() => _MyPointsState();
}

class _MyPointsState extends State<MyPoints> {
  late MyPointsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool sending = false;

  bool loadPoints = false;

  double amount = 0;

  void getPoint() {
    setState(() {
      loadPoints = true;
    });

    get(ApiPaths.getPoints+id).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    }).then((value) {
      if(value['code']>=200 && value['code']<300){
        setState(() {
          amount = value['body']['data']*1.0;
          loadPoints = false;
        });
      } else {
        getPoint();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyPointsModel());
    getPoint();
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
            alignment: const AlignmentDirectional(1, 0),
            child: Text(
              'نقاطي',
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
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.9,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C6166),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0, 0),
                        child: Text(
                          'يمكنك استبدال نقاطك بجوائز قيمة من مزاد كلنا خادم',
                          textAlign: TextAlign.end,
                          style:
                          FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            color: const Color(0xFF35E917),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      'ستصلك رسالة من الدعم الفني بجائزتك',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      'عندما يصل رصيد نقاطكالي حد الاستبدال',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0, 0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(20, 50, 20, 20),
                      child: CircularPercentIndicator(
                        percent: amount/100,
                        radius: MediaQuery.sizeOf(context).width * 0.25,
                        lineWidth: 12,
                        animation: true,
                        animateFromLastPercent: true,
                        progressColor: const Color(0xFF1C6166),
                        backgroundColor: const Color(0xFFDDDDDD),
                        center: Text(
                          '$amount',
                          style: FlutterFlowTheme.of(context).headlineSmall,
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
