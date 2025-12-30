import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/data_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int _selectedIndex = 2; // Índice "Orders"
  Future<List<Map<String, dynamic>>>? _ordersFuture;
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _cartItems = DataProvider().getCart();
      _ordersFuture = DataProvider().getOrders();
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        context.go('/homepage');
        break;
      case 1:
        context.go('/menupage');
        break;
      case 2:
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  void _updateCartQuantity(int index, int newQty) {
    DataProvider().updateCartQuantity(index, newQty);
    _refreshData();
  }

  double get _cartTotal {
    return _cartItems.fold(0, (sum, item) {
      double price = 0.0;
      var pParam = item['price'];
      if (pParam is num) {
        price = pParam.toDouble();
      } else if (pParam is String) {
        String pStr = pParam.replaceAll('€', '').trim();
        price = double.tryParse(pStr) ?? 0.0;
      }
      int qty = item['quantity'] as int;
      return sum + (price * qty);
    });
  }

  int get _cartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  Widget _buildProductImage(String path) {
    if (path.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        color: Colors.grey.shade200,
        child: const Icon(Icons.fastfood, color: Colors.grey),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: 60,
        height: 60,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(path),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(), // Remove back button if top-level tab
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'My Orders',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ORDER SUMMARY (CART) ---
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_cartItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Your cart is empty"),
                    )
                  else
                    ..._cartItems.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map item = entry.value;
                      return _buildCartItemRow(idx, item);
                    }),

                  if (_cartItems.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total $_cartItemCount items',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        Text(
                          '€${_cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/checkout');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEBC2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Place Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- ORDERED ITEMS (HISTORY) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ordered Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Color(0xFFFEBC2F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                // Prepara lista a ser exibida
                List<Map<String, dynamic>> ordersToShow = [];

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  ordersToShow.addAll(snapshot.data!);
                }

                // Se não houver pedidos reais, exibir DEMO para corresponder ao Design
                if (ordersToShow.isEmpty) {
                  ordersToShow = [
                    {
                      'title': 'Cheese Burger',
                      'description':
                          'Delivery - lahore pakistan\nFrom U Burgers',
                      'status': 'Arriving',
                      'caminhoFicheiro': 'assets/images/cheeseburger.png',
                      'price': 10.00,
                    },
                    {
                      'title': 'Ham burger',
                      'description':
                          'Delivery - Lahore Pakistan\nFrom U Burgers',
                      'status': 'Delivered',
                      'caminhoFicheiro': 'assets/images/hambur.png',
                      'price': 12.50,
                    },
                  ];
                }

                return Column(
                  children: ordersToShow
                      .map((order) => _buildHistoryItem(order))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCartItemRow(int index, Map item) {
    final qty = item['quantity'] as int;
    final name = item['title'] ?? item['name'] ?? 'Prodc';
    final price = item['price'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '€$price',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item['description'] ??
                      'Delicious burger with updates', // Descrição fictícia se não houver
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Qty Controls aligned right
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _updateCartQuantity(index, qty - 1),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Text(
                          '$qty',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        InkWell(
                          onTap: () => _updateCartQuantity(index, qty + 1),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Icon(Icons.add, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map order) {
    String status = order['status'] ?? 'Delivered';
    Color statusColor = const Color(0xFFFEBC2F);

    // Normalizar status Text
    String statusText = status;
    if (status == 'pendente') statusText = 'Arriving';
    if (status == 'entregue') statusText = 'Delivered';
    if (status == 'Arriving' || status == 'Delivered') statusText = status;

    // Subtítulo customizável (para demo)
    String subtitle =
        order['description'] ?? 'Delivery - Lahore Pakistan\nFrom U Burgers';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildProductImage(
              order['caminhoFicheiro'] ?? order['thumbnail'] ?? '',
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['title'] ?? 'Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Tracking navigation
              context.push('/delivery'); // Assuming track goes to map
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEBC2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text('Track', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.restaurant_menu, 'Menu', 1),
          _buildNavItem(Icons.receipt_long, 'Orders', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFEBC2F) : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFFEBC2F),
                fontWeight: FontWeight.bold,
              ),
            ),
          // Se quiser apenas indicador, ou cor diferente, ajuste aqui
        ],
      ),
    );
  }
}
