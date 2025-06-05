import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengembalianForm extends StatefulWidget {
  @override
  _PengembalianFormState createState() => _PengembalianFormState();
}

class _PengembalianFormState extends State<PengembalianForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _peminjamController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tglPinjamController = TextEditingController();
  final TextEditingController _tglKembaliController = TextEditingController();

  String? selectedBarang;
  String? selectedKondisi;
  File? _pickedImage; // untuk mobile
  Uint8List? _webImage; // untuk web
  String? _webImageName; // nama file untuk web

  List<String> kondisiList = ['baik', 'rusak', 'hilang'];

  int? _peminjamanId; // simpan id peminjaman terakhir untuk delete

  @override
  void initState() {
    super.initState();
    _loadUserAndPeminjaman();
  }

  Future<void> _loadUserAndPeminjaman() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      _peminjamController.text = email;

      final response = await http.get(Uri.parse(
          'http://127.0.0.1:8000/api/peminjaman_terakhir?email=$email'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _peminjamanId = data['id']; // simpan id peminjaman terakhir
          selectedBarang = data['barang'];
          _jumlahController.text = data['jumlah'].toString();
          _tglPinjamController.text = data['tanggal_pinjam'] ?? '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal mengambil data peminjaman terakhir')));
      }
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _webImageName = pickedFile.name;
        });
      } else {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() &&
        selectedBarang != null &&
        selectedKondisi != null) {
      final uri = Uri.parse('http://127.0.0.1:8000/api/pengembalian');
      var request = http.MultipartRequest('POST', uri);

      request.fields['peminjam'] = _peminjamController.text;
      request.fields['barang'] = selectedBarang!;
      request.fields['jumlah'] = _jumlahController.text;
      request.fields['tanggal_pinjam'] = _tglPinjamController.text;
      request.fields['tanggal_kembali'] = _tglKembaliController.text;
      request.fields['kondisi_barang'] = selectedKondisi!;

      if (kIsWeb && _webImage != null && _webImageName != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'gambar',
          _webImage!,
          filename: _webImageName!,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else if (_pickedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'gambar',
          _pickedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      try {
        var response = await request.send();

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pengembalian berhasil dikirim.')),
          );

          // Hapus data peminjaman lama via DELETE API
          if (_peminjamanId != null) {
            final deleteResponse = await http.delete(
              Uri.parse('http://127.0.0.1:8000/api/peminjaman/$_peminjamanId'),
            );

            if (deleteResponse.statusCode == 200) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data peminjaman lama berhasil dihapus.')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menghapus data peminjaman lama.')),
              );
            }
          }

          _formKey.currentState?.reset();
          setState(() {
            selectedBarang = null;
            selectedKondisi = null;
            _pickedImage = null;
            _webImage = null;
            _webImageName = null;
            _jumlahController.text = '';
            _tglPinjamController.text = '';
            _tglKembaliController.text = '';
            _peminjamanId = null;
          });

          Navigator.pop(context, true); // kembali ke halaman sebelumnya
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim data. Status code: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saat mengirim data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Form Pengembalian')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _peminjamController,
                decoration: InputDecoration(labelText: 'Nama Peminjam'),
                readOnly: true,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Barang'),
                readOnly: true,
                controller: TextEditingController(text: selectedBarang ?? ''),
              ),
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Jumlah'),
                readOnly: true,
              ),
              TextFormField(
                controller: _tglPinjamController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Tanggal Pinjam'),
                onTap: () => _pickDate(_tglPinjamController),
              ),
              TextFormField(
                controller: _tglKembaliController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Tanggal Kembali'),
                onTap: () => _pickDate(_tglKembaliController),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Tanggal kembali harus diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedKondisi,
                hint: Text('Pilih Kondisi'),
                items: kondisiList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (value) => setState(() => selectedKondisi = value),
                validator: (value) => value == null ? 'Pilih kondisi' : null,
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Pilih Gambar'),
              ),
              if (_pickedImage != null || _webImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: kIsWeb
                      ? Image.memory(_webImage!, height: 100)
                      : Image.file(_pickedImage!, height: 100),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Kembalikan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
