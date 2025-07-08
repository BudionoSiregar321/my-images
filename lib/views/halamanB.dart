import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/tombolHapusBeranda.dart';
import 'package:flutter_application_1/views/detail.dart';
import 'package:flutter_application_1/views/halamanNotif.dart';
import 'package:flutter_application_1/views/keranjang.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/model/logic.dart';
import 'package:flutter_application_1/database/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/views/login.dart';

class HalamanBeranda extends StatefulWidget {
  const HalamanBeranda({super.key});

  @override
  State<HalamanBeranda> createState() => _HalamanBerandaState();
}

class _HalamanBerandaState extends State<HalamanBeranda> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _isiDatabaseJikaPerlu();
    _user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _isiDatabaseJikaPerlu() async {
    try {
      final dbHandler = DatabaseHandler();
      final data = await dbHandler.loadAllDataWithCache();
      if (data.isEmpty) {
        if (await dbHandler.isOnline()) {
          await dbHandler.simpanSemuaBukuKeDatabase();
          await dbHandler.simpanSemuaDiskonKeDatabase();
        } else {
          print("Offline, tidak bisa mengisi database untuk pertama kali.");
        }
      }
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BerandaController(),
      child: Consumer<BerandaController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(120.0),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _user != null && _user!.displayName != null
                              ? "Halo, ${_user!.displayName} 👋"
                              : "Halo 👋",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.black54,
                                size: 24,
                              ),
                              onPressed: () {
                                if (controller.isConnected) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HalamanKeranjang(),
                                    ),
                                  );
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
                              },
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.black54,
                                size: 24,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Halamannotif(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.logout_outlined,
                                color: Colors.red,
                                size: 24,
                              ),
                              tooltip: "Logout",
                              onPressed: _signOut,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: TextField(
                        onChanged: controller.filterBuku,
                        decoration: const InputDecoration(
                          hintText: 'Cari buku...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body:
                controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.hasilPencarian.isEmpty &&
                        controller.dataDiskon.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Tidak ada data.'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.refreshData(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: controller.refreshData,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (controller.dataDiskon.isNotEmpty)
                            SizedBox(
                              height: 200,
                              child: PageView.builder(
                                controller: controller.pageController,
                                itemCount: controller.dataDiskon.length,
                                itemBuilder: (context, index) {
                                  final item = controller.dataDiskon[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item['gambar'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(Icons.error),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              'List buku Terlaris:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: controller.hasilPencarian.length,
                              itemBuilder: (context, index) {
                                final buku = controller.hasilPencarian[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 7,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => HalamanDetail(
                                                judul: buku['judul'],
                                                sinopsis: buku['sinopsis'],
                                                deskripsi:
                                                    buku['deskripsi'] ??
                                                    'Tidak ada deskripsi',
                                                gambar: buku['gambar'],
                                              ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          buku['gambar'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            );
                                          },
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
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
                                        buku['judul'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        buku['sinopsis'],
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                        ),
                                        onPressed:
                                            () => controller.tambahKeKeranjang(
                                              context,
                                              buku,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            floatingActionButton: FloatingButtonHapus(),
          );
        },
      ),
    );
  }
}
