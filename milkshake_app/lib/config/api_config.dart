class ApiConfig {
  static const String baseUrl = 'http://localhost:5203';

  static const String authEndpoint        = '$baseUrl/api/auth';
  static const String ordersEndpoint      = '$baseUrl/api/orders';
  static const String lookupsEndpoint     = '$baseUrl/api/lookups';
  static const String restaurantsEndpoint = '$baseUrl/api/restaurants';
  static const String discountsEndpoint   = '$baseUrl/api/discounts';

  static const Duration timeout = Duration(seconds: 30);
}
