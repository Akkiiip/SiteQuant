import 'package:flutter/material.dart';
import '../models/paint_result.dart';
import '../models/productivity_standard.dart';
import '../services/estimate_cost_calculator.dart';
import '../services/estimate_format.dart';
import '../services/measurement_system.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_header.dart';

class PaintResultScreen extends StatelessWidget {
  final PaintResult result;
  final MeasurementSystem system;
  const PaintResultScreen({super.key, required this.result, required this.system});
  String _area(double value) => '${EstimateFormat.number(MeasurementPreferences.fromSquareMetres(value, system), 2)} ${system.areaUnit}';
  String _number(double value, [int precision = 2]) => EstimateFormat.number(value, precision);
  @override
  Widget build(BuildContext context) {
    final labour=result.labour; final productivity=result.productivity;
    final displayedArea=MeasurementPreferences.fromSquareMetres(result.netArea,system);
    final unitCost=EstimateCostCalculator.perUnit(result.totalCost,displayedArea);
    return AppScaffold(title:'Paint Estimate',bodyBuilder:(context,padding)=>ListView(padding:padding,children:[
      Text('Estimate Summary',style:Theme.of(context).textTheme.headlineMedium),const SizedBox(height:16),
      _section(context,'Summary',Icons.summarize_outlined,[
        _row(context,'Net Area',_area(result.netArea)),
        _row(context,'Material Cost',EstimateFormat.money(result.materialCost)),
        _row(context,'Labour Cost',EstimateFormat.money(labour.totalCost)),
        _row(context,'Total Cost',EstimateFormat.money(result.totalCost)),
        _row(context,'Cost per ${system.areaUnit}',unitCost==null?'Not applicable':EstimateFormat.money(unitCost)),
      ]),
      _section(context,'Materials',Icons.inventory_2_outlined,[
        for(final material in result.materials) _row(context,material.input.kind.label,'${_number(material.finalQuantity)} ${material.input.kind.unit} - ${EstimateFormat.money(material.cost)}'),
      ]),
      _section(context,'Labour & Time',Icons.groups_outlined,[
        _row(context,'Crew','${productivity.crew[LabourRole.painter]} Painter(s) + ${productivity.crew[LabourRole.helper]} Helper(s)'),
        _row(context,'Working Days','${_number(productivity.workingDays)} days'),
        _row(context,'Labour Cost',EstimateFormat.money(labour.totalCost)),
      ]),
      _section(context,'Calculation Details',Icons.expand_more_rounded,[
        ExpansionTile(title:const Text('Calculation Details'),children:[
          _row(context,'Work Type',result.workType.label),
          _row(context,'Gross Area',_area(result.grossArea)),
          _row(context,'Deductions',_area(result.deductionArea)),
          for(final material in result.materials) ...[
            _row(context,'${material.input.kind.label} coats','${material.input.coats}'),
            _row(context,'${material.input.kind.label} coverage',_number(material.input.coverage)),
            _row(context,'${material.input.kind.label} wastage','${_number(material.input.wastagePercent)}%'),
            _row(context,'${material.input.kind.label} reference rate','${EstimateFormat.money(material.input.rate)} / ${material.input.kind.unit}'),
          ],
          _row(context,'Productivity basis',productivity.standard.name),
          Text(productivity.standard.basis),
          _row(context,'Painter mandays',_number(productivity.mandays[LabourRole.painter]!)),
          _row(context,'Helper mandays',_number(productivity.mandays[LabourRole.helper]!)),
          _row(context,'Painter daily wage','${EstimateFormat.money(labour.dailyWages[LabourRole.painter]!)} / day'),
          _row(context,'Helper daily wage','${EstimateFormat.money(labour.dailyWages[LabourRole.helper]!)} / day'),
          _row(context,'Painter labour cost',EstimateFormat.money(labour.costs[LabourRole.painter]!)),
          _row(context,'Helper labour cost',EstimateFormat.money(labour.costs[LabourRole.helper]!)),
          const Text('Working days use the controlling role requirement for the selected crew.'),
        ]),
      ]),
      PrimaryButton(onPressed:()=>Navigator.pop(context),icon:Icons.edit_outlined,label:'Edit Calculation'),const SizedBox(height:16),
    ]));
  }
  Widget _section(BuildContext context,String title,IconData icon,List<Widget> children)=>Padding(padding:const EdgeInsets.only(bottom:16),child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[SectionHeader(title:title,icon:icon,compact:true),const SizedBox(height:12),...children]))));
  Widget _row(BuildContext context,String label,String value)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Expanded(child:Text(label)),const SizedBox(width:12),Expanded(child:Text(value,textAlign:TextAlign.end,style:Theme.of(context).textTheme.labelLarge))]));
}
