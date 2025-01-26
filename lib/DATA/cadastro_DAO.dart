import 'package:senhas/DATA/ServiceModel.dart';
import 'package:senhas/DATA/database.dart';
import 'package:sqflite/sqflite.dart';

class CadastroDao {
  static const String tableSql = 'CREATE TABLE $_tablename('
      '$_id INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$_service TEXT, '
      '$_password TEXT, '
      '$_group TEXT, '
      '$_privacy INTEGER)';

  static const String groupTableSql = 'CREATE TABLE $_groupTableName('
      '$_groupId INTEGER PRIMARY KEY AUTOINCREMENT, '
      '$_groupName TEXT UNIQUE, '
      '$_groupPrivacy INTEGER DEFAULT 0)';

  static const String _tablename = 'cadastroServices';
  static const String _id = 'id';
  static const String _service = 'servico';
  static const String _password = 'senha';
  static const String _group = 'grupo';
  static const String _privacy = 'privacidade';

  static const String _groupTableName = 'groups';
  static const String _groupId = 'grupoid';
  static const String _groupName = 'nome';
  static const String _groupPrivacy = 'group_privacy';

  // INSERIR NOVO SERVIÇO
  Future<int> insertService(ServiceModel service) async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.insert(_tablename, service.toMap());
  }

  // ATUALIZAR SERVIÇO EXISTENTE
  Future<int> updateService(ServiceModel service) async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.update(
      _tablename,
      service.toMap(),
      where: '$_id = ?',
      whereArgs: [service.id],
    );
  }

  // OBTER TODOS OS SERVIÇOS CADASTRADOS
  Future<List<ServiceModel>> findAllServices() async {
    final Database bancoDeDados = await getDatabase();
    final List<Map<String, dynamic>> result =
    await bancoDeDados.query(_tablename);
    return result.map((map) => ServiceModel.fromMap(map)).toList();
  }

  // DELETAR SERVIÇO ESPECÍFICO
  Future<int> deleteService(int id) async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.delete(
      _tablename,
      where: '$_id = ?',
      whereArgs: [id],
    );
  }

  // INSERIR NOVO GRUPO
  Future<int> insertGroup(String groupName, bool isPrivate) async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.insert(
      _groupTableName,
      {
        _groupName: groupName,
        _groupPrivacy: isPrivate ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // BUSCAR TODOS OS GRUPOS
  Future<List<Map<String, dynamic>>> findAllGroups() async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.query(_groupTableName);
  }

  // DELETAR GRUPO
  Future<void> deleteGroup(String groupName) async {
    final Database bancoDeDados = await getDatabase();
    const semCategoria = 'Sem Categoria';

    try {
      // Garante que "Sem Categoria" existe antes de mover serviços
      final List<Map<String, dynamic>> categoriaExistente =
      await bancoDeDados.query(
        _groupTableName,
        where: '$_groupName = ?',
        whereArgs: [semCategoria],
      );

      if (categoriaExistente.isEmpty) {
        await bancoDeDados.insert(_groupTableName, {
          _groupName: semCategoria,
          _groupPrivacy: 0,
        });
      }

      // Atualiza os serviços do grupo excluído para "Sem Categoria"
      await bancoDeDados.update(
        _tablename,
        {_group: semCategoria},
        where: '$_group = ?',
        whereArgs: [groupName],
      );

      // Exclui o grupo
      await bancoDeDados.delete(
        _groupTableName,
        where: '$_groupName = ?',
        whereArgs: [groupName],
      );
    } catch (e) {
      print('Erro ao excluir grupo: $e');
    }
  }

  // ATUALIZA O GRUPO DE UM SERVIÇO
  Future<int> updateServiceGroup(String oldGroup, String newGroup) async {
    final Database bancoDeDados = await getDatabase();
    return bancoDeDados.update(
      _tablename,
      {_group: newGroup},
      where: '$_group = ?',
      whereArgs: [oldGroup],
    );
  }

  // ATUALIZAR A PRIVACIDADE DE UM GRUPO
  // Atualizar a privacidade de um grupo
  Future<int> updateGroupPrivacy(String groupName, bool isPrivate) async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.update(
      _groupTableName,
      {_groupPrivacy: isPrivate ? 1 : 0},
      where: '$_groupName = ?',
      whereArgs: [groupName],
    );
  }


  // BUSCAR GRUPOS PÚBLICOS
  Future<List<Map<String, dynamic>>> findPublicGroups() async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.query(
      _groupTableName,
      where: '$_groupPrivacy = ?',
      whereArgs: [0], // Públicos têm privacidade = 0
    );
  }

  // BUSCAR GRUPOS PRIVADOS
  Future<List<Map<String, dynamic>>> findPrivateGroups() async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.query(
      _groupTableName,
      where: '$_groupPrivacy = ?',
      whereArgs: [1], // Privados têm privacidade = 1
    );
  }
}
