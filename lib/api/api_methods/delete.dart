import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

Future<Map> delete(String apiUrl, Map<String, dynamic> map) async {
  final headers = {'Content-Type': 'application/json'};
  final response = await http.delete(Uri.parse(apiUrl),
      headers: headers, body: jsonEncode(map));
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
