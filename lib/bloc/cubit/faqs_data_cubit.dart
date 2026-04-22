
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:sense2quit/widgets/expandableTile.dart.dart';
import 'package:flutter/material.dart';

part 'faqs_data_state.dart';

class FaqsDataCubit extends Cubit<FaqsDataState> {
  FaqsDataCubit() : super(FaqsDataInitial());
  Map? data;
  void getFaqData() async {
    final String response = await rootBundle.loadString('lib/assets/faq_data.json');
    final a = await jsonDecode(response);
    data ??= a;
    emit(FaqsDataState(data: data));
  }
  Widget getFAQ(Map? data){
    
    List<ExpandableTile> list = <ExpandableTile>[];
    if(data == null){
      return Column(children: list,);
    }
    for(var i = 0; i < data['items'].length; i++){
        final map = data['items'][i];
        list.add(ExpandableTile(
          title: map['Question'], 
          children: <Widget>[
              Text(map['Answer'],style: const TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.bold)),
            ],
          )
        );
    }
    return Column(children: list);
  }
}
