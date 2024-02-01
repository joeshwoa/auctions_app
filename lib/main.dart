import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mazad/api/api_methods/put.dart';
import 'package:mazad/api/api_paths.dart';
import 'package:mazad/api/send_and_resive_image_methods/decode.dart';
import 'package:mazad/variable/account_details.dart';
import 'package:mazad/variable/shared_preferences.dart';
import 'package:mazad/variable/token.dart';
import 'package:mazad/view/pages/splash_screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  token = sharedPreferences.getString('token') ?? '';
  log(token);
  if(token.isNotEmpty) {
    Map<String,dynamic> data = {
      'token': token,
    };
    Map responseMap = await put(ApiPaths.checkExpired,data).onError((error, stackTrace) {
      return {
        'code':0,
        'error':error
      };
    });
    if(responseMap['code']>=200 && responseMap['code']<300) {
      id = responseMap['body']['data']['_id'];
      name = responseMap['body']['data']['name'];
      email = responseMap['body']['data']['email'];
      phone = responseMap['body']['data']['phone'];
      active = responseMap['body']['data']['active'];
      if(responseMap['body']['data']['profileImg'] != null) profileImg = decode(responseMap['body']['data']['profileImg']);

      tokenNotExpired = true;
    } else {
      tokenNotExpired = false;
    }
    log(responseMap.toString());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mazad',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1c6166)),
        useMaterial3: true,
      ),
      home: SplashScreen(haveToken: token.isNotEmpty, tokenNotExpired: token.isNotEmpty?tokenNotExpired:false),
    );
  }
}
