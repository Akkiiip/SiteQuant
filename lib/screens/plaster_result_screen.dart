import 'package:flutter/material.dart';
import '../models/plaster_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_cost_calculator.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';

class PlasterResultScreen extends StatelessWidget {
  final PlasterResult result; final PlasterType type; final MeasurementSystem system;
  const PlasterResultScreen({super.key,required this.result,required this.type,required this.system});
  String _area(double value)=>'${EstimateFormat.number(value,2)} m²';
  String _number(double value,[int precision=2])=>EstimateFormat.number(value,precision);
  @override Widget build(BuildContext context){
    final productivity=result.productivity; final labour=result.labour;
    final displayArea=MeasurementPreferences.fromSquareMetres(result.area,system);
    final unitCost=EstimateCostCalculator.perUnit(result.totalCost,displayArea);
    return AppScaffold(title:'Calculation Result',bodyBuilder:(context,padding)=>ListView(padding:padding,children:[
      Text('Plaster Takeoff V2',style:Theme.of(context).textTheme.headlineMedium),const SizedBox(height:16),
      _section(context,'Plaster Quantity',Icons.format_paint_outlined,[
        _row(context,'Net Area',_area(result.area)),
        _row(context,'Thickness','${_number(result.thicknessMm)} mm'),
        _row(context,'Cement','${_number(result.cementBags)} bags'),
        _row(context,'Sand','${_number(result.sandM3)} m3'),
      ]),
      _section(context,'Material Cost',Icons.payments_outlined,[
        _row(context,'Material Cost',EstimateFormat.money(result.materialCost)),
      ]),
      _section(context,'Labour & Time',Icons.groups_outlined,[
        _row(context,'Crew','${productivity.crew[LabourRole.mason]} Mason(s) + ${productivity.crew[LabourRole.helper]} Helper(s)'),
        _row(context,'Working Days','${_number(productivity.workingDays)} days'),
        _row(context,'Labour Cost',EstimateFormat.money(labour.totalCost)),
      ]),
      _section(context,'Calculation Details',Icons.expand_more_rounded,[
        ExpansionTile(title:const Text('Calculation Details'),children:[
          _row(context,'Productivity basis',productivity.standard.name),Text(productivity.standard.basis),
          _row(context,'Mason mandays',_number(productivity.mandays[LabourRole.mason]!)),
          _row(context,'Helper mandays',_number(productivity.mandays[LabourRole.helper]!)),
          _row(context,'Mason daily wage','${EstimateFormat.money(labour.dailyWages[LabourRole.mason]!)} / day'),
          _row(context,'Helper daily wage','${EstimateFormat.money(labour.dailyWages[LabourRole.helper]!)} / day'),
          _row(context,'Mason labour cost',EstimateFormat.money(labour.costs[LabourRole.mason]!)),
          _row(context,'Helper labour cost',EstimateFormat.money(labour.costs[LabourRole.helper]!)),
          _row(context,'Gross Area',_area(result.grossArea)),_row(context,'Deductions',_area(result.deductionArea)),
          _row(context,'Wet Volume',_number(result.wetVolume)),_row(context,'Dry Volume',_number(result.dryVolume)),
          const Text('Working days use the controlling role requirement for the selected crew.'),
        ]),
      ]),
      _section(context,'Total Cost',Icons.summarize_outlined,[
        _row(context,'Material Cost',EstimateFormat.money(result.materialCost)),
        _row(context,'Labour Cost',EstimateFormat.money(labour.totalCost)),
        _row(context,'Total Plaster Cost',EstimateFormat.money(result.totalCost)),
        _row(context,'Cost per m²',unitCost==null?'Not applicable':EstimateFormat.money(unitCost)),
      ]),
      PrimaryButton(onPressed:()=>Navigator.pop(context),icon:Icons.edit_outlined,label:'Edit Calculation'),const SizedBox(height:16),
    ]));
  }
  Widget _section(BuildContext context,String title,IconData icon,List<Widget> children)=>Padding(padding:const EdgeInsets.only(bottom:16),child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SectionHeader(title:title,icon:icon,compact:true),const SizedBox(height:12),...children]))));
  Widget _row(BuildContext context,String label,String value)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(label)),const SizedBox(width:12),Expanded(child:Text(value,textAlign:TextAlign.end,style:Theme.of(context).textTheme.labelLarge))]));
}
