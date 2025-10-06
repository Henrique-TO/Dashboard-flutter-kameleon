import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/pedido.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'app.db';
  static const int _version = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    _database = await openDatabase(path, version: _version, onCreate: _onCreate);
    return _database!;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente TEXT NOT NULL,
        numero TEXT NOT NULL,
        imagem TEXT,
        data TEXT NOT NULL,
        tags TEXT
      )
    ''');
  }

  Future<int> insertPedido(Pedido pedido) async {
    Database db = await database;
    return await db.insert('pedidos', pedido.toMap());
  }

  Future<List<Pedido>> getPedidos({Map<String, dynamic>? filters}) async {
    Database db = await database;
    String whereString = '1=1';
    List<dynamic> whereArgs = [];

    // Adicione filtros como no original (ex: mês, ano, etc.)
    if (filters != null) {
      if (filters['month'] != null) {
        whereString += " AND strftime('%m', data) = ?";
        whereArgs.add(filters['month'].padLeft(2, '0'));
      }
      // Adicione outros filtros similarmente...
    }

    final List<Map<String, dynamic>> maps = await db.query('pedidos', where: whereString, whereArgs: whereArgs);
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  Future<int> updatePedido(Pedido pedido) async {
    Database db = await database;
    return await db.update('pedidos', pedido.toMap(), where: 'id = ?', whereArgs: [pedido.id]);
  }

  Future<int> deletePedido(int id) async {
    Database db = await database;
    return await db.delete('pedidos', where: 'id = ?', whereArgs: [id]);
  }
}