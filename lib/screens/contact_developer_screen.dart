import 'package:flutter/material.dart';
import '../services/clipboard_writer.dart';
import '../services/contact_developer_service.dart';

class ContactDeveloperScreen extends StatefulWidget {
  final ContactDeveloperService service;
  final ClipboardWriter clipboardWriter;
  const ContactDeveloperScreen({super.key,this.service=const ContactDeveloperService(),this.clipboardWriter=const FlutterClipboardWriter()});
  @override State<ContactDeveloperScreen> createState()=>_ContactDeveloperScreenState();
}
class _ContactDeveloperScreenState extends State<ContactDeveloperScreen>{
  final name=TextEditingController(),email=TextEditingController(),message=TextEditingController();
  ContactCategory category=ContactCategory.generalFeedback;
  @override void dispose(){name.dispose();email.dispose();message.dispose();super.dispose();}
  bool valid(){if(message.text.trim().isEmpty){notice('Message is required.');return false;}if(email.text.trim().isNotEmpty&&!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim())){notice('Enter a valid email address.');return false;}return true;}
  void notice(String s)=>ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content:Text(s)));
  Future<void> send()async{if(!valid())return;final ok=await widget.service.open(category:category,name:name.text,senderEmail:email.text,message:message.text);if(!ok&&mounted)showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Could not open your email app.'),content:const Text(ContactDeveloperService.email),actions:[TextButton(onPressed:()async{await widget.clipboardWriter.writeText(ContactDeveloperService.email);if(c.mounted)Navigator.pop(c);notice('Email copied.');},child:const Text('Copy Email')),TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Close'))]));}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Contact Developer')),body:SafeArea(child:ListView(padding:const EdgeInsets.all(16),children:[Text('Need help with SiteQuant?',style:Theme.of(context).textTheme.headlineSmall),const Text('Report bugs, suggest features, or send us your feedback.'),const SizedBox(height:20),DropdownButtonFormField<ContactCategory>(initialValue:category,decoration:const InputDecoration(labelText:'Contact category'),items:ContactCategory.values.map((v)=>DropdownMenuItem(value:v,child:Text(v.label))).toList(),onChanged:(v)=>setState(()=>category=v!)),TextField(controller:name,decoration:const InputDecoration(labelText:'Name (optional)')),TextField(controller:email,decoration:const InputDecoration(labelText:'Email (optional)'),keyboardType:TextInputType.emailAddress),TextField(controller:message,decoration:const InputDecoration(labelText:'Message'),maxLines:6),const SizedBox(height:16),FilledButton.icon(onPressed:send,icon:const Icon(Icons.send),label:const Text('Send Message'))])));
}
