// import 'package:local_auth/local_auth.dart';
//
// class BiometricHelper {
//   final LocalAuthentication _auth = LocalAuthentication();
//
//   // Verifica se o dispositivo suporta biometria
//   Future<bool> isBiometricAvailable() async {
//     try {
//       return await _auth.canCheckBiometrics;
//     } catch (e) {
//       return false;
//     }
//   }
//
//   // Autentica o usuário
//   Future<bool> authenticate() async {
//     try {
//       final bool didAuthenticate = await _auth.authenticate(
//         localizedReason: 'Autentique-se para exibir grupos privados.',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//         ),
//       );
//       return didAuthenticate;
//     } catch (e) {
//       return false;
//     }
//   }
// }
