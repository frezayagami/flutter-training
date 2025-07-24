import 'package:flutter/material.dart';
import 'package:spending_tracker/screens/dashboard/widgets/transaction_list_item.widget.dart';
import 'package:spending_tracker/screens/transaction_form/transaction_form.screen.dart';
import 'package:spending_tracker/services/database_service.dart'; 
import 'package:spending_tracker/models/transaction.dart'; 
import 'package:spending_tracker/utils/helpers.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<Transaction>> _transactionsFuture;
  int _selectedIndex = 0; // Untuk BottomNavBar

  @override
  void initState() {
    super.initState();
    _refreshTransactions();
  }

  // Fungsi untuk memuat ulang data dari database
  void _refreshTransactions() {
    setState(() {
      _transactionsFuture = _dbService.getTransactions();
    });
  }

  // Fungsi untuk navigasi ke halaman form
  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    // Jika halaman form ditutup dan mengembalikan nilai 'true', refresh data
    if (result == true) {
      _refreshTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Menggunakan FutureBuilder untuk menangani state (loading, error, data)
        child: FutureBuilder<List<Transaction>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final transactions = snapshot.data ?? [];
            return _buildDashboardUI(transactions);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Widget untuk membangun seluruh UI dashboard
  Widget _buildDashboardUI(List<Transaction> transactions) {
    // Menghitung total pengeluaran bulan ini
    double totalBulanIni = transactions
        .where((tx) =>
            tx.tanggal.month == DateTime.now().month &&
            tx.tanggal.year == DateTime.now().year)
        .fold(0, (sum, item) => sum + item.nominal);

    return RefreshIndicator(
      onRefresh: () async => _refreshTransactions(),
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Header
          const Text(
            'Hello, Ozza',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Kartu Ringkasan
          _buildSummaryCard(totalBulanIni),
          const SizedBox(height: 30),

          // Daftar Transaksi
          transactions.isEmpty
              ? _buildEmptyState()
              : _buildTransactionList(transactions),
        ],
      ),
    );
  }

  // Widget untuk kartu ringkasan
  Widget _buildSummaryCard(double total) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF20C997),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF20C997).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pengeluaran bulan ini', style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            formatRupiah(total),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _navigateAndRefresh(const TransactionFormScreen()),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Catat Pengeluaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          )
        ],
      ),
    );
  }

  // Widget untuk menampilkan daftar transaksi yang sudah dikelompokkan
  Widget _buildTransactionList(List<Transaction> transactions) {
    // Mengelompokkan transaksi berdasarkan tanggal
    Map<String, List<Transaction>> groupedTransactions = {};
    for (var tx in transactions) {
      String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tx.tanggal);
      if (groupedTransactions[formattedDate] == null) {
        groupedTransactions[formattedDate] = [];
      }
      groupedTransactions[formattedDate]!.add(tx);
    }

    return Column(
      children: groupedTransactions.entries.map((entry) {
        String date = entry.key;
        List<Transaction> dailyTransactions = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                date,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            ...dailyTransactions.map((tx) => TransactionListItem(
                  transaction: tx,
                  onDelete: () async {
                    bool success = await _dbService.deleteTransaction(tx.id);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
                      _refreshTransactions();
                    }
                  },
                  onEdit: () => _navigateAndRefresh(TransactionFormScreen(transaction: tx)),
                )).toList(),
          ],
        );
      }).toList(),
    );
  }

  // Widget untuk tampilan saat tidak ada data
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Belum ada transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Yuk, catat pengeluaran pertamamu!', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
  
  // Widget untuk Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      selectedItemColor: const Color(0xFF20C997),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
      ],
    );
  }
}