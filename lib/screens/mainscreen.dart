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
          color: Colors.amberAccent[200],
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
                          ..color = Colors.orange[700],
                      ),  
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment :MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Are you ready for some action? One player is the prey, who needs to go to all waypoints. The other players are hunters, who try to get close enough to the prey to catch it.",
                        style: TextStyle(
                          fontSize: 16,
                        ),  
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 0.0, bottom: 80.0),
                child: Row(
                  mainAxisAlignment :MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Come up with a name and host a game, or fill in the name of an existing game and join it.",
                        style: TextStyle(
                          fontSize: 16,
                        ),  
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 0.0, bottom: 30.0),
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
                    color: Colors.orange[700],
                    child: Text('Host'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/lobby');
                    },
                  ),
                  RaisedButton(
                    color: Colors.orange[700],
                    child: const Text('Join'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/lobby');
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