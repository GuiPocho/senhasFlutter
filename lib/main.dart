import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senhas/BiometricAuth.dart';
import 'package:senhas/DATA/Cadastro_Provider.dart';
import 'package:senhas/DATA/Group_Provider.dart';
import 'package:senhas/HOME.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CadastroProvider()),
        ChangeNotifierProxyProvider<CadastroProvider, GroupProvider>(
          create: (_) => GroupProvider(null),
          update: (context, cadastroProv, previous) =>
              GroupProvider(cadastroProv),
        ),
      ],
      child: const SenhaApp(),
    ),
  );
}

class SenhaApp extends StatelessWidget {
  const SenhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const BiometricAuthScreen(), // Substitui a Home inicial
    );
  }
}

// Tela de autenticação biométrica
class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({Key? key}) : super(key: key);

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final BiometricAuth _biometricAuth = BiometricAuth();

  @override
  void initState() {
    super.initState();
    _authenticate(); // Inicia a autenticação assim que a tela carrega
  }

  Future<void> _authenticate() async {
    bool isAuthenticated = await _biometricAuth.authenticate();

    if (isAuthenticated) {
      // Autenticação bem-sucedida, navega para a tela inicial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      // Autenticação falhou
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erro de Autenticação"),
          content: const Text("Não foi possível autenticar com biometria."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tentar Novamente"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.fingerprint, size: 100),
            SizedBox(height: 20),
            Text(
              "Autenticando...",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
