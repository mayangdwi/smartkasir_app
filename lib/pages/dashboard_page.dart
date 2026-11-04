import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/produk.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String kategoriTerpilih = 'Semua';

  final List<String> kategori = ['Semua', 'Makanan', 'Minuman', 'Snack'];

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final produkTampil = dummyProduk.where((produk) {
      return kategoriTerpilih == 'Semua' || produk.kategori == kategoriTerpilih;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Kasir',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner promo
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola penjualan dengan mudah bersama Smart Kasir.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          // Pilihan kategori
          SizedBox(
            height: 45,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: kategori.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = kategori[index];
                final terpilih = item == kategoriTerpilih;

                return ChoiceChip(
                  label: Text(item),
                  selected: terpilih,
                  onSelected: (_) {
                    setState(() {
                      kategoriTerpilih = item;
                    });
                  },
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Daftar Produk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Grid produk
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: produkTampil.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final produk = produkTampil[index];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar produk
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              produk.gambarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const ColoredBox(
                                  color: Colors.black12,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                            if (produk.diskonPersen > 0)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'PROMO ${produk.diskonPersen}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Informasi produk
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produk.nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatRupiah.format(produk.harga),
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Status stok
                            Text(
                              produk.stok == 0
                                  ? 'Habis'
                                  : produk.stok <= 5
                                  ? 'Sisa ${produk.stok}'
                                  : 'Stok ${produk.stok}',
                              style: TextStyle(
                                color: produk.stok == 0
                                    ? Colors.red
                                    : produk.stok <= 5
                                    ? Colors.orange
                                    : Colors.green,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Tombol tambah
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: produk.stok == 0
                                    ? null
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${produk.nama} ditambahkan',
                                                ),
                                              ),
                                            );
                                      },
                                child: const Text('Tambah'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
