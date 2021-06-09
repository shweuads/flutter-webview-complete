import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview/helpers/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/bottom_sheet.dart';

class WebViewBottom extends StatefulWidget {
  Completer<WebViewController> _webviewFuture;
  final bool isOpen;
  WebViewBottom(this._webviewFuture, [this.isOpen = false]);
  @override
  _WebViewBottomState createState() => _WebViewBottomState();
}
class _WebViewBottomState extends State<WebViewBottom> {
  int _currentIndex = 0;
  late InterstitialAd _interstitialAd;
  bool _isInterstitialAdReady = false;
  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            this._interstitialAd = ad;
            _isInterstitialAdReady = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
            _isInterstitialAdReady = false;

          },
        ));
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: widget._webviewFuture.future,
      builder: (ctx, snapshot) => snapshot.connectionState ==
              ConnectionState.done
          ? BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.arrow_back_ios), label: 'Previous'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.arrow_forward_ios), label: 'forward'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.refresh), label: 'Refresh'),
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
              ],
              onTap: (index) async {
                if (_isInterstitialAdReady) _interstitialAd.show();

                if (index == 0) {
                  setState(() {
                    _currentIndex = index;
                  });
                  await snapshot.data!.goBack();
                } else if (index == 1) {
                  setState(() {
                    _currentIndex = index;
                  });
                  await snapshot.data!.goForward();
                } else if (index == 2) {
                  setState(() {
                    _currentIndex = index;
                  });
                  await snapshot.data!.reload();
                } else {
                  if (!widget.isOpen) {
                    setState(() {
                      _currentIndex = index;
                    });
                    showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return  Wrap(
                              children: <Widget>[
                                Container(
                                    child: BottomView(widget._webviewFuture),
                                )
                              ]
                          );
                        });
                  }
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              currentIndex: _currentIndex,
            )
          : Container(),
    );
  }
}
