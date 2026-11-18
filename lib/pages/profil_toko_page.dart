import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kelola_karyawan_page.dart';

class ProfilTokoPage extends StatefulWidget {
  const ProfilTokoPage({super.key});

  @override
  State<ProfilTokoPage> createState() => _ProfilTokoPageState();
}

class _ProfilTokoPageState extends State<ProfilTokoPage> {
  final _namaTokoController = TextEditingController();
  final _alamatController = TextEditingController();
  final _noWaController = TextEditingController();
  final _footerController = TextEditingController();
  final _instagramController = TextEditingController();
  bool _sedangMenyimpan = false;
  String _activeCashierName = 'Belum Ditentukan';

  @override
  void initState() {
    super.initState();
    _muatProfilToko();
  }

  @override
  void dispose() {
    _namaTokoController.dispose();
    _alamatController.dispose();
    _noWaController.dispose();
    _footerController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _muatProfilToko() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _namaTokoController.text =
          prefs.getString('nama_toko') ?? 'SmartKasir Poliban';
      _alamatController.text = prefs.getString('alamat_toko') ??
          'Jl. Brigjen H. Hasan Basry, Banjarmasin';
      _noWaController.text = prefs.getString('no_wa') ?? '081234567890';
      _footerController.text = prefs.getString('footer_struk') ??
          'Terima Kasih Atas Kunjungan Anda! Barang yang sudah dibeli tidak dapat ditukar.';
      _instagramController.text = prefs.getString('ig_toko') ?? '';
      _activeCashierName =
          prefs.getString('active_cashier_name') ?? 'Belum Ditentukan';
    });
  }

  Future<void> _simpanProfilToko() async {
    setState(() => _sedangMenyimpan = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nama_toko', _namaTokoController.text.trim());
      await prefs.setString('alamat_toko', _alamatController.text.trim());
      await prefs.setString('no_wa', _noWaController.text.trim());
      await prefs.setString('footer_struk', _footerController.text.trim());
      await prefs.setString('ig_toko', _instagramController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Identitas toko berhasil diperbarui!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil toko: $error'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profil & Pengaturan Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF1E3A8A),
                    child: Icon(Icons.storefront, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KASIR AKTIF SHIFT INI',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeCashierName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KelolaKaryawanPage(),
                        ),
                      );
                      await _muatProfilToko();
                    },
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('Kelola'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'IDENTITAS USAHA & STRUK KASIR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _namaTokoController,
              decoration: _decoration('Nama Toko / Usaha', Icons.store),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _alamatController,
              maxLines: 2,
              decoration: _decoration('Alamat Toko', Icons.location_on_outlined),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noWaController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _decoration(
                'Nomor WhatsApp / Kontak Toko',
                Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _instagramController,
              decoration: _decoration(
                'Instagram Toko (@nama_toko)',
                Icons.camera_alt_outlined,
                hint: '@namatoko',
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _footerController,
              maxLines: 2,
              decoration: _decoration(
                'Catatan Kaki Struk (Footer Nota)',
                Icons.receipt_outlined,
                hint: 'Terima kasih atas kunjungan Anda!',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _sedangMenyimpan ? null : _simpanProfilToko,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _sedangMenyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _sedangMenyimpan ? 'Menyimpan Pengaturan...' : 'Simpan Profil Toko',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
