import 'package:flutter/material.dart';
import 'package:flutter_webview/screen/webview.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  Future<void> customdelay(BuildContext context) async {
    Future.delayed(Duration(seconds: 8)).then((value) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => WebViewExample()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: customdelay(context),
        builder: (ctx, snapshot) => Center(
          child: Image.asset('assets/images/kol.gif'),
        ),
      ),
    );
  }
}
