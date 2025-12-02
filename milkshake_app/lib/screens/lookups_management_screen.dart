import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../models/models.dart';

class LookupsManagementScreen extends StatefulWidget {
  @override
  _LookupsManagementScreenState createState() =>
      _LookupsManagementScreenState();
}

class _LookupsManagementScreenState extends State<LookupsManagementScreen> {
  List<Lookup> _flavours = [];
  List<Lookup> _toppings = [];
  List<Lookup> _consistencies = [];

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

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          'Lookup Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- MILKSHAKE SELECTIONS HEADER ---
                  Text(
                    'Milkshake Selections',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- TOP ROW: FLAVOURS + TOPPINGS ---
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildLookupSection(
                                'Milkshake Flavours',
                                _flavours,
                                'Flavour',
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildLookupSection(
                                'Milkshake Toppings',
                                _toppings,
                                'Topping',
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLookupSection(
                              'Milkshake Flavours',
                              _flavours,
                              'Flavour',
                            ),
                            const SizedBox(height: 24),
                            _buildLookupSection(
                              'Milkshake Toppings',
                              _toppings,
                              'Topping',
                            ),
                          ],
                        ),

                  const SizedBox(height: 32),

                  // --- CONSISTENCIES (EXTRA CARD BELOW) ---
                  _buildLookupSection(
                    'Milkshake Consistencies',
                    _consistencies,
                    'Consistency',
                  ),
                ],
              ),
            ),
    );
  }

  // ==================== LOOKUP SECTIONS ====================

  Widget _buildLookupSection(String title, List<Lookup> items, String type) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(type),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLookupTable(items, type),
          ],
        ),
      ),
    );
  }

  Widget _buildLookupTable(List<Lookup> items, String type) {
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.5),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            _buildHeaderCell('Name'),
            _buildHeaderCell('Type'),
            _buildHeaderCell('Value'),
            _buildHeaderCell('Last Updated'),
            _buildHeaderCell('Actions'),
          ],
        ),
        // Data rows
        if (items.isEmpty)
          TableRow(
            children: [
              _buildEmptyCell('No records'),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
            ],
          )
        else
          ...items.map((item) => _buildLookupDataRow(item, type)),
      ],
    );
  }

  TableRow _buildLookupDataRow(Lookup item, String type) {
    final formattedNow =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    return TableRow(
      children: [
        _buildDataCell(item.name),
        _buildDataCell(type),
        _buildDataCell(
          item.price > 0 ? 'R${item.price.toStringAsFixed(2)}' : '-',
        ),
        _buildDataCell(formattedNow),
        _buildLookupActionCell(item, type),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Color(0xFF455A64),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Color(0xFF263238)),
      ),
    );
  }

  Widget _buildEmptyCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF9E9E9E),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildLookupActionCell(Lookup item, String type) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Wrap(
      spacing: 4,            
      runSpacing: 4, 
        children: [
          TextButton(
            onPressed: () => _showDeleteDialog(item, type),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFD32F2F), fontSize: 13),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => _showEditDialog(item, type),
            child: Text(
              'Edit',
              style: TextStyle(color: Colors.blue[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DUPLICATE CHECK ====================

  bool _lookupExists(String type, String name, {int? excludeId}) {
    final target = name.trim().toLowerCase();

    List<Lookup> list;
    switch (type.toLowerCase()) {
      case 'flavour':
        list = _flavours;
        break;
      case 'topping':
        list = _toppings;
        break;
      case 'consistency':
        list = _consistencies;
        break;
      default:
        list = [];
    }

    return list.any((l) {
      if (excludeId != null && l.id == excludeId) return false;
      return l.name.trim().toLowerCase() == target;
    });
  }

  // ==================== DIALOGS ====================

  void _showAddDialog(String type) {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Add New $type'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: 'R ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final priceText = priceController.text.trim();

            if (name.isEmpty || priceText.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in both name and price'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (_lookupExists(type, name)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$type with that name already exists'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final price = double.tryParse(priceText) ?? 0.0;

            final result = await ApiService.createLookup(
              type: type,
              name: name,
              price: price,
              description: descriptionController.text,
            );

            final messenger = ScaffoldMessenger.of(context);

            if (result['success'] == true) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('$type added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(dialogContext, rootNavigator: true).pop();
              _loadData();
            } else {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Failed to add $type'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
          ),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}



void _showEditDialog(Lookup item, String type) {
  final nameController = TextEditingController(text: item.name);
  final priceController = TextEditingController(text: item.price.toString());
  final descriptionController =
      TextEditingController(text: item.description ?? '');

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Edit $type'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: 'R ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final priceText = priceController.text.trim();

            if (name.isEmpty || priceText.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in both name and price'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (_lookupExists(type, name, excludeId: item.id)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$type with that name already exists'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final price = double.tryParse(priceText) ?? 0.0;

            final result = await ApiService.updateLookup(
              type: type,
              id: item.id,
              name: name,
              price: price,
              description: descriptionController.text,
            );

            final messenger = ScaffoldMessenger.of(context);

            if (result['success'] == true) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('$type updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );

              Navigator.of(dialogContext, rootNavigator: true).pop();
              _loadData();
            } else {
              messenger.showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Failed to update $type'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
          ),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}


void _showDeleteDialog(Lookup item, String type) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Delete $type'),
      content: Text('Are you sure you want to delete "${item.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final result = await ApiService.deleteLookup(
              id: item.id,
            );

            if (result['success'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$type deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.of(dialogContext, rootNavigator: true).pop();
              _loadData();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(result['message'] ?? 'Failed to delete $type'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
}
