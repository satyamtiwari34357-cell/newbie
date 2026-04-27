import "dart:convert";

import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:http/http.dart" as http;

class ApiClient {
  static String get baseUrl => dotenv.env["API_BASE_URL"] ?? "http://192.168.0.195:5000/api/v1";

  static Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await http.get(Uri.parse("$baseUrl$path"), headers: _headers(token));
    return _parse(response);
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {String? token}) async {
    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  static Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {String? token}) async {
    final response = await http.put(
      Uri.parse("$baseUrl$path"),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  static Map<String, String> _headers(String? token) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token"
    };
  }

  static Map<String, dynamic> _parse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(data["message"] ?? "API error");
    }
    return data;
  }
}
