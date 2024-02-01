import 'package:mazad/model/auction_model.dart';
import 'package:mazad/variable/cached_image.dart';

Auction createAuction(Map<String, dynamic> json) {
  final String id = json['_id']??'';
  final String code = json['code'] != null?json['code'].toString():'';
  final String title = json['title']??'';
  final String description = json['description']??'';
  final double price = json['price']*1.0??0;
  final String bestOfferOwner = json['bestOfferOwner']??'';
  final double bestOfferPrice = json['bestOffer'] != null?json['bestOffer']*1.0:price;
  final bool isCar = json['isCar']??false;
  final String category = isCar?'':json['category'] != null?json['category']['name']:'';
  final String subCategory = isCar?'':json['subCategory'] != null?json['subCategory']['name']:'';
  final String type = isCar?json['type']??'':'';
  final String carBrand = isCar?json['carBrand'] != null?json['carBrand']['name']:'':'';
  final String carSubBrand = isCar?json['carSubBrand'] != null?json['carSubBrand']['name']:'':'';
  final String shape = isCar?json['shape'] != null?json['shape']['name']:'':'';
  final String model = isCar?json['model'] != null?json['model']['year'].toString():'':'';
  final String gaz = isCar?json['gaz']??'':'';
  final bool auto = isCar?json['auto']??true:true;
  final bool sell = isCar?json['sell']??true:true;
  final int walkFrom = isCar?json['walkFrom']??0:0;
  final int walkTo = isCar?json['walkTo']??0:0;
  final String publisherArea = json['user']['area']??'';
  final String publisherCity = json['user']['city']??'';
  final String publisherName = json['user']['name']??'';
  final DateTime time = json['remainingTime']!=null?DateTime.parse(json['remainingTime']):DateTime.now();
  final Duration remainingTime = Duration(days: time.day, hours: time.hour, minutes: time.minute, seconds: time.second);
  final bool cancelOptions = json['cancel']??false;
  final String winner = json['winner'] != null?json['winner']['name']:'';

  return Auction(id, code, title, description, price, bestOfferOwner, bestOfferPrice,remainingTime, publisherArea, publisherCity, publisherName, '', category, subCategory, isCar, type, carBrand, carSubBrand, shape, model, gaz, auto, sell, walkFrom, walkTo, cachedImages.contains(id), '', [], cancelOptions, winner);
}