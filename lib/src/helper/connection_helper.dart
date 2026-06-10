import 'dart:async';
import 'package:asistencia_vial_app/src/environment/environment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

enum ConnectionStatus { ok, noInternet, serverDown, timeout }

/// Backward-compatible boolean check.
Future<bool> isConnectedToServer() async {
  final status = await checkConnectionStatus();
  return status == ConnectionStatus.ok;
}

/// Detailed check that distinguishes the failure type.
Future<ConnectionStatus> checkConnectionStatus() async {
  // Fast local check — does the device have any network interface?
  final connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult.every((r) => r == ConnectivityResult.none)) {
    return ConnectionStatus.noInternet;
  }

  // Reachability check against the actual server.
  try {
    final response = await http
        .get(Uri.parse('${Environment.API_URL}test'))
        .timeout(const Duration(seconds: 5));

    return response.statusCode == 200
        ? ConnectionStatus.ok
        : ConnectionStatus.serverDown;
  } on TimeoutException {
    return ConnectionStatus.timeout;
  } catch (_) {
    return ConnectionStatus.serverDown;
  }
}
