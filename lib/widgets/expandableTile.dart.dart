import 'package:flutter/material.dart';

class ExpandableTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const ExpandableTile({super.key, required this.title, required this.children});
  @override
  Widget build(BuildContext context){
    return ListTileTheme(
      tileColor: Colors.blue,
      child: Padding(
      padding: const EdgeInsets.only(top: 2, left: 6.0, right: 6.0, bottom: 2),
          child: ExpansionTile(
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold),
          ),
          
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          children: children,
      ),
      )
    );
  }
}