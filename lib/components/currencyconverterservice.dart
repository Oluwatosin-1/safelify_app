import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
class CurrencyConverterService {
  final String _apiKey = 'd4a85647a7912c464f1bea84'; // Replace with your currency conversion API key

  // Function to get exchange rates from API
  Future<double?> getExchangeRate(String fromCurrency, String toCurrency) async {
    try {
      final response = await http.get(Uri.parse(
          'https://v6.exchangerate-api.com/v6/$_apiKey/pair/$fromCurrency/$toCurrency'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          return data['conversion_rate']; // Extracting the conversion rate
        } else {
          if (kDebugMode) {
            print("Error: API result was not successful");
          }
        }
      } else {
        if (kDebugMode) {
          print("Error: Failed to fetch exchange rate with status code ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching exchange rate: $e");
      }
    }
    return null;
  }
}