import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senhas/Background.dart';
import 'package:senhas/Boxcard.dart';
import 'package:senhas/DATA/Cadastro_Provider.dart';
import 'package:senhas/DATA/ServiceModel.dart';
import 'package:senhas/Header.dart';
import 'package:senhas/Styles.dart';
import 'package:senhas/Wave.dart';
import 'package:senhas/Inclusao.dart';
import 'package:senhas/DATA/Group_Provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 28.0),
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
                        title: Text('PASSWORD VAULT', style: headingTextStyle),
                        centerTitle: true,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer2<CadastroProvider, GroupProvider>(
                    builder: (context, cadastroProvider, groupProvider, child) {
                      final servicos = cadastroProvider.servicos;

                      // Filtra os grupos públicos
                      final gruposPublicos = groupProvider.gruposPublicos;

                      if (servicos.isEmpty || gruposPublicos.isEmpty) {
                        return const Center(
                          child: Text('Nenhum serviço ou grupo cadastrado'),
                        );
                      }

                      // Filtra os serviços que pertencem apenas aos grupos públicos
                      final Map<String, List<ServiceModel>> grupos = _agruparServicosPorGrupo(
                        servicos,
                        gruposPublicos,
                      );

                      return ListView(
                        children: grupos.entries.map((entry) {
                          final String grupo = entry.key;
                          final List<ServiceModel> servicosGrupo = entry.value;

                          return ExpansionTile(
                            title: Text(
                              grupo,
                              style: secundaryTextStyle,
                            ),
                            children: servicosGrupo.map((service) {
                              return Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.startToEnd,
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirmar a exclusão'),
                                        content: Text(
                                            "Deseja excluir '${service.servico}'?"),
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
                                },
                                onDismissed: (direction) {
                                  cadastroProvider.deleteService(service.id!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${service.servico} excluído!'),
                                    ),
                                  );
                                },
                                background: Container(
                                  color: iconsColors.withOpacity(0.5),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Icon(Icons.delete,
                                      color: iconsColors, size: 50),
                                ),
                                child: Boxcard(
                                  boxcontent: Text(service.servico),
                                  hiddenContent: service.senha,
                                ),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Inclusao()),
                        );
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Agrupar os serviços por grupo público
  Map<String, List<ServiceModel>> _agruparServicosPorGrupo(
      List<ServiceModel> servicos,
      List<Map<String, dynamic>> gruposPublicos,
      ) {
    final Map<String, List<ServiceModel>> grupos = {};
    final List<String> nomesGruposPublicos =
    gruposPublicos.map((grupo) => grupo['nome'] as String).toList();

    for (final service in servicos) {
      final String grupo = service.grupo ?? 'Sem Categoria';
      if (nomesGruposPublicos.contains(grupo)) {
        if (!grupos.containsKey(grupo)) {
          grupos[grupo] = [];
        }
        grupos[grupo]!.add(service);
      }
    }

    return grupos;
  }
}
