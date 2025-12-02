import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../models/models.dart';

class RestaurantSelectionScreen extends StatefulWidget {
  @override
  _RestaurantSelectionScreenState createState() => _RestaurantSelectionScreenState();
}

class _RestaurantSelectionScreenState extends State<RestaurantSelectionScreen> {
  List<Restaurant> _restaurants = [];
  List<DrinkItem> _cart = [];
  Restaurant? _selectedRestaurant;
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  List<TimeSlot> _timeSlots = [];
  
  bool _isLoading = true;
  bool _isLoadingTimeSlots = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['cart'] != null) {
        setState(() {
          _cart = args['cart'] as List<DrinkItem>;
        });
      }
      _loadRestaurants();
    });
  }

  Future<void> _loadRestaurants() async {
    final restaurants = await ApiService.getRestaurants();
    
    if (mounted) {
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTimeSlots() async {
    if (_selectedRestaurant == null || _selectedDate == null) return;
    
    setState(() => _isLoadingTimeSlots = true);
    
    String hoursString = _selectedRestaurant!.hours;
    
    List<TimeSlot> timeSlots = [];
    
    try {
      int openHour = 8;  
      int closeHour = 20; 
      
      if (hoursString.contains('-')) {
        var parts = hoursString.split('-');
        if (parts.length == 2) {
          var openPart = parts[0].trim();
          if (openPart.contains(':')) {
            openHour = int.tryParse(openPart.split(':')[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 8;
          }
          var closePart = parts[1].trim();
          if (closePart.contains(':')) {
            closeHour = int.tryParse(closePart.split(':')[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 20;
          }
        }
      }
      
      if (openHour < 6) openHour = 8;
      if (closeHour > 23) closeHour = 20;
      if (closeHour <= openHour) closeHour = openHour + 10;
      
      for (int hour = openHour; hour < closeHour; hour++) {
        String time1 = '${hour.toString().padLeft(2, '0')}:00';
        timeSlots.add(TimeSlot(
          time: time1,
          isAvailable: true,
        ));
        
        String time2 = '${hour.toString().padLeft(2, '0')}:30';
        timeSlots.add(TimeSlot(
          time: time2,
          isAvailable: true,
        ));
      }
      
      String finalTime = '${closeHour.toString().padLeft(2, '0')}:00';
      timeSlots.add(TimeSlot(
        time: finalTime,
        isAvailable: true,
      ));
      
      if (_selectedDate!.year == DateTime.now().year &&
          _selectedDate!.month == DateTime.now().month &&
          _selectedDate!.day == DateTime.now().day) {
        
        int currentHour = DateTime.now().hour;
        int currentMinute = DateTime.now().minute;
        
        timeSlots = timeSlots.where((slot) {
          var parts = slot.time.split(':');
          int slotHour = int.parse(parts[0]);
          int slotMinute = int.parse(parts[1]);
          
          if (slotHour > currentHour + 1) return true;
          if (slotHour == currentHour + 1 && slotMinute >= currentMinute) return true;
          return false;
        }).toList();
      }
      
    } catch (e) {
      for (int hour = 8; hour < 20; hour++) {
        timeSlots.add(TimeSlot(time: '${hour.toString().padLeft(2, '0')}:00', isAvailable: true));
        timeSlots.add(TimeSlot(time: '${hour.toString().padLeft(2, '0')}:30', isAvailable: true));
      }
    }
    
    if (mounted) {
      setState(() {
        _timeSlots = timeSlots;
        _isLoadingTimeSlots = false;
        _selectedTimeSlot = null;
      });
    }
  }

  double get _subtotal {
    return _cart.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get _vat {
    return _subtotal * 0.15;
  }

  double get _total {
    return _subtotal + _vat;
  }

  void _proceedToPayment() {
    if (_selectedRestaurant == null) {
      _showError('Please select a restaurant');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select a pickup date');
      return;
    }
    if (_selectedTimeSlot == null) {
      _showError('Please select a pickup time');
      return;
    }

    _createOrder();
  }

  Future<void> _createOrder() async {
  final userProvider = context.read<UserProvider>();

  setState(() => _isLoading = true);

  try {
    final pickupDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      int.parse(_selectedTimeSlot!.time.split(':')[0]),
      int.parse(_selectedTimeSlot!.time.split(':')[1]),
    );

    final result = await ApiService.createOrder(
      userId: userProvider.userId,
      restaurantId: _selectedRestaurant!.id,
      pickupTime: pickupDateTime,
      items: _cart,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>?;

      if (data == null || data['id'] == null) {
        _showError('Order created but no order ID was returned.');
        return;
      }

      final int orderId = data['id'] as int;
      final double totalAmount =
          (data['totalCost'] as num?)?.toDouble() ?? _total;

      Navigator.pushNamed(
        context,
        '/payment',
        arguments: {
          'orderId': orderId,
          'totalAmount': totalAmount,
          'pickupTime':
              data['pickupTime'] ?? pickupDateTime.toIso8601String(),
          'restaurant':
              data['restaurantName'] ?? _selectedRestaurant!.name,
          'cart': _cart,
          'userId': userProvider.userId,
        },
      );
    } else {
      _showError(
          result['message'] ?? 'Failed to create order. Please try again.');
    }
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showError('An error occurred while creating the order: $e');
  }
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Select Restaurant & Pickup Time'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left side - Restaurant selection
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Restaurant',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Restaurant Cards
                        ..._restaurants.map((restaurant) {
                          return _buildRestaurantCard(restaurant);
                        }).toList(),
                        
                        if (_selectedRestaurant != null) ...[
                          SizedBox(height: 32),
                          
                          // Date Selection
                          Text(
                            'Select Pickup Date',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          Card(
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(Icons.calendar_today, color: Colors.blue[700]),
                              title: Text(
                                _selectedDate != null
                                    ? DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate!)
                                    : 'Choose date',
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(Duration(days: 30)),
                                );
                                
                                if (date != null) {
                                  setState(() {
                                    _selectedDate = date;
                                    _selectedTimeSlot = null;
                                  });
                                  _loadTimeSlots();
                                }
                              },
                            ),
                          ),
                        ],
                        
                        if (_selectedDate != null) ...[
                          SizedBox(height: 32),
                          
                          // Time Slot Selection
                          Text(
                            'Select Pickup Time',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          if (_isLoadingTimeSlots)
                            Center(child: CircularProgressIndicator())
                          else if (_timeSlots.isEmpty)
                            Card(
                              elevation: 2,
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'No available time slots for this date',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _timeSlots.map((slot) {
                                return _buildTimeSlotChip(slot);
                              }).toList(),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Right side - Order Summary
                Container(
                  width: 350,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        // Cart Items
                        ..._cart.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Drink ${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'R${item.totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    item.flavour.name,
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  Text(
                                    '+ ${item.topping.name}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  Text(
                                    '+ ${item.consistency.name}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 16),
                        
                        // Selected Restaurant
                        if (_selectedRestaurant != null) ...[
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 20, color: Colors.blue[700]),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedRestaurant!.name,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      _selectedRestaurant!.address,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                        
                        // Selected Date & Time
                        if (_selectedDate != null) ...[
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 20, color: Colors.blue[700]),
                              SizedBox(width: 8),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_selectedDate!),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                        
                        if (_selectedTimeSlot != null) ...[
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 20, color: Colors.blue[700]),
                              SizedBox(width: 8),
                              Text(
                                _selectedTimeSlot!.time,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                        
                        Divider(),
                        SizedBox(height: 16),
                        
                        // Price Summary
                        _buildSummaryRow('Subtotal', _subtotal),
                        _buildSummaryRow('VAT (15%)', _vat),
                        SizedBox(height: 8),
                        Divider(thickness: 2),
                        SizedBox(height: 8),
                        _buildSummaryRow('Total', _total, isTotal: true),
                        
                        SizedBox(height: 24),
                        
                        // Proceed Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (_selectedRestaurant != null &&
                                    _selectedDate != null &&
                                    _selectedTimeSlot != null)
                                ? _proceedToPayment
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Proceed to Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    final isSelected = _selectedRestaurant?.id == restaurant.id;
    
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue[700]! : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRestaurant = restaurant;
            _selectedDate = null;
            _selectedTimeSlot = null;
            _timeSlots = [];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  size: 32,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      restaurant.address,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          restaurant.phoneNumber ?? 'No phone',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          restaurant.hours,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Colors.blue[700], size: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotChip(TimeSlot slot) {
    final isSelected = _selectedTimeSlot?.time == slot.time;
    final isAvailable = slot.isAvailable;
    
    return FilterChip(
      label: Text(slot.time),
      selected: isSelected,
      onSelected: isAvailable
          ? (selected) {
              setState(() {
                _selectedTimeSlot = selected ? slot : null;
              });
            }
          : null,
      selectedColor: Colors.blue[700],
      backgroundColor: isAvailable ? Colors.white : Colors.grey[300],
      disabledColor: Colors.grey[300],
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : isAvailable
                ? Colors.black87
                : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? Colors.blue[700]!
            : isAvailable
                ? Colors.grey[400]!
                : Colors.grey[300]!,
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey[700],
            ),
          ),
          Text(
            'R${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.blue[700] : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
