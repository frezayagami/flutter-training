import 'package:mysql1/mysql1.dart';
import '../models/transaction.dart';

class DatabaseService {
  static final _settings = ConnectionSettings(
    host: '10.0.2.2',
    port: 3306,
    user: 'root',
    password: null,
    db: 'db_pengeluaran',
  );

  // Fungsi READ 
  Future<List<Transaction>> getTransactions() async {
    MySqlConnection? conn;
    try {
      conn = await MySqlConnection.connect(_settings);
      Results results = await conn.query(
          'SELECT id, deskripsi, nominal, kategori, tanggal, ikon FROM tb_pengeluaran ORDER BY tanggal DESC, id DESC');
      List<Transaction> transactions =
          results.map((row) => Transaction.fromMap(row.fields)).toList();
      return transactions;
    } catch (e) {
      print('Error saat mengambil data: $e');
      return [];
    } finally {
      await conn?.close();
    }
  }

  // --- FUNGSI CREATE  ---
  Future<bool> addTransaction({
    required String deskripsi,
    required double nominal,
    required String kategori,
    required String tanggal,
    String? ikon,
  }) async {
    MySqlConnection? conn;
    try {
      conn = await MySqlConnection.connect(_settings);
      // PERBAIKAN: Menggunakan conn.query() dengan parameter
      await conn.query(
          'INSERT INTO tb_pengeluaran (deskripsi, nominal, kategori, tanggal, ikon) VALUES (?, ?, ?, ?, ?)',
          [deskripsi, nominal, kategori, tanggal, ikon]);
      return true;
    } catch (e) {
      print('Error saat menambah data: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  // --- FUNGSI UPDATE  ---
  Future<bool> updateTransaction({
    required int id,
    required String deskripsi,
    required double nominal,
    required String kategori,
    required String tanggal,
    String? ikon,
  }) async {
    MySqlConnection? conn;
    try {
      conn = await MySqlConnection.connect(_settings);
      // PERBAIKAN: Menggunakan conn.query() dengan parameter
      await conn.query(
          '''UPDATE tb_pengeluaran 
           SET deskripsi = ?, nominal = ?, kategori = ?, tanggal = ?, ikon = ?
           WHERE id = ?''',
          [deskripsi, nominal, kategori, tanggal, ikon, id]);
      return true;
    } catch (e) {
      print('Error saat mengubah data: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }

  // --- FUNGSI DELETE  ---
  Future<bool> deleteTransaction(int id) async {
    MySqlConnection? conn;
    try {
      conn = await MySqlConnection.connect(_settings);
      // PERBAIKAN: Menggunakan conn.query() dengan parameter
      await conn.query('DELETE FROM tb_pengeluaran WHERE id = ?', [id]);
      return true;
    } catch (e) {
      print('Error saat menghapus data: $e');
      return false;
    } finally {
      await conn?.close();
    }
  }
}
