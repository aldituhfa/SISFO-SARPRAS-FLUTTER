import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang.dart';

Future<List<Barang>> fetchBarang() async {
  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/api/barang'), // Ganti sesuai IP jika pakai HP
  );

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => Barang.fromJson(data)).toList();
  } else {
    throw Exception('Gagal memuat data barang');
  }
}
