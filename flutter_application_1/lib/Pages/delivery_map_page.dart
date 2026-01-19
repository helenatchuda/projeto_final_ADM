import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryMapPage extends StatefulWidget {
  const DeliveryMapPage({super.key});

  @override
  _DeliveryMapPageState createState() => _DeliveryMapPageState();
}

class _DeliveryMapPageState extends State<DeliveryMapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  // Coordenadas de Viseu (centro do mapa) inicial
  final LatLng _viseuCenter = const LatLng(40.6610, -7.9097);
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Teste se os serviços de localização estão ativados.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Serviços de localização não estão habilitados, não continue
      // acessando a posição e solicite aos usuários do
      // App para habilitar os serviços de localização.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização desativada. Por favor ative o GPS.'),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissões negadas, próxima vez que tentar
        // solicitar permissões, tente novamente.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // As permissões são negadas para sempre, não podemos solicitar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Permissão negada permanentemente. Ative nas configurações.',
          ),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Se as permissões forem concedidas
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    // NÃO movemos mais a câmera automaticamente para o usuário
    // pois o requisito é focar em Viseu.
    // O usuário pode clicar no botão de "minha localização" se quiser.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa real
          // Mapa (Substituído por imagem estática para evitar erro de API Key na Demo)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E3DF), // Cor de fundo típica de mapas
              image: DecorationImage(
                image: NetworkImage(
                  'https://i.imgur.com/2XgU8M6.png',
                ), // Exemplo de imagem de mapa genérica
                fit: BoxFit.cover,
                opacity: 0.7,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, size: 50, color: Colors.red),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(blurRadius: 5, color: Colors.black26),
                      ],
                    ),
                    child: Text(
                      "Viseu, Portugal",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),

          // Restante UI (barra topo, cards, botões…)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // … o resto do bottom card etc, sem alterações
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final GoogleMapController controller = await _mapController.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: _viseuCenter, zoom: 16),
            ),
          );
        },
        label: const Text('Ir para Restaurante (Viseu)'),
        icon: const Icon(Icons.store),
        backgroundColor: const Color(0xFFFEBC2F),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
