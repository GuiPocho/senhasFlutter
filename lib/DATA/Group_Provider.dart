import 'package:flutter/material.dart';
import 'package:senhas/DATA/cadastro_DAO.dart';
import 'package:senhas/DATA/Cadastro_Provider.dart';

class GroupProvider with ChangeNotifier {
  final CadastroDao _cadastroDao = CadastroDao();

  // Instância do CadastroProvider
  final CadastroProvider? cadastroProvider;

  // Lista local de grupos
  List<Map<String, dynamic>> _grupos = [];
  List<Map<String, dynamic>> get grupos => _grupos;

  GroupProvider(this.cadastroProvider) {
    _loadGroups();
  }

  // Getter para todos os grupos (usado na tela de criação/gerenciamento de grupos)
  List<Map<String, dynamic>> get todosGrupos => _grupos;

  // Getter para grupos públicos (usado na tela inicial)
  List<Map<String, dynamic>> get gruposPublicos =>
      _grupos.where((grupo) => grupo['group_privacy'] == 0).toList();

  // Carrega os grupos do banco de dados
  Future<void> _loadGroups() async {
    try {
      _grupos = await _cadastroDao.findAllGroups();
      notifyListeners(); // Avisa as telas que dependem deste provider
    } catch (e) {
      debugPrint('Erro ao carregar grupos: $e');
    }
  }

  // Recarrega grupos externamente (se quiser chamar direto da UI)
  Future<void> refreshGroups() async {
    await _loadGroups();
  }

  // Adicionar um grupo
  // Atualizar o método addGroup
  Future<void> addGroup(String groupName, bool isPrivate) async {
    if (groupName.trim().isNotEmpty) {
      try {
        await _cadastroDao.insertGroup(groupName, isPrivate); // Adiciona com privacidade
        await _loadGroups(); // Recarrega os grupos
      } catch (e) {
        debugPrint('Erro ao adicionar grupo: $e');
      }
    }
  }


  // Alterar a privacidade do grupo
  Future<void> toggleGroupPrivacy(String groupName) async {
    try {
      final grupo =
      _grupos.firstWhere((grupo) => grupo['nome'] == groupName);
      final novaPrivacidade = grupo['group_privacy'] == 0 ? 1 : 0;
      await _cadastroDao.updateGroupPrivacy(groupName, novaPrivacidade == 1);
      await _loadGroups(); // Após atualizar, recarrega e notifica
    } catch (e) {
      debugPrint('Erro ao alterar privacidade do grupo: $e');
    }
  }

  // Excluir um grupo:
  Future<void> deleteGroup(String groupName) async {
    try {
      // Exclui o grupo no banco de dados
      await _cadastroDao.deleteGroup(groupName);

      // Recarrega os grupos após a exclusão
      await _loadGroups();
    } catch (e) {
      debugPrint('Erro ao excluir grupo: $e');
    }
  }


  // Garante a criação dos grupos padrão
  Future<void> ensureDefaultGroups() async {
    try {
      const defaultGroups = [
        'Email',
        'Rede Social',
        'Jogos',
        'Bancos',
        'Sem Categoria'
      ];

      for (final group in defaultGroups) {
        await _cadastroDao.insertGroup(group, false); // Grupos padrão como públicos
      }

      await _loadGroups(); // Recarrega os grupos após a inserção
    } catch (e) {
      debugPrint('Erro ao garantir grupos padrão: $e');
    }
  }
}
