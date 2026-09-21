import 'package:flutter/material.dart';
import '../models/masonry_result.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/masonry_diagram.dart';
import 'masonry_calculator_screen.dart';
class MasonryV2Screen extends StatelessWidget {
 const MasonryV2Screen({super.key});
 @override Widget build(BuildContext context)=>AppScaffold(title:'Masonry',bodyBuilder:(context,padding)=>ListView(padding:padding,children:[Text('Select masonry type',style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:12),for(final type in MasonryType.values) _card(context,type)]));
 Widget _card(BuildContext context,MasonryType type)=>Padding(padding:const EdgeInsets.only(bottom:12),child:Card(child:InkWell(borderRadius:BorderRadius.circular(12),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>MasonryCalculatorScreen(type:type))),child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(type.label,style:Theme.of(context).textTheme.titleLarge),Text(type==MasonryType.clayBrick?'Traditional brick masonry':'Reference estimate with editable assumptions'),MasonryDiagram(type:type)])))));
}
