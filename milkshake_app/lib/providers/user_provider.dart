import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  String get userName => _user?.fullName ?? 'Guest';
  String get userFirstName => _user?.firstName ?? 'Guest';
  int get userId => _user?.id ?? 0;
  String get userRole => _user?.role ?? 'Patron';
  String get userEmail => _user?.email ?? '';

  Future<void> setUser(User user) async {
    _user = user;
    notifyListeners();
    await _saveUserToPrefs(user);
  }

  Future<void> loadUserFromPrefs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      
      if (userJson != null) {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        _user = User.fromJson(userData);
      }
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(user.toJson()));
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  void updateUserStats({
    int? completedOrders,
    int? drinksPurchased,
    int? discountTier,
    String? tierName,
    double? discountPercentage,
  }) {
    if (_user != null) {
      _user = User(
        id: _user!.id,
        fullName: _user!.fullName,
        email: _user!.email,
        mobileNumber: _user!.mobileNumber,
        role: _user!.role,
        totalCompletedOrders: completedOrders ?? _user!.totalCompletedOrders,
        totalDrinksPurchased: drinksPurchased ?? _user!.totalDrinksPurchased,
        currentDiscountTier: discountTier ?? _user!.currentDiscountTier,
        discountTierName: tierName ?? _user!.discountTierName,
        discountPercentage: discountPercentage ?? _user!.discountPercentage,
      );
      notifyListeners();
      _saveUserToPrefs(_user!);
    }
  }
}