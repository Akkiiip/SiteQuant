import 'package:flutter/material.dart';
import '../services/excavation_calculator.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dimension_input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';
import 'excavation_result_screen.dart';
enum _Type { rectangular, trench, circularPit }
extension on _Type { String get label => this == _Type.rectangular ? 'Rectangular' : this == _Type.trench ? 'Trench' : 'Circular Pit'; }
class ExcavationScreen extends StatefulWidget { const ExcavationScreen({super.key}); @override State<ExcavationScreen> createState() => _ExcavationScreenState(); }
class _ExcavationScreenState extends State<ExcavationScreen> {
 final _one=TextEditingController(),_two=TextEditingController(),_depth=TextEditingController(); _Type _type=_Type.rectangular;
 @override void dispose(){_one.dispose();_two.dispose();_depth.dispose();super.dispose();}
 double? _v(TextEditingController c,String n){final v=double.tryParse(c.text.trim());if(v==null||v<=0){ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content:Text('Enter a value greater than zero for $n.')));return null;}return v;}
 void _go(){final a=_v(_one,_type==_Type.circularPit?'Diameter':'Length'),b=_type==_Type.circularPit?0.0:_v(_two,'Width'),d=_v(_depth,'Depth');if(a==null||b==null||d==null)return;final r=_type==_Type.circularPit?ExcavationCalculator.circularPit(diameter:a,depth:d):_type==_Type.trench?ExcavationCalculator.trench(length:a,width:b,depth:d):ExcavationCalculator.rectangular(length:a,width:b,depth:d);Navigator.push(context,MaterialPageRoute(builder:(_)=>ExcavationResultScreen(result:r,type:_type.label)));}
 @override Widget build(BuildContext c)=>AppScaffold(title:'Excavation Calculator',bodyBuilder:(c,p)=>SingleChildScrollView(padding:p,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Excavation Takeoff',style:Theme.of(c).textTheme.headlineMedium),const SizedBox(height:20),Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SectionHeader(title:'Excavation Type',icon:Icons.landscape_rounded,compact:true),const SizedBox(height:12),Wrap(spacing:8,runSpacing:8,children:_Type.values.map((t)=>ChoiceChip(label:Text(t.label),selected:_type==t,onSelected:(_)=>setState((){_type=t;_one.clear();_two.clear();_depth.clear();}))).toList())]))),const SizedBox(height:16),Card(child:Padding(padding:const EdgeInsets.all(18),child:Column(children:[DimensionInputField(controller:_one,label:_type==_Type.circularPit?'Diameter':'Length'),if(_type!=_Type.circularPit)...[const SizedBox(height:14),DimensionInputField(controller:_two,label:'Width')],const SizedBox(height:14),DimensionInputField(controller:_depth,label:'Depth')]))),const SizedBox(height:24),PrimaryButton(onPressed:_go,icon:Icons.calculate_rounded,label:'Calculate Volume')])));
}
