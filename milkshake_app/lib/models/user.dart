class User {
  final int id;
  final String fullName;
  final String email;
  final String mobileNumber;
  final String role;
  final int totalCompletedOrders;
  final int totalDrinksPurchased;
  final int currentDiscountTier;
  final String? discountTierName;
  final double? discountPercentage;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.role,
    this.totalCompletedOrders = 0,
    this.totalDrinksPurchased = 0,
    this.currentDiscountTier = 0,
    this.discountTierName,
    this.discountPercentage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userId'] ?? json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      role: json['role'] ?? 'Patron',
      totalCompletedOrders: json['totalCompletedOrders'] ?? 0,
      totalDrinksPurchased: json['totalDrinksPurchased'] ?? 0,
      currentDiscountTier: json['currentDiscountTier'] ?? 0,
      discountTierName: json['discountTierName'],
      discountPercentage: json['discountPercentage']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'mobileNumber': mobileNumber,
      'role': role,
      'totalCompletedOrders': totalCompletedOrders,
      'totalDrinksPurchased': totalDrinksPurchased,
      'currentDiscountTier': currentDiscountTier,
      'discountTierName': discountTierName,
      'discountPercentage': discountPercentage,
    };
  }

  String get firstName => fullName.split(' ').first;
  
  String get tierDisplay {
    if (discountTierName != null) {
      return '$discountTierName (${discountPercentage?.toStringAsFixed(0)}%)';
    }
    return 'No Tier';
  }
}