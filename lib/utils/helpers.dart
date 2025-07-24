import 'package:intl/intl.dart';

// Fungsi untuk memformat angka menjadi format mata uang Rupiah
String formatRupiah(double amount) {
  final format =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  return format.format(amount);
}

// Fungsi untuk memformat angka menjadi format angka biasa dengan pemisah ribuan
String formatAngka(double amount) {
  final format = NumberFormat("#,##0", "id_ID");
  return format.format(amount);
}
