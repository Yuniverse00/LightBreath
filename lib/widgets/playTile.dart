import 'package:flutter/material.dart';

class PlayTile extends StatelessWidget {
  final String imagePath;
  final String name;
  final Function() onTap;
  const PlayTile({super.key, required this.imagePath, required this.name, required this.onTap});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25,10,25,10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(imagePath, fit: BoxFit.contain, height: 40, width: 40,),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                ],
              ),
              GestureDetector(
                onTap: onTap,
                child: Image.asset(
                  'lib/assets/button_play.png',
                  fit: BoxFit.contain, 
                  height: 50, 
                  width: 100,
                  ), 
                
              ) 
            ],
          ),
        ),
      ),
    );
  }
}


