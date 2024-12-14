import 'package:flutter/material.dart';
import 'package:senhas/DATA/ServiceModel.dart';
import 'package:senhas/DATA/cadastro_DAO.dart';

class CadastroProvider with ChangeNotifier {
  final CadastroDao _cadastroDao = CadastroDao();
  List<ServiceModel> _servicos = [];
  List<Map<String, dynamic>> _gruposDetalhes = [];

  // Getter público para acessar os serviços
  List<ServiceModel> get servicos => _servicos;

  // Obter serviços públicos, filtrando pelos grupos públicos
  List<ServiceModel> get publicServices {
    final gruposPublicos = _gruposDetalhes
        .where((grupo) => grupo['group_privacy'] == 0)
        .map((grupo) => grupo['nome'] as String)
        .toSet();

    return _servicos.where((service) {
      return gruposPublicos.contains(service.grupo ?? 'Sem Categoria');
    }).toList();
  }

  // Obter serviços privados, filtrando pelos grupos privados
  List<ServiceModel> get privateServices {
    final gruposPrivados = _gruposDetalhes
        .where((grupo) => grupo['group_privacy'] == 1)
        .map((grupo) => grupo['nome'] as String)
        .toSet();

    return _servicos.where((service) {
      return gruposPrivados.contains(service.grupo);
    }).toList();
  }

  CadastroProvider() {
    _loadServices(); // Carrega os serviços ao inicializar
  }

  // Carrega os serviços do banco e os detalhes dos grupos
  Future<void> _loadServices() async {
    try {
      _servicos = await _cadastroDao.findAllServices();
      _gruposDetalhes = await _cadastroDao.findAllGroups();
      notifyListeners(); // Notifica a interface sobre mudanças
    } catch (e) {
      print('Erro ao carregar serviços ou grupos: $e');
    }
  }

  // Adiciona ou atualiza um serviço
  Future<void> addOrUpdateService(ServiceModel service) async {
    try {
      if (service.id == null) {
        // Serviço novo
        await _cadastroDao.insertService(service);
      } else {
        // Atualiza serviço existente
        await _cadastroDao.updateService(service);
      }
      await _loadServices(); // Recarrega os serviços após a operação
    } catch (e) {
      print('Erro ao adicionar ou atualizar serviço: $e');
    }
  }

  // Exclui um serviço
  Future<void> deleteService(int id) async {
    try {
      await _cadastroDao.deleteService(id);
      await _loadServices(); // Recarrega os serviços após a exclusão
    } catch (e) {
      print('Erro ao excluir serviço: $e');
    }
  }

  // Atualiza os detalhes dos grupos (se necessário explicitamente)
  Future<void> refreshGroups(List<Map<String, dynamic>> grupos) async {
    _gruposDetalhes = grupos;
    // Após atualizar os grupos, recarrega também os serviços
    await _loadServices();
    // O _loadServices() já chama notifyListeners(), então não é necessário chamar de novo
  }

}
