import 'package:flutter/material.dart';
import 'package:senhas/DATA/Cadastro_Provider.dart';
import 'package:senhas/DATA/Group_Provider.dart';
import 'package:senhas/HOME.dart';
import 'package:senhas/Inclusao.dart';
import 'package:provider/provider.dart';
import 'package:senhas/Tela_grupo.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GroupProvider()),
          ChangeNotifierProvider(create: (_) => CadastroProvider()),

        ],
            child: SenhaApp()),
      );
}

class SenhaApp extends StatelessWidget {
  const SenhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
        );

  }
}


