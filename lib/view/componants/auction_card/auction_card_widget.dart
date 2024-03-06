import 'dart:convert';
import 'dart:developer';

import 'package:cache_manager/cache_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutterflow_ui/flutterflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:mazad/api/api_methods/post.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/model/auction_model.dart';
import 'package:mazad/variable/account_details.dart';
import 'package:mazad/variable/cached_image.dart';
import 'package:mazad/view/pages/auction_details/auction_details.dart';

import 'auction_card_model.dart';
export 'auction_card_model.dart';

enum AuctionCardPosition {
  home,
  favorite,
  comingSoon,
  myAuctionCreatedByMe,
  myAuctionAttendedByMe,
  expiredAuctionCreatedByMe,
  expiredAuctionAttendedByMe,
  expiredAuctionWon
}

class AuctionCardWidget extends StatefulWidget {
  const AuctionCardWidget({super.key,required this.auctionCardPosition,required this.auction,required this.model});
  final AuctionCardPosition auctionCardPosition;
  final Auction auction;
  final model;

  @override
  State<AuctionCardWidget> createState() => _AuctionCardWidgetState();
}

class _AuctionCardWidgetState extends State<AuctionCardWidget> {
  late AuctionCardModel _model;
  
  int imageNumber = 0;

  bool sending = false;
  
