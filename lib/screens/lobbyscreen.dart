import 'package:flutter/material.dart';
import 'package:gunnars_test/main.dart';

class LobbyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby'),
      ),
      body: Center(
        child: Container(
          color: Colors.amberAccent[200],
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(top: 20.0, bottom: 0.0),
                child: Row(
                  mainAxisAlignment :MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "The Hunt",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 42,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = Colors.orange[700],
                      ),  
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment :MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Lobby",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),  
                    ),
                  ],
                ),
              ),
              Expanded(
                child:Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Player name",
                            style: TextStyle(fontWeight: FontWeight.bold,),
                          ),
                          Text(
                            "Hunter/Prey",
                            style: TextStyle(fontWeight: FontWeight.bold,),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Gunnhaxxor'),
                          Switch(
                            value: true,
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.orange[100],
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                    RaisedButton(
                      color: Colors.orange[700],
                      child: Text('Start game'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/game');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}