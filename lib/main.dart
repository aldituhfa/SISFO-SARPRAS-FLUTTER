import 'package:flutter/material.dart';
import 'package:sisfo_sarpras_flutter/screens/data_barang_screen.dart';
import 'package:sisfo_sarpras_flutter/screens/data_peminjaman_screen.dart';
import 'package:sisfo_sarpras_flutter/screens/form_peminjaman_screen.dart';
import 'package:sisfo_sarpras_flutter/screens/history_screen.dart';
import 'package:sisfo_sarpras_flutter/screens/pengembalian_form.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Peminjaman',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/data-barang': (context) => DataBarangScreen(),
        '/form-peminjaman': (context) => FormPeminjamanScreen(),
        '/data-peminjaman': (context) => DataPeminjamanScreen(),
        '/pengembalian-form': (context) => PengembalianForm(),
        '/history': (context) => HistoryScreen(),
      },
    );
  }
}
