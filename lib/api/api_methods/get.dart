import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

Future<Map> get(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));
  //log(response.statusCode.toString());
  //log(response.body.toString());
  Map<String, dynamic> resMap;
  if(response.body.isNotEmpty){
    if(response.body[0] != '{') {
      resMap = {
        'code' : response.statusCode,
        'body' : {}
      };
    } else {
      resMap = {
        'code' : response.statusCode,
        'body' : jsonDecode(response.body)
      };
    }
  }else {
    resMap = {
      'code' : response.statusCode,
      'body' : {}
    };
  }
  return resMap;
}
