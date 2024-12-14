import 'package:senhas/DATA/cadastro_DAO.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';


Future<Database> getDatabase() async {
  final String path = join(await getDatabasesPath(), 'cadastro.db');

  return openDatabase(
    path,
    onCreate: (db, version) {
      db.execute(CadastroDao.tableSql);
      db.execute(CadastroDao.groupTableSql);
    },
    version: 1,
  );
}