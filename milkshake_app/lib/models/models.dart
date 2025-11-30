class Lookup {
  final int id;
  final String name;
  final String type;
  final double price;
  final String? description;

  Lookup({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.description,
  });

  factory Lookup.fromJson(Map<String, dynamic> json) {
    return Lookup(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
    );
  }
}

class Restaurant {
  final int id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String openingTime;
  final String closingTime;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    required this.openingTime,
    required this.closingTime,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
    );
  }

  String get hours => '$openingTime - $closingTime';
}

class TimeSlot {
  final String time;
  final bool isAvailable;

  TimeSlot({
    required this.time,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      time: json['time'],
      isAvailable: json['isAvailable'],
    );
  }
}

class DrinkItem {
  final Lookup flavour;
  final Lookup topping;
  final Lookup consistency;

  DrinkItem({
    required this.flavour,
    required this.topping,
    required this.consistency,
  });

  double get totalPrice => flavour.price + topping.price + consistency.price;

  String get description => '${flavour.name} + ${topping.name} + ${consistency.name}';
}

class DiscountInfo {
  final String? currentTier;
  final double currentDiscount;
  final String? nextTier;
  final double nextDiscount;
  final int ordersToNextTier;
  final int drinksNeededPerOrder;
  final int currentOrders;
  final int currentDrinks;

  DiscountInfo({
    this.currentTier,
    required this.currentDiscount,
    this.nextTier,
    required this.nextDiscount,
    required this.ordersToNextTier,
    required this.drinksNeededPerOrder,
    required this.currentOrders,
    required this.currentDrinks,
  });

  factory DiscountInfo.fromJson(Map<String, dynamic> json) {
    String? _toNullableString(dynamic value) {
      if (value == null) return null;
      // if backend sends 0, 1, etc. this will still be okay
      return value.toString();
    }

    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return DiscountInfo(
      currentTier: _toNullableString(json['currentTier']),
      currentDiscount: _toDouble(json['currentDiscount']),
      nextTier: _toNullableString(json['nextTier']),
      nextDiscount: _toDouble(json['nextDiscount']),
      ordersToNextTier: _toInt(json['ordersToNextTier']),
      drinksNeededPerOrder: _toInt(json['drinksNeededPerOrder']),
      currentOrders: _toInt(json['currentOrders']),
      currentDrinks: _toInt(json['currentDrinks']),
    );
  }

  double get progressToNextTier {
    if (ordersToNextTier == 0) return 1.0;
    return currentOrders / ordersToNextTier;
  }
}
