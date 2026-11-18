import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/database_helper.dart';
import '../models/karyawan.dart';
import 'form_karyawan_page.dart';

class KelolaKaryawanPage extends StatefulWidget {
  const KelolaKaryawanPage({super.key});

  @override
  State<KelolaKaryawanPage> createState() => _KelolaKaryawanPageState();
}

class _KelolaKaryawanPageState extends State<KelolaKaryawanPage> {
  late Future<List<Karyawan>> _karyawanFuture;
  int? _activeCashierId;
  String _activeCashierName = 'Belum Ditentukan';

  @override
  void initState() {
    super.initState();
    _karyawanFuture = DatabaseHelper.instance.getAllKaryawan();
    _muatData();
  }

  Future<void> _muatData() async {
    final prefs = await SharedPreferences.getInstance();
    final staff = await DatabaseHelper.instance.getAllKaryawan();
    if (!mounted) return;
    setState(() {
      _activeCashierId = prefs.getInt('active_cashier_id');
      _activeCashierName =
          prefs.getString('active_cashier_name') ?? 'Belum Ditentukan';
      _karyawanFuture = Future.value(staff);
    });
  }

  Future<void> _setKasirAktif(Karyawan staff) async {
    if (staff.id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_cashier_id', staff.id!);
    await prefs.setString('active_cashier_name', staff.namaKaryawan);
    if (!mounted) return;
    setState(() {
      _activeCashierId = staff.id;
      _activeCashierName = staff.namaKaryawan;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kasir aktif giliran saat ini: "${staff.namaKaryawan}"'),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _bukaForm({Karyawan? karyawan}) async {
    final refresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormKaryawanPage(karyawan: karyawan),
      ),
    );
    if (refresh == true && mounted) await _muatData();
  }

  Future<void> _konfirmasiHapusKaryawan(Karyawan staff) async {
    if (staff.id == _activeCashierId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Karyawan "${staff.namaKaryawan}" sedang aktif bertugas! Ganti kasir aktif terlebih dahulu sebelum menghapus.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hapus Karyawan?'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin menghapus staf "${staff.namaKaryawan}" (${staff.peran})? Data tidak dapat dipulihkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted || staff.id == null) return;
    await DatabaseHelper.instance.deleteKaryawan(staff.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data staf "${staff.namaKaryawan}" telah dihapus!'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
    await _muatData();
  }

  Widget _buildRoleBadge(String role) {
    final Color background;
    final Color foreground;
    if (role == 'Manajer') {
      background = Colors.amber.shade100;
      foreground = Colors.amber.shade900;
    } else if (role == 'Admin') {
      background = Colors.blue.shade100;
      foreground = Colors.blue.shade900;
    } else if (role == 'Supervisor') {
      background = Colors.purple.shade100;
      foreground = Colors.purple.shade900;
    } else {
      background = Colors.green.shade100;
      foreground = Colors.green.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: foreground,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Kelola Karyawan & Kasir',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.amber,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KASIR AKTIF BERJAGA SAAT INI',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _activeCashierName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Karyawan>>(
              future: _karyawanFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan database: ${snapshot.error}'),
                  );
                }

                final staffList = snapshot.data ?? [];
                if (staffList.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data karyawan terdaftar.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    final staff = staffList[index];
                    final isActive = staff.id == _activeCashierId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? const Color(0xFF1E3A8A)
                              : Colors.grey.shade200,
                          foregroundColor:
                              isActive ? Colors.white : Colors.grey.shade700,
                          child: Text(
                            staff.namaKaryawan.isNotEmpty
                                ? staff.namaKaryawan[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                staff.namaKaryawan,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildRoleBadge(staff.peran),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'PIN: ••••  |  ID: #${staff.id}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: isActive
                                  ? 'Kasir Aktif'
                                  : 'Set sebagai Kasir Aktif',
                              onPressed: () => _setKasirAktif(staff),
                              icon: Icon(
                                isActive ? Icons.star : Icons.star_border,
                                color: isActive
                                    ? Colors.amber
                                    : Colors.grey.shade700,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Edit Data',
                              onPressed: () => _bukaForm(karyawan: staff),
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Hapus Staf',
                              onPressed: () => _konfirmasiHapusKaryawan(staff),
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Karyawan'),
      ),
    );
  }
}
