import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import '../models/models.dart';

class NewOrderScreen extends StatefulWidget {
  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  List<Lookup> _flavours = [];
  List<Lookup> _toppings = [];
  List<Lookup> _consistencies = [];
  List<DrinkItem> _cart = [];
  
  final _numDrinksController = TextEditingController(text: '1');
  int _numDrinks = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final flavours = await ApiService.getFlavours();
    final toppings = await ApiService.getToppings();
    final consistencies = await ApiService.getConsistencies();
    
    if (mounted) {
      setState(() {
        _flavours = flavours;
        _toppings = toppings;
        _consistencies = consistencies;
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Placement'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Number of Milkshakes Required?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _numDrinksController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: 'Insert number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          onChanged: (value) {
                          final num = int.tryParse(value) ?? 1;
                          if (num >= 1 && num <= 10) {
                            setState(() {
                              _numDrinks = num;

                              if (_cart.length > _numDrinks) {
                                _cart = _cart.sublist(0, _numDrinks);
                              }
                            });
                          }
                        },
                      ),
                        SizedBox(height: 24),
                        
                        ..._buildDrinkForms(),
                        
                        SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _cart.length == _numDrinks
                                ? () {
                                    Navigator.pushNamed(
                                      context,
                                      '/restaurants',
                                      arguments: {'cart': _cart},
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Continue',
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
                
                Container(
                  width: 350,
                  color: Colors.grey[50],
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
                        SizedBox(height: 8),
                        Text(
                          'Milky Shaky',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        SizedBox(height: 24),
                        
                        _buildSummaryRow('Number of Drinks', '${_cart.length}'),
                        _buildSummaryRow('Subtotal', 'R${_subtotal.toStringAsFixed(2)}'),
                        _buildSummaryRow('VAT (15%)', 'R${_vat.toStringAsFixed(2)}'),
                        
                        SizedBox(height: 16),
                        Divider(thickness: 2),
                        SizedBox(height: 16),
                        
                        _buildSummaryRow(
                          'Total cost',
                          'R${_total.toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                        
                        if (_cart.length != _numDrinks) ...[
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[300]!),
                            ),
                            child: Text(
                              'Continue when all data captured',
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _buildDrinkForms() {
    List<Widget> forms = [];
    
    for (int i = 0; i < _numDrinks; i++) {
      forms.add(_buildDrinkForm(i));
      forms.add(SizedBox(height: 24));
    }
    
    return forms;
  }

  Widget _buildDrinkForm(int index) {
    final drinkData = index < _cart.length
        ? {
            'flavour': _cart[index].flavour,
            'topping': _cart[index].topping,
            'consistency': _cart[index].consistency,
          }
        : <String, Lookup?>{
            'flavour': null,
            'topping': null,
            'consistency': null,
          };
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Milkshake ${index + 1}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (index < _cart.length)
                  Text(
                    'R${_cart[index].totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            
            // Flavour
            Text('Flavour', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            DropdownButtonFormField<Lookup>(
              value: drinkData['flavour'],
              decoration: InputDecoration(
                hintText: 'Select',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _flavours.map((flavour) {
                return DropdownMenuItem(
                  value: flavour,
                  child: Text('${flavour.name} - R${flavour.price.toStringAsFixed(2)}'),
                );
              }).toList(),
              onChanged: (value) {
                _updateDrink(index, flavour: value);
              },
            ),
            SizedBox(height: 16),
            
            Text('Thick or Not', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            DropdownButtonFormField<Lookup>(
              value: drinkData['consistency'],
              decoration: InputDecoration(
                hintText: 'Select',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _consistencies.map((consistency) {
                return DropdownMenuItem(
                  value: consistency,
                  child: Text(
                    '${consistency.name}${consistency.price > 0 ? ' (+R${consistency.price.toStringAsFixed(2)})' : ''}',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                _updateDrink(index, consistency: value);
              },
            ),
            SizedBox(height: 16),
            
            Text('Topping', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            DropdownButtonFormField<Lookup>(
              value: drinkData['topping'],
              decoration: InputDecoration(
                hintText: 'Select',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _toppings.map((topping) {
                return DropdownMenuItem(
                  value: topping,
                  child: Text('${topping.name} - R${topping.price.toStringAsFixed(2)}'),
                );
              }).toList(),
              onChanged: (value) {
                _updateDrink(index, topping: value);
              },
            ),
            
            if (index < _cart.length) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _cart.removeAt(index);
                      });
                    },
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _updateDrink(int index, {Lookup? flavour, Lookup? topping, Lookup? consistency}) {
  setState(() {
    if (index >= _cart.length) {
      final newDrink = DrinkItem(
        flavour: flavour ?? _flavours.first,
        topping: topping ?? _toppings.first,
        consistency: consistency ?? _consistencies.first,
      );
      _cart.add(newDrink);
    } else {
      final old = _cart[index];
      _cart[index] = DrinkItem(
        flavour: flavour ?? old.flavour,
        topping: topping ?? old.topping,
        consistency: consistency ?? old.consistency,
      );
    }
  });
}


  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
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
            value,
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

  @override
  void dispose() {
    _numDrinksController.dispose();
    super.dispose();
  }
}