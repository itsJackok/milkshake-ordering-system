import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';

class PatronReportsScreen extends StatefulWidget {
  @override
  _PatronReportsScreenState createState() => _PatronReportsScreenState();
}

class _PatronReportsScreenState extends State<PatronReportsScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _selectedTab = 'Orders';
  String _dateFilter = 'Single Date';
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final userProvider = context.read<UserProvider>();
    final result = await ApiService.getUserOrders(userProvider.userId);
    
    if (mounted) {
      setState(() {
        _orders = result['data'] ?? [];
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredOrders {
    if (_selectedDate == null && _startDate == null) {
      return _orders;
    }
    
    return _orders.where((order) {
      final orderDate = DateTime.parse(order['orderDate']);
      
      if (_dateFilter == 'Single Date' && _selectedDate != null) {
        return orderDate.year == _selectedDate!.year &&
               orderDate.month == _selectedDate!.month &&
               orderDate.day == _selectedDate!.day;
      } else if (_dateFilter == 'Date Range' && _startDate != null && _endDate != null) {
        return orderDate.isAfter(_startDate!.subtract(Duration(days: 1))) &&
               orderDate.isBefore(_endDate!.add(Duration(days: 1)));
      }
      
      return true;
    }).toList();
  }

  Map<String, int> get _drinkCounts {
    Map<String, int> counts = {};
    
    for (var order in _filteredOrders) {
      final items = order['items'] as List? ?? [];
      for (var item in items) {
        final flavour = item['flavourName'] ?? 'Unknown';
        counts[flavour] = (counts[flavour] ?? 0) + 1;
      }
    }
    
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Reporting History'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                // Export functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Export feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: Text('Export'),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filters
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Date Filter Dropdown
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _dateFilter,
                          underline: SizedBox(),
                          items: ['Single Date', 'Date Range', 'None'].map((filter) {
                            return DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _dateFilter = value!;
                              _selectedDate = null;
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      
                      // Date Picker Button
                      if (_dateFilter == 'Single Date')
                        ElevatedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() => _selectedDate = date);
                            }
                          },
                          icon: Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _selectedDate != null
                                ? DateFormat('yyyy/MM/dd').format(_selectedDate!)
                                : 'Select Date',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      
                      if (_dateFilter == 'Date Range') ...[
                        ElevatedButton.icon(
                          onPressed: () async {
                            final dates = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (dates != null) {
                              setState(() {
                                _startDate = dates.start;
                                _endDate = dates.end;
                              });
                            }
                          },
                          icon: Icon(Icons.date_range, size: 16),
                          label: Text(
                            _startDate != null && _endDate != null
                                ? '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'
                                : 'Select Range',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ],
                      
                      Spacer(),
                      
                      // Clear Button
                      if (_selectedDate != null || _startDate != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = null;
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                          child: Text('Clear'),
                        ),
                    ],
                  ),
                ),
                
                // Tabs
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildTabButton('Orders'),
                      SizedBox(width: 8),
                      _buildTabButton('Trends'),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: _selectedTab == 'Orders'
                      ? _buildOrdersTab()
                      : _buildTrendsTab(),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String tab) {
    final isSelected = _selectedTab == tab;
    return TextButton(
      onPressed: () {
        setState(() => _selectedTab = tab);
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? Colors.blue[700] : Colors.grey[600],
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tab,
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4),
              height: 3,
              width: 40,
              color: Colors.blue[700],
            ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Orders',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_filteredOrders.length} results',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Orders Table
          Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: [
                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Flavour', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Topping', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Consistency', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Payment Status', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _filteredOrders.take(10).map((order) {
                  final orderDate = DateTime.parse(order['orderDate']);
                  final items = order['items'] as List? ?? [];
                  final firstItem = items.isNotEmpty ? items[0] : null;
                  final paymentStatus = order['paymentStatus'] ?? 'Pending';
                  
                  return DataRow(
                    cells: [
                      DataCell(Text(DateFormat('yyyy/MM/dd').format(orderDate))),
                      DataCell(Text(DateFormat('HH:mm').format(orderDate))),
                      DataCell(Text(firstItem?['flavourName'] ?? '-')),
                      DataCell(Text(firstItem?['toppingName'] ?? '-')),
                      DataCell(Text(firstItem?['consistencyName'] ?? '-')),
                      DataCell(_buildStatusBadge(paymentStatus)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Pagination
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: null,
                child: Text('Previous'),
              ),
              ...List.generate(3, (index) {
                return TextButton(
                  onPressed: () {},
                  child: Text('${index + 1}'),
                  style: TextButton.styleFrom(
                    foregroundColor: index == 0 ? Colors.blue[700] : Colors.grey,
                  ),
                );
              }),
              TextButton(
                onPressed: () {},
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    final drinkCounts = _drinkCounts;
    final maxCount = drinkCounts.values.fold(0, (max, val) => val > max ? val : max);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Drink Preferences',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          
          // Bar Chart
          Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Drinks by Flavour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  if (drinkCounts.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No orders yet'),
                      ),
                    )
                  else
                    ...drinkCounts.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key),
                                Text(
                                  '${entry.value} orders',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: entry.value / maxCount,
                                minHeight: 24,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue[700]!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 24),
          
          // Summary Stats
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.shopping_bag, size: 40, color: Colors.blue[700]),
                        SizedBox(height: 8),
                        Text(
                          '${_filteredOrders.length}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text('Total Orders'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.local_drink, size: 40, color: Colors.green[700]),
                        SizedBox(height: 8),
                        Text(
                          '${_filteredOrders.fold(0, (sum, order) => sum + (order['items'] as List).length)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text('Total Drinks'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    
    switch (status.toLowerCase()) {
      case 'paid':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}