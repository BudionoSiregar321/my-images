import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/db.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class BerandaController with ChangeNotifier {
  late PageController pageController;
  int halamanSaatIni = 0;
  Timer? timer;

  List<Map<String, dynamic>> dataDiskon = [];
  List<Map<String, dynamic>> dataBuku = [];
  List<Map<String, dynamic>> hasilPencarian = [];
  String keyword = '';
  bool isLoading = true;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool isConnected = true;

  BerandaController() {
    pageController = PageController();
    _initialize();
  }

  Future<void> _initialize() async {
    final initialResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(initialResult);

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    _muatData();
    _mulaiSlider();
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final hasConnection = !result.contains(ConnectivityResult.none);

    if (isConnected != hasConnection) {
      isConnected = hasConnection;
      print(
        "Koneksi terdeteksi berubah. Status saat ini: ${isConnected ? 'Online' : 'Offline'}",
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  Future<void> tambahKeKeranjang(
    BuildContext context,
    Map<String, dynamic> buku,
  ) async {
    if (isConnected) {
      try {
        await DatabaseHandler().tambahKeKeranjang({
          'judul': buku['judul'],
          'gambar': buku['gambar'],
          'sinopsis': buku['sinopsis'],
          'deskripsi': buku['deskripsi'] ?? '',
        });

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item berhasil ditambahkan ke keranjang'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menambahkan ke keranjang: $e')),
        );
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

  void _mulaiSlider() {
    timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (dataDiskon.isEmpty) return;
      if (pageController.hasClients) {
        halamanSaatIni = (halamanSaatIni + 1) % dataDiskon.length;
        pageController.animateToPage(
          halamanSaatIni,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _muatData() async {
    try {
      isLoading = true;
      notifyListeners();
      List<Map<String, dynamic>> semua =
          await DatabaseHandler().loadAllDataWithCache();
      dataDiskon =
          semua
              .where(
                (item) =>
                    item['judul'].toString().toLowerCase().contains('diskon'),
              )
              .toList();
      dataBuku =
          semua
              .where(
                (item) =>
                    !item['judul'].toString().toLowerCase().contains('diskon'),
              )
              .toList();
      hasilPencarian = dataBuku;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  void filterBuku(String keyword) {
    this.keyword = keyword.toLowerCase();
    hasilPencarian =
        dataBuku
            .where(
              (buku) =>
                  buku['judul'].toString().toLowerCase().contains(this.keyword),
            )
            .toList();
    notifyListeners();
  }

  Future<void> hapusDatabase(BuildContext context) async {
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harus online untuk menghapus database.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final dbHandler = DatabaseHandler();
      final allData = await dbHandler.loadAllData();
      for (var item in allData) {
        await dbHandler.deleteData(item['id']);
      }
      await dbHandler.clearKeranjang();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database berhasil dihapus')),
      );
      dataBuku.clear();
      dataDiskon.clear();
      hasilPencarian.clear();
      notifyListeners();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error menghapus database: $e')));
    }
  }

  Future<void> refreshData() async {
    await _muatData();
  }
}
