import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

class ManagerReportsScreen extends StatefulWidget {
  @override
  _ManagerReportsScreenState createState() => _ManagerReportsScreenState();
}

class _ManagerReportsScreenState extends State<ManagerReportsScreen> {
  bool _isLoading = false;
  String _selectedTab = 'Trends';
  String _dateFilter = 'None';
  DateTime? _selectedDate;
  DateTime? _startDate;
  DateTime? _endDate;

  List<double> weeklyData = [];
  List<double> monthlyData = [];
  Map<String, double> growthData = {};

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await ApiService.getManagerReportStats(
        dateFilter: _dateFilter,
        singleDate: _selectedDate,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;

      setState(() {
        weeklyData = stats.weeklyOrders;
        monthlyData = stats.monthlyOrders;
        growthData = stats.yearlyGrowth;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load report data: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _buildFilterLabel() {
    if (_dateFilter == 'Single Date' && _selectedDate != null) {
      return DateFormat('dd MMM yyyy').format(_selectedDate!);
    }
    if (_dateFilter == 'Date Range' && _startDate != null && _endDate != null) {
      return '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}';
    }
    return 'No date filter applied';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reports'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully!')),
                );
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'Reporting History',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'System User',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),

                _buildFilterButton('Single Date', _dateFilter == 'Single Date'),
                const SizedBox(width: 8),
                _buildFilterButton('Date Range', _dateFilter == 'Date Range'),
                const SizedBox(width: 8),
                _buildFilterButton('None', _dateFilter == 'None'),

                const Spacer(),

                Text(
                  _buildFilterLabel(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(width: 16),

                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Reload data',
                  onPressed: _loadReportData,
                ),

                IconButton(
                  icon: const Icon(Icons.print, size: 20),
                  onPressed: () {},
                  tooltip: 'Print',
                ),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _dateFilter = 'None';
                      _selectedDate = null;
                      _startDate = null;
                      _endDate = null;
                    });
                    _loadReportData();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildTab('Orders'),
                const SizedBox(width: 24),
                _buildTab('Trends'),
                const SizedBox(width: 24),
                _buildTab('Audit Lookups'),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _selectedTab == 'Trends'
                        ? _buildTrendsView()
                        : _buildPlaceholderView(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return ElevatedButton(
      onPressed: () async {
        setState(() => _dateFilter = label);

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[600] : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return InkWell(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue[600]! : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue[600] : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendsView() {
    final hasAnyData =
        weeklyData.isNotEmpty || monthlyData.isNotEmpty || growthData.isNotEmpty;

    if (!hasAnyData) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(Icons.insights, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No report data found for the selected filter',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildWeeklyChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildMonthlyChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildGrowthChart()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBottomBarChart('Weekly ', weeklyData),
            ),
            const SizedBox(width: 16),
            Expanded(child: _buildBottomGrowthChart()),
            const SizedBox(width: 16),
            Expanded(
              child: _buildBottomBarChart('Monthly ', monthlyData),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Weekly',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: weeklyData.isEmpty
                      ? 10
                      : (weeklyData.reduce((a, b) => a > b ? a : b) + 10),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt()],
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklyData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blue[700],
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: weeklyData.isEmpty
                                ? 10
                                : (weeklyData.reduce(
                                        (a, b) => a > b ? a : b) +
                                    10),
                            color: Colors.blue[50],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Monthly',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: monthlyData.isEmpty
                      ? 10
                      : (monthlyData.reduce((a, b) => a > b ? a : b) + 10),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[value.toInt()],
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: monthlyData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blue[700],
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: monthlyData.isEmpty
                                ? 10
                                : (monthlyData.reduce(
                                        (a, b) => a > b ? a : b) +
                                    10),
                            color: Colors.blue[50],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Growth',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Yearly',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final years = growthData.keys.toList();
                          if (value.toInt() >= 0 &&
                              value.toInt() < years.length) {
                            return Text(
                              years[value.toInt()],
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[600]),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: growthData.values
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value,
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.green[400],
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green[100]!.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarChart(String title, List<double> data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: data.isEmpty
                      ? 10
                      : (data.reduce((a, b) => a > b ? a : b) + 10),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const labels = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul'
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey[600]),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.blue[700],
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: data.isEmpty
                                ? 10
                                : (data.reduce(
                                        (a, b) => a > b ? a : b) +
                                    10),
                            color: Colors.blue[50],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomGrowthChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Growth Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Yearly',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final years = growthData.keys.toList();
                          if (value.toInt() >= 0 &&
                              value.toInt() < years.length) {
                            return Text(
                              years[value.toInt()],
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[600]),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: growthData.values
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value,
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.green[400],
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green[100]!.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Select "Trends" tab to view analytics',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
