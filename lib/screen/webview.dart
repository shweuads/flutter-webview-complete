import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webview/helpers/ad_helper.dart';
import 'package:flutter_webview/widgets/webview_bottom.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/connection.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class WebViewExample extends StatefulWidget {
  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  var url = 'https://www.beingguru.com/';
  var currentProgress = 0;
  var init = true;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _initGoogleMobileAds();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd.load();
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  @override
  void didChangeDependencies() {
    if (init) _showPrivacyPoloicy();
    init = false;
    super.didChangeDependencies();
  }

  void _showPrivacyPoloicy() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('privacy')) {
    } else {
      // show the privacy and save to shared pref
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Text("""Why do we use it?
                    It is a long established fact that a reader will be
                    distracted by the readable content of a page when looking
                    at its layout. The point of using Lorem Ipsum
                    is that it has a more-or-less normal distribution of letters,
                    as opposed to using 'Content here, content here', making it
                    look like readable English. Many desktop publishing packages and
                    web page editors now use Lorem Ipsum as their default model
                    text, and a
                    search for 'lorem ipsum' will uncover many web sites
                    still in their infancy. Various versions have evolved over the
                    years, sometimes by accident, sometimes on purpose (injected
                    humour and the like)"""),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(' Agree'))
          ],
        ),
      );

      /// then saving the status in prefs
      await prefs.setBool('privacy', true);
    }
  }

  void _setProgress(int progess) {
    setState(() {
      currentProgress = progess;
    });
  }

  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    final _connected = Provider.of<Connection>(context).getConnection;
    return WillPopScope(
      onWillPop: _backPressed,
      child: Scaffold(
        body: SafeArea(
          child: !_connected
              ? Center(
                  child: Lottie.asset(
                    'assets/no_internet.json',
                    width: 250,
                    height: 350,
                  ),
                )
              : Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 50),
                      child: WebView(
                        initialUrl: url,
                        javascriptMode: JavascriptMode.unrestricted,
                        onPageStarted: (url) {
                          print("this is message : " + url);
                        },
                        onPageFinished: (str) {
                          print('this is the end url ' + url);
                        },
                        onProgress: _setProgress,
                        onWebViewCreated: (webViewController) async {
                          // finally signal a complete() to the completer
                          _controller.complete(webViewController);
                        },
                      ),
                    ),
                    if (_isBannerAdReady)
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: _bannerAd.size.width.toDouble(),
                          height: _bannerAd.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd),
                        ),
                      ),
                    Center(
                      child: currentProgress < 100
                          ? Lottie.asset('assets/loading.json')
                          : Container(),
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: _connected ? WebViewBottom(_controller) : null,
      ),
    );
  }

  Future<bool> _backPressed() async {
    return true;
  }
  @override
  void dispose() {
    _bannerAd.dispose();

    super.dispose();
  }
}
