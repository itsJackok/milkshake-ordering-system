import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DiscountInfo? _discountInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiscountInfo();
  }
  String _formatTierName(String? raw) {
  if (raw == null || raw.isEmpty) return 'next tier';
  final match = RegExp(r'tierName:\s*([^,}]+)').firstMatch(raw);
  return match?.group(1)?.trim() ?? raw;
}

  Future<void> _loadDiscountInfo() async {
    try {
      final userProvider = context.read<UserProvider>();

      if (userProvider.userId == 0) {
        setState(() {
          _discountInfo = null;
          _isLoading = false;
        });
        return;
      }

      final info =
          await ApiService.getCustomerDiscountInfo(userProvider.userId);

      if (!mounted) return;

      setState(() {
        _discountInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _discountInfo = null;
        _isLoading = false;
      });
      debugPrint('Error loading discount info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userProvider.userFirstName.isNotEmpty
                              ? userProvider.userFirstName[0].toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProvider.userName,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'No email',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userProvider.userRole,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Stats row
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.shopping_bag,
                                      title: 'Orders',
                                      value:
                                          '${user?.totalCompletedOrders ?? 0}',
                                      color: const Color(0xFF667eea),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatCard(
                                      icon: Icons.local_drink,
                                      title: 'Drinks',
                                      value:
                                          '${user?.totalDrinksPurchased ?? 0}',
                                      color: const Color(0xFF11998e),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              Text(
                                'Your Discount Tier',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (_discountInfo != null) ...[
                                // Current tier card
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _getTierColors(
                                          _discountInfo!.currentTier),
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            _getTierColors(_discountInfo!.currentTier)[0]
                                                .withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _discountInfo!.currentTier ??
                                                    'No Tier',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${_discountInfo!.currentDiscount.toStringAsFixed(0)}% Discount',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            _getTierIcon(
                                                _discountInfo!.currentTier),
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                if (_discountInfo!.nextTier != null) ...[
                                  Text(
                                    'Progress to ${_formatTierName(_discountInfo!.nextTier)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Progress card
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${_discountInfo!.currentOrders} / ${_discountInfo!.ordersToNextTier} orders',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${(_discountInfo!.progressToNextTier * 100).toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF667eea),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: _discountInfo!
                                                .progressToNextTier,
                                            minHeight: 12,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(
                                              Color(0xFF667eea),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                               '${_discountInfo!.currentOrders} more orders with '
                                                '${_discountInfo!.drinksNeededPerOrder}+ drinks each to unlock '
                                                '${_formatTierName(_discountInfo!.nextTier)}!',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Next reward card
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.blue[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.stars,
                                            color: Colors.blue[700], size: 32),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Next Reward',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue[900],
                                                ),
                                              ),
                                              Text(
                                                  '${_discountInfo!.nextDiscount.toStringAsFixed(0)}% discount with '
                                                  '${_formatTierName(_discountInfo!.nextTier)}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  // Max tier card
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[50],
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Colors.amber[200]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.emoji_events,
                                            color: Colors.amber[700],
                                            size: 40),
                                        const SizedBox(width: 16),
                                        Expanded(
                                            child: Text(
                                            'You\'ve reached the highest tier! 🎉',
                                            style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900, 
                                           ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],

                              const SizedBox(height: 32),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showLogoutDialog();
                                  },
                                  icon: const Icon(Icons.logout,
                                      color: Colors.red),
                                  label: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getTierColors(String? tier) {
    if (tier == null) return [Colors.grey, Colors.grey[300]!];

    switch (tier.toLowerCase()) {
      case 'bronze':
        return const [Color(0xFFCD7F32), Color(0xFFDDA15E)];
      case 'silver':
        return const [Color(0xFFC0C0C0), Color(0xFFE8E8E8)];
      case 'gold':
        return const [Color(0xFFFFD700), Color(0xFFFFA500)];
      default:
        return [Colors.grey, Colors.grey[300]!];
    }
  }

  IconData _getTierIcon(String? tier) {
    if (tier == null) return Icons.card_giftcard;

    switch (tier.toLowerCase()) {
      case 'bronze':
        return Icons.workspace_premium;
      case 'silver':
        return Icons.military_tech;
      case 'gold':
        return Icons.emoji_events;
      default:
        return Icons.card_giftcard;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<UserProvider>().logout();
              Navigator.pop(dialogContext);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/auth',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
