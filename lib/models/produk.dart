class Produk {
  final int id;
  final String nama;
  final String kategori;
  final double harga;
  final int stok;
  final String gambarUrl;
  final int diskonPersen;

  Produk({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.stok,
    required this.gambarUrl,
    this.diskonPersen = 0,
  });
}

final List<Produk> dummyProduk = [
  Produk(
    id: 1,
    nama: 'Nasi Goreng',
    kategori: 'Makanan',
    harga: 15000,
    stok: 10,
    gambarUrl: 'https://picsum.photos/200?1',
    diskonPersen: 20,
  ),
  Produk(
    id: 2,
    nama: 'Mie Goreng',
    kategori: 'Makanan',
    harga: 12000,
    stok: 4,
    gambarUrl: 'https://picsum.photos/200?2',
  ),
  Produk(
    id: 3,
    nama: 'Es Teh',
    kategori: 'Minuman',
    harga: 5000,
    stok: 20,
    gambarUrl: 'https://picsum.photos/200?3',
  ),
  Produk(
    id: 4,
    nama: 'Kopi Susu',
    kategori: 'Minuman',
    harga: 10000,
    stok: 0,
    gambarUrl: 'https://picsum.photos/200?4',
  ),
  Produk(
    id: 5,
    nama: 'Keripik',
    kategori: 'Snack',
    harga: 8000,
    stok: 3,
    gambarUrl: 'https://picsum.photos/200?5',
  ),
  Produk(
    id: 6,
    nama: 'Roti Cokelat',
    kategori: 'Snack',
    harga: 7000,
    stok: 15,
    gambarUrl: 'https://picsum.photos/200?6',
  ),
];
