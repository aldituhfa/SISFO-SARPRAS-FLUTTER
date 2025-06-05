import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataPeminjamanScreen extends StatefulWidget {
  @override
  _DataPeminjamanScreenState createState() => _DataPeminjamanScreenState();
}

class _DataPeminjamanScreenState extends State<DataPeminjamanScreen> {
  List<dynamic> peminjamanList = [];
  Set<int> returnedIndexes = {}; // hanya sementara di memori
  bool isLoading = true;
  bool showList = true;

  int currentPage = 0;
  final int itemsPerPage = 5;

  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    if (email != null) {
      setState(() {
        userEmail = email;
      });
      await fetchPeminjaman();
    }
  }

  Future<void> fetchPeminjaman() async {
    setState(() {
      isLoading = true;
    });

    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/peminjaman'));

    if (response.statusCode == 200) {
      final List<dynamic> allData = json.decode(response.body);

      final filteredData = allData.where((item) {
        return item['nama_peminjam'] == userEmail &&
            item['status'] != 'Dikembalikan';
      }).toList();

      setState(() {
        peminjamanList = filteredData;
        isLoading = false;
        currentPage = 0;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Gagal memuat data peminjaman');
    }
  }

  List<dynamic> getPaginatedData() {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage);
    return peminjamanList.sublist(
      startIndex,
      endIndex > peminjamanList.length ? peminjamanList.length : endIndex,
    );
  }

  void nextPage() {
    if ((currentPage + 1) * itemsPerPage < peminjamanList.length) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey[800],
        title: Row(
          children: const [
            Text(
              "Data Peminjaman",
              style: TextStyle(color: Colors.white),
            ),
            Spacer(),
            Icon(Icons.account_circle, color: Colors.white),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.blueGrey[50],
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showList = false;
                });

                Navigator.pushNamed(context, '/form-peminjaman').then((_) async {
                  await fetchPeminjaman();
                  setState(() {
                    showList = true;
                  });
                });
              },
              icon: Icon(Icons.add),
              label: Text("Pinjam Barang"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: showList
                ? (isLoading
                    ? Center(child: CircularProgressIndicator())
                    : peminjamanList.isEmpty
                        ? Center(
                            child: Text(
                              "Tidak ada data peminjaman aktif.",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: getPaginatedData().length,
                            itemBuilder: (context, index) {
                              final itemIndex = currentPage * itemsPerPage + index;
                              final item = getPaginatedData()[index];

                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Barang: ${item['barang']}"),
                                    Text("Jumlah: ${item['jumlah']}"),
                                    Text("Tanggal: ${item['tanggal_pinjam']}"),
                                    Text("Status: ${item['status']}"),
                                    SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: returnedIndexes.contains(itemIndex)
                                          ? Text(
                                              "Sudah Dikembalikan",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : ElevatedButton.icon(
                                              onPressed: () async {
                                                final result = await Navigator.pushNamed(
                                                  context,
                                                  '/pengembalian-form',
                                                  arguments: {
                                                    'peminjam': item['nama_peminjam'],
                                                    'barang': item['barang'],
                                                    'jumlah': item['jumlah'],
                                                    'tanggal_pinjam': item['tanggal_pinjam'],
                                                  },
                                                );

                                                if (result == true) {
                                                  setState(() {
                                                    returnedIndexes.add(itemIndex);
                                                  });
                                                }
                                              },
                                              icon: Icon(Icons.keyboard_return),
                                              label: Text("Kembalikan"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.teal[700],
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ))
                : Center(child: CircularProgressIndicator()),
          ),
          if (peminjamanList.length > itemsPerPage && showList)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: previousPage,
                  icon: Icon(Icons.arrow_back),
                ),
                Text('${currentPage + 1}'),
                IconButton(
                  onPressed: nextPage,
                  icon: Icon(Icons.arrow_forward),
                ),
              ],
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
}
