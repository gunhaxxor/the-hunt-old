import 'package:flutter/material.dart';
import 'package:gunnars_test/main.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Hunt'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 80.0, bottom: 30.0),
                child: Row(
                  mainAxisAlignment :MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "The Hunt",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 72,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = Colors.orange[600],
                      ),  
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 80.0, bottom: 30.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Game Name',
                        ),
                        onChanged: (value) {
                          print(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Host'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ),
                  RaisedButton(
                    child: const Text('Join'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/game');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}