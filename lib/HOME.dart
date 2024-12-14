import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senhas/Adicionar.dart';
import 'package:senhas/Background.dart';
import 'package:senhas/Boxcard.dart';
import 'package:senhas/DATA/Cadastro_Provider.dart';
import 'package:senhas/DATA/Group_Provider.dart';
import 'package:senhas/DATA/ServiceModel.dart';
import 'package:senhas/Header.dart';
import 'package:senhas/Inclusao.dart';
import 'package:senhas/Styles.dart';
import 'package:senhas/Wave.dart';
import 'package:senhas/biometria.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _mostrarPrivados = false;

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
                    title: Row(
                      children: [
                        Text('PASSWORD VAULT', style: headingTextStyle),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            final biometricHelper = BiometricHelper();

                            // Verifica se a biometria está disponível
                            if (await biometricHelper.isBiometricAvailable()) {
                              // Tenta autenticar
                              final isAuthenticated = await biometricHelper.authenticate();
                              if (isAuthenticated) {
                                // Alterna a visibilidade dos grupos privados
                                setState(() {
                                  _mostrarPrivados = !_mostrarPrivados;
                                });
                                Provider.of<GroupProvider>(context, listen: false)
                                    .toggleMostrarPrivados(_mostrarPrivados);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Autenticação falhou')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Biometria não disponível')),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: Image.asset('assets/peixe.png'),
                            ),
                          ),
                        ),



                      ],
                    ),
                    centerTitle: true,
                  ),
                ],
              ),
            ),
                Expanded(
                  child: Consumer2<CadastroProvider, GroupProvider>(
                    builder: (context, cadastroProvider, groupProvider, child) {
                      // Obtém os grupos com base na visibilidade
                      final grupos = groupProvider.gruposDetalhes;

                      // Agrupa os serviços com base nos grupos
                      final gruposEServicos = _agruparServicosPorGrupo(
                        cadastroProvider.servicos,
                        grupos.map((g) => g['nome'].toString()).toList(),
                      );

                      if (gruposEServicos.isEmpty) {
                        return const Center(
                          child: Text('Nenhum serviço cadastrado'),
                        );
                      }

                      return ListView(
                        children: gruposEServicos.entries.map((entry) {
                          final String grupo = entry.key;
                          final List<ServiceModel> servicos = entry.value;

                          return ExpansionTile(
                            title: Text(grupo, style: secundaryTextStyle),
                            children: servicos.isEmpty
                                ? [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Nenhum serviço neste grupo'),
                              ),
                            ]
                                : servicos.map((service) {
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
                                        content: Text('${service.servico} excluído!')),
                                  );
                                },
                                background: Container(
                                  color: iconsColors.withOpacity(0.5),
                                  alignment: Alignment.centerLeft,
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                          MaterialPageRoute(builder: (context) => const Inclusao()),
                        );
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                )

              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função para agrupar serviços por grupo
  Map<String, List<ServiceModel>> _agruparServicosPorGrupo(
      List<ServiceModel> servicos, List<String> grupos) {
    final Map<String, List<ServiceModel>> gruposEServicos = {};

    // Inicializa o mapa com os grupos disponíveis
    for (final grupo in grupos) {
      gruposEServicos[grupo] = [];
    }

    // Garante que 'Sem Categoria' exista
    if (!gruposEServicos.containsKey('Sem Categoria')) {
      gruposEServicos['Sem Categoria'] = [];
    }

    for (final service in servicos) {
      final groupName = service.grupo ?? 'Sem Categoria';
      if (gruposEServicos.containsKey(groupName)) {
        gruposEServicos[groupName]!.add(service);
      }
    }

    return gruposEServicos;
  }
}
