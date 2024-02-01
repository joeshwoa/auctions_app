import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mazad/view/pages/coming_soon_page/coming_soon_page.dart';
import 'package:mazad/view/pages/create_auction_page/create_auction_page.dart';
import 'package:mazad/view/pages/favorite_page/favorite_page.dart';
import 'package:mazad/view/pages/home_page/home_page.dart';
import 'package:mazad/view/pages/my_account_page/my_account_page.dart';
import 'package:mazad/view/pages/my_auctions_page/my_auctions_page.dart';
import 'package:mazad/view/pages/search_page/search_page.dart';

import 'layout_model.dart';
export 'layout_model.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late LayoutModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  int pageNumber = 5;
  List<Widget> pages = [const MyAccountPage(),const CreateAuctionPage(),const MyAuctionsPage(),const ComingSoonPage(),const FavoritePage(),const HomePage(),SearchPage(searchKey: '')];
  List<String> title = ['حسابي','انشاء مزاد','مزاداتي','مزادات تبدا قريبا','المفضلة','مزادات نشطة','بحث المزادات'];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LayoutModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
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
            Size.fromHeight(MediaQuery.sizeOf(context).height * 0.08),
            child: AppBar(
              backgroundColor: const Color(0xFF1C6166),
              automaticallyImplyLeading: false,
              leadingWidth: 30,
              toolbarHeight: MediaQuery.sizeOf(context).height * 0.08,
              /*leading: pageNumber == 5?FlutterFlowIconButton(
                borderColor: const Color(0x00FFFFFF),
                borderRadius: 20,
                borderWidth: 1,
                buttonSize: 24,
                fillColor: const Color(0x00FFFFFF),
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  print('IconButton pressed ...');
                },
              ):const SizedBox(),*/
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if(pageNumber == 5 || pageNumber == 6)Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.35,
                        child: TextFormField(
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          textInputAction: TextInputAction.search,
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'بحث سوم',
                            labelStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            hintStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.white,
                            ),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.end,
                          validator:
                          _model.textControllerValidator.asValidator(context),
                          onFieldSubmitted: (value) {
                            if (value.isNotEmpty) {
                              setState(() {
                                pages[6] = SearchPage(
                                  key: UniqueKey(), // Ensure a new instance is created
                                  searchKey: value,
                                );
                                pageNumber = 6;
                              });
                            } else {
                              setState(() {
                                pageNumber = 5;
                              });
                            }
                          },
                          keyboardType: TextInputType.text,
                          autocorrect: true,
                        ),
                      ),
                    ),
                    Text(
                      title[pageNumber],
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
          ),
          body: SafeArea(
            top: true,
            child: pages[pageNumber],
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Colors.white,
                  ),
                ),
                label: 'حسابي',
                activeIcon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.person_add_alt_1_outlined,
                    color: Color(0xff2fc72a),
                  ),
                ),
                backgroundColor: Color(0xff1c6166),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add_outlined,
                    color: Colors.white,
                  ),
                ),
                label: 'انشاء مزاد',
                activeIcon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add_outlined,
                    color: Color(0xff2fc72a),
                  ),
                ),
                backgroundColor: Color(0xff1c6166),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.notification_add_outlined,
                    color: Colors.white,
                  ),
                ),
                label: 'مزاداتي',
                activeIcon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.notification_add_outlined,
                      color: Color(0xff2fc72a),
                    ),
                  ),
                ),
                backgroundColor: Color(0xff1c6166),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.alarm_add_outlined,
                    color: Colors.white,
                  ),
                ),
                label: 'قريبا',
                activeIcon: Icon(
                  Icons.alarm_add_outlined,
                  color: Color(0xff2fc72a),
                ),
                backgroundColor: Color(0xff1c6166),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                ),
                label: 'المفضلة',
                activeIcon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.favorite_border,
                    color: Color(0xff2fc72a),
                  ),
                ),
                backgroundColor: Color(0xff1c6166),
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                  ),
                ),
                label: 'الرئيسية',
                activeIcon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.home_outlined,
                    color: Color(0xff2fc72a),
                  ),
                ),
                backgroundColor: Color(0xff1c6166),
              ),
            ],
            fixedColor: const Color(0xff2fc72a),
            backgroundColor: const Color(0xff1c6166),
            currentIndex: pageNumber<6?pageNumber:5,
            onTap: (int num) {
              setState(() {
                _model.textController!.clear();
                pageNumber = num;
              });
            },
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: FlutterFlowTheme.of(context).labelMedium.override(
              fontFamily: 'Readex Pro',
              color: const Color(0xff2fc72a),
              fontSize: 10,
            ),
            unselectedLabelStyle: FlutterFlowTheme.of(context).labelMedium.override(
              fontFamily: 'Readex Pro',
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}