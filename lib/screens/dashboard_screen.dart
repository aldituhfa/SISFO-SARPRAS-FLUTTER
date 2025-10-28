import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  int jumlahBarang = 0;
  int jumlahPeminjaman = 0;
  List<dynamic> barangTerbaru = [];
  String? userEmail;

  @override
  void initState() {
    super.initState();
    fetchJumlahBarang();
    fetchJumlahPeminjaman();
    fetchBarangTerbaru();
    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email') ?? '';
    });
  }

  Future<void> fetchJumlahBarang() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/barang/count');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          jumlahBarang = data['jumlah_barang'];
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> fetchJumlahPeminjaman() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/peminjaman');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          jumlahPeminjaman = data.length;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> fetchBarangTerbaru() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/barang/terbaru');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          barangTerbaru = data;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Widget buildInfoCard(String title, int value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        color: Colors.grey[200], // Ganti dari Colors.white
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$value',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBarangTerbaruCard() {
    return Card(
      color: Colors.grey[200], // Ganti warna putih jadi abu terang
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.fiber_new, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Barang Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Column(
              children: barangTerbaru.take(3).map((item) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(item['nama_barang']),
                  leading: const Icon(Icons.new_releases, color: Colors.green),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderBox() {
    return Container(
      width: double.infinity,
      color: Colors.blueGrey[800],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Text(
        'Selamat datang di aplikasi sarpras',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget buildRiwayatButtonCard() {
    return Card(
      color: Colors.blueGrey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/history'),
          icon: const Icon(Icons.history, color: Colors.white),
          label: const Text(
            'Riwayat Pengembalian',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Ganti dari default putih
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: showAccountDialog,
          ),
        ],
      ),
      body: ListView(
        children: [
          buildHeaderBox(),
          const SizedBox(height: 10),
          Row(
            children: [
              buildInfoCard(
                  'Jumlah Barang', jumlahBarang, Icons.inventory, Colors.blue),
              buildInfoCard('Peminjaman', jumlahPeminjaman, Icons.assignment,
                  Colors.orange),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/data-barang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                    ),
                    child: const Text(
                      'Data Barang',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/data-peminjaman'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                    ),
                    child: const Text(
                      'Data Peminjaman',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          buildRiwayatButtonCard(),
          buildBarangTerbaruCard(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[800],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/data-barang');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/data-peminjaman');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Peminjaman',
          ),
        ],
      ),
    );
  }

  void showAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Akun'),
        content: Text(userEmail != null && userEmail!.isNotEmpty
            ? 'Email: $userEmail'
            : 'Selamat datang di aplikasi ini!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
