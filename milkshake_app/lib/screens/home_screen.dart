import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DiscountInfo? _discountInfo;
  bool _isLoading = true;
  double _greetingOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDiscountInfo();

    Future.microtask(() {
      if (mounted) {
        setState(() {
          _greetingOpacity = 1.0;
        });
      }
    });
  }

  Future<void> _loadDiscountInfo() async {
    final userProvider = context.read<UserProvider>();
    final info = await ApiService.getCustomerDiscountInfo(userProvider.userId);

    if (mounted) {
      setState(() {
        _discountInfo = info;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final discount = _discountInfo;

    double progress = 0.0;
    int remainingOrders = 0;

    if (discount != null && discount.ordersToNextTier > 0) {
      progress =
          (discount.currentOrders / discount.ordersToNextTier).clamp(0.0, 1.0);
      remainingOrders =
          (discount.ordersToNextTier - discount.currentOrders).clamp(0, 9999);
    }

    final roleLabel =
        userProvider.userRole == 'Manager' ? 'Manager' : 'Patron';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading:
            false,
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    opacity: _greetingOpacity,
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOut,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${userProvider.userFirstName} 👋',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Welcome to Milky Shaky Dashboard',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            roleLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF424242),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio:
                        2.3, 
                    children: [
                      _buildStatCard(
                        'Current Tier',
                        discount?.currentTier ??
                            'No Tier',
                        Icons.stars,
                        const Color(0xFF0066FF),
                        '', 
                      ),
                      _buildStatCard(
                        'Current Discount',
                        discount != null
                            ? '${discount.currentDiscount.toStringAsFixed(0)}%'
                            : '0%',
                        Icons.local_offer,
                        const Color(0xFF4CAF50),
                        'Loyalty Active',
                      ),
                      _buildStatCard(
                        'Orders Placed',
                        discount != null ? '${discount.currentOrders}' : '0',
                        Icons.shopping_cart,
                        const Color(0xFFF57C00),
                        'All time',
                      ),
                      _buildStatCard(
                        'To Next Tier',
                        (discount != null &&
                                discount.ordersToNextTier > 0 &&
                                remainingOrders > 0)
                            ? '$remainingOrders left'
                            : 'Tier unlocked',
                        Icons.trending_up,
                        const Color(0xFFD32F2F),
                        (discount != null && remainingOrders > 0)
                            ? 'Next tier'
                            : '',
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // DISCOUNT / PROGRESS SECTION
                  if (discount != null) ...[
                    Text(
                      'Loyalty Progress',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDiscountProgressCard(
                      discount,
                      progress,
                      remainingOrders,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // QUICK ACTIONS
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildQuickActionCard(
                        icon: Icons.local_drink,
                        title: 'New Order',
                        subtitle: 'Create a fresh milkshake order',
                        onTap: () {
                          Navigator.pushNamed(context, '/order');
                        },
                      ),
                      _buildQuickActionCard(
                        icon: Icons.history,
                        title: 'My Orders',
                        subtitle: 'View your order history',
                        onTap: () {
                          Navigator.pushNamed(context, '/history');
                        },
                      ),
                      _buildQuickActionCard(
                        icon: Icons.bar_chart,
                        title: userProvider.userRole == 'Manager'
                            ? 'Store Reports'
                            : 'My Stats',
                        subtitle: userProvider.userRole == 'Manager'
                            ? 'View store performance'
                            : 'See your activity',
                        onTap: () {
                          if (userProvider.userRole == 'Manager') {
                            Navigator.pushNamed(context, '/reports/manager');
                          } else {
                            Navigator.pushNamed(context, '/reports/patron');
                          }
                        },
                      ),
                      if (userProvider.userRole == 'Manager')
                        _buildQuickActionCard(
                          icon: Icons.settings,
                          title: 'Manage Lookups',
                          subtitle: 'Flavours, toppings & more',
                          onTap: () {
                            Navigator.pushNamed(context, '/lookups');
                          },
                        ),
                      if (userProvider.userRole == 'Manager')
                        _buildQuickActionCard(
                          icon: Icons.tune,
                          title: 'Config Values',
                          subtitle: 'VAT, max drinks, etc.',
                          onTap: () {
                            Navigator.pushNamed(context, '/config');
                          },
                        ),
                      _buildQuickActionCard(
                        icon: Icons.person,
                        title: 'Profile',
                        subtitle: 'Manage your details',
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // LOWER SECTION: POPULAR FLAVOURS + RECENT ORDERS (STATIC FOR NOW)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPopularFlavoursCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildRecentOrdersCard()),
                    ],
                  ),
                ],
              ),
            ),
    );
  }


  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String footer,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                ),
              ),
              if (footer.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  footer,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountProgressCard(
    DiscountInfo discount,
    double progress,
    int remainingOrders,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (discount.ordersToNextTier > 0 && remainingOrders > 0)
                ? 'Progress to next tier'
                : 'Current tier: ${discount.currentTier ?? 'None'}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (discount.ordersToNextTier > 0)
            Text(
              '${discount.currentOrders}/${discount.ordersToNextTier} orders',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF616161),
              ),
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0066FF),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (discount.ordersToNextTier > 0 && remainingOrders > 0)
                ? '$remainingOrders more orders to unlock the next tier 🎉'
                : 'You\'ve unlocked the available tier.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF424242),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 160,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_drink,
                  size: 24, color: Color(0xFF0066FF)),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularFlavoursCard() {
    final flavours = [
      {'name': 'Chocolate', 'orders': 523, 'percentage': 0.35},
      {'name': 'Vanilla', 'orders': 412, 'percentage': 0.28},
      {'name': 'Strawberry', 'orders': 356, 'percentage': 0.24},
      {'name': 'Coffee', 'orders': 189, 'percentage': 0.13},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Flavours',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...flavours.map((flavour) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        flavour['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${flavour['orders']} orders',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: flavour['percentage'] as double,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0066FF),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    final orders = [
      {
        'id': '#12345',
        'flavour': 'Chocolate',
        'time': '2 mins ago',
        'status': 'Paid'
      },
      {
        'id': '#12344',
        'flavour': 'Vanilla',
        'time': '15 mins ago',
        'status': 'Paid'
      },
      {
        'id': '#12343',
        'flavour': 'Strawberry',
        'time': '23 mins ago',
        'status': 'Pending'
      },
      {
        'id': '#12342',
        'flavour': 'Coffee',
        'time': '1 hour ago',
        'status': 'Paid'
      },
      {
        'id': '#12341',
        'flavour': 'Oreo',
        'time': '2 hours ago',
        'status': 'Cancelled'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders (sample)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...orders.map((order) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['id'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['flavour'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['status'] as String),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order['status'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                _getStatusTextColor(order['status'] as String),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['time'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFFE8F5E9);
      case 'Pending':
        return const Color(0xFFFFF3E0);
      case 'Cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF2E7D32);
      case 'Pending':
        return const Color(0xFFF57C00);
      case 'Cancelled':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF666666);
    }
  }
}
