import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      // Verifica se o dispositivo suporta biometria
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      List<BiometricType> availableBiometrics =
      await _localAuth.getAvailableBiometrics();

      debugPrint("Suporte a biometria: $canCheckBiometrics");
      debugPrint("Dispositivo suportado: $isDeviceSupported");
      debugPrint("Tipos disponíveis: $availableBiometrics");

      if (!canCheckBiometrics ||
          !isDeviceSupported ||
          availableBiometrics.isEmpty) {
          debugPrint("Biometria indisponível ou não configurada.");
        return false;
      }

      // Tenta autenticar com biometria
      return await _localAuth.authenticate(
        localizedReason: 'Use sua biometria para acessar o aplicativo',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint("Erro durante a autenticação: $e");
      return false;
    }
  }
}
