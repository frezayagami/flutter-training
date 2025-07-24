class Transaction {
  final int id;
  final String deskripsi;
  final double nominal;
  final String kategori;
  final DateTime tanggal;
  final String? ikon;

  Transaction({
    required this.id,
    required this.deskripsi,
    required this.nominal,
    required this.kategori,
    required this.tanggal,
    this.ikon,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      deskripsi: map['deskripsi'],
      nominal: double.parse(map['nominal'].toString()),
      kategori: map['kategori'],
      tanggal: DateTime.parse(map['tanggal'].toString()),
      ikon: map['ikon'],
    );
  }
}