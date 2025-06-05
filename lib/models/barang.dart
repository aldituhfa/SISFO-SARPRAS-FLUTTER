class Barang {
  final int id;
  final String nama;
  final String kategori;
  final int stok;
  final String satuan;
  final String lokasi;

  Barang({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.stok,
    required this.satuan,
    required this.lokasi,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'] ?? 0,
      nama: json['nama_barang'] ?? 'Tanpa Nama',
      kategori: json['kategori']?['nama_kategori'] ?? 'Tanpa Kategori',
      stok: json['stok'] ?? 0,
      satuan: json['satuan'] ?? 'Tanpa Satuan',
      lokasi: json['lokasi'] ?? 'Tanpa Lokasi',
    );
  }
}
