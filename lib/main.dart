import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spending_tracker/screens/dashboard/dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Baris ini wajib ada di main() yang async
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Inisialisasi data format tanggal untuk 'id_ID' (Indonesia)
  await initializeDateFormatting('id_ID', null); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spending Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Mengatur tema utama aplikasi
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF20C997)),
        useMaterial3: true,
        // Mengatur font default aplikasi menggunakan package google_fonts
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Warna background
      ),
      home: const DashboardScreen(), // Halaman pertama yang dibuka
    );
  }
}
