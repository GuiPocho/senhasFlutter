import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senhas/DATA/Cadastro_Provider.dart';
import 'package:senhas/DATA/Group_Provider.dart';
import 'package:senhas/DATA/ServiceModel.dart';

import 'package:senhas/Background.dart';
import 'package:senhas/Header.dart';
import 'package:senhas/Styles.dart';
import 'package:senhas/Tela_grupo.dart';

class Inclusao extends StatefulWidget {
  const Inclusao({super.key});

  @override
  State<Inclusao> createState() => _InclusaoState();
}

class _InclusaoState extends State<Inclusao> {
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool privacy = false;
  bool isPrivate = false;
  String? grupoSelecionado;

  void saveData() {
    final service = serviceController.text.trim();
    final password = passwordController.text.trim();
    final group = grupoSelecionado ?? 'Sem Categoria';

    print('Grupo selecionado ao salvar $group ');

    if (service.isNotEmpty && password.isNotEmpty) {
      final newService = ServiceModel(
        servico: service,
        senha: password,
        privacidade: privacy,
        grupo: group,
      );

      final cadastroProvider =
      Provider.of<CadastroProvider>(context, listen: false);
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
    final groupProvider = Provider.of<GroupProvider>(context);
    final grupos = groupProvider.gruposDisponiveis;

grupoSelecionado ??= grupos.isNotEmpty ? grupos.first : 'Sem Categoria';

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
                          onPressed: () {
                            Navigator.push (context, MaterialPageRoute(builder: (context) => TelaGrupo(),
                            ),
                            ).then((grupoSelecionadoRetornado) {
                              if (grupoSelecionadoRetornado != null && grupoSelecionadoRetornado is String) {
                                setState(() {
                                  grupoSelecionado = grupoSelecionadoRetornado;
                                });
                              }
                            }
                            );
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                          )
                        ),
                        child: Text(grupoSelecionado ?? 'Selecionar grupo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      //     child: child)
                      //
                      // DropdownButtonFormField<String>(
                      //   value: grupoSelecionado,
                      //   items: _buildDropdownItems(grupos, groupProvider),
                      //   onChanged: (valor) {
                      //     setState(() {
                      //       if (valor == "Novo Grupo") {
                      //         _mostrarDialogoCriarGrupo(groupProvider);
                      //       } else {
                      //         grupoSelecionado = valor;
                      //       }
                      //     });
                      //   },
                      //   decoration: InputDecoration(
                      //     filled: true,
                      //     fillColor: const Color(0x80F2F2F2),
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8.0),
                      //       borderSide: const BorderSide(color: Colors.white60),
                      //     ),
                      //   ),
                      // ),
                                        ),
                    ),),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     const Text('PRIVACIDADE'),
                  //     Switch(
                  //       value: privacy,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           privacy = value;
                  //         });
                  //       },
                  //     )
                  //   ],
                  // ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveData,
                    child: const Text('SALVAR'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
      List<String> grupos, GroupProvider groupProvider) {
    return [
      ...grupos.map((grupo) {
        return DropdownMenuItem(
          value: grupo,
          child: GestureDetector(
            onLongPress: () async {
              final confirmacao = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Excluir Grupo'),
                    content:
                    Text('Tem certeza de que deseja excluir o grupo "$grupo"?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Excluir'),
                      ),
                    ],
                  );
                },
              );

              if (confirmacao == true) {
                await groupProvider.deleteGroup(grupo);

                setState(() {
                  grupoSelecionado = groupProvider.gruposDisponiveis.isNotEmpty
                      ? groupProvider.gruposDisponiveis.first
                      : 'Sem Categoria';
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Grupo "$grupo" excluído com sucesso!')),
                );
              }
            },
            child: Text(grupo),
          ),
        );
      }),
      const DropdownMenuItem(
        value: "Novo Grupo",
        child: Text("Criar Novo Grupo"),
      ),
    ];
  }

  void _mostrarDialogoCriarGrupo(GroupProvider groupProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final novoGrupoController = TextEditingController();
        return AlertDialog(
          title: const Text('Criar Novo Grupo'),
          content: TextField(
            controller: novoGrupoController,
            decoration: const InputDecoration(
              hintText: 'Nome do Grupo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                },
                child: const Text('Cancelar'),
        ),
        TextButton(
        onPressed: () async {
        final novoGrupo = novoGrupoController.text.trim();
        if (novoGrupo.isNotEmpty) {
        await groupProvider.addGroup(novoGrupo, isPrivate);
        setState(() {
        grupoSelecionado = novoGrupo;
        }
        );
                }
                Navigator.pop(context);
              },
              child: const Text('Criar'),
            ),

          ],
        );
      },
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
