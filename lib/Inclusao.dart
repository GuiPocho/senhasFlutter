import 'package:flutter/material.dart';
import 'package:senhas/DATA/ServiceModel.dart';
import 'package:provider/provider.dart';
import 'package:senhas/Background.dart';
import 'package:senhas/Grupos.dart';
import 'package:senhas/Header.dart';
import 'package:senhas/Styles.dart';

import 'package:senhas/DATA/Cadastro_Provider.dart';

class Inclusao extends StatefulWidget {
  const Inclusao({super.key});

  @override
  State<Inclusao> createState() => _InclusaoState();
}

class _InclusaoState extends State<Inclusao> {
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? grupoSelecionado;

  void saveData() {
    final service = serviceController.text.trim();
    final password = passwordController.text.trim();

    if (service.isNotEmpty && password.isNotEmpty) {
      final cadastroProvider =
      Provider.of<CadastroProvider>(context, listen: false);
      final newService = ServiceModel(
        servico: service,
        senha: password,
        grupo: grupoSelecionado ?? 'Sem Categoria',
        privacidade: true
      );

      cadastroProvider.addOrUpdateService(newService);

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira todos os campos obrigatórios')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Header(),
                  const SizedBox(height: 12),
                  Text('ADICIONE UMA CONTA:', style: secundaryTextStyle),
                  _buildTextField(
                    controller: serviceController,
                    hintText: 'email / conta / serviço',
                  ),
                  const SizedBox(height: 8),
                  Text('ADICIONE A SENHA:', style: secundaryTextStyle),
                  _buildTextField(
                    controller: passwordController,
                    hintText: 'Senha a ser lembrada',
                  ),
                  const SizedBox(height: 8),
                  Text('SELECIONE UM GRUPO', style: secundaryTextStyle),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final grupoSelecionadoRetornado =
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TelaGrupos()),
                          );

                          if (grupoSelecionadoRetornado != null &&
                              grupoSelecionadoRetornado is String) {
                            setState(() {
                              grupoSelecionado = grupoSelecionadoRetornado;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          grupoSelecionado ?? 'Gerenciar Grupos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveData,
                    child: const Text('SALVAR'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: iconsColors.withOpacity(0.5)),
          filled: true,
          fillColor: const Color(0x80F2F2F2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.white60),
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}
