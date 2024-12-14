import 'package:senhas/DATA/ServiceModel.dart';
import 'package:senhas/DATA/database.dart';
import 'package:sqflite/sqflite.dart';



class CadastroDao {
  static const String tableSql ='CREATE TABLE $_tablename('
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


// METODO INSERIR NOVO SERVIÇO
Future<int> insertService(ServiceModel service) async {
  final Database bancoDeDados = await getDatabase();
  return await bancoDeDados.insert(_tablename, service.toMap());
}

// METODO ATUALIZAR SERVIÇO EXISTENTE
Future<int> updateService(ServiceModel service) async {
  final Database bancoDeDados = await getDatabase();
  return await bancoDeDados.update(
    _tablename,
    service.toMap(),
    where: '$_id = ?',
    whereArgs: [service.id],
  );
}

//METODO PARA OBTER TODOS OS SERVIÇOS CADASTRADOS
Future<List<ServiceModel>> findAllServices() async {
  final Database bancoDeDados = await getDatabase();
  final List<Map<String, dynamic>> result =
      await bancoDeDados.query(_tablename);
  return result.map((map) => ServiceModel.fromMap(map)).toList();
}

//METODO PARA BUSCAR SERVICO POR ID
// Future<ServiceModel?> findById(int id) async {
//   final Database bancoDeDados = await getDatabase();
//   final List<Map<String, dynamic>> maps = await bancoDeDados.query(
//   _tablename,
//   where: '$_id = ?',
//   whereArgs: [id],
//   );
//   if (maps.isNotEmpty) {
//     return ServiceModel.fromMap(maps.first);
//   }
//   return null;
// }

//METODO PARA DELETAR SERVIÇO ESPECIFICO
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
      {_groupName: groupName,
      _groupPrivacy: isPrivate ? 1 : 0,
      },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

// BUSCAR TODOS GRUPOS

  Future<List<Map<String, dynamic>>> findAllGroups() async {
    final Database bancoDeDados = await getDatabase();
    final List<Map<String, dynamic>> result = await bancoDeDados.query(_groupTableName);
    return result;
  }


Future<int> deleteGroup(String groupName) async {
  final Database bancoDeDados = await getDatabase();
  return await bancoDeDados.delete(
      _groupTableName,
    where: '$_groupName = ?',
    whereArgs: [groupName],
);
  }

  Future<int> updateServiceGroup(String oldGroup, String newGroup) async {
    final Database bancoDeDados = await getDatabase();
    return bancoDeDados.update(
      _tablename,
      {_group: newGroup},
      where: '$_group = ?',
      whereArgs: [oldGroup],
    );
  }

  Future<int> updateGroupPrivacy(String groupName, bool isPrivate) async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.update(
      _groupTableName,
      {_groupPrivacy: isPrivate ? 1 : 0},
      where: '$_groupName = ?',
      whereArgs: [groupName],
    );
  }

  Future<List<Map<String, dynamic>>> findPublicGroups() async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.query(
      _groupTableName,
      where: '$_groupPrivacy = ?',
      whereArgs: [0], // Públicos têm privacidade = 0
    );
  }

  Future<List<Map<String, dynamic>>> findPrivateGroups() async {
    final Database bancoDeDados = await getDatabase();
    return await bancoDeDados.query(
      _groupTableName,
      where: '$_groupPrivacy = ?',
      whereArgs: [1], // Privados têm privacidade = 1
    );
  }


// ATUALIZAR O GRUPO POR ID

// Future<int> updateGroup(int groupId, String newName) async {
//   final Database bancoDeDados = await getDatabase();
//   return await bancoDeDados.update(
//       _groupTableName,
//       {_groupName: newName},
//     where: '$_groupId = ?',
//     whereArgs: [groupId],
//   );
// }
//
//   Future<Map<String, List<ServiceModel>>> findServiceGroup() async {
//     final List<ServiceModel> allServices = await findAll();
//
//     final Map<String, List<ServiceModel>> groupServices = {};
//
//     for (final service in allServices) {
//       final groupKey = service.grupo ?? 'Sem grupo'; // Define "Sem grupo" como padrão
//       if (!groupServices.containsKey(groupKey)) {
//         groupServices[groupKey] = [];
//       }
//       groupServices[groupKey]!.add(service); // Adiciona o serviço ao grupo
//     }
//
//     return groupServices; // Retorna o mapa
//   }
//
//   Future<int> deleteServicesByGroup(String groupName) async {
//     final Database bancoDeDados = await getDatabase();
//     return await bancoDeDados.delete(
//       _tablename,
//       where: '$_group = ?',
//       whereArgs: [groupName],
//     );
//   }
//
//   Future<bool> groupExists(String groupName) async {
//     final Database bancoDeDados = await getDatabase();
//     final List<Map<String, dynamic>> maps = await bancoDeDados.query(
//       _groupTableName,
//       where: '$_groupName = ?',
//       whereArgs: [groupName],
//     );
//     return maps.isNotEmpty; // Retorna true se o grupo existir
//   }
//
//   Future<int> deleteGroupByName(String groupName) async {
//     final Database bancoDeDados = await getDatabase();
//     return await bancoDeDados.delete(
//       _groupTableName,
//       where: '$_groupName = ?',
//       whereArgs: [groupName],
//     );
//   }
//
//   Future<int> updateServiceGroup(String oldGroup, String newGroup) async {
//   final Database bancoDeDados = await getDatabase();
//   return await bancoDeDados.update(
//     _tablename,
//     {_group: newGroup},
//     where: '$_group = ?',
//     whereArgs: [oldGroup],
//   );
//   }


}