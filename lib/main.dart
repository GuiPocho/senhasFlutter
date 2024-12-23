import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senhas/DATA/Cadastro_Provider.dart'; // Ajuste o caminho conforme seu projeto
import 'package:senhas/DATA/Group_Provider.dart';
         // Arquivo que criaremos/ajustaremos
import 'package:senhas/HOME.dart';                    // Tela inicial do seu app

void main() {
  runApp(
    MultiProvider(
      providers: [
        // 1. Cria primeiro o CadastroProvider
        ChangeNotifierProvider(
          create: (_) => CadastroProvider(),
        ),

        // 2. Cria o GroupProvider via ChangeNotifierProxyProvider
        ChangeNotifierProxyProvider<CadastroProvider, GroupProvider>(
          create: (_) => GroupProvider(null), // Inicialmente nulo
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
      home: const Home(),
    );
  }
}
