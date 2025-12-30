import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Basededados {
  static const String nomebd = "bdadm2.db";
  static const int versao = 5;
  static Database? _basededados;

  Future<Database> get basededados async {
    if (_basededados != null) return _basededados!;
    _basededados = await _initDatabase();
    return _basededados!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), nomebd);
    return await openDatabase(
      path,
      version: versao,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        price TEXT,
        caminhoFicheiro TEXT,
        rating TEXT,
        time TEXT
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE Produtos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          price TEXT,
          caminhoFicheiro TEXT
        )
        
      ''');
    }
    if (oldVersion < 3) {
      // Adiciona colunas se vier da versão 2 ou anterior
      // SQLite não suporta adicionar múltiplas colunas num único ALTER TABLE em algumas versões,
      // mas é seguro fazer um por um.
      try {
        await db.execute('ALTER TABLE Produtos ADD COLUMN rating TEXT');
        await db.execute('ALTER TABLE Produtos ADD COLUMN time TEXT');
      } catch (e) {
        // Ignora se já existir
      }
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE Clientes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT,
          email TEXT,
          foto TEXT
        )
      ''');
      // Inserir usuário padrão
      await db.insert('Clientes', {
        'nome': 'Helena Dilva',
        'email': 'helena@example.com',
        'foto': '',
      });
    }
    if (oldVersion < 5) {
      // Tabela de Pedidos
      await db.execute('''
        CREATE TABLE Pedidos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          produto_id INTEGER,
          quantidade INTEGER,
          data TEXT,
          status TEXT, -- 'entregue', 'pendente'
          FOREIGN KEY(produto_id) REFERENCES Produtos(id)
        )
      ''');
      // Tabela de Favoritos (apenas IDs dos produtos favoritos)
      await db.execute('''
        CREATE TABLE Favoritos (
          produto_id INTEGER PRIMARY KEY,
          FOREIGN KEY(produto_id) REFERENCES Produtos(id)
        )
      ''');
    }
  }

  Future<void> inserirvalor(
    String title,
    String description,
    String price,
    String caminhoFicheiro,
    String rating,
    String time,
  ) async {
    final db = await basededados;
    await db.insert('Produtos', {
      'title': title,
      'description': description,
      'price': price,
      'caminhoFicheiro': caminhoFicheiro,
      'rating': rating,
      'time': time,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> obterTodosProdutosMap() async {
    final db = await basededados;
    return await db.query('Produtos', orderBy: 'title');
  }

  Future<List<Map<String, String>>> consulta2() async {
    final db = await basededados;
    final resultado = await db.query(
      'Produtos',
      columns: ['title', 'price', 'caminhoFicheiro'],
    );
    return resultado.map((map) {
      return {
        'title': map['title'] as String,
        'price': map['price'] as String,
        'caminhoFicheiro': map['caminhoFicheiro'] as String,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> listarProdutos() async {
    final db = await basededados;
    final List<Map<String, dynamic>> resultado = await db.query(
      'Produtos',
      orderBy: 'title',
    );
    return resultado;
  }

  Future<void> removerProduto(int id) async {
    final db = await basededados;
    await db.delete('Produtos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> apagatabela() async {
    final db = await basededados;
    // DROP TABLE: Apaga a tabela e limpa todos os dados
    await db.execute('DROP TABLE IF EXISTS Produtos');
    // Chama o onCreate para recriar a tabela limpa imediatamente
    await _onCreate(db, versao);
  }

  Future<void> fechar() async {
    final db = await basededados;
    await db.close();
    _basededados = null;
  }

  Future<Map<String, dynamic>?> getPerfil() async {
    final db = await basededados;
    final List<Map<String, dynamic>> maps = await db.query(
      'Clientes',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> updatePerfil(String nome, String email) async {
    final db = await basededados;
    await db.update(
      'Clientes',
      {'nome': nome, 'email': email},
      where: 'id = ?',
      whereArgs: [1], // Assumindo usuário único com ID 1
    );
  }

  // --- MÉTODOS PARA FAVORITOS ---
  Future<void> toggleFavorito(int produtoId) async {
    final db = await basededados;
    // Verifica se já existe
    final result = await db.query(
      'Favoritos',
      where: 'produto_id = ?',
      whereArgs: [produtoId],
    );
    if (result.isEmpty) {
      await db.insert('Favoritos', {'produto_id': produtoId});
    } else {
      await db.delete(
        'Favoritos',
        where: 'produto_id = ?',
        whereArgs: [produtoId],
      );
    }
  }

  Future<List<Map<String, dynamic>>> listarFavoritos() async {
    final db = await basededados;
    // Join para pegar detalhes do produto
    return await db.rawQuery('''
      SELECT p.* FROM Produtos p
      INNER JOIN Favoritos f ON p.id = f.produto_id
    ''');
  }

  // --- MÉTODOS PARA PEDIDOS ---
  Future<void> adicionarPedido(int produtoId, int quantidade) async {
    final db = await basededados;
    await db.insert('Pedidos', {
      'produto_id': produtoId,
      'quantidade': quantidade,
      'data': DateTime.now().toIso8601String(),
      'status': 'pendente',
    });
  }

  Future<List<Map<String, dynamic>>> listarPedidos() async {
    final db = await basededados;
    return await db.rawQuery('''
      SELECT p.*, ped.quantidade, ped.status, ped.data 
      FROM Pedidos ped
      INNER JOIN Produtos p ON p.id = ped.produto_id
      ORDER BY ped.data DESC
    ''');
  }
}
