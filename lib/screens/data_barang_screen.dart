import 'package:flutter/material.dart';
import '../models/barang.dart';
import '../services/barang_service.dart';

class DataBarangScreen extends StatefulWidget {
  @override
  _DataBarangScreenState createState() => _DataBarangScreenState();
}

class _DataBarangScreenState extends State<DataBarangScreen> {
  late Future<List<Barang>> futureBarang;
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    futureBarang = fetchBarang();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[800],
        automaticallyImplyLeading: false, 
        title: Row(
          children: [
            Text(
              "Data Barang",
              style: TextStyle(color: Colors.white),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              onPressed: () {
                // Aksi tambahan jika diperlukan
              },
            )
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tombol Pinjam Barang
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/form-peminjaman');
              },
              icon: const Icon(Icons.add),
              label: const Text("Pinjam Barang"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 169, 214, 239),
              ),
            ),
          ),
          // List Barang
          Expanded(
            child: FutureBuilder<List<Barang>>(
              future: futureBarang,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final items = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 kolom
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3 / 2.3,
                    ),
                    itemBuilder: (context, index) {
                      final barang = items[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                barang.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text("Kategori: ${barang.kategori}",
                                  style: const TextStyle(fontSize: 12)),
                              Text("Stok: ${barang.stok} ${barang.satuan}",
                                  style: const TextStyle(fontSize: 12)),
                              const Spacer(),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.teal),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      barang.lokasi,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[800],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 2,
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

  void onNavTapped(int index) {
    setState(() => selectedIndex = index);
    if (index == 0) Navigator.pushNamed(context, '/dashboard');
    if (index == 1) Navigator.pushNamed(context, '/data-barang');
    if (index == 2) Navigator.pushNamed(context, '/data-peminjaman');
  }
}
