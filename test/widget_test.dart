// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:device_preview/device_preview.dart';
import 'package:flutter/widgets.dart' show Key;
import 'package:flutter_test/flutter_test.dart';

import 'package:purrfile/app.dart';
import 'package:purrfile/services/supabase_service.dart';

void main() {
  testWidgets('shows the login screen', (WidgetTester tester) async {
    await SupabaseService.init();
    await tester.pumpWidget(
      DevicePreview(
        enabled: false,
        builder: (_) => const PurrFileApp(),
      ),
    );

    expect(find.byKey(const Key('purrfile_logo')), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });
}
