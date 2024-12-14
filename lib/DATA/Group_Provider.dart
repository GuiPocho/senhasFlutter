import 'package:flutter/material.dart';
import 'package:senhas/DATA/cadastro_DAO.dart';

class GroupProvider with ChangeNotifier {
  final CadastroDao _cadastroDao = CadastroDao();

  // Armazena detalhes completos dos grupos
  List<Map<String, dynamic>> _gruposDetalhes = [];

  // Controle de exibição de grupos privados
  bool _mostrarPrivados = false;

  // Getter público para acessar todos os grupos (independente de privacidade)
  List<Map<String, dynamic>> get allGroups => _gruposDetalhes;

  // Getter público para acessar grupos filtrados por privacidade
  List<Map<String, dynamic>> get gruposDetalhes {
    return _mostrarPrivados
        ? _gruposDetalhes // Retorna todos os grupos
        : _gruposDetalhes.where((g) => g['group_privacy'] == 0).toList(); // Retorna apenas públicos
  }

  // Getter para saber o estado de visibilidade dos grupos privados
  bool get mostrarPrivados => _mostrarPrivados;

  // Getter para expor apenas nomes dos grupos filtrados
  List<String> get gruposDisponiveis =>
      gruposDetalhes.map((g) => g['nome'] as String).toList();

  final List<String> _gruposPadroes = [
    'Netflix',
    'Spotify',
    'Gmail',
  ];

  GroupProvider() {
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final gruposNoBanco = await _cadastroDao.findAllGroups();

      final todosGrupos = [
        {'nome': 'Sem Categoria', 'group_privacy': 0},
        ..._gruposPadroes.map((nome) => {'nome': nome, 'group_privacy': 0}),
      ];

      // Adiciona grupos padrão se não existirem
      for (var grupo in todosGrupos) {
        final groupName = (grupo['nome'] ?? 'Sem Nome').toString();
        final isPrivate = grupo['group_privacy'] == 1;
        if (!gruposNoBanco.any((g) => g['nome'] == groupName)) {
          await _cadastroDao.insertGroup(groupName, isPrivate);
        }
      }

      _gruposDetalhes = await _cadastroDao.findAllGroups();
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar grupos: $e');
    }
  }

  Future<void> addGroup(String groupName, bool isPrivate) async {
    try {
      if (!gruposDisponiveis.contains(groupName)) {
        await _cadastroDao.insertGroup(groupName, isPrivate);
        await _loadGroups();
      }
    } catch (e) {
      print('Erro ao adicionar grupo: $e');
    }
  }

  Future<void> toggleGroupPrivacy(String groupName) async {
    try {
      // Encontra o grupo específico
      final grupo = _gruposDetalhes.firstWhere((g) => g['nome'] == groupName);

      // Altera a privacidade do grupo
      final isPrivate = grupo['group_privacy'] == 1;
      await _cadastroDao.updateGroupPrivacy(groupName, !isPrivate);

      // Atualiza o estado do grupo na memória
      grupo['group_privacy'] = !isPrivate ? 1 : 0;

      notifyListeners(); // Notifica a interface sobre a mudança
    } catch (e) {
      print('Erro ao alternar privacidade do grupo: $e');
    }
  }

  Future<void> deleteGroup(String groupName) async {
    try {
      const semCategoria = 'Sem Categoria';

      // Garante que "Sem Categoria" exista
      if (!_gruposDetalhes.any((grupo) => grupo['nome'] == semCategoria)) {
        await _cadastroDao.insertGroup(semCategoria, false);
        _gruposDetalhes.add({'nome': semCategoria, 'group_privacy': 0});
      }

      // Move os serviços do grupo excluído para "Sem Categoria"
      await _cadastroDao.updateServiceGroup(groupName, semCategoria);

      // Exclui o grupo do banco de dados
      await _cadastroDao.deleteGroup(groupName);

      // Atualiza a lista de grupos localmente
      _gruposDetalhes.removeWhere((g) => g['nome'] == groupName);

      notifyListeners();
    } catch (e) {
      print('Erro ao excluir grupo: $e');
    }
  }

  // Alterna o estado de visibilidade dos grupos privados
  void toggleMostrarPrivados(bool value) {
    _mostrarPrivados = value;
    notifyListeners(); // Notifica a interface sobre a mudança
  }
}
