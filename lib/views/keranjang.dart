import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/db.dart';
import 'package:flutter_application_1/utils/tombolCheckOut.dart';

class HalamanKeranjang extends StatefulWidget {
  const HalamanKeranjang({Key? key}) : super(key: key);

  @override
  _HalamanKeranjangState createState() => _HalamanKeranjangState();
}

class _HalamanKeranjangState extends State<HalamanKeranjang> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  List<Map<String, dynamic>> _dataKeranjang = [];
  bool _isLoading = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _muatDataKeranjang();
  }

  Future<void> _muatDataKeranjang() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });

    final bool online = await _dbHandler.isOnline();
    if (!mounted) return;

    if (online) {
      try {
        final data = await _dbHandler.getKeranjang();
        setState(() {
          _dataKeranjang = data;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error memuat data: $e')));
      }
    } else {
      setState(() {
        _isOffline = true;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _hapusItem(String id) async {
    final bool online = await _dbHandler.isOnline();
    if (!mounted) return;

    if (online) {
      try {
        await _dbHandler.hapusDariKeranjang(id);
        _muatDataKeranjang();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item berhasil dihapus')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error menghapus item: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Harus Online Terlebih Dahulu Untuk Mengakses Fitur Ini',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 86, 154, 255),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isOffline
              ? const Center(
                child: Text(
                  'Anda sedang offline.\nSilakan periksa koneksi internet Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
              : _dataKeranjang.isEmpty
              ? const Center(child: Text('Keranjang kosong'))
              : Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _dataKeranjang.length,
                      itemBuilder: (context, index) {
                        final item = _dataKeranjang[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item['gambar'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                            title: Text(
                              item['judul'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              item['sinopsis'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(item['id']),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color.fromARGB(255, 240, 240, 240),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Jumlah barang: ",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _dataKeranjang.length.toString(),
                          style: const TextStyle(fontSize: 17),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 80,
                    color: const Color.fromARGB(255, 125, 173, 245),
                    child: const Center(child: TombolCheckOut()),
                  ),
                ],
              ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _hapusItem(id);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
