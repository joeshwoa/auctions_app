import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mazad/api/api_methods/get.dart';
import 'package:mazad/api/api_methods/post.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/create_models/create_auction_model.dart';
import 'package:mazad/model/auction_model.dart';
import 'package:mazad/variable/cached_image.dart';
import 'package:mazad/view/componants/auction_card/auction_card_widget.dart';

import 'search_page_model.dart';
export 'search_page_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key,required this.searchKey});
  final String searchKey;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late HomePageModel _model;

  bool carAuctions = false;

  bool loading = false;
  
  int page = 1; // Initial page number
  int numberOfPages = 1;
  late final ScrollController _controller;
  int itemCounter = 1;

  void _scrollListener() {
    if ((_controller.offset+MediaQuery.sizeOf(context).height * 0.15) >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange && !loading && page < numberOfPages) {
      setState(() {
        itemCounter = _model.auctions.length +1;
      });
      searchAuctions();
    }
  }

  Future<void> searchAuctions() async {
    if (!loading && page <= numberOfPages) {
      if(mounted){
        setState(() {
          loading = true;
        });
      }

      Map<String,dynamic> data = {
        'val': widget.searchKey
      };

      final responseMap = await post("${ApiPaths.searchAuction}"/*?page=$page*/,data).onError((error, stackTrace) {
        return {
          'code':0,
        'error':error
        };
      });

      if (responseMap['code'] >= 200 && responseMap['code'] < 300) {
        final Map<String, dynamic> responseData = responseMap['body'];
        print(responseData);
        /*numberOfPages = responseData['paginationResult']['numberOfPages'];*/
        final List<Auction> newAuctions = [];

        for(int i=0;i<responseData["data"].length;i++){
          newAuctions.add(createAuction(responseData["data"][i]));
          if(mounted) {
            _model.auctionCardModels.add(createModel(context, () => AuctionCardModel()));
          }
        }

        if(mounted){
          setState(() {
            _model.auctions.addAll(newAuctions);

            itemCounter = _model.auctions.length;
            page++; // Increment page number for the next API call
            loading = false;
          });
        }
        getAuctionsImages();
      }  else if (responseMap['code'] == 999) {
        if (mounted) {
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
        searchAuctions();
      }else {
        if (mounted) {
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
        searchAuctions();
      }
    }
  }

  Future<void> _refresh() async{
    setState(() {
      itemCounter = 1;
      page=1;
      _model.auctions.clear();
    });
    searchAuctions();
  }

  Future<void> getAuctionsImages() async {
    for(int i=0; i<_model.auctions.length; i++) {
      if(!cachedImages.contains(_model.auctions[i].id)) {
        final responseMap = await get("${ApiPaths.getAuctionProfileImage}${_model.auctions[i].id}").onError((error, stackTrace) {
          return {
            'code':0,
            'error':error
          };
        });

        if (responseMap['code'] >= 200 && responseMap['code'] < 300) {
          print(responseMap);
          final Map<String, dynamic> responseData = responseMap['body'];
          if(mounted){
            setState(() {
              _model.auctions[i].publisherImage = responseData['data']['user']['profileImg']??'';
            });
          }
        }

        final responseMap2 = await get("${ApiPaths.getAuctionImages}${_model.auctions[i].id}").onError((error, stackTrace) {
          return {
            'code':0,
        'error':error
          };
        });

        if (responseMap2['code'] >= 200 && responseMap2['code'] < 300) {
          final Map<String, dynamic> responseData2 = responseMap2['body'];
          _model.auctions[i].imageCaver = responseData2['data']['imageCover'];
          _model.auctions[i].images = [_model.auctions[i].imageCaver];
          if(responseData2['data']['images'] != null && responseData2['data']['images'].length > 0) {
            for(int ii = 0; ii < responseData2['data']['images'].length; ii++) {
              if(i == 3) {
                print(responseData2['data']['images'].length);
                for(int iii = 0; iii < responseData2['data']['images'].length; iii++) {
                  print('${iii}: ${responseData2['data']['images'][iii].length}');
                }
              }
              _model.auctions[i].images.add(responseData2['data']['images'][ii]);
            }
          }
          if(mounted){
            setState(() {
              cachedImages.add(_model.auctions[i].id);
              numberOfCachedImages.addAll({_model.auctions[i].id:_model.auctions[i].images.length});
              _model.auctions[i].imagesLoaded = true;
            });
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
    searchAuctions();
  }

  @override
  void dispose() {
    _model.dispose();
    searchAuctions().ignore();
    _controller.dispose();
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
        child: Align(
          alignment: const AlignmentDirectional(0.00, 0.00),
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              /*physics: const AlwaysScrollableScrollPhysics(),*/
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              /*shrinkWrap: true,*/
              itemCount: itemCounter,
              itemBuilder: (context, index) {
                if (index < _model.auctions.length) {
                  // Render category card
                  return wrapWithModel(
                    model: _model.auctionCardModels[index],
                    updateCallback: () => setState(() {}),
                    child: AuctionCardWidget(auctionCardPosition: AuctionCardPosition.comingSoon,auction: _model.auctions[index],model: _model),
                  );
                } else if (loading) {
                  // Render loading indicator while fetching more data
                  return Container(
                    width: MediaQuery.sizeOf(context).width * 0.96,
                    height: MediaQuery.sizeOf(context).height * 0.3,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF1C6166),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1C6166),),
                    ),
                  );
                } else {
                  // Render an empty container at the end
                  return Container(
                  );
                }
              },
              controller: _controller,
            ),
          ),
        ),
      ),
    );
  }
}
