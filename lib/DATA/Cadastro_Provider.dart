import 'package:flutter/material.dart';
import 'package:senhas/DATA/ServiceModel.dart';
import 'package:senhas/DATA/cadastro_DAO.dart';

class CadastroProvider with ChangeNotifier {
  final CadastroDao _cadastroDao = CadastroDao();

  // Lista interna de serviços
  List<ServiceModel> _servicos = [];

  // Lista interna de grupos com seus detalhes (nome, privacidade etc.)
  List<Map<String, dynamic>> _gruposDetalhes = [];

  // Getter para serviços: outras telas usam `cadastroProvider.servicos`
  List<ServiceModel> get servicos => _servicos;

  // Se quiser acessar os grupos no CadastroProvider
  List<Map<String, dynamic>> get gruposDetalhes => _gruposDetalhes;

  // Construtor que carrega os dados ao inicializar o Provider
  CadastroProvider() {
    _loadServices();
  }

  /// Carrega todos os serviços e grupos do banco de dados
  Future<void> _loadServices() async {
    try {
      // Carrega serviços
      _servicos = await _cadastroDao.findAllServices();

      // Carrega grupos
      _gruposDetalhes = await _cadastroDao.findAllGroups();

      // Notifica os consumidores (telas) para rebuild
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar serviços ou grupos: $e');
    }
  }

  /// Adiciona ou atualiza um serviço no banco de dados
  Future<void> addOrUpdateService(ServiceModel service) async {
    try {
      if (service.id == null) {
        // ID nulo => serviço novo
        await _cadastroDao.insertService(service);
      } else {
        // Atualiza serviço existente
        await _cadastroDao.updateService(service);
      }

      // Recarrega a lista de serviços e grupos para refletir mudanças
      await _loadServices();
    } catch (e) {
      debugPrint('Erro ao adicionar ou atualizar serviço: $e');
    }
  }

  /// Exclui um serviço do banco de dados
  Future<void> deleteService(int id) async {
    try {
      await _cadastroDao.deleteService(id);

      // Atualiza a lista de serviços e grupos
      await _loadServices();
    } catch (e) {
      debugPrint('Erro ao excluir serviço: $e');
    }
  }

  /// Atualiza os grupos caso seja necessário explicitamente
  /// Útil se o GroupProvider ou outra lógica atualizar a tabela de grupos
  /// e quisermos garantir que o CadastroProvider também esteja em sincronia
  Future<void> refreshGroups(List<Map<String, dynamic>> grupos) async {
    _gruposDetalhes = grupos;
    notifyListeners(); // Notifica apenas para atualizar tela se necessário
  }

  /// Move todos os serviços de um grupo para o grupo "Sem Categoria"
  /// Chamado quando um grupo é excluído (via GroupProvider), por exemplo.
  Future<void> moveServicesToDefaultGroup(String groupName) async {
    try {
      const defaultGroup = 'Sem Categoria';

      // Garante que "Sem Categoria" exista nos detalhes de grupos
      if (!_gruposDetalhes.any((g) => g['nome'] == defaultGroup)) {
        // Insere "Sem Categoria" no banco, caso não exista
        await _cadastroDao.insertGroup(defaultGroup, false);
        // Atualiza a lista local de grupos
        _gruposDetalhes.add({'nome': defaultGroup, 'group_privacy': 0});
      }

      // Atualiza todos os serviços do grupo para "Sem Categoria"
      await _cadastroDao.updateServiceGroup(groupName, defaultGroup);

      // Recarrega serviços e grupos para refletir a mudança
      await _loadServices();
    } catch (e) {
      debugPrint('Erro ao mover serviços para o grupo padrão: $e');
    }
  }
}
