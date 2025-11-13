import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';


// Configuração do GoRouter
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/homepage',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/menupage',
      builder: (context, state) => const MenuPage(),
    ),
  ],
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Uso do MaterialApp.router com a configuração do GoRouter
    return MaterialApp.router(
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
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeString =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });

    // Armazena a referência do Timer para que possa ser cancelado
    final int secondsToNextMinute = 60 - now.second;
    _timer = Timer(Duration(seconds: secondsToNextMinute), _updateTime);
  }

  // **CORREÇÃO DO ERRO:** Implementação do dispose para cancelar o Timer
  @override
  void dispose() {
    _timer.cancel(); // <--- Resolve o setState() called after dispose()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo amarelo
          Container(color: const Color(0xFFFEBC2F)),

          // Hambúrguer de cima à direita
          Positioned(
            top: 20,
            right: -23,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/hamburger2.png', width: 200),
            ),
          ),

          // Hambúrguer de baixo à esquerda
          Positioned(
            bottom: 30,
            left: -20,
            child: Opacity(
              opacity: 0.6,
              child: Image.asset('assets/images/hamburger.png', width: 300),
            ),
          ),

          // Logotipo central
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
                  const Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Ícones de Status (Sinal e Bateria)
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

          // Botão na parte inferior
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
                      // Usando context.push para ir para a HomePage e permitir o retorno
                      context.push('/homepage');
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

  final List<Map<String, String>> burgers = [
    {
      'name': 'Cheeseburger',
      'image': 'assets/images/cheeseburger.png',
      'rating': '4.8',
      'time': '25 mins',
    },
    {
      'name': 'Veggie Burger',
      'image': 'assets/images/veggie_burger.png',
      'rating': '4.5',
      'time': '30 mins',
    },
    {
      'name': 'Hamburger',
      'image': 'assets/images/hambur.png',
      'rating': '4.5',
      'time': '32 mins',
    },
    {
      'name': 'Chicken Burger',
      'image': 'assets/images/chicken_burger.png',
      'rating': '4.2',
      'time': '34 mins',
    },
  ];

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
                  // Top bar (ajustado para incluir o botão de voltar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // **NOVO: Botão de Voltar para a SplashScreen**
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                        onPressed: () {
                          // Retorna para a página anterior (SplashScreen)
                          context.pop(); 
                        },
                      ),
                      
                      const SizedBox(width: 10), // Espaçamento

                      // Container que contém o texto de localização e o ícone de notificação
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
                            const Icon(Icons.notifications_none, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Search bar
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

                  // Burger Grid
                  GridView.builder(
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
                              child: Image.asset(
                                burger['image']!,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    burger['name']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      Text(
                                        '${burger['rating']} • ${burger['time']}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                ],
              ),
            ),
          ),

          // Barra superior (hora, wifi, etc.) - Pode ser ajustada ou removida para melhor design
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
                   // Navega para MenuPage
                  context.push('/menupage');
                },
              ),
              // Botão preto central (Botão de Menu/Ação Principal)
              Center(
                child: SizedBox(
                  width: 80,
                  height: 5,
                  child: ElevatedButton(
                    onPressed: () {
                      // Este botão também navega para o MenuPage
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

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Volta para a página anterior (HomePage)
            context.pop();
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'MENU PAGE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