  late List<String> images = [];
  late String coverImage = '';

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AuctionCardModel());

    if(cachedImages.contains(widget.auction.id)) {
      ReadCache.getString(key: '${widget.auction.id}/coverImage').then((value) {
        setState(() {
          coverImage = value;
        });
      });

      ReadCache.getStringList(key: '${widget.auction.id}/images').then((value) {
        setState(() {
          images = value;
        });
      });
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    addOrRemoveFavoriteAuction().ignore();
    super.dispose();
  }

  Future<void> addOrRemoveFavoriteAuction() async {
    setState(() {
      sending = true;
    });

    Map<String,dynamic> data = {
      "user":id,
      "mazad":widget.auction.id,
      "isCar":widget.auction.isCar
    };

    Map responseMap = await post(ApiPaths.addOrRemoveFavoriteAuction,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });

    setState(() {
      sending = false;
    });

    if(responseMap['code']>=200 && responseMap['code']<300) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text(
              responseMap['body']['data']?'تم اضافة المزاد الي المفضلة':'تم ازالة المزاد من المفضلة',
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
    } else {
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
        log(responseMap.toString());
      }
    }
  }

  void closeAuction() {
    setState(() {
      int i = widget.model.auctions.indexOf(widget.auction);
      widget.model.auctions.removeAt(i);
      widget.model.auctionCardModels.removeAt(i);
      widget.model.onUpdate();
    });
    _model.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
    widget.auctionCardPosition.index == 0?Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionDetails(auction: widget.auction,canSoom: true,coverImage: coverImage,images: images),));
        },
        padding: EdgeInsets.zero,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.auction.isCar?Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: const Color(0xFF719C9F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                          child: Text(
                            widget.auction.type,
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.code,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'كود المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                      height: MediaQuery.sizeOf(context).width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: coverImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(coverImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):widget.auction.images.isNotEmpty && widget.auction.publisherImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(widget.auction.publisherImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.1,
                          width: MediaQuery.sizeOf(context).height * 0.1,
                          child: Image(
                              image: AssetImage(
                                  'assets/images/man.png'
                              ),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).width * 0.18,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1C6166),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      scrollPhysics: const PageScrollPhysics(),
                                      height: MediaQuery.sizeOf(context).width * 0.18,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      initialPage: 0,
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                      autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          imageNumber = index;
                                        });
                                      },
                                    ),
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                                        SizedBox.expand(
                                            child: InteractiveViewer(
                                              child: images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):widget.auction.images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(widget.auction.images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):SizedBox(
                                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                                  width: MediaQuery.sizeOf(context).height * 0.1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: const CircularProgressIndicator(color: Color(0xff1c6166),),
                                                  )
                                              ),
                                            )),
                                    itemCount: numberOfCachedImages[widget.auction.id]??widget.auction.images.length,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        await addOrRemoveFavoriteAuction();
                                      },
                                      icon: sending?SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.01,
                                          width: MediaQuery.sizeOf(context).height * 0.01,
                                          child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                      ):const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(numberOfCachedImages[widget.auction.id] != null) 
                              for(int i=0;i<numberOfCachedImages[widget.auction.id]!;i++)...[
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1c6166),
                                    radius: imageNumber == i? 6:3,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.auction.publisherName,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.auction.title,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.price.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'حد السوم',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      widget.auction.bestOfferOwner,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.bestOfferPrice.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'اخر سومه',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.publisherArea,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () {
                        //print('Button pressed ...');
                      },
                      text: 'سوم الان',
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 15,
                      ),
                      options: FFButtonOptions(
                        width: MediaQuery.sizeOf(context).width * 0.20,
                        height: MediaQuery.sizeOf(context).height * 0.05,
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: const Color(0xFF1C6166),
                        textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        elevation: 3,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ينتهي في',
                          textAlign: TextAlign.end,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FlipClockPlus.reverseCountdown(
                          duration: widget.auction.remainingTime,
                          digitColor: Colors.white,
                          backgroundColor: const Color(0xff1c6166),
                          digitSize: 10.0,
                          width: MediaQuery.sizeOf(context).width * 0.035,
                          height: MediaQuery.sizeOf(context).height * 0.025,
                          centerGapSpace: 0.5,
                          spacing: const EdgeInsets.all(2),
                          daysLabelStr: 'يوم',
                          hoursLabelStr: 'ساعة',
                          minutesLabelStr: 'دقيقة',
                          secondsLabelStr: 'ثانية',
                          separator: Text(
                            ':',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                          onDone: closeAuction,

                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ):
    widget.auctionCardPosition.index == 1?Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionDetails(auction: widget.auction,canSoom: true,coverImage: coverImage,images: images),));
        },
        padding: EdgeInsets.zero,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.auction.isCar?Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: const Color(0xFF719C9F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                          child: Text(
                            widget.auction.type,
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.code,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'كود المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                      height: MediaQuery.sizeOf(context).width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: coverImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(coverImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):widget.auction.images.isNotEmpty && widget.auction.publisherImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(widget.auction.publisherImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.1,
                          width: MediaQuery.sizeOf(context).height * 0.1,
                          child: Image(
                              image: AssetImage(
                                  'assets/images/man.png'
                              ),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).width * 0.18,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1C6166),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      scrollPhysics: const PageScrollPhysics(),
                                      height: MediaQuery.sizeOf(context).width * 0.18,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      initialPage: 0,
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                      autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          imageNumber = index;
                                        });
                                      },
                                    ),
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                                        SizedBox.expand(
                                            child: InteractiveViewer(
                                              child: images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):widget.auction.images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(widget.auction.images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):SizedBox(
                                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                                  width: MediaQuery.sizeOf(context).height * 0.1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: const CircularProgressIndicator(color: Color(0xff1c6166),),
                                                  )
                                              ),
                                            )
                                        ),
                                    itemCount: numberOfCachedImages[widget.auction.id]??widget.auction.images.length,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        await addOrRemoveFavoriteAuction();
                                      },
                                      icon: sending?SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.01,
                                          width: MediaQuery.sizeOf(context).height * 0.01,
                                          child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                      ):const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(numberOfCachedImages[widget.auction.id] != null) 
                              for(int i=0;i<numberOfCachedImages[widget.auction.id]!;i++)...[
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1c6166),
                                    radius: imageNumber == i? 6:3,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.auction.publisherName,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.auction.title,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.price.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'حد السوم',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      widget.auction.bestOfferOwner,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.bestOfferPrice.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'اخر سومه',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.publisherArea,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () {
                        //print('Button pressed ...');
                      },
                      text: 'سوم الان',
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 15,
                      ),
                      options: FFButtonOptions(
                        width: MediaQuery.sizeOf(context).width * 0.20,
                        height: MediaQuery.sizeOf(context).height * 0.05,
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: const Color(0xFF1C6166),
                        textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        elevation: 3,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ينتهي في',
                          textAlign: TextAlign.end,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FlipClockPlus.reverseCountdown(
                          duration: widget.auction.remainingTime,
                          digitColor: Colors.white,
                          backgroundColor: const Color(0xff1c6166),
                          digitSize: 10.0,
                          width: MediaQuery.sizeOf(context).width * 0.035,
                          height: MediaQuery.sizeOf(context).height * 0.025,
                          centerGapSpace: 0.5,
                          spacing: const EdgeInsets.all(2),
                          daysLabelStr: 'يوم',
                          hoursLabelStr: 'ساعة',
                          minutesLabelStr: 'دقيقة',
                          secondsLabelStr: 'ثانية',
                          separator: Text(
                            ':',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                          onDone: closeAuction,

                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ):
    widget.auctionCardPosition.index == 2?Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionDetails(auction: widget.auction,canSoom: false,coverImage: coverImage,images: images),));
        },
        padding: EdgeInsets.zero,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.auction.isCar?Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: const Color(0xFF719C9F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                          child: Text(
                            widget.auction.type,
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.code,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'كود المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                      height: MediaQuery.sizeOf(context).width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: coverImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(coverImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):widget.auction.images.isNotEmpty && widget.auction.publisherImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(widget.auction.publisherImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.1,
                          width: MediaQuery.sizeOf(context).height * 0.1,
                          child: Image(
                              image: AssetImage(
                                  'assets/images/man.png'
                              ),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).width * 0.18,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1C6166),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      scrollPhysics: const PageScrollPhysics(),
                                      height: MediaQuery.sizeOf(context).width * 0.18,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      initialPage: 0,
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                      autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          imageNumber = index;
                                        });
                                      },
                                    ),
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                                        SizedBox.expand(
                                            child: InteractiveViewer(
                                              child: images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):widget.auction.images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(widget.auction.images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):SizedBox(
                                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                                  width: MediaQuery.sizeOf(context).height * 0.1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: const CircularProgressIndicator(color: Color(0xff1c6166),),
                                                  )
                                              ),
                                            )
                                        ),
                                    itemCount: numberOfCachedImages[widget.auction.id]??widget.auction.images.length,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        await addOrRemoveFavoriteAuction();
                                      },
                                      icon: sending?SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.01,
                                          width: MediaQuery.sizeOf(context).height * 0.01,
                                          child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                      ):const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(numberOfCachedImages[widget.auction.id] != null) 
                              for(int i=0;i<numberOfCachedImages[widget.auction.id]!;i++)...[
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1c6166),
                                    radius: imageNumber == i? 6:3,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.auction.publisherName,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.auction.title,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.price.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'حد السوم',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      widget.auction.bestOfferOwner,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.bestOfferPrice.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'اخر سومه',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.publisherArea,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    /*FFButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: 'سوم الان',
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 15,
                      ),
                      options: FFButtonOptions(
                        width: MediaQuery.sizeOf(context).width * 0.20,
                        height: MediaQuery.sizeOf(context).height * 0.05,
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: const Color(0xFF1C6166),
                        textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        elevation: 3,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),*/
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.20,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'يبدا في',
                          textAlign: TextAlign.end,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FlipClockPlus.reverseCountdown(
                          duration: widget.auction.remainingTime,
                          digitColor: Colors.white,
                          backgroundColor: const Color(0xff1c6166),
                          digitSize: 10.0,
                          width: MediaQuery.sizeOf(context).width * 0.035,
                          height: MediaQuery.sizeOf(context).height * 0.025,
                          centerGapSpace: 0.5,
                          spacing: const EdgeInsets.all(2),
                          daysLabelStr: 'يوم',
                          hoursLabelStr: 'ساعة',
                          minutesLabelStr: 'دقيقة',
                          secondsLabelStr: 'ثانية',
                          separator: Text(
                            ':',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                          onDone: closeAuction,

                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ):
    widget.auctionCardPosition.index == 3?Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionDetails(auction: widget.auction,canSoom: true,coverImage: coverImage,images: images),));
        },
        padding: EdgeInsets.zero,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.auction.isCar?Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: const Color(0xFF719C9F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                          child: Text(
                            widget.auction.type,
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                    FlutterFlowIconButton(
                      borderColor: const Color(0x00FFFFFF),
                      borderRadius: 20,
                      borderWidth: 1,
                      buttonSize: 40,
                      fillColor: const Color(0x00FFFFFF),
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: widget.auction.title));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child: Text(
                                'تم نسخ عنوان المزاد قم بنشره الان',
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
                      },
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.35,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.code,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'كود المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                      height: MediaQuery.sizeOf(context).width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: coverImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(coverImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):widget.auction.images.isNotEmpty && widget.auction.publisherImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(widget.auction.publisherImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.1,
                          width: MediaQuery.sizeOf(context).height * 0.1,
                          child: Image(
                              image: AssetImage(
                                  'assets/images/man.png'
                              ),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).width * 0.18,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1C6166),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      scrollPhysics: const PageScrollPhysics(),
                                      height: MediaQuery.sizeOf(context).width * 0.18,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      initialPage: 0,
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                      autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          imageNumber = index;
                                        });
                                      },
                                    ),
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                                        SizedBox.expand(
                                            child: InteractiveViewer(
                                              child: images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):widget.auction.images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(widget.auction.images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):SizedBox(
                                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                                  width: MediaQuery.sizeOf(context).height * 0.1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: const CircularProgressIndicator(color: Color(0xff1c6166),),
                                                  )
                                              ),
                                            )),
                                    itemCount: numberOfCachedImages[widget.auction.id]??widget.auction.images.length,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        await addOrRemoveFavoriteAuction();
                                      },
                                      icon: sending?SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.01,
                                          width: MediaQuery.sizeOf(context).height * 0.01,
                                          child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                      ):const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(numberOfCachedImages[widget.auction.id] != null) 
                              for(int i=0;i<numberOfCachedImages[widget.auction.id]!;i++)...[
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1c6166),
                                    radius: imageNumber == i? 6:3,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.auction.publisherName,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.auction.title,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.price.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'حد السوم',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      widget.auction.bestOfferOwner,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.bestOfferPrice.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'اخر سومه',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.publisherArea,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () {
                        //print('Button pressed ...');
                      },
                      text: 'ترويج المزاد',
                      options: FFButtonOptions(
                        width: MediaQuery.sizeOf(context).width * 0.20,
                        height: MediaQuery.sizeOf(context).height * 0.05,
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: const Color(0xFF1C6166),
                        textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        elevation: 3,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'يبدا في',
                          textAlign: TextAlign.end,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FlipClockPlus.reverseCountdown(
                          duration: widget.auction.remainingTime,
                          digitColor: Colors.white,
                          backgroundColor: const Color(0xff1c6166),
                          digitSize: 10.0,
                          width: MediaQuery.sizeOf(context).width * 0.035,
                          height: MediaQuery.sizeOf(context).height * 0.025,
                          centerGapSpace: 0.5,
                          spacing: const EdgeInsets.all(2),
                          daysLabelStr: 'يوم',
                          hoursLabelStr: 'ساعة',
                          minutesLabelStr: 'دقيقة',
                          secondsLabelStr: 'ثانية',
                          separator: Text(
                            ':',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                          onDone: closeAuction,

                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ):
    widget.auctionCardPosition.index == 4?Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionDetails(auction: widget.auction,canSoom: true,coverImage: coverImage,images: images),));
        },
        padding: EdgeInsets.zero,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.auction.isCar?Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: const Color(0xFF719C9F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                          child: Text(
                            widget.auction.type,
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.code,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'كود المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                      height: MediaQuery.sizeOf(context).width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: coverImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(coverImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):widget.auction.images.isNotEmpty && widget.auction.publisherImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(widget.auction.publisherImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.1,
                          width: MediaQuery.sizeOf(context).height * 0.1,
                          child: Image(
                              image: AssetImage(
                                  'assets/images/man.png'
                              ),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).width * 0.18,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1C6166),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      scrollPhysics: const PageScrollPhysics(),
                                      height: MediaQuery.sizeOf(context).width * 0.18,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      initialPage: 0,
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                      autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          imageNumber = index;
                                        });
                                      },
                                    ),
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                                        SizedBox.expand(
                                            child: InteractiveViewer(
                                              child: images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):widget.auction.images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(widget.auction.images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):SizedBox(
                                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                                  width: MediaQuery.sizeOf(context).height * 0.1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: const CircularProgressIndicator(color: Color(0xff1c6166),),
                                                  )
                                              ),
                                            )),
                                    itemCount: numberOfCachedImages[widget.auction.id]??widget.auction.images.length,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        await addOrRemoveFavoriteAuction();
                                      },
                                      icon: sending?SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.01,
                                          width: MediaQuery.sizeOf(context).height * 0.01,
                                          child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                      ):const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(numberOfCachedImages[widget.auction.id] != null) 
                              for(int i=0;i<numberOfCachedImages[widget.auction.id]!;i++)...[
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1c6166),
                                    radius: imageNumber == i? 6:3,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.auction.publisherName,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.auction.title,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.price.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'حد السوم',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      widget.auction.bestOfferOwner,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.bestOfferPrice.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'اخر سومه',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.publisherArea,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () {
                        //print('Button pressed ...');
                      },
                      text: 'سوم الان',
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 15,
                      ),
                      options: FFButtonOptions(
                        width: MediaQuery.sizeOf(context).width * 0.20,
                        height: MediaQuery.sizeOf(context).height * 0.05,
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: const Color(0xFF1C6166),
                        textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        elevation: 3,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ينتهي في',
                          textAlign: TextAlign.end,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        FlipClockPlus.reverseCountdown(
                          duration: widget.auction.remainingTime,
                          digitColor: Colors.white,
                          backgroundColor: const Color(0xff1c6166),
                          digitSize: 10.0,
                          width: MediaQuery.sizeOf(context).width * 0.035,
                          height: MediaQuery.sizeOf(context).height * 0.025,
                          centerGapSpace: 0.5,
                          spacing: const EdgeInsets.all(2),
                          daysLabelStr: 'يوم',
                          hoursLabelStr: 'ساعة',
                          minutesLabelStr: 'دقيقة',
                          secondsLabelStr: 'ثانية',
                          separator: Text(
                            ':',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                          onDone: closeAuction,

                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ):
    widget.auctionCardPosition.index == 5?Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionDetails(auction: widget.auction,canSoom: false,coverImage: coverImage,images: images),));
        },
        padding: EdgeInsets.zero,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.auction.isCar?Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: const Color(0xFF719C9F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                          child: Text(
                            widget.auction.type,
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                    FlutterFlowIconButton(
                      borderColor: const Color(0x00FFFFFF),
                      borderRadius: 20,
                      borderWidth: 1,
                      buttonSize: 40,
                      fillColor: const Color(0x00FFFFFF),
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: widget.auction.title));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child: Text(
                                'تم نسخ عنوان المزاد قم بنشره الان',
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
                      },
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.35,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.code,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'كود المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                      height: MediaQuery.sizeOf(context).width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: coverImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(coverImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):widget.auction.images.isNotEmpty && widget.auction.publisherImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(widget.auction.publisherImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.1,
                          width: MediaQuery.sizeOf(context).height * 0.1,
                          child: Image(
                              image: AssetImage(
                                  'assets/images/man.png'
                              ),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).width * 0.18,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1C6166),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      scrollPhysics: const PageScrollPhysics(),
                                      height: MediaQuery.sizeOf(context).width * 0.18,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      initialPage: 0,
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                      autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          imageNumber = index;
                                        });
                                      },
                                    ),
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                                        SizedBox.expand(
                                            child: InteractiveViewer(
                                              child: images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):widget.auction.images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(widget.auction.images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):SizedBox(
                                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                                  width: MediaQuery.sizeOf(context).height * 0.1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: const CircularProgressIndicator(color: Color(0xff1c6166),),
                                                  )
                                              ),
                                            )),
                                    itemCount: numberOfCachedImages[widget.auction.id]??widget.auction.images.length,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        await addOrRemoveFavoriteAuction();
                                      },
                                      icon: sending?SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.01,
                                          width: MediaQuery.sizeOf(context).height * 0.01,
                                          child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                      ):const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(numberOfCachedImages[widget.auction.id] != null) 
                              for(int i=0;i<numberOfCachedImages[widget.auction.id]!;i++)...[
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1c6166),
                                    radius: imageNumber == i? 6:3,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.auction.publisherName,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.auction.title,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.price.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'حد السوم',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      widget.auction.bestOfferOwner,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.bestOfferPrice.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'اخر سومه',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.publisherArea,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Transform.rotate(
                                  angle: 0.2,
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width * 0.01,
                                    height: MediaQuery.sizeOf(context).height * 0.015,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffbc053d),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: -0.2,
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width * 0.01,
                                    height: MediaQuery.sizeOf(context).height * 0.015,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffbc053d),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).height * 0.03,
                              decoration: BoxDecoration(
                                  color: const Color(0xffbc053d),
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Center(
                                child: Text(
                                  'المزاد منتهي',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ):
    widget.auctionCardPosition.index == 6?Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionDetails(auction: widget.auction,canSoom: false,coverImage: coverImage,images: images),));
        },
        padding: EdgeInsets.zero,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.auction.isCar?Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: const Color(0xFF719C9F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                          child: Text(
                            widget.auction.type,
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                    FlutterFlowIconButton(
                      borderColor: const Color(0x00FFFFFF),
                      borderRadius: 20,
                      borderWidth: 1,
                      buttonSize: 40,
                      fillColor: const Color(0x00FFFFFF),
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: widget.auction.title));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child: Text(
                                'تم نسخ عنوان المزاد قم بنشره الان',
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
                      },
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.35,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.code,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'كود المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                      height: MediaQuery.sizeOf(context).width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: coverImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(coverImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):widget.auction.images.isNotEmpty && widget.auction.publisherImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(widget.auction.publisherImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.1,
                          width: MediaQuery.sizeOf(context).height * 0.1,
                          child: Image(
                              image: AssetImage(
                                  'assets/images/man.png'
                              ),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).width * 0.18,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1C6166),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      scrollPhysics: const PageScrollPhysics(),
                                      height: MediaQuery.sizeOf(context).width * 0.18,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      initialPage: 0,
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                      autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          imageNumber = index;
                                        });
                                      },
                                    ),
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                                        SizedBox.expand(
                                            child: InteractiveViewer(
                                              child: images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):widget.auction.images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(widget.auction.images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):SizedBox(
                                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                                  width: MediaQuery.sizeOf(context).height * 0.1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: const CircularProgressIndicator(color: Color(0xff1c6166),),
                                                  )
                                              ),
                                            )),
                                    itemCount: numberOfCachedImages[widget.auction.id]??widget.auction.images.length,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        await addOrRemoveFavoriteAuction();
                                      },
                                      icon: sending?SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.01,
                                          width: MediaQuery.sizeOf(context).height * 0.01,
                                          child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                      ):const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(numberOfCachedImages[widget.auction.id] != null) 
                              for(int i=0;i<numberOfCachedImages[widget.auction.id]!;i++)...[
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1c6166),
                                    radius: imageNumber == i? 6:3,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.auction.publisherName,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.auction.title,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.price.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'حد السوم',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      widget.auction.bestOfferOwner,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.bestOfferPrice.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'اخر سومه',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.publisherArea,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Transform.rotate(
                                  angle: 0.2,
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width * 0.01,
                                    height: MediaQuery.sizeOf(context).height * 0.015,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffbc053d),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: -0.2,
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width * 0.01,
                                    height: MediaQuery.sizeOf(context).height * 0.015,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffbc053d),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).height * 0.03,
                              decoration: BoxDecoration(
                                  color: const Color(0xffbc053d),
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Center(
                                child: Text(
                                  'المزاد منتهي',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ):
    Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
      child: MaterialButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuctionDetails(auction: widget.auction,canSoom: false,coverImage: coverImage,images: images),));
        },
        padding: EdgeInsets.zero,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    widget.auction.isCar?Container(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: const Color(0xFF719C9F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: const AlignmentDirectional(0.00, 0.00),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                          child: Text(
                            widget.auction.type,
                            style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ):SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.2,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                    ),
                    FlutterFlowIconButton(
                      borderColor: const Color(0x00FFFFFF),
                      borderRadius: 20,
                      borderWidth: 1,
                      buttonSize: 40,
                      fillColor: const Color(0x00FFFFFF),
                      icon: const Icon(
                        Icons.share_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text: widget.auction.title));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(child: Text(
                                'تم نسخ عنوان المزاد قم بنشره الان',
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
                      },
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.35,
                      height: MediaQuery.sizeOf(context).height * 0.03,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 0, 2, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.code,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'كود المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                      height: MediaQuery.sizeOf(context).width * 0.15,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: coverImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(coverImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):widget.auction.images.isNotEmpty && widget.auction.publisherImage.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.1,
                          height: MediaQuery.sizeOf(context).width * 0.1,
                          child: Image(
                              image: MemoryImage(
                                  base64Decode(widget.auction.publisherImage)
                              ),
                              fit: BoxFit.cover
                          ),
                        ),
                      ):SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.1,
                          width: MediaQuery.sizeOf(context).height * 0.1,
                          child: Image(
                              image: AssetImage(
                                  'assets/images/man.png'
                              ),
                              fit: BoxFit.cover
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).width * 0.18,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFF1C6166),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      scrollPhysics: const PageScrollPhysics(),
                                      height: MediaQuery.sizeOf(context).width * 0.18,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: false,
                                      autoPlay: true,
                                      initialPage: 0,
                                      pauseAutoPlayOnTouch: true,
                                      pauseAutoPlayOnManualNavigate: true,
                                      autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          imageNumber = index;
                                        });
                                      },
                                    ),
                                    itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
                                        SizedBox.expand(
                                            child: InteractiveViewer(
                                              child: images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):widget.auction.images.isNotEmpty?ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: MediaQuery.sizeOf(context).width * 0.18,
                                                  height: MediaQuery.sizeOf(context).width * 0.18,
                                                  child: Image(
                                                      image: MemoryImage(
                                                          base64Decode(widget.auction.images[itemIndex])
                                                      ),
                                                      fit: BoxFit.cover
                                                  ),
                                                ),
                                              ):SizedBox(
                                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                                  width: MediaQuery.sizeOf(context).height * 0.1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: const CircularProgressIndicator(color: Color(0xff1c6166),),
                                                  )
                                              ),
                                            )),
                                    itemCount: numberOfCachedImages[widget.auction.id]??widget.auction.images.length,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        5, 5, 5, 5),
                                    child: IconButton(
                                      onPressed: () async {
                                        await addOrRemoveFavoriteAuction();
                                      },
                                      icon: sending?SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.01,
                                          width: MediaQuery.sizeOf(context).height * 0.01,
                                          child: const CircularProgressIndicator(color: Color(0xff1c6166),)
                                      ):const Icon(
                                        Icons.favorite_border_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if(numberOfCachedImages[widget.auction.id] != null) 
                              for(int i=0;i<numberOfCachedImages[widget.auction.id]!;i++)...[
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircleAvatar(
                                    backgroundColor: const Color(0xff1c6166),
                                    radius: imageNumber == i? 6:3,
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.auction.publisherName,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                widget.auction.title,
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.price.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'حد السوم',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      widget.auction.bestOfferOwner,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 15,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'SAR',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        color: const Color(0xFF1C6166),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.00, 0.00),
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(
                                            2, 2, 2, 2),
                                        child: Text(
                                          widget.auction.bestOfferPrice.toString(),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                            fontFamily: 'Readex Pro',
                                            color: const Color(0xFF1C6166),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      ':',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                    const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                    child: Text(
                                      'اخر سومه',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 3),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width * 0.25,
                      height: MediaQuery.sizeOf(context).height * 0.05,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF719C9F),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: const AlignmentDirectional(0.00, 0.00),
                                child: Padding(
                                  padding:
                                  const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                                  child: Text(
                                    widget.auction.publisherArea,
                                    textAlign: TextAlign.end,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Readex Pro',
                                      color: const Color(0xFF1C6166),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                ':',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                              child: Text(
                                'المزاد',
                                textAlign: TextAlign.end,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                  fontFamily: 'Readex Pro',
                                  color: const Color(0xFF1C6166),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Transform.rotate(
                                  angle: 0.2,
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width * 0.01,
                                    height: MediaQuery.sizeOf(context).height * 0.015,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffbc053d),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: -0.2,
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width * 0.01,
                                    height: MediaQuery.sizeOf(context).height * 0.015,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffbc053d),
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.18,
                              height: MediaQuery.sizeOf(context).height * 0.03,
                              decoration: BoxDecoration(
                                  color: const Color(0xffbc053d),
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: Center(
                                child: Text(
                                  'رسي علي',
                                  textAlign: TextAlign.end,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      fontFamily: 'Readex Pro',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
