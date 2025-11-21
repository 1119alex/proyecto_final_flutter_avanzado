import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Servicio para monitorear el estado de conectividad
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection();

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  ConnectivityService() {
    _init();
  }

  void _init() {
    // Escuchar cambios de conectividad
    _connectivity.onConnectivityChanged.listen((results) async {
      await _checkConnection();
    });

    // Verificar conexión inicial
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final hasInternet = await _internetChecker.hasInternetAccess;
      _isConnected = hasInternet;
      _connectionStatusController.add(_isConnected);
      debugPrint('Conectividad: $_isConnected');
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add(false);
      debugPrint('Error verificando conectividad: $e');
    }
  }

  Future<bool> checkConnectivity() async {
    await _checkConnection();
    return _isConnected;
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
