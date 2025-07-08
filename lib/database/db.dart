import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseHandler._internal();
  factory DatabaseHandler() => _instance;

  static const String _bukuCollection = 'buku';
  static const String _keranjangCollection = 'keranjang';

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> simpanCacheBuku(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString('cache_buku', jsonString);
  }

  Future<List<Map<String, dynamic>>> ambilCacheBuku() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_buku');
    if (jsonString != null) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> loadAllDataWithCache() async {
    if (await isOnline()) {
      try {
        final querySnapshot =
            await _firestore.collection(_bukuCollection).get();
        final data =
            querySnapshot.docs.map((doc) {
              final book = doc.data();
              book['id'] = doc.id;
              return book;
            }).toList();

        await simpanCacheBuku(data);
        return data;
      } catch (e) {
        print('Error loading data online: $e');
        return await ambilCacheBuku();
      }
    } else {
      return await ambilCacheBuku();
    }
  }

  Future<String> insertData(Map<String, dynamic> data) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_bukuCollection)
              .where('judul', isEqualTo: data['judul'])
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }

      final docRef = await _firestore.collection(_bukuCollection).add(data);
      return docRef.id;
    } catch (e) {
      print('Error inserting data: $e');
      throw Exception('Failed to insert data');
    }
  }

  Future<void> updateData(Map<String, dynamic> data, String id) async {
    try {
      await _firestore.collection(_bukuCollection).doc(id).update(data);
    } catch (e) {
      print('Error updating data: $e');
      throw Exception('Failed to update data');
    }
  }

  Future<void> deleteData(String id) async {
    try {
      await _firestore.collection(_bukuCollection).doc(id).delete();
    } catch (e) {
      print('Error deleting data: $e');
      throw Exception('Failed to delete data');
    }
  }

  Future<String> tambahKeKeranjang(Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(_keranjangCollection).add({
        'judul': data['judul'],
        'gambar': data['gambar'],
        'sinopsis': data['sinopsis'],
        'deskripsi': data['deskripsi'],
        'timestamp': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding to cart: $e');
      throw Exception('Failed to add to cart');
    }
  }

  Future<List<Map<String, dynamic>>> getKeranjang() async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_keranjangCollection)
              .orderBy('timestamp', descending: true)
              .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting cart: $e');
      throw Exception('Failed to get cart');
    }
  }

  Future<void> hapusDariKeranjang(String id) async {
    try {
      await _firestore.collection(_keranjangCollection).doc(id).delete();
    } catch (e) {
      print('Error removing from cart: $e');
      throw Exception('Failed to remove from cart');
    }
  }

  Future<void> simpanSemuaBukuKeDatabase() async {
    const String githubBaseUrl =
        'https://raw.githubusercontent.com/BudionoSiregar321/my-images/main/assets/images/';

    List<Map<String, String>> daftarBuku = [
      {
        'judul': 'Dasar Flutter',
        'gambar': '${githubBaseUrl}buku1.jpg',
        'sinopsis': 'Buku pelajaran Flutter',
        'deskripsi':
            'Buku ini dirancang untuk pemula yang ingin mempelajari dasar-dasar pengembangan aplikasi menggunakan Flutter. Di dalamnya dibahas komponen UI, state management, hingga pembuatan aplikasi sederhana.',
      },
      {
        'judul': 'Psychology of money',
        'gambar': '${githubBaseUrl}buku2.jpg',
        'sinopsis': 'Buku pelajaran keuangan',
        'deskripsi':
            'Melalui buku ini, pembaca diajak memahami bagaimana pola pikir dan emosi memengaruhi cara seseorang mengelola uang, mengambil keputusan finansial, serta membentuk kebiasaan jangka panjang dalam kehidupan ekonomi.',
      },
      {
        'judul': 'Indonesia Ingris',
        'gambar': '${githubBaseUrl}buku3.jpg',
        'sinopsis': 'Buku kamus Bahasa Inggris',
        'deskripsi':
            'Kamus lengkap ini berisi ribuan kosakata bahasa Indonesia dan padanan katanya dalam bahasa Inggris. Sangat cocok digunakan untuk pelajar, mahasiswa, maupun profesional yang ingin meningkatkan kemampuan bahasa.',
      },
      {
        'judul': 'Saraswati',
        'gambar': '${githubBaseUrl}buku4.jpg',
        'sinopsis': 'Cerita misteri keluarga',
        'deskripsi':
            'Mengisahkan sebuah keluarga yang terlibat dalam serangkaian kejadian misterius, buku ini membawa pembaca menelusuri jejak masa lalu, rahasia yang tersembunyi, dan konflik batin yang menyentuh.',
      },
      {
        'judul': 'Doraemon',
        'gambar': '${githubBaseUrl}buku5.jpg',
        'sinopsis': 'Komik Petualangan Jepang',
        'deskripsi':
            'Kumpulan cerita petualangan seru antara Doraemon dan Nobita, yang selalu menggunakan alat-alat ajaib dari masa depan untuk menghadapi masalah sehari-hari. Lucu, penuh imajinasi, dan edukatif.',
      },
      {
        'judul': 'Dunia Bawah Laut',
        'gambar': '${githubBaseUrl}buku6.jpg',
        'sinopsis': 'Buku tentang laut',
        'deskripsi':
            'Buku ini mengajak pembaca menyelami kehidupan bawah laut yang menakjubkan. Disertai gambar dan penjelasan ilmiah tentang berbagai jenis biota laut, ekosistem, dan pentingnya menjaga laut.',
      },
      {
        'judul': 'Harry Potter',
        'gambar': '${githubBaseUrl}buku7.jpg',
        'sinopsis': 'Harry Potter petualangan',
        'deskripsi':
            'Kisah penyihir muda bernama Harry Potter yang masuk ke dunia sihir dan berjuang melawan kekuatan gelap. Buku ini dipenuhi dengan petualangan, persahabatan, dan pelajaran hidup yang dalam.',
      },
      {
        'judul': 'Laskar Pelangi',
        'gambar': '${githubBaseUrl}buku8.jpg',
        'sinopsis': 'Laskar Pelangi kisah inspiratif',
        'deskripsi':
            'Buku ini bercerita tentang perjuangan sekelompok anak dari Belitung dalam meraih mimpi mereka di tengah keterbatasan. Menggugah, menyentuh, dan penuh semangat optimisme.',
      },
      {
        'judul': 'Naruto',
        'gambar': '${githubBaseUrl}buku9.jpg',
        'sinopsis': 'Naruto dan Sasuke',
        'deskripsi':
            'Cerita epik tentang perjalanan seorang anak yatim bernama Naruto Uzumaki yang bercita-cita menjadi ninja terkuat di desanya. Buku ini penuh aksi, persahabatan, dan nilai-nilai kehidupan.',
      },
      {
        'judul': 'Si Juki',
        'gambar': '${githubBaseUrl}buku10.jpg',
        'sinopsis': 'Si Juki komik lucu',
        'deskripsi':
            'Komik lokal yang mengangkat keseharian Juki, tokoh jenaka yang selalu terlibat dalam kejadian lucu dan satir. Cocok untuk hiburan ringan dengan gaya khas Indonesia.',
      },
    ];

    for (var item in daftarBuku) {
      await insertData({
        'judul': item['judul'],
        'gambar': item['gambar'],
        'sinopsis': item['sinopsis'],
        'deskripsi': item['deskripsi'],
      });
    }
  }

  Future<void> simpanSemuaDiskonKeDatabase() async {
    const String githubBaseUrl =
        'https://raw.githubusercontent.com/BudionoSiregar321/my-images/main/assets/images/';

    List<Map<String, String>> daftarDiskon = [
      {
        'judul': 'Diskon 1',
        'gambar': '${githubBaseUrl}diskon1.jpg',
        'sinopsis': 'Diskon pertama, super hemat!',
      },
      {
        'judul': 'Diskon 2',
        'gambar': '${githubBaseUrl}diskon2.jpg',
        'sinopsis': 'Diskon kedua, jangan lewatkan!',
      },
      {
        'judul': 'Diskon 3',
        'gambar': '${githubBaseUrl}diskon3.jpg',
        'sinopsis': 'Diskon ketiga, cuma hari ini!',
      },
      {
        'judul': 'Diskon 4',
        'gambar': '${githubBaseUrl}diskon4.jpg',
        'sinopsis': 'Diskon keempat, spesial akhir pekan!',
      },
    ];

    for (var item in daftarDiskon) {
      await insertData({
        'judul': item['judul'],
        'gambar': item['gambar'],
        'sinopsis': item['sinopsis'],
        'deskripsi': '',
      });
    }
  }

  Stream<List<Map<String, dynamic>>> streamAllData() {
    return _firestore
        .collection(_bukuCollection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> streamKeranjang() {
    return _firestore
        .collection(_keranjangCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList(),
        );
  }

  Future<List<Map<String, dynamic>>> searchBuku(String query) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_bukuCollection)
              .where('judul', isGreaterThanOrEqualTo: query)
              .where('judul', isLessThan: query + '\uf8ff')
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error searching books: $e');
      throw Exception('Failed to search books');
    }
  }

  Future<void> clearKeranjang() async {
    try {
      final querySnapshot =
          await _firestore.collection(_keranjangCollection).get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing cart: $e');
      throw Exception('Failed to clear cart');
    }
  }

  Future<List<Map<String, dynamic>>> loadAllData() async {
    try {
      final querySnapshot = await _firestore.collection(_bukuCollection).get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error loading all data: $e');
      throw Exception('Failed to load all data');
    }
  }
}
