part of 'tips_cubit.dart';

final class TipsState {
  List<String>? tips;
  String? dailyTips;
  List<Map>? videos;
  bool isMute = false;
  TipsState({this.tips, this.videos,required this.isMute});
}

