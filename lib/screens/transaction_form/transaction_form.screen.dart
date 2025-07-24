import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spending_tracker/models/transaction.dart';
import 'package:spending_tracker/services/database_service.dart';

class TransactionFormScreen extends StatefulWidget {
  final Transaction? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  late TextEditingController _nominalController;
  late TextEditingController _deskripsiController;
  late TextEditingController _tanggalController;
  String _kategori = 'Makanan dan Minuman';
  String _ikon = 'fastfood';

  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _nominalController = TextEditingController();
    _deskripsiController = TextEditingController();
    _tanggalController =
        TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    if (_isEditMode) {
      final tx = widget.transaction!;
      _nominalController.text = tx.nominal.toStringAsFixed(0);
      _deskripsiController.text = tx.deskripsi;
      _kategori = tx.kategori;
      _ikon = tx.ikon ?? 'fastfood';
      _tanggalController.text = DateFormat('yyyy-MM-dd').format(tx.tanggal);
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _deskripsiController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
  
  Future<void> _submitForm() async {
    // Memanggil validasi sebelum submit
    if (_formKey.currentState!.validate()) {
      final nominal = double.tryParse(_nominalController.text) ?? 0;
      
      bool success = false;
      if (_isEditMode) {
        success = await _dbService.updateTransaction(
          id: widget.transaction!.id,
          deskripsi: _deskripsiController.text,
          nominal: nominal,
          kategori: _kategori,
          tanggal: _tanggalController.text,
          ikon: _ikon,
        );
      } else {
        success = await _dbService.addTransaction(
          deskripsi: _deskripsiController.text,
          nominal: nominal,
          kategori: _kategori,
          tanggal: _tanggalController.text,
          ikon: _ikon,
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan!')),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan data.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Pengeluaran' : 'Tambah Pengeluaran'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            TextFormField(
              controller: _nominalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal Pengeluaran',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                prefixText: 'Rp ',
              ),
              
              validator: (value) {
                // 1. Cek jika kosong
                if (value == null || value.isEmpty) {
                  return 'Nominal tidak boleh kosong';
                }
                // 2. Cek jika bukan angka
                final number = double.tryParse(value);
                if (number == null) {
                  return 'Masukkan angka yang valid';
                }
                // 3. TAMBAHAN: Cek jika angka kurang dari atau sama dengan nol
                if (number <= 0) {
                  return 'Nominal harus lebih dari 0';
                }
                // Jika semua validasi lolos
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Input Deskripsi 
            TextFormField(
              controller: _deskripsiController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Deskripsi tidak boleh kosong';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Input Kategori 
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Jenis Pengeluaran',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              items: const [
                DropdownMenuItem(value: 'Makanan dan Minuman', child: Text('Makanan dan Minuman')),
                DropdownMenuItem(value: 'Transportasi', child: Text('Transportasi')),
                DropdownMenuItem(value: 'Belanja', child: Text('Belanja')),
                DropdownMenuItem(value: 'Hiburan', child: Text('Hiburan')),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _kategori = value;
                    const categoryIconMap = {
                      'Makanan dan Minuman': 'fastfood',
                      'Transportasi': 'directions_bus',
                      'Belanja': 'shopping_cart',
                      'Hiburan': 'movie',
                      'Lainnya': 'wallet_outlined',
                    };
                    _ikon = categoryIconMap[value] ?? 'wallet_outlined';
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Input Tanggal 
            TextFormField(
              controller: _tanggalController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                suffixIcon: Icon(Icons.event),
              ),
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tanggal tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),

            // Tombol Simpan 
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20C997),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isEditMode ? 'Simpan Perubahan' : 'Tambahkan',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
