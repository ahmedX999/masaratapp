import 'package:flutter/material.dart';
import 'screens/post_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Video Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LiveVideoPlayer(),
    );
  }
}

class LiveVideoPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://ok.ru/live/7800224095758',
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
