import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senhas/Background.dart';
import 'package:senhas/DATA/Group_Provider.dart';
import 'package:senhas/GrupoBoxCard.dart';
import 'package:senhas/Wave.dart';
import 'package:senhas/Styles.dart';


class TelaGrupos extends StatefulWidget {
  const TelaGrupos({super.key});

  @override
  State<TelaGrupos> createState() => _TelaGruposState();
}

class _TelaGruposState extends State<TelaGrupos> {
  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final grupos = groupProvider.grupos;

    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
            child: Column(
              children: [
                Container(
                  height: 140.0,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 160.0),
                        painter: WavePainter(),
                      ),
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: Text('GRUPOS', style: headingTextStyle),
                        centerTitle: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: grupos.isEmpty
                      ? const Center(
                    child: Text(
                      'Nenhum grupo disponível',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 2.0,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: grupos.length,
                    itemBuilder: (context, index) {
                      final grupo = grupos[index];

                      return GestureDetector(
                        onTap: () {
                          // Seleciona o grupo
                          Navigator.pop(context, grupo['nome']);
                        },
                        onLongPress: () async {
                          // Exclui o grupo
                          final confirmacao = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Excluir Grupo'),
                                content: Text(
                                    'Tem certeza de que deseja excluir o grupo "${grupo['nome']}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmacao == true) {
                            await groupProvider.deleteGroup(grupo['nome']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Grupo "${grupo['nome']}" excluído com sucesso!',
                                ),
                              ),
                            );
                          }
                        },
                        child: GroupBoxCard(groupName: grupo['nome']),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAdicionarGrupo(context, groupProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoAdicionarGrupo(BuildContext context, GroupProvider groupProvider) {
    final controlador = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Grupo'),
        content: TextField(
          controller: controlador,
          decoration: const InputDecoration(
            hintText: 'Nome do grupo',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await groupProvider.addGroup(controlador.text);
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
