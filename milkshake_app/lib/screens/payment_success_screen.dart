import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final int orderId = args['orderId'] as int;
    final double amount = (args['amount'] as num).toDouble();
    final String restaurantName = args['restaurantName'] as String;
    final String pickupTimeStr = args['pickupTime'] as String;
    final String transactionId = args['transactionId'] as String;
    final String paymentMethod = args['paymentMethod'] as String;
    final String customerName = args['customerName'] as String;
    final String customerEmail = args['customerEmail'] as String;
    final List<dynamic> items = args['items'] as List<dynamic>;

    final DateTime pickupTime = DateTime.parse(pickupTimeStr);
    final String pickupFormatted =
        DateFormat('EEE, dd MMM yyyy • HH:mm').format(pickupTime);

    // Simple VAT breakdown assuming total includes VAT at 15%
    final double subtotal = amount / 1.15;
    final double vat = amount - subtotal;

  return Scaffold(
  backgroundColor: const Color(0xFFF4F4F4),
  body: SafeArea(
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER (blue gradient, tick icon)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF64b6ff)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Payment Successful!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thank you for your payment, $customerName',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // CONTENT
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Receipt box
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF667eea),
                              width: 1.5,
                            ),
                            color: const Color(0xFFF8FAFF),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'OFFICIAL RECEIPT',
                                    style: TextStyle(
                                      color: const Color(0xFF667eea),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Order #$orderId',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _infoRow('Customer', customerName),
                              _infoRow('Email', customerEmail),
                              _infoRow(
                                'Order Date',
                                DateFormat('EEE, dd MMM yyyy • HH:mm')
                                    .format(DateTime.now()),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Payment Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF28a745),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'PAID',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Payment details
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💳 Payment Details',
                                style: TextStyle(
                                  color: const Color(0xFF667eea),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _infoRow('Payment Method', paymentMethod),
                              _infoRow('Transaction ID', transactionId),
                              _infoRow(
                                'Paid At',
                                DateFormat('EEE, dd MMM yyyy • HH:mm')
                                    .format(DateTime.now()),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Order items
                        if (items.isNotEmpty) ...[
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              color: const Color(0xFF667eea),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              children: items.map((e) {
                                final item = e as DrinkItem;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.flavour.name} (${item.consistency.name})\n${item.topping.name}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'R${item.totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Price summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0x1A667eea),
                                Color(0x1A64b6ff),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              _priceRow(
                                'Subtotal',
                                'R${subtotal.toStringAsFixed(2)}',
                                isBold: false,
                              ),
                              _priceRow(
                                'VAT (15%)',
                                'R${vat.toStringAsFixed(2)}',
                                isBold: false,
                              ),
                              const SizedBox(height: 6),
                              _priceRow(
                                'TOTAL PAID',
                                'R${amount.toStringAsFixed(2)}',
                                isBold: true,
                                highlight: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Pickup info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFFFFC107),
                                width: 4,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '📍 Pickup Information',
                                style: TextStyle(
                                  color: Color(0xFF856404),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                restaurantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pickupFormatted,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F5FF),
                            borderRadius: BorderRadius.circular(6),
                            border: const Border(
                              left: BorderSide(
                                color: Color(0xFF0066FF),
                                width: 3,
                              ),
                            ),
                          ),
                          child: const Text(
                            '📋 Please present this receipt when collecting your order. '
                            'Your delicious milkshakes are being prepared fresh for you! 😋',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.popUntil(
                                  context,
                                  ModalRoute.withName('/home'),
                                );
                              },
                              child: const Text('Back to Home'),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.popUntil(
                                  context,
                                  ModalRoute.withName('/auth'),
                                );
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

  }

  // Helper widgets

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _priceRow(String label, String value,
      {bool isBold = false, bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: highlight ? const Color(0xFF667eea) : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 20 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: highlight ? const Color(0xFF667eea) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
