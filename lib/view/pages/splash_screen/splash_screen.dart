import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mazad/view/pages/layout/layout.dart';
import 'package:mazad/view/pages/sign_in/sign_in.dart';
import 'package:mazad/view/pages/sign_up/sign_up.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key,required this.haveToken,required this.tokenNotExpired});
  final bool haveToken;
  final bool tokenNotExpired;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    if(!widget.haveToken){
      Timer(const Duration(seconds: 3), ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp())));
    }else if(widget.haveToken && widget.tokenNotExpired){
      Timer(const Duration(seconds: 3), ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Layout())));
    }else if(widget.haveToken && !widget.tokenNotExpired){
      Timer(const Duration(seconds: 3), ()=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignIn())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:Scaffold( resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xff1c6166),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              child: const Image(image: AssetImage('assets/images/background for splash screen.png'),fit: BoxFit.cover),
            ),
            Container(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        const Color(0xff1c6166).withOpacity(0.8),
                        Colors.white.withOpacity(0.8)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                  )
              ),
            ),
            /*Center(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).width*50/100,
                width: MediaQuery.sizeOf(context).width*50/100,
                child: const Image(image: AssetImage(AppImages.logo),fit: BoxFit.contain),
              ),
            )*/
          ],
        ),
      ),
    ));
  }
}
