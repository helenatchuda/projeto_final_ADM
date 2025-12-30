import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'basededados.dart';

class DataProvider {
  static final DataProvider _instance = DataProvider._internal();
  factory DataProvider() => _instance;
  DataProvider._internal();

  // Listas em memória para Web (persistência de sessão)
  final List<Map<String, dynamic>> _webOrders = [];
  final List<Map<String, dynamic>> _webFavorites = [];
  final Map<String, dynamic> _webProfile = {
    'nome': 'Helena Dilva',
    'email': 'helena@example.com',
    'foto': '',
  };

  // Carrinho (Global para Web e Native por simplicidade de sessão)
  final List<Map<String, dynamic>> _cart = [];

  // --- CARRINHO ---
  void addToCart(Map<String, dynamic> product, int quantity) {
    // Verifica se já existe para incrementar
    final index = _cart.indexWhere((item) => item['id'] == product['id']);
    if (index >= 0) {
      _cart[index]['quantity'] = (_cart[index]['quantity'] as int) + quantity;
    } else {
      _cart.add({...product, 'quantity': quantity});
    }
  }

  void updateCartQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cart.length) {
      if (newQuantity <= 0) {
        _cart.removeAt(index);
      } else {
        _cart[index]['quantity'] = newQuantity;
      }
    }
  }

  List<Map<String, dynamic>> getCart() {
    return List.from(_cart);
  }

  void clearCart() {
    _cart.clear();
  }

  // --- PRODUTOS ---
  Future<List<Map<String, dynamic>>> getProducts() async {
    if (kIsWeb) {
      try {
        final String response = await rootBundle.loadString('assets/data.json');
        final data = json.decode(response);
        final List<dynamic> products = data['products'];

        // Mapeia adicionando ID baseado no índice simulando BD
        return products.asMap().entries.map((entry) {
          int idx = entry.key + 1;
          var item = entry.value;
          return {
            'id': idx,
            'title': item['title'],
            'price': item['price'],
            'caminhoFicheiro': item['thumbnail'],
            'rating': item['rating'],
            'time': item['time'],
          };
        }).toList();
      } catch (e) {
        print('Erro ao ler JSON na Web: $e');
        return [];
      }
    } else {
      return await Basededados().listarProdutos();
    }
  }

  // --- PEDIDOS ---
  Future<void> addOrder(int produtoId, int quantidade) async {
    if (kIsWeb) {
      final produtos = await getProducts();
      final produto = produtos.firstWhere(
        (p) => p['id'] == produtoId,
        orElse: () => {},
      );

      if (produto.isNotEmpty) {
        _webOrders.add({
          ...produto,
          'quantidade': quantidade,
          'data': DateTime.now().toIso8601String(),
          'status': 'pendente',
        });
      }
    } else {
      await Basededados().adicionarPedido(produtoId, quantidade);
    }
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    if (kIsWeb) {
      return List.from(_webOrders.reversed);
    } else {
      return await Basededados().listarPedidos();
    }
  }

  // --- FAVORITOS ---
  Future<void> toggleFavorite(int produtoId) async {
    if (kIsWeb) {
      final index = _webFavorites.indexWhere((p) => p['id'] == produtoId);
      if (index >= 0) {
        _webFavorites.removeAt(index);
      } else {
        final produtos = await getProducts();
        final produto = produtos.firstWhere(
          (p) => p['id'] == produtoId,
          orElse: () => {},
        );
        if (produto.isNotEmpty) {
          _webFavorites.add(produto);
        }
      }
    } else {
      await Basededados().toggleFavorito(produtoId);
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    if (kIsWeb) {
      return List.from(_webFavorites);
    } else {
      return await Basededados().listarFavoritos();
    }
  }

  // --- PERFIL ---
  Future<Map<String, dynamic>?> getProfile() async {
    if (kIsWeb) {
      return _webProfile;
    } else {
      return await Basededados().getPerfil();
    }
  }

  Future<void> updateProfile(String nome, String email) async {
    if (kIsWeb) {
      _webProfile['nome'] = nome;
      _webProfile['email'] = email;
    } else {
      await Basededados().updatePerfil(nome, email);
    }
  }
}
