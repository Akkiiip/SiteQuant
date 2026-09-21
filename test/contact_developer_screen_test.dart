import 'package:flutter/material.dart';
import 'package:site_quant/services/clipboard_writer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/screens/contact_developer_screen.dart';
import 'package:site_quant/screens/settings_screen.dart';
import 'package:site_quant/services/contact_developer_service.dart';

class FakeClipboardWriter implements ClipboardWriter { String? text; @override Future<void> writeText(String value) async { text=value; } }

class FakeLauncher implements ContactEmailLauncher {
  FakeLauncher(this.result);
  final bool result;
  Uri? uri;
  @override Future<bool> launch(Uri value) async { uri=value; return result; }
}

void main() {
  testWidgets('Settings opens the existing Contact Developer destination', (t) async {
    await t.pumpWidget(const MaterialApp(home: SettingsScreen()));
    expect(find.text('Contact feature coming soon.'), findsNothing);
    await t.drag(find.byType(ListView), const Offset(0, -240));
    await t.pumpAndSettle();
    await t.tap(find.text('Contact Developer'));
    await t.pumpAndSettle();
    expect(find.byType(ContactDeveloperScreen), findsOneWidget);
    expect(find.text('Need help with SiteQuant?'), findsOneWidget);
  });

  testWidgets('contact form validates, selects categories and launches a draft at 360 px', (t) async {
    await t.binding.setSurfaceSize(const Size(360,800));
    addTearDown(()=>t.binding.setSurfaceSize(null));
    final fake=FakeLauncher(true);
    await t.pumpWidget(MaterialApp(home: ContactDeveloperScreen(service:ContactDeveloperService(launcher:fake))));
    expect(find.text('Contact Developer'), findsOneWidget);
    expect(find.text('Need help with SiteQuant?'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<ContactCategory>), findsOneWidget);
    await t.tap(find.text('Send Message'));
    await t.pumpAndSettle();
    expect(find.text('Message is required.'), findsOneWidget);
    await t.enterText(find.byType(TextField).at(0),'Site Engineer');
    await t.enterText(find.byType(TextField).at(1),'bad-email');
    await t.enterText(find.byType(TextField).at(2),'A useful message');
    await t.tap(find.text('Send Message'));
    await t.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    await t.enterText(find.byType(TextField).at(1),'engineer@example.com');
    for(final category in ContactCategory.values) {
      await t.tap(find.byType(DropdownButtonFormField<ContactCategory>));
      await t.pumpAndSettle();
      await t.tap(find.text(category.label).last);
      await t.pumpAndSettle();
    }
    await t.tap(find.text('Send Message'));
    await t.pumpAndSettle();
    expect(fake.uri!.path,ContactDeveloperService.email);
    expect(fake.uri!.queryParameters['subject'],'SiteQuant Feedback');
    expect(fake.uri!.queryParameters['body'],contains('1.0.0+4'));
    expect(fake.uri!.queryParameters['body'],contains('A useful message'));
    expect(fake.uri!.queryParameters['body'],contains('Site Engineer'));
    expect(t.takeException(),isNull);
  });

  testWidgets('unavailable email launcher shows copy-email fallback', (t) async {
    final fake=FakeLauncher(false);
    final clipboard=FakeClipboardWriter();
    await t.pumpWidget(MaterialApp(home:ContactDeveloperScreen(service:ContactDeveloperService(launcher:fake),clipboardWriter:clipboard)));
    await t.enterText(find.byType(TextField).at(2),'Help please');
    await t.tap(find.text('Send Message'));
    await t.pumpAndSettle();
    expect(find.text('Could not open your email app.'),findsOneWidget);
    expect(find.text(ContactDeveloperService.email),findsOneWidget);
    expect(find.text('Copy Email'),findsOneWidget);
    await t.tap(find.text('Copy Email'));
    await t.pumpAndSettle();
    expect(clipboard.text,ContactDeveloperService.email);
    expect(find.text('Email copied.'),findsOneWidget);
  });
}

