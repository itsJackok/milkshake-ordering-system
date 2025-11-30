import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/models.dart';

class ApiService {
  // Test connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.lookupsEndpoint}/flavours'),
      ).timeout(ApiConfig.timeout);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // AUTH ENDPOINTS
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String mobileNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'mobileNumber': mobileNumber,
          'password': password,
          'role': role,
        }),
      ).timeout(ApiConfig.timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // LOOKUPS ENDPOINTS
  static Future<List<Lookup>> getFlavours() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.lookupsEndpoint}/flavours'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Lookup.fromJson(json)).toList();
      }
      throw Exception('Failed to load flavours');
    } catch (e) {
      print('Error loading flavours: $e');
      return [];
    }
  }

  static Future<List<Lookup>> getToppings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.lookupsEndpoint}/toppings'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Lookup.fromJson(json)).toList();
      }
      throw Exception('Failed to load toppings');
    } catch (e) {
      print('Error loading toppings: $e');
      return [];
    }
  }

  static Future<List<Lookup>> getConsistencies() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.lookupsEndpoint}/consistencies'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Lookup.fromJson(json)).toList();
      }
      throw Exception('Failed to load consistencies');
    } catch (e) {
      print('Error loading consistencies: $e');
      return [];
    }
  }

  // LOOKUP MANAGEMENT ENDPOINTS (Create, Update, Delete)
  static Future<Map<String, dynamic>> createLookup({
    required String type,
    required String name,
    required double price,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.lookupsEndpoint}/$type'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'price': price,
        }),
      ).timeout(ApiConfig.timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating lookup: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateLookup({
    required String type,
    required int id,
    required String name,
    required double price,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.lookupsEndpoint}/$type/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'price': price,
        }),
      ).timeout(ApiConfig.timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating lookup: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteLookup({
    required String type,
    required int id,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.lookupsEndpoint}/$type/$id'),
      ).timeout(ApiConfig.timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting lookup: $e',
      };
    }
  }

  // RESTAURANTS ENDPOINTS
  static Future<List<Restaurant>> getRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.restaurantsEndpoint}'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Restaurant.fromJson(json)).toList();
      }
      throw Exception('Failed to load restaurants');
    } catch (e) {
      print('Error loading restaurants: $e');
      return [];
    }
  }

  static Future<List<TimeSlot>> getAvailableTimeSlots(
    int restaurantId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.restaurantsEndpoint}/$restaurantId/available-times?date=$dateStr',
        ),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TimeSlot.fromJson(json)).toList();
      }
      throw Exception('Failed to load time slots');
    } catch (e) {
      print('Error loading time slots: $e');
      return [];
    }
  }

  // ORDERS ENDPOINTS
  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required int restaurantId,
    required DateTime pickupTime,
    required List<DrinkItem> items,
  }) async {
    try {
      final itemsJson = items.map((item) => {
        'flavourId': item.flavour.id,
        'toppingId': item.topping.id,
        'consistencyId': item.consistency.id,
      }).toList();

      final response = await http.post(
        Uri.parse('${ApiConfig.ordersEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'restaurantId': restaurantId,
          'pickupTime': pickupTime.toIso8601String(),
          'items': itemsJson,
        }),
      ).timeout(ApiConfig.timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserOrders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.ordersEndpoint}/user/$userId'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to load orders');
    } catch (e) {
      print('Error loading orders: $e');
      return {'success': false, 'data': []};
    }
  }

  // DISCOUNT ENDPOINTS
  static Future<DiscountInfo?> getCustomerDiscountInfo(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.discountsEndpoint}/my-info/$userId'),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DiscountInfo.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error loading discount info: $e');
      return null;
    }
  }

  // PAYMENT ENDPOINTS
  static Future<Map<String, dynamic>> processPayment({
    required int orderId,
    required int userId,
    required double amount,
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cvv,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/payments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'userId': userId,
          'amount': amount,
          'paymentMethod': 'Card',
          'cardLastFour': cardNumber.replaceAll(' ', '').substring(12),
          'cardHolder': cardHolder,
        }),
      ).timeout(ApiConfig.timeout);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Payment processing error: $e',
      };
    }
  }

  // CONFIG MANAGEMENT ENDPOINTS
  static Future<List<Map<String, dynamic>>> getConfigs() async {
    try {
      print('Fetching configs from: ${ApiConfig.baseUrl}/api/configs');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/configs'),
      ).timeout(ApiConfig.timeout);

      print('Configs response status: ${response.statusCode}');
      print('Configs response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          print('Empty response body');
          return [];
        }
        
        final dynamic data = jsonDecode(response.body);
        print('Parsed data type: ${data.runtimeType}');
        
        if (data is List) {
          return List<Map<String, dynamic>>.from(
            data.map((item) => Map<String, dynamic>.from(item))
          );
        } else {
          print('Unexpected data format: $data');
          return [];
        }
      } else {
        print('API returned error status: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('Error loading configs: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createConfig({
    required String name,
    required String type,
    required String value,
    required int createdBy,
  }) async {
    try {
      print('Creating config: name=$name, type=$type, value=$value, createdBy=$createdBy');
      
      // Your backend doesn't have a POST endpoint yet
      // Returning mock success for now
      return {
        'success': false,
        'message': 'Backend POST /api/configurations endpoint not implemented yet',
      };
    } catch (e) {
      print('Error creating config: $e');
      return {
        'success': false,
        'message': 'Error creating config: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> updateConfig({
    required int id,
    required String value,
    required String reason,
    required int updatedBy,
  }) async {
    try {
      print('Updating config: id=$id, value=$value, reason=$reason');
      
      // Need to convert id to key - but we don't have the key!
      // This needs to be fixed - should pass key instead of id
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/configurations/config_$id?updatedBy=$updatedBy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'value': value,
          'reason': reason,
        }),
      ).timeout(ApiConfig.timeout);

      print('Update Config Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true, 'message': 'Config updated successfully'};
        }
        final result = jsonDecode(response.body);
        return result;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error updating config: $e');
      return {
        'success': false,
        'message': 'Error updating config: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteConfig({
    required int id,
    required String reason,
    required int deletedBy,
  }) async {
    try {
      print('Deleting config: id=$id, reason=$reason');
      
      // Your backend doesn't have DELETE endpoint
      return {
        'success': false,
        'message': 'Backend DELETE /api/configurations endpoint not implemented yet',
      };
    } catch (e) {
      print('Error deleting config: $e');
      return {
        'success': false,
        'message': 'Error deleting config: $e',
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getConfigAuditLog() async {
    try {
      // Your backend doesn't have audit-log endpoint yet
      print('Audit log endpoint not implemented in backend');
      return [];
    } catch (e) {
      print('Error loading audit log: $e');
      return [];
    }
  }
}