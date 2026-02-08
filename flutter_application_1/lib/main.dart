import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:io' as dart_io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data_provider.dart';
import 'Pages/menu_page.dart';
import 'Pages/burger_detail_page.dart';
import 'Pages/orders_page.dart';
import 'Pages/checkout_page.dart';
import 'Pages/checkout_form_page.dart';
import 'Pages/delivery_map_page.dart';
import 'Pages/profile_page.dart';
import 'Pages/favorites_page.dart';
import 'Pages/payment_methods_page.dart';
import 'Pages/addresses_page.dart';
import 'Pages/help_support_page.dart';
import 'Pages/cart_page.dart';
import 'basededados.dart';
import 'servidor.dart';
import 'package:path_provider/path_provider.dart';

// Configuração do GoRouter
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/homepage', builder: (context, state) => const HomePage()),
    GoRoute(path: '/menupage', builder: (context, state) => const MenuPage()),
    GoRoute(
      path: '/burgerdetail',
      builder: (context, state) {
        final product = state.extra as Map<String, dynamic>?;
        return BurgerDetailPage(product: product);
      },
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
    GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/checkoutform',
      builder: (context, state) => const CheckoutFormPage(),
    ),
    GoRoute(
      path: '/delivery',
      builder: (context, state) => const DeliveryMapPage(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentMethodsPage(),
    ),
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const AddressesPage(),
    ),
    GoRoute(
      path: '/help',
      builder: (context, state) => const HelpSupportPage(),
    ),
  ],
);

void main() {
  // Inicialização necessária para sqflite no Desktop (Windows/Linux)
  if (!kIsWeb &&
      (dart_io.Platform.isWindows ||
          dart_io.Platform.isLinux ||
          dart_io.Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fasty Fast Delivery',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _timeString = '';
  // Variável para armazenar a referência do Timer
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _initDataAndSync();
  }

  Future<void> _initDataAndSync() async {
    if (kIsWeb) return;

    try {
      final bd = Basededados();
      final directory = await getApplicationDocumentsDirectory();

      final servidor = Servidor(url: 'local', bd: bd, appPath: directory.path);

      await servidor.descarregaInsbd();
    } catch (e) {
      print('Erro na inicialização: $e');
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _timeString =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      });
    }

    final int secondsToNextMinute = 60 - now.second;
    _timer = Timer(Duration(seconds: secondsToNextMinute), _updateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFFFEBC2F)),

          Positioned(
            top: 20,
            right: -23,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/hamburger2.png', width: 200),
            ),
          ),

          Positioned(
            bottom: 30,
            left: -20,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/hamburger.png', width: 300),
            ),
          ),

          Center(child: Image.asset('assets/images/logotipo.png', width: 300)),

          Positioned(
            top: 3,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _timeString.isEmpty ? '9:41' : _timeString,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: const [
                      Icon(Icons.wifi, color: Colors.black, size: 21),
                      Icon(
                        Icons.signal_cellular_alt,
                        color: Colors.black,
                        size: 21,
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.battery_full, color: Colors.black, size: 21),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -30,
            left: 0,
            right: 0,
            child: BottomAppBar(
              color: Colors.transparent,
              child: Center(
                child: SizedBox(
                  width: 250,
                  height: 7,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/homepage');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(''),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;

  final List<Map<String, String>> categories = [
    {'name': 'Cheese', 'image': 'assets/images/cheeseburger.png'},
    {'name': 'Chicken', 'image': 'assets/images/chicken_burger.png'},
    {'name': 'Veggie', 'image': 'assets/images/veggie_burger.png'},
    {'name': 'Ham', 'image': 'assets/images/hambur.png'},
  ];

  Future<List<Map<String, dynamic>>>? _burgersFuture;

  @override
  void initState() {
    super.initState();
    _burgersFuture = DataProvider().getProducts();
  }

  Widget _buildProductImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50),
      );
    } else {
      return Image.file(
        dart_io.File(path),
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.location_on, color: Colors.orange),
                                SizedBox(width: 10),
                                Text(
                                  'Deliver now\nLahore Pakistan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.notifications_none,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.filter_list, color: Colors.grey),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Categories
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = index == selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 45),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromARGB(255, 252, 251, 249)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? const Color.fromARGB(255, 254, 254, 253)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(category['image']!, width: 50),
                                const SizedBox(height: 5),
                                Text(
                                  category['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Explore Burgers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Burger Grid (FutureBuilder)
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _burgersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Erro: ${snapshot.error}"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(" produtos não encontrados"),
                        );
                      }

                      final burgers = snapshot.data!;

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 230,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: burgers.length,
                        itemBuilder: (context, index) {
                          final burger = burgers[index];
                          // Adaptei nomes dos campos do BD
                          final name = burger['title'] ?? 'Sem Nome';
                          final imagePath = burger['caminhoFicheiro'] ?? '';
                          final rating = burger['rating'] ?? '0.0';
                          final time = burger['time'] ?? '--';

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                  child: _buildProductImage(imagePath),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 18,
                                            color: Colors.orange,
                                          ),
                                          Text('$rating • $time'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.favorite_border,
                                            color: Colors.orange,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 3,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.wifi, color: Colors.black, size: 21),
                      Icon(
                        Icons.signal_cellular_alt,
                        color: Colors.black,
                        size: 21,
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.battery_full, color: Colors.black, size: 21),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.orange),
                tooltip: 'Home',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.restaurant, color: Colors.grey),
                tooltip: 'Menu',
                onPressed: () {
                  context.push('/menupage');
                },
              ),

              Center(
                child: SizedBox(
                  width: 80,
                  height: 5,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/menupage');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(''),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.receipt_long, color: Colors.grey),
                tooltip: 'Orders',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person, color: Colors.grey),
                tooltip: 'Profile',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
