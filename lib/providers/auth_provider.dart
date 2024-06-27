import 'package:flutter/foundation.dart';
import 'package:storyapp/apis/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  AuthProvider(this.authService);

  bool isLoadingLogin = false;
  bool isLoadingLogout = false;
  bool isLoadingRegister = false;
  bool isLoggedIn = false;
  bool isRegistered = false;

  Future<bool> logout() async {
    isLoadingLogout = true;
    notifyListeners();

    await authService.logout();
    isLoggedIn = await authService.isLoggedIn();

    isLoadingLogout = false;
    notifyListeners();

    return !isLoggedIn;
  }

  Future<bool> login(String email, String password) async {
    isLoadingLogin = true;
    notifyListeners();

    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password are required.");
    }

    try {
      await authService.login(email, password);
      isLoggedIn = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error during login: $e');
      }
      isLoggedIn = false;
    }

    isLoadingLogin = false;
    notifyListeners();
    return isLoggedIn;
  }

  Future<bool> register(String name, String email, String password) async {
    isLoadingRegister = true;
    notifyListeners();

    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password are required.");
    }

    try {
      await authService.register(name, email, password);
      isRegistered = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error during register: $e');
      }
      isRegistered = false;
    }

    isLoadingRegister = false;
    notifyListeners();

    return isRegistered;
  }
}
