import 'package:flutter/material.dart';

class VideoTile extends StatelessWidget {
final String imagePath;
  final String name;
  final Function() onTap;
  const VideoTile({super.key, required this.imagePath, required this.name, required this.onTap});


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0,1,0,1),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(imagePath,fit: BoxFit.contain, height: 50, width: 100,),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                    )
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