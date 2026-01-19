import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_1/data_provider.dart';

class BurgerDetailPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const BurgerDetailPage({super.key, this.product});

  @override
  State<BurgerDetailPage> createState() => _BurgerDetailPageState();
}

class _BurgerDetailPageState extends State<BurgerDetailPage> {
  int _quantity = 1;
  int _selectedSize = 1; 
  final List<bool> _addOns = [false, false, false, false, false];
  final List<String> _addOnNames = [
    'Cheese',
    'Onion',
    'Egg',
    'Pickles',
    'Bacon',
  ];
  final List<double> _addOnPrices = [1.50, 0.50, 2.00, 0.50, 2.50];

  @override
  Widget build(BuildContext context) {
    if (widget.product == null) {
      return const Scaffold(body: Center(child: Text("Product not found")));
    }

    final product = widget.product!;
    final name = product['title'] ?? product['name'] ?? 'Burger';
    final priceStr = product['price'].toString();
    final priceDisplay = priceStr.startsWith('€') ? priceStr : '€$priceStr';
    final imagePath = product['caminhoFicheiro'] ?? product['thumbnail'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Background base
      body: Stack(
        children: [
          // 1. Fundo Amarelo (Topo)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35, // ~35% da tela
            child: Container(color: const Color(0xFFFEBC2F)),
          ),

          // 2. Conteúdo Principal (Scrollable)
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Espaço para a AppBar e Imagem no topo amarelo
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  // Imagem do Burguer (Centralizada no amarelo)
                  Center(
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Builder(
                        builder: (context) {
                          if (imagePath.isEmpty) {
                            return const Icon(
                              Icons.fastfood,
                              size: 100,
                              color: Colors.white,
                            );
                          }
                          if (imagePath.startsWith('assets/')) {
                            return Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                            );
                          }
                          return const Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Container Branco com Detalhes (Bordas arredondadas no topo)
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(25),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título e Preço
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              priceDisplay,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFEBC2F),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Avaliação e Tempo
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFEBC2F),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product['rating'] ?? '4.8'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(1.2k reviews)',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Icon(
                              Icons.access_time_filled,
                              color: Color(0xFFFEBC2F),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product['time'] ?? '25 mins',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Best Burger making experience',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),

                        const SizedBox(height: 25),

                        // Opções (Size)
                        const Text(
                          'Size',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildSizeOption('Single', 0),
                            const SizedBox(width: 10),
                            _buildSizeOption('Large', 1),
                            const SizedBox(width: 10),
                            _buildSizeOption('Medium', 2),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Add-ons (Badges)
                        const Text(
                          'Add Ons',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(_addOnNames.length, (index) {
                            return _buildAddOnChip(index);
                          }),
                        ),

                        // Espaço extra para não ficar colado no botão inferior se houver scroll
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Header Action Buttons (Sobrepostos)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          if (product['id'] != null) {
                            DataProvider().toggleFavorite(product['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Toggled favorite')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar (Quantidade e Botão Add)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Quantity Selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      if (_quantity > 1) {
                        setState(() => _quantity--);
                      }
                    },
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() => _quantity++);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  DataProvider().addToCart(product, _quantity);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$_quantity x $name added to cart!'),
                    ),
                  );
                  context.push('/cart');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEBC2F),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
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

  Widget _buildSizeOption(String label, int index) {
    final isSelected = _selectedSize == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSize = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEBC2F) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25), // Pill shape
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddOnChip(int index) {
    final isSelected = _addOns[index];
    final label = _addOnNames[index];
    // Exibição simplificada conforme screenshot (Chips cinzas ou coloridos)
    return GestureDetector(
      onTap: () => setState(() => _addOns[index] = !_addOns[index]),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEBC2F) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isSelected ? '$label (+€${_addOnPrices[index]})' : label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// End of class
