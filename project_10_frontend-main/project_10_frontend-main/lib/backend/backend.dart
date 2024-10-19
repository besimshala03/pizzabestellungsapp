import 'package:project_10_frontend/model/Bestellung.dart';
import 'package:project_10_frontend/model/pizza.dart';
import 'package:project_10_frontend/model/zutaten.dart';
import 'package:project_10_frontend/model/getraenke.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class Backend {
  // use IP 10.0.2.2 to access localhost from emulator.
  // static const _backend = "http://10.0.2.2:8080/";

  // use IP 127.0.0.1 to access ip adresss from windows device
  static const _backend = "http://10.28.55.0:8080/";

  Future<Pizza> createPizza(
      http.Client client, String name, String description) async {
    Map data = {
      'name': name,
      'description': description,
    };

    var response = await client.post(Uri.parse('${_backend}item'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(data));

    if (response.statusCode == 200) {
      return Pizza.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create item');
    }
  }

  Future<List<Pizza>> fetchPizzaList(http.Client client) async {
    final response = await client.get(Uri.parse('${_backend}pizza'));

    if (response.statusCode == 200) {
      return List<Pizza>.from(json
          .decode(utf8.decode(response.bodyBytes))
          .map((x) => Pizza.fromJson(x)));
    } else {
      throw Exception('Failed to load pizza list');
    }
  }

  Future<Pizza> fetchPizzaById(http.Client client, int id) async {
    final response = await client.get(Uri.parse('${_backend}pizza/$id'));

    if (response.statusCode == 200) {
      return Pizza.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load pizza');
    }
  }

  Future<List<Zutaten>> fetchZutatenData(http.Client client) async {
    final response = await client.get(Uri.parse('${_backend}zutaten'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((item) => Zutaten.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load Zutaten');
    }
  }

  Future<Zutaten> fetchZutatById(http.Client client, int id) async {
    final response = await client.get(Uri.parse('${_backend}zutaten/$id'));

    if (response.statusCode == 200) {
      return Zutaten.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load Zutat');
    }
  }

  Future<List<Getraenke>> fetchGetraenkeData(http.Client client) async {
    final response = await client.get(Uri.parse('${_backend}getraenke'));

    if (response.statusCode == 200) {
      try {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => Getraenke.fromJson(item)).toList();
      } catch (e) {
        print('Decoding error: $e');
        throw Exception('Failed to decode Getraenke data');
      }
    } else {
      throw Exception('Failed to load Getraenke');
    }
  }

  Future<Getraenke> fetchGetraenkeById(http.Client client, int id) async {
    final response = await client.get(Uri.parse('${_backend}getraenke/$id'));

    if (response.statusCode == 200) {
      return Getraenke.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load Getraenke');
    }
  }

  createItem(http.Client client, String text, String text2) {}

  Future<void> addBestellung(
      http.Client client,
      List<Pizza> pizza,
      List<Getraenke> getraenke,
      double preis,
      String datumUhrzeit,
      String adresse,
      String kundenname) async {
    final url = Uri.parse('${_backend}bestellung');
    final body = json.encode({
      'pizzas': pizza.map((pizza) => pizza.toJson()).toList(),
      'getraenke': getraenke.map((getraenk) => getraenk.toJson()).toList(),
      'totalPrice': preis,
      'datumUhrzeit': datumUhrzeit,
      'adresse': adresse,
      'kundenname': kundenname,
    });

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add Bestellung');
    }
  }

  Future<void> deleteBestellung(http.Client client, int id) async {
    final response =
        await client.delete(Uri.parse('${_backend}bestellung/$id'));

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete Bestellung');
    }
  }

  Future<Bestellung> editBestellung(http.Client client, int id,
      List<Pizza> pizza, List<Getraenke> getraenke, double preis) async {
    Map data = {
      'pizza': pizza.map((pizza) => pizza.toJson()).toList(),
      'getraenke': getraenke.map((getraenke) => getraenke.toJson()).toList(),
      'preis': preis,
    };

    final response = await client.put(
      Uri.parse('${_backend}bestellung/$id'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return Bestellung.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to edit Bestellung');
    }
  }

  Future<List<Bestellung>> fetchBestellungList(http.Client client) async {
    final response = await client.get(Uri.parse('${_backend}bestellung'));

    if (response.statusCode == 200) {
      return List<Bestellung>.from(json
          .decode(utf8.decode(response.bodyBytes))
          .map((x) => Bestellung.fromJson(x)));
    } else {
      throw Exception('Failed to load Bestellungliste');
    }
  }

  Future<void> updateBestellung(http.Client client, int id,
      Map<String, dynamic> bestellungDetails) async {
    final url = Uri.parse('${_backend}bestellung/$id');
    final body = json.encode(bestellungDetails);

    final response = await client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update Bestellung');
    }
  }

  Future<Bestellung> fetchBestellungById(http.Client client, int id) async {
    final response = await client.get(Uri.parse('${_backend}bestellung/$id'));

    if (response.statusCode == 200) {
      return Bestellung.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load Bestellung');
    }
  }

  Future<String> deletePizzaById(http.Client client, int id) async {
    final url = Uri.parse('${_backend}pizza/$id');
    final response = await client.delete(url);

    if (response.statusCode == 200) {
      return "Pizza erfolgreich gelöscht";
    } else {
      throw Exception('Fehler beim Löschen der Pizza: ${response.body}');
    }
  }

  Future<String> deleteGetraenkeById(http.Client client, int id) async {
    final url = Uri.parse('${_backend}getraenke/$id');
    final response = await client.delete(url);

    if (response.statusCode == 200) {
      return "Getränk erfolgreich gelöscht";
    } else {
      throw Exception('Fehler beim Löschen des Getränks: ${response.body}');
    }
  }

  Future<http.Response> updatePizzaById(
      http.Client client, int id, Pizza pizzaDetails) async {
    String url =
        '${_backend.endsWith('/') ? _backend : _backend + '/'}pizza/$id';
    final response = await client.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(pizzaDetails.toJson()),
    );

    return response;
  }

  Future<http.Response> deleteZutatenByPizza(
      http.Client client, Pizza pizza) async {
    final url = Uri.parse('${_backend}zutaten');
    final response = await client.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(pizza.toJson()),
    );

    return response;
  }
}
