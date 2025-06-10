// import 'package:icard_lite/core/icard_client/dto/updateData/res_dto/update_data.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute('''
  CREATE TABLE Categories(
    id INTEGER PRIMARY KEY,
    name TEXT,
    image TEXT
  )
''');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'complaints.db',
      version: 3,
      onCreate: (sql.Database database, int version) async {
        print('------CREATING TABLE------');
        await createTables(database);
      },
    );
  }

  static Future<void> insertItem({required List<dynamic> items, tableName}) async {
    final sql.Database db = await SQLHelper.db();

    for (var item in items) {
      await db.insert(tableName, item.toMap(), conflictAlgorithm: sql.ConflictAlgorithm.replace);
    }

    print('success');
  }

  static Future<void> insertOneItem({required Map<String, dynamic> item, required String tableName}) async {
    final sql.Database db = await SQLHelper.db();
    await db.insert(tableName, item, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getItems({required String tableName, List<String>? columns}) async {
    final sql.Database db = await SQLHelper.db();
    final List<Map<String, dynamic>> maps = await db.query(tableName, columns: columns, orderBy: 'id DESC');
    return maps;
  }

  static Future<bool> isTableExist(String tableName) async {
    final sql.Database db = await SQLHelper.db();
    final List<Map<String, dynamic>> tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    return tables.isNotEmpty;
  }

  // static Future<void> deleteItems(String tableName) async {
  //   final sql.Database db = await SQLHelper.db();
  //   await db.delete(tableName);
  //   print('deleted');
  // }

  static Future<void> deleteItem({required String tableName, required int id}) async {
    final sql.Database db = await SQLHelper.db();
    await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

//delete all items

  static Future<void> deleteAllItems(String tableName) async {
    final sql.Database db = await SQLHelper.db();
    await db.delete(tableName);
  }

  //getitems

  // static Future<void> updateItem(
  //     String tableName, Map<String, dynamic> item) async {
  //   final sql.Database db = await SQLHelper.db();
  //   await db.update(tableName, item);
  // }
}