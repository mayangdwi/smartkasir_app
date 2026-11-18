import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/database_helper.dart';
import '../models/karyawan.dart';

class FormKaryawanPage extends StatefulWidget {
  final Karyawan? karyawan;

  const FormKaryawanPage({super.key, this.karyawan});

  @override
  State<FormKaryawanPage> createState() => _FormKaryawanPageState();
}

class _FormKaryawanPageState extends State<FormKaryawanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _pinController = TextEditingController();
  String _peranTerpilih = 'Kasir';
  bool _sedangMenyimpan = false;

  bool get _isEditMode => widget.karyawan != null;
  final List<String> _daftarPeran = [
    'Kasir',
    'Admin',
    'Manajer',
    'Supervisor',
  ];

  @override
  void initState() {
    super.initState();
    final karyawan = widget.karyawan;
    if (karyawan != null) {
      _namaController.text = karyawan.namaKaryawan;
      _pinController.text = karyawan.pin;
      _peranTerpilih = karyawan.peran;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _simpanKaryawan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sedangMenyimpan = true);

    try {
      final dataKaryawan = Karyawan(
        id: _isEditMode ? widget.karyawan!.id : null,
        namaKaryawan: _namaController.text.trim(),
        pin: _pinController.text.trim(),
        peran: _peranTerpilih,
      );

      if (_isEditMode) {
        await DatabaseHelper.instance.updateKaryawan(dataKaryawan);
      } else {
        await DatabaseHelper.instance.insertKaryawan(dataKaryawan);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Data karyawan "${dataKaryawan.namaKaryawan}" berhasil diperbarui!'
                : 'Karyawan baru "${dataKaryawan.namaKaryawan}" berhasil ditambahkan!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan database: $error'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Data Karyawan' : 'Tambah Staf Kasir Baru',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      color: Colors.blue.shade800,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Setiap staf kasir memakai PIN tepat 6 digit untuk keamanan sesi.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration(
                  'Nama Lengkap Karyawan',
                  Icons.person_outline,
                  hint: 'Contoh: Siti Rahmah',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama karyawan wajib diisi!';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama karyawan minimal 3 karakter!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: _decoration(
                  'PIN Kasir (6 Digit Angka)',
                  Icons.lock_outline,
                  hint: 'Contoh: 123456',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'PIN kasir wajib diisi!';
                  }
                  if (value.length != 6) {
                    return 'PIN kasir harus tepat 6 digit angka!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _peranTerpilih,
                decoration: _decoration(
                  'Peran / Jabatan Toko',
                  Icons.work_outline,
                ),
                items: _daftarPeran
                    .map(
                      (peran) => DropdownMenuItem(
                        value: peran,
                        child: Text(peran),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _peranTerpilih = value);
                  }
                },
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _sedangMenyimpan ? null : _simpanKaryawan,
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
                    : Icon(
                        _isEditMode
                            ? Icons.check_circle_outline
                            : Icons.save_outlined,
                      ),
                label: Text(
                  _sedangMenyimpan
                      ? 'Menyimpan...'
                      : (_isEditMode
                            ? 'Perbarui Data Karyawan'
                            : 'Simpan Karyawan Baru'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
