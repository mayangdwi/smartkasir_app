import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/karyawan.dart';
import '../models/produk.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smartkasir.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _createDB,
          onUpgrade: _onUpgradeDB,
        ),
      );
    }

    final dbPath = await getDatabasesPath();
    final dbFilePath = join(dbPath, filePath);
    return openDatabase(
      dbFilePath,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode_produk TEXT UNIQUE,
        nama_produk TEXT NOT NULL,
        kategori TEXT NOT NULL,
        harga_beli REAL NOT NULL,
        harga_jual REAL NOT NULL,
        stok INTEGER NOT NULL,
        gambar_path TEXT,
        diskon_persen INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    await _createKaryawanTable(db);

    for (final produk in produkAwalSQLite) {
      await db.insert('produk', produk.toMap());
    }

    await db.rawInsert('''
      INSERT INTO karyawan (nama_karyawan, pin, peran)
      VALUES ('Ahmad Kasir', '1234', 'Kasir')
    ''');
    await db.rawInsert('''
      INSERT INTO karyawan (nama_karyawan, pin, peran)
      VALUES ('Siti Supervisor', '8888', 'Manajer')
    ''');
  }

  Future<void> _createKaryawanTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS karyawan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_karyawan TEXT NOT NULL,
        pin TEXT NOT NULL,
        peran TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createKaryawanTable(db);
      final existing = await db.query('karyawan', limit: 1);
      if (existing.isEmpty) {
        await db.rawInsert('''
          INSERT INTO karyawan (nama_karyawan, pin, peran)
          VALUES ('Ahmad Kasir', '1234', 'Kasir')
        ''');
        await db.rawInsert('''
          INSERT INTO karyawan (nama_karyawan, pin, peran)
          VALUES ('Siti Supervisor', '8888', 'Manajer')
        ''');
      }
    }
  }

  // CRUD tabel karyawan
  Future<int> insertKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return db.insert('karyawan', karyawan.toMap());
  }

  Future<List<Karyawan>> getAllKaryawan() async {
    final db = await instance.database;
    final result = await db.query('karyawan', orderBy: 'id ASC');
    return result.map((json) => Karyawan.fromMap(json)).toList();
  }

  Future<int> updateKaryawan(Karyawan karyawan) async {
    final db = await instance.database;
    return db.update(
      'karyawan',
      karyawan.toMap(),
      where: 'id = ?',
      whereArgs: [karyawan.id],
    );
  }

  Future<int> deleteKaryawan(int id) async {
    final db = await instance.database;
    return db.delete('karyawan', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD tabel produk dari Minggu 11
  Future<int> insertProduk(Produk produk) async {
    final db = await instance.database;
    return db.insert(
      'produk',
      produk.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Produk>> getAllProduk() async {
    final db = await instance.database;
    final result = await db.query('produk', orderBy: 'id DESC');
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<List<Produk>> getProdukByKategori(String kategori) async {
    if (kategori == 'Semua') return getAllProduk();
    final db = await instance.database;
    final result = await db.query(
      'produk',
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'id DESC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<List<Produk>> searchProduk(String keyword) async {
    final db = await instance.database;
    final result = await db.query(
      'produk',
      where: 'nama_produk LIKE ?',
      whereArgs: ['%$keyword%'],
      orderBy: 'id DESC',
    );
    return result.map((json) => Produk.fromMap(json)).toList();
  }

  Future<int> updateProduk(Produk produk) async {
    final db = await instance.database;
    return db.update(
      'produk',
      produk.toMap(),
      where: 'id = ?',
      whereArgs: [produk.id],
    );
  }

  Future<int> deleteProduk(int id) async {
    final db = await instance.database;
    return db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }
}
