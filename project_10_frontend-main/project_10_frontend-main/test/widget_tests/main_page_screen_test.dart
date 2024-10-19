import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'package:project_10_frontend/model/Bestellung.dart';
import 'package:http/http.dart' as http;
import 'package:project_10_frontend/screen/main_page.dart';

import 'main_page_screen_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  tearDown(() {
    reset(mockClient);
  });

  testWidgets('zeigt Bestellungen korrekt an', (WidgetTester tester) async {
    List<Bestellung> mockBestellungen = [
      Bestellung(
          id: 1,
          pizza: [],
          getraenke: [],
          preis: 15.0,
          datumUhrzeit: '2024-12-12',
          adresse: 'xyz',
          kundenname: 'zyx'),
      Bestellung(
          id: 2,
          pizza: [],
          getraenke: [],
          preis: 20.0,
          datumUhrzeit: '2024-12-12',
          adresse: 'xyz',
          kundenname: 'zyx'),
    ];
    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung')))
        .thenAnswer((_) async => http.Response(
            jsonEncode(mockBestellungen.map((b) => b.toJson()).toList()), 200));

    await tester.pumpWidget(MaterialApp(
      home: MainPage(Backend(), mockClient),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(find.text('Bestellung 1'), findsOneWidget);
    expect(find.text('Bestellung 2'), findsOneWidget);
  });

  testWidgets('zeigt Fehlermeldung bei fehlenden Bestellungen an',
      (WidgetTester tester) async {
    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung')))
        .thenAnswer((_) async => http.Response('Server error', 500));

    await tester.pumpWidget(MaterialApp(
      home: MainPage(Backend(), mockClient),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Fehler beim Laden der Bestellungen: Server error'),
        findsNothing);
  });

  testWidgets('löscht eine Bestellung erfolgreich',
      (WidgetTester tester) async {
    List<Bestellung> mockBestellungen = [
      Bestellung(
          id: 1,
          pizza: [],
          getraenke: [],
          preis: 15.0,
          datumUhrzeit: '2024-12-12',
          adresse: 'xyz',
          kundenname: 'zyx'),
    ];

    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung')))
        .thenAnswer((_) async => http.Response(
            jsonEncode(mockBestellungen.map((b) => b.toJson()).toList()), 200));

    when(mockClient.delete(Uri.parse('http://127.0.0.1:8080/bestellung/1')))
        .thenAnswer((_) async => http.Response('{"status": "success"}', 200));

    await tester.pumpWidget(MaterialApp(
      home: MainPage(Backend(), mockClient),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Bestellung 1'), findsOneWidget);

    await tester.tap(find.byKey(Key('Delete')).first);
    await tester.pumpAndSettle();

    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung')))
        .thenAnswer((_) async => http.Response(jsonEncode([]), 200));

    await tester.pumpWidget(MaterialApp(
      home: MainPage(Backend(), mockClient),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Bestellung 1'), findsOneWidget);
  });

  testWidgets('zeigt Hinweis bei fehlerhaftem Löschen einer Bestellung an',
      (WidgetTester tester) async {
    List<Bestellung> mockBestellungen = [
      Bestellung(
          id: 1,
          pizza: [],
          getraenke: [],
          preis: 15.0,
          datumUhrzeit: '2024-12-12',
          adresse: 'xyz',
          kundenname: 'zyx'),
    ];

    when(mockClient.get(Uri.parse('http://127.0.0.1:8080/bestellung')))
        .thenAnswer((_) async => http.Response(
            jsonEncode(mockBestellungen.map((b) => b.toJson()).toList()), 200));

    when(mockClient.delete(Uri.parse('http://127.0.0.1:8080/bestellung/1')))
        .thenAnswer((_) async => http.Response('Server error', 500));

    await tester.pumpWidget(MaterialApp(
      home: MainPage(Backend(), mockClient),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Bestellung 1'), findsOneWidget);

    await tester.tap(find.byKey(Key('Delete')).first);
    await tester.pumpAndSettle();

    expect(find.text('Fehler beim Löschen der Bestellung'), findsNothing);
  });
}
