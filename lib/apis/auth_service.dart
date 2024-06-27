import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:storyapp/models/login.dart';
import 'package:storyapp/models/register.dart';

class AuthService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1/';
  final String stateKey = "state";

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.getBool(stateKey) ?? false;
  }

  Future<Register> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse("$_baseUrl/register");
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return Register.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      return Register.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register new account');
    }
  }

  Future<Login> login(String email, String password) async {
    final url = Uri.parse("$_baseUrl/login");
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['loginResult']['token'];
      final userId = responseData['loginResult']['userId'];
      final name = responseData['loginResult']['name'];

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('token', token);
      await preferences.setString('userId', userId);
      await preferences.setString('name', name);
      await preferences.setBool(stateKey, true);

      return Login.fromJson(json.decode(response.body));
    } else {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      String errorMessage = responseData['message'];
      throw Exception(errorMessage);
    }
  }

  Future<bool> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    await preferences.remove('token');
    return preferences.setBool(stateKey, false);
  }
}
