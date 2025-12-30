import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/data_provider.dart';

class CheckoutFormPage extends StatefulWidget {
  const CheckoutFormPage({super.key});

  @override
  State<CheckoutFormPage> createState() => _CheckoutFormPageState();
}

class _CheckoutFormPageState extends State<CheckoutFormPage> {
  int _selectedPayment = 0; // 0: COD, 1: Card
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  List<Map<String, dynamic>> _cartItems = [];
  double _subtotal = 0.0;
  final double _deliveryFee = 3.50; // Alinhado com o texto

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() {
    _cartItems = DataProvider().getCart();
    _subtotal = _cartItems.fold(0, (sum, item) {
      double price = 0.0;
      var pParam = item['price'];
      if (pParam is num) {
        price = pParam.toDouble();
      } else if (pParam is String) {
        String pStr = pParam.replaceAll(RegExp(r'[^\d.]'), '');
        price = double.tryParse(pStr) ?? 0.0;
      }
      int qty = int.tryParse(item['quantity'].toString()) ?? 1;
      return sum + (price * qty);
    });
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) return;

    // Salvar Pedidos
    for (var item in _cartItems) {
      int prodId = item['id'];
      int qty = int.tryParse(item['quantity'].toString()) ?? 1;
      await DataProvider().addOrder(prodId, qty);
    }

    // Limpar carrinho
    DataProvider().clearCart();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      context.go('/delivery');
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = _subtotal + _deliveryFee;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Info Section
            const Text(
              'Delivery Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Name Field
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'Enter your name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 15),

            // Phone Field
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              hint: 'Enter phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            // Delivery Time
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Time',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          '25-30 mins',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Payment Method
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: _buildPaymentOption(
                    'Cash on Delivery',
                    Icons.money,
                    0,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildPaymentOption(
                    'Credit Card',
                    Icons.credit_card,
                    1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Address
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _buildTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Enter delivery address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: 25),

            // Order Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildRow('Subtotal', '€${_subtotal.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildRow('Delivery', '€${_deliveryFee.toStringAsFixed(2)}'),
                  const Divider(height: 20),
                  _buildRow(
                    'Total',
                    '€${total.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cartItems.isEmpty ? null : () => _placeOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEBC2F),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Place Order',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: InputBorder.none,
                labelStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String label, IconData icon, int index) {
    final isSelected = _selectedPayment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEBC2F) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFFFEBC2F) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isBold ? 16 : 14,
            color: isBold ? const Color(0xFFFEBC2F) : Colors.black,
          ),
        ),
      ],
    );
  }
}
