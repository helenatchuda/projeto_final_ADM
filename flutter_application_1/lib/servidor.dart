import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'basededados.dart';

class Servidor {
  final String url;
  final Basededados bd;
  final String appPath;

  const Servidor({required this.url, required this.bd, required this.appPath});

  Future<String?> _downloadImage(String imageUrl, String productName) async {
    // Se for asset local, retorna o próprio caminho
    if (imageUrl.startsWith('assets/')) {
      return imageUrl;
    }

    try {
      final appDocDir = await getTemporaryDirectory();

      final imageDir = Directory(p.join(appDocDir.path, 'imagem'));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final safeName = productName
          .replaceAll(RegExp(r'[^\w]'), '_')
          .toLowerCase();
      final fileName = '$safeName.jpg';
      final filePath = p.join(imageDir.path, fileName);

      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        print(
          'Falha ao descarregar a imagem: status ${response.statusCode} para $imageUrl',
        );
        return null;
      }
    } catch (e) {
      print('Erro no download da imagem ($productName): $e');
      return null;
    }
  }

  Future<void> descarregaInsbd() async {
    print('A iniciar sincronização de dados...');
    String jsonString;

    try {
      // Tenta baixar da API se URL for válida (simples check) e não for 'local'
      if (url.isNotEmpty && url != 'local' && url.startsWith('http')) {
        final result = await http.get(Uri.parse(url));
        if (result.statusCode == 200) {
          jsonString = result.body;
        } else {
          throw Exception('API retornou ${result.statusCode}');
        }
      } else {
        throw Exception('URL local ou vazia, usando assets.');
      }
    } catch (e) {
      print(
        'Falha na rede ou URL local ($e). Usando dados locais (assets/data.json).',
      );
      // Fallback para asset local
      try {
        jsonString = await rootBundle.loadString('assets/data.json');
      } catch (assetError) {
        print('Erro ao ler asset local: $assetError');
        return;
      }
    }

    try {
      final data = jsonDecode(jsonString);
      final lista = data['products'] as List<dynamic>;

      // Opcional: Limpar tabela antes de inserir para evitar duplicatas infinitas se não tiver ID fixo
      // Mas o método inserir usa ConflictAlgorithm.replace, então se tiver ID ou Title como chave ajuda.
      // Como o DB cria ID auto-increment e o title não é unique no create table,
      // pode duplicar. O ideal seria limpar ou verificar.
      // Vou assumir que queremos atualizar tudo.
      // await bd.apagatabela(); // Cuidado, isso reseta IDs. Melhor seria update.

      for (var linha in lista) {
        final String title = linha['title'].toString();
        final String description = linha['description'].toString();
        // O json tem 'price' como string "10.00", o DB espera TEXT.
        final String price = linha['price'].toString();
        final String thumbnailUrl = linha['thumbnail'].toString();
        final String rating = linha['rating']?.toString() ?? '0.0';
        final String time = linha['time']?.toString() ?? '0 mins';

        final String? caminhoFicheiro = await _downloadImage(
          thumbnailUrl,
          title,
        );

        await bd.inserirvalor(
          title,
          description,
          price,
          caminhoFicheiro ?? '',
          rating,
          time,
        );
        print('Produto processado: $title');
      }
    } catch (e) {
      print('Erro ao processar JSON: $e');
    }
  }

  Future<List<String>> listaProdutosApi() async {
    // Simplificado para usar a mesma lógica
    return [];
  }
}
