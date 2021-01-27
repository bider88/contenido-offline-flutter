import 'package:flutter/material.dart';

class ContentDownloadedPage extends StatefulWidget {
  final String title;

  ContentDownloadedPage({Key key, this.title}) : super(key: key);

  @override
  _ContentDownloadedPageState createState() => _ContentDownloadedPageState();
}

class _ContentDownloadedPageState extends State<ContentDownloadedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
    );
  }
}