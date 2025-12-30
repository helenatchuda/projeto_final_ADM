import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/data_provider.dart';
import 'dart:io';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}
// ... (código intermediário omitido, focando na remoção do dart:io)

class _CheckoutPageState extends State<CheckoutPage> {
  // Em um app real, o carrinho viria de um Provider/GetX global.
  // Por simplicidade, vamos simular que o carrinho tem itens do DB aleatórios ou fixos,
  // mas o correto seria o User adicionar no Menu e vir para cá.

  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    // Carregar itens do carrinho real
    var items = DataProvider().getCart();

    // Se vazio, usar DEMO items para visualização do fluxo
    if (items.isEmpty) {
      items = [
        {
          'title': 'Cheese Burger',
          'price': 10.00,
          'quantity': 1,
          'caminhoFicheiro': 'assets/images/cheeseburger.png',
        },
        {
          'title': 'Ham burger',
          'price': 12.50,
          'quantity': 1,
          'caminhoFicheiro': 'assets/images/hambur.png',
        },
      ];
    }

    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  String _couponCode = '';
  final double _deliveryFee = 5.00;

  double get subtotal {
    return cartItems.fold(0, (sum, item) {
      // Robust price parsing
      double price = 0.0;
      var pParam = item['price'];
      if (pParam is num) {
        price = pParam.toDouble();
      } else if (pParam is String) {
        String pStr = pParam.replaceAll(
          RegExp(r'[^\d.]'),
          '',
        ); // Remove currency chars
        price = double.tryParse(pStr) ?? 0.0;
      }

      int qty = int.tryParse(item['quantity'].toString()) ?? 1;
      return sum + (price * qty);
    });
  }

  double get total => subtotal + _deliveryFee;

  void _processCheckout() {
    // Apenas navegar para o formulário de entrega/pagamento
    // O pedido será efetivado lá.
    context.push('/checkoutform');
  }

  Widget _buildProductImage(String path) {
    if (path.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        color: Colors.grey.shade200,
        child: const Icon(Icons.fastfood, color: Colors.grey),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: 70,
        height: 70,
        fit: BoxFit.contain, // Contain para ver o burguer todo
        errorBuilder: (context, error, stackTrace) => Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(path),
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 70,
          height: 70,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco geral
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cartItems.isEmpty)
                    const Center(child: Text("Cart is empty")),

                  // Cart Items
                  ...cartItems.asMap().entries.map((entry) {
                    return _buildCartItem(entry.value, entry.key);
                  }),

                  const SizedBox(height: 20),

                  // Coupon Input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (value) => _couponCode = value,
                            decoration: const InputDecoration(
                              hintText: 'Apply Coupon',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Coupon "$_couponCode" applied!'),
                              ),
                            );
                          },
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              color: Color(0xFFFEBC2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Subtotal',
                          '€${subtotal.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryRow(
                          'Delivery Fee',
                          '€${_deliveryFee.toStringAsFixed(2)}',
                        ),
                        const Divider(height: 25),
                        _buildSummaryRow(
                          'Total',
                          '€${total.toStringAsFixed(2)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _processCheckout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEBC2F),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue to payment',
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

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildProductImage(
              item['caminhoFicheiro'] ?? item['thumbnail'] ?? '',
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? 'Product',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '€${item['price']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFEBC2F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildQuantityButton(Icons.remove, () {
                if (item['quantity'] > 1) {
                  setState(() => cartItems[index]['quantity']--);
                }
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${item['quantity']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _buildQuantityButton(Icons.add, () {
                setState(() => cartItems[index]['quantity']++);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFFFEBC2F) : Colors.black,
          ),
        ),
      ],
    );
  }
}
