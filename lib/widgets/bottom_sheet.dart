import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview/widgets/webview_bottom.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomView extends StatelessWidget {
  Completer<WebViewController> _controller;

  BottomView(this._controller);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WebViewBottom(_controller, true),
        ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.share),
          ),
          title: Text('Share App ', style: TextStyle(fontSize: 20)),
          onTap: () {
            Share.share(
                'Hi Download this App Now \n https://play.google.com/store/apps/details?id=com.duolingo');
          },
        ),
        Divider(),
        ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.open_in_browser),
          ),
          title: Text(
            'Open in Browser',
            style: TextStyle(fontSize: 20),
          ),
          onTap: () {
            _launchUrl();
          },
        ),
        Divider(),
      ],
    );
  }

  Future<void> _launchUrl() async {
    await canLaunch('https://www.beingguru.com/')
        ? await launch('https://www.beingguru.com/')
        : print('error while launching the url');
  }
}
