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

  @override
  void initState() {
    super.initState();
    _loadDiscountInfo();
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

    // Safely calculate progress + remaining orders
    double progress = 0.0;
    int remainingOrders = 0;

    if (discount != null && discount.ordersToNextTier > 0) {
      progress = (discount.currentOrders / discount.ordersToNextTier)
          .clamp(0.0, 1.0);
      remainingOrders =
          (discount.ordersToNextTier - discount.currentOrders).clamp(0, 9999);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello,',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '${userProvider.userFirstName}! 👋',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                userProvider.userFirstName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    if (!_isLoading && discount != null)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.card_giftcard,
                                color: Colors.amber, size: 32),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    discount.currentTier ?? 'No Tier Yet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${discount.currentDiscount.toStringAsFixed(0)}% Discount',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // MAIN CONTENT
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What would you like today?',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24),

                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _buildActionCard(
                              icon: Icons.local_drink,
                              title: 'Order Now',
                              subtitle: 'Create new order',
                              color: Color(0xFF667eea),
                              onTap: () {
                                Navigator.pushNamed(context, '/order');
                              },
                            ),
                            _buildActionCard(
                              icon: Icons.history,
                              title: 'My Orders',
                              subtitle: 'View order history',
                              color: Color(0xFF11998e),
                              onTap: () {
                                Navigator.pushNamed(context, '/history');
                              },
                            ),
                            _buildActionCard(
                              icon: Icons.bar_chart,
                              title: 'Reports',
                              subtitle: userProvider.userRole == 'Manager'
                                  ? 'Store analytics'
                                  : 'Your stats',
                              color: Color(0xFF4CAF50),
                              onTap: () {
                                if (userProvider.userRole == 'Manager') {
                                  Navigator.pushNamed(
                                      context, '/reports/manager');
                                } else {
                                  Navigator.pushNamed(
                                      context, '/reports/patron');
                                }
                              },
                            ),
                            if (userProvider.userRole == 'Manager')
                              _buildActionCard(
                                icon: Icons.settings,
                                title: 'Manage Lookups',
                                subtitle: 'Edit flavours & toppings',
                                color: Color(0xFFf093fb),
                                onTap: () {
                                  Navigator.pushNamed(context, '/lookups');
                                },
                              ),
                            if (userProvider.userRole == 'Manager')
                              _buildActionCard(
                                icon: Icons.tune,
                                title: 'Config Values',
                                subtitle: 'VAT, Max drinks, etc',
                                color: Color(0xFFFF6B6B),
                                onTap: () {
                                  Navigator.pushNamed(context, '/config');
                                },
                              ),
                            _buildActionCard(
                              icon: Icons.person,
                              title: 'Profile',
                              subtitle: 'Your account',
                              color: Color(0xFFfa709a),
                              onTap: () {
                                Navigator.pushNamed(context, '/profile');
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 32),

                        // Special offers title
                        Text(
                          '🎉 Special Offers',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Welcome bonus card
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer,
                                  size: 40, color: Colors.orange[800]),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome Bonus!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[900],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Order 5 times to unlock Bronze tier!',
                                      style: TextStyle(
                                          color: Colors.orange[800]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        // Progress card (only if there is a next tier)
                        if (discount != null && discount.nextTier != null)
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Progress to ${discount.nextTier} tier',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      '${discount.currentOrders}/${discount.ordersToNextTier}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: Colors.blue[100],
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                      Colors.blue[600]!,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  remainingOrders > 0
                                      ? '$remainingOrders more orders to unlock!'
                                      : 'You\'ve unlocked this tier 🎉',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
