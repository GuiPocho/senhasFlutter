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
  Future<void> addGroup(String groupName) async {
    if (groupName.trim().isNotEmpty) {
      try {
        await _cadastroDao.insertGroup(groupName, false);
        await _loadGroups(); // Após inserir, recarrega e notifica
      } catch (e) {
        debugPrint('Erro ao adicionar grupo: $e');
      }
    }
  }

  // Excluir um grupo:
  // 1) Move serviços para "Sem Categoria" via CadastroProvider
  // 2) Exclui o grupo
  // 3) Recarrega e notifica
  Future<void> deleteGroup(String groupName) async {
    try {
      // 1) Se tiver o CadastroProvider, realoca os serviços
      if (cadastroProvider != null) {
        await cadastroProvider!.moveServicesToDefaultGroup(groupName);
      } else {
        // Se por algum motivo não tiver, faz manual
        const defaultGroup = 'Sem Categoria';
        await _cadastroDao.updateServiceGroup(groupName, defaultGroup);
      }

      // 2) Exclui o grupo no banco
      await _cadastroDao.deleteGroup(groupName);

      // 3) Recarrega a lista de grupos e notifica
      await _loadGroups(); // <=== FUNDAMENTAL
      // _loadGroups() chama notifyListeners() internamente

    } catch (e) {
      print('Erro ao excluir grupo: $e');
    }
  }


}
