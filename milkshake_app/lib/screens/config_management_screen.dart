import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';

class ConfigManagementScreen extends StatefulWidget {
  @override
  _ConfigManagementScreenState createState() => _ConfigManagementScreenState();
}

class _ConfigManagementScreenState extends State<ConfigManagementScreen> {
  List<Map<String, dynamic>> _configs = [];
  List<Map<String, dynamic>> _auditLog = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    setState(() => _isLoading = true);
    
    try {
      final configs = await ApiService.getConfigs();
      
      final auditLog = await ApiService.getConfigAuditLog();
      
      if (mounted) {
        setState(() {
          _configs = configs;
          _auditLog = auditLog;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading configs: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading configurations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Configuration Management'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Banner
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange[700], size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Important Notice',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Changes to configuration values will NOT affect existing orders. Only new orders will use the updated values.',
                                style: TextStyle(color: Colors.orange[800]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Configuration Values Section
                  _buildConfigSection(),
                  
                  SizedBox(height: 32),
                  
                  // Audit Log Section
                  _buildAuditSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildConfigSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Config Values',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddConfigDialog(),
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Add New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Configurations Table
            _buildConfigTable(),
          ],
        ),
      ),
    );
  }

Widget _buildConfigTable() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
      columns: const [
        DataColumn(
          label: Text(
            'Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Value',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Last Updated',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Actions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: _configs.map((config) {
        final id = config['id'] ?? config['configId'];
        final name = (config['name'] ?? config['key'] ?? 'Unknown').toString();
        final type =
            (config['dataType'] ?? config['type'] ?? 'Config').toString();
        final value = (config['value'] ?? '').toString();

        final rawDate = config['lastUpdated'] ??
            config['lastUpdatedAt'] ??
            config['updatedAt'] ??
            config['createdAt'];

        String lastUpdatedText = 'N/A';
        if (rawDate != null && rawDate.toString().trim().isNotEmpty) {
          try {
            final dt = DateTime.parse(rawDate.toString());
            lastUpdatedText =
                DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
          } catch (_) {
            lastUpdatedText = rawDate.toString();
          }
        }

        return DataRow(
          cells: [
            DataCell(Text(name)),
            DataCell(Text(type)),
            DataCell(
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ),
            DataCell(Text(lastUpdatedText)),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => _showDeleteConfigDialog({
                      ...config,
                      'id': id,
                      'name': name,
                      'value': value,
                    }),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () => _showEditConfigDialog({
                      ...config,
                      'id': id,
                      'name': name,
                      'value': value,
                    }),
                    child: Text(
                      'Edit',
                      style:
                          TextStyle(color: Colors.blue[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    ),
  );
}


  Widget _buildAuditSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.blue[700]),
                SizedBox(width: 12),
                Text(
                  'Configuration Audit Log',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Track all configuration changes',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 16),
            
            // Audit Log Table
            _buildAuditTable(),
          ],
        ),
      ),
    );
  }

    Widget _buildAuditTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
        columns: const [
          DataColumn(label: Text('Config Name', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Old Value', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('New Value', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Changed By', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Changed At', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: _auditLog.map((log) {
          return DataRow(
            cells: [
              DataCell(Text(log['configName'] ?? '')),
              DataCell(
                Text(
                  log['oldValue'] ?? '',
                  style: TextStyle(
                    color: Colors.red[700],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              DataCell(
                Text(
                  log['newValue'] ?? '',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(Text(log['changedBy'] ?? '')),
              DataCell(Text(log['changedAt'] ?? '')),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    log['reason'] ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAddConfigDialog() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    String selectedType = 'Config';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Configuration Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Discount Threshold',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['Config', 'Setting', 'Parameter'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType = value!;
                },
              ),
              const SizedBox(height: 16),
              const Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  hintText: 'e.g., 100 or 15%',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  valueController.text.isNotEmpty) {
                final userProvider = context.read<UserProvider>();

                final result = await ApiService.createConfig(
                  name: nameController.text.trim(),
                  type: selectedType,
                  value: valueController.text.trim(),
                  createdBy: userProvider.userId,
                );

                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuration added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                  _loadConfigs();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ?? 'Failed to add configuration',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  void _showEditConfigDialog(Map<String, dynamic> config) {
    final id = config['id'] ?? config['configId'];
    final name = (config['name'] ?? config['key'] ?? '').toString();
    final currentValue = (config['value'] ?? '').toString();

    final valueController = TextEditingController(text: currentValue);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configuration',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Current Value: '),
                  Text(
                    currentValue,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('New Value', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                decoration: InputDecoration(
                  hintText: 'Enter new value',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Reason for Change *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Explain why this change is needed...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will NOT affect existing orders',
                        style: TextStyle(fontSize: 12, color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (valueController.text.isNotEmpty &&
                  reasonController.text.isNotEmpty) {
                final userProvider = context.read<UserProvider>();

                final result = await ApiService.updateConfig(
                  id: id,
                  value: valueController.text.trim(),
                  reason: reasonController.text.trim(),
                  updatedBy: userProvider.userId,
                );

                if (result['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Configuration updated! Change logged in audit trail.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                  _loadConfigs();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ?? 'Failed to update configuration',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for this change'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfigDialog(Map<String, dynamic> config) {
    final id = config['id'] ?? config['configId'];
    final name = (config['name'] ?? config['key'] ?? '').toString();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "$name"?'),
            const SizedBox(height: 16),
            Text(
              'Reason for Deletion *',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Explain why...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final userProvider = context.read<UserProvider>();

              final result = await ApiService.deleteConfig(
                id: id,
                reason: reasonController.text.trim(),
                deletedBy: userProvider.userId,
              );

              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configuration deleted! Change logged.'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
                _loadConfigs();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ?? 'Failed to delete configuration',
                    ),
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
