import 'package:flutter/material.dart';

class Index extends StatelessWidget {
const Index({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Information")),
      body: const Column(
        children: [
          ListTile(
            title: Text("test1"),
          ),
          ListTile(
            title: Text("test3"),
          ),
          ListTile(
            title: Text("View source code on GitHub"),
            leading: Icon(Icons.link),
          ),
          ListTile(
            title: Text("View documentation on GitHub"),
            leading: Icon(Icons.link),
          ),
        ],
      ),
    );
  }
}