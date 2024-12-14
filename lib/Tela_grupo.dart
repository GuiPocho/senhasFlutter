import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senhas/Background.dart';
import 'package:senhas/GrupoBoxCard.dart';
import 'package:senhas/Header.dart';
import 'package:senhas/DATA/Group_Provider.dart';
import 'package:senhas/DATA/Cadastro_Provider.dart'; // Import adicionado para reconhecer CadastroProvider


class TelaGrupo extends StatelessWidget {
  const TelaGrupo({super.key});

  @override
  Widget build(BuildContext context) {
    // Use watch para reconstruir quando notifyListeners for chamado
    final groupProvider = context.watch<GroupProvider>();
    final gruposDetalhes = groupProvider.allGroups;


    final List<Map<String, dynamic>> todosGrupos = [
      {'nome': 'Incluir Grupo', 'group_privacy': 0},
      ...groupProvider.gruposDetalhes
    ];


    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 28.0),
            child: Column(
              children: [
                Header(),
                const SizedBox(height: 20), // Espaço após o cabeçalho
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Duas colunas
                      crossAxisSpacing: 10, // Espaço horizontal
                      mainAxisSpacing: 10, // Espaço vertical
                      childAspectRatio: 1.5, // Proporção dos cards
                    ),
                    itemCount: todosGrupos.length,
                    itemBuilder: (context, index) {
                      final grupo = todosGrupos[index];
                      return  GroupBoxCard(
                        groupName: grupo['nome'],
                        isPrivate: grupo['group_privacy'] == 1,
                        onTap: () {
                          if (grupo['nome'] == 'Incluir Grupo') {
                            _mostrarDialogoCriarGrupo(context, groupProvider);
                          } else {
                            Navigator.pop(context, grupo['nome']);
                          }
                        },
                        onSwipeRight: () {
                          if (_isGrupoPadrao(grupo['nome'])) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Não é possível alterar um grupo padrão')),
                            );
                            return; // Retorna aqui dentro do if
                          }

                          // Atualiza a privacidade diretamente na memória
                          groupProvider.toggleGroupPrivacy(grupo['nome']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Privacidade do grupo "${grupo['nome']}" alterada!')),
                          );
                        },
                        onLongPress: () async {
                          if (!_isGrupoPadrao(grupo['nome']) && grupo['nome'] != 'Incluir Grupo') {
                            final confirmacao = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Excluir Grupo'),
                                  content: Text('Deseja excluir o grupo "${grupo['nome']}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Excluir'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmacao == true) {
                              await groupProvider.deleteGroup(grupo['nome']);
                              Provider.of<CadastroProvider>(context, listen: false).refreshGroups(groupProvider.gruposDetalhes);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Grupo "${grupo['nome']}" excluído com sucesso!')),
                              );
                            }
                          }
                        },
                      );

                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool _isGrupoPadrao(String grupo) {
    const gruposPadroes = [
      'Netflix',
      'Spotify',
      'Gmail',
      'Sem Categoria',
    ];
    return gruposPadroes.contains(grupo);
  }

  void _mostrarDialogoCriarGrupo(BuildContext context, GroupProvider groupProvider) {
    final TextEditingController novoGrupoController = TextEditingController();
    bool isPrivate = false;
    showDialog(
      context: context,
      builder: (context) {
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
                  Navigator.pop(context);
                }
              },
              child: const Text('Criar'),
            ),
          ],
        );
      },
    );
  }
}
