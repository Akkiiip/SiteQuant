import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/screens/settings_screen.dart';
import 'package:site_quant/screens/contact_developer_screen.dart';
import 'package:site_quant/services/support_actions.dart';

void main() {
  test('rate prefers native listing and falls back on false or exception', () async {
    for (final throws in [false, true]) {
      final urls = <Uri>[];
      final actions = SupportActions(launch: (uri) async {
        urls.add(uri);
        if (uri.scheme == 'market') {
          if (throws) throw Exception('No store');
          return false;
        }
        return true;
      });
      expect(await actions.rate(), isTrue);
      expect(urls.map((u) => u.scheme), ['market', 'https']);
      expect(urls.last.toString(), SupportActions.playStoreUrl);
    }
    var calls = 0;
    expect(await SupportActions(launch: (_) async { calls++; return true; }).rate(), isTrue);
    expect(calls, 1);
  });

  test('external failures return false safely', () async {
    expect(await SupportActions(launch: (_) async => false).rate(), isFalse);
    expect(await SupportActions(shareOperation: (_) async => throw Exception('Unavailable')).share(), isFalse);
  });

  testWidgets('Support renders and Rate, Share, Contact actions work at 360 px', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => t.binding.setSurfaceSize(null));
    final urls = <Uri>[];
    String? shared;
    await t.pumpWidget(MaterialApp(home: SettingsScreen(
      supportActions: SupportActions(
        launch: (uri) async { urls.add(uri); return true; },
        shareOperation: (text) async { shared = text; },
      ),
    )));
    Future<void> reveal(String text) async {
      for (var i = 0; i < 8 && find.text(text).hitTestable().evaluate().isEmpty; i++) {
        await t.drag(find.byType(ListView), const Offset(0, -180));
        await t.pumpAndSettle();
      }
      expect(find.text(text).hitTestable(), findsOneWidget);
    }
    await reveal('Rate SiteQuant');
    expect(find.text('Support'), findsOneWidget);
    await t.tap(find.text('Rate SiteQuant'));
    await t.pumpAndSettle();
    expect(urls.single.toString(), 'market://details?id=com.sitequant.app');
    await reveal('Share SiteQuant');
    await t.tap(find.text('Share SiteQuant'));
    await t.pumpAndSettle();
    expect(shared, SupportActions.shareText);
    expect(shared, contains(SupportActions.playStoreUrl));
    await reveal('Contact Developer');
    expect(find.text('Contact Developer'), findsOneWidget);
    await t.tap(find.text('Contact Developer'));
    await t.pumpAndSettle();
    expect(find.byType(ContactDeveloperScreen), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}


