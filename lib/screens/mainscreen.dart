import 'package:flutter/material.dart';
import 'package:gunnars_test/main.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Start game fyfan!'),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/game');
          },
        ),
      ),
    );
  }
}