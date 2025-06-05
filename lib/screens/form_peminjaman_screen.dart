import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FormPeminjamanScreen extends StatefulWidget {
  @override
  _FormPeminjamanScreenState createState() => _FormPeminjamanScreenState();
}

class _FormPeminjamanScreenState extends State<FormPeminjamanScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  int userId = 5; // Ganti sesuai user yang login
  String? selectedBarang;
  List<String> listBarang = [];
  Map<String, int> stokBarang = {}; // Menyimpan stok per barang

  @override
  void initState() {
    super.initState();
    fetchBarangList();
    getEmailFromPrefs(); // ambil email dari SharedPreferences
  }

  Future<void> getEmailFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    if (email != null) {
      setState(() {
        _namaController.text = email; // isi otomatis dengan email
      });
    }
  }

  Future<void> fetchBarangList() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/barang'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        listBarang = data.map((item) => item['nama_barang'] as String).toList();
        stokBarang = {
          for (var item in data) item['nama_barang']: item['stok'] as int,
        };
      });
    } else {
      print('Gagal mengambil data barang');
    }
  }

  Future<void> submitPeminjaman() async {
    if (!_formKey.currentState!.validate()) return;

    final jumlah = int.tryParse(_jumlahController.text) ?? 0;
    final stok = stokBarang[selectedBarang] ?? 0;

    if (jumlah > stok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah melebihi stok barang ($stok tersedia)')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:8000/api/peminjaman'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'nama_peminjam': _namaController.text,
        'tanggal_pinjam': _tanggalController.text,
        'barang': selectedBarang,
        'jumlah': jumlah,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil dikirim, menunggu persetujuan')),
      );

      _tanggalController.clear();
      _jumlahController.clear();
      setState(() {
        selectedBarang = null;
      });

      fetchLatestStatus(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim data')),
      );
    }
  }

  Future<void> fetchLatestStatus(int userId) async {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 5));
      final response = await http.get(
        Uri.parse(
            'http://127.0.0.1:8000/api/status-peminjaman?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];

        if (status == 'dipinjam') {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Permintaan Diterima'),
              content: Text('Permintaan diterima oleh admin'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                )
              ],
            ),
          );
          return false;
        } else if (status == 'ditolak') {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Permintaan Ditolak'),
              content: Text('Maaf, permintaan ditolak oleh admin'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                )
              ],
            ),
          );
          return false;
        }
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Peminjaman')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Peminjam'),
                readOnly: true,
              ),
              TextFormField(
                controller: _tanggalController,
                decoration: InputDecoration(labelText: 'Tanggal Pinjam'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _tanggalController.text =
                        picked.toIso8601String().split('T').first;
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Tanggal harus dipilih'
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedBarang,
                decoration: InputDecoration(labelText: 'Pilih Barang'),
                items: listBarang
                    .map((barang) => DropdownMenuItem(
                          value: barang,
                          child: Text(barang),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBarang = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Silakan pilih barang' : null,
              ),
              if (selectedBarang != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Stok tersedia: ${stokBarang[selectedBarang] ?? 0}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              TextFormField(
                controller: _jumlahController,
                decoration: InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Jumlah harus diisi'
                    : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitPeminjaman,
                child: Text('Kirim'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
