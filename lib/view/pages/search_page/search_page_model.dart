import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:mazad/model/auction_model.dart';
import 'package:mazad/view/componants/auction_card/auction_card_widget.dart';
import 'search_page.dart' show SearchPage;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<SearchPage> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  late List<AuctionCardModel> auctionCardModels = [];
  List<Auction> auctions = [];

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {

  }

  @override
  void dispose() {
    unfocusNode.dispose();
    for(int i=0; i<auctionCardModels.length; i++) {
      auctionCardModels[i].dispose();
    }
  }

/// Action blocks are added here.

/// Additional helper methods are added here.
}
