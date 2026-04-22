

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:sense2quit/widgets/expandableTile.dart.dart';
import 'package:flutter/material.dart';
import 'package:sense2quit/widgets/VideoTile.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part 'tips_state.dart';

class TipsCubit extends Cubit<TipsState> {
  TipsCubit() : super(TipsState(isMute: true));
  List<String>? tips;
  List<Map>? videos;
  String? dailyTip; 
  int tipsRefreshTimeSeconds = 86400;
  
  void mute(bool cur){
    emit(TipsState(tips: tips,isMute: !cur));
  }

  List<VideoTile> getVideoList(YoutubePlayerController controller) {
    List<VideoTile> a = <VideoTile>[]; 
    for (int i = 0; i < videos!.length; i++){
      Map e = videos![i];
      a.add(
      VideoTile(
        imagePath: "https://img.youtube.com/vi/${e['vid']}/mqdefault.jpg", 
        name: videos![i]['name'], 
        onTap: () => {
          controller.load(YoutubePlayer.convertUrlToId('https://www.youtube.com/watch?v=${e['vid']}')!),
        }
      )
        
      );
    }
    videos!.map((e) => {
      safePrint(e),

      
    });
    return a;
  }

  void getTipsVideoData() async {
    final String tipsResponse = await rootBundle.loadString('lib/assets/data.json');
    final String videoResponse = await rootBundle.loadString('lib/assets/video_data.json');
    final tipsMap = await jsonDecode(tipsResponse);
    final videoMap = await jsonDecode(videoResponse);
    tips ??= List<String>.from(tipsMap['tips']);
    videos ??= List<Map>.from(videoMap['videos']);
    emit(TipsState(tips: tips, videos:videos, isMute: false));

  }
  String getDailyTip(){
    int curTimestamp = DateTime.now().millisecondsSinceEpoch;
    int index = (curTimestamp~/86400000)%tips!.length;
    return tips![index];
  }
  Widget getTipsWidget() {
    if (tips == null){
      return Container();
    }
    return ExpandableTile(
      title: 'TIPS',
      children: [
        ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: tips!.map((e) => 
                    Text(
                      e,
                      style: const TextStyle(color: Colors.black, fontSize: 16), 
                      )
                    )
                    .toList(),
                  ) 
                ),  
              ),
            )
            ]
    );
  }
}
