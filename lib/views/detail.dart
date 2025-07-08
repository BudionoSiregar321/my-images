import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HalamanDetail extends StatelessWidget {
  final String judul;
  final String sinopsis;
  final String deskripsi;
  final String gambar;

  const HalamanDetail({
    super.key,
    required this.judul,
    required this.sinopsis,
    required this.deskripsi,
    required this.gambar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 86, 154, 255),
        title: Text(judul),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              judul,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 25, 149, 250),
              ),
            ),
            const SizedBox(height: 8),
            Text(sinopsis, style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),
            const Text(
              'Deskripsi:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 25, 149, 250),
              ),
            ),
            const SizedBox(height: 8),
            Text(deskripsi, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (gambar.startsWith('http://') || gambar.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: gambar,
        width: 300,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              width: 300,
              height: 200,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              width: 300,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error, color: Colors.red, size: 50),
              ),
            ),
      );
    } else {
      return Image.asset(
        gambar,
        width: 300,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              width: 300,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error, color: Colors.red, size: 50),
              ),
            ),
      );
    }
  }
}

class HalamanDetailSimple extends StatelessWidget {
  final String judul;
  final String sinopsis;
  final String deskripsi;
  final String gambar;

  const HalamanDetailSimple({
    super.key,
    required this.judul,
    required this.sinopsis,
    required this.deskripsi,
    required this.gambar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 86, 154, 255),
        title: Text(judul),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildSimpleImage(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              judul,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 25, 149, 250),
              ),
            ),
            const SizedBox(height: 8),
            Text(sinopsis, style: const TextStyle(fontSize: 16)),
            const Divider(height: 32),
            const Text(
              'Deskripsi:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 25, 149, 250),
              ),
            ),
            const SizedBox(height: 8),
            Text(deskripsi, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleImage() {
    if (gambar.startsWith('http://') || gambar.startsWith('https://')) {
      return Image.network(
        gambar,
        width: 300,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 300,
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder:
            (context, error, stackTrace) => Container(
              width: 300,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error, color: Colors.red, size: 50),
              ),
            ),
      );
    } else {
      return Image.asset(
        gambar,
        width: 300,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              width: 300,
              height: 200,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error, color: Colors.red, size: 50),
              ),
            ),
      );
    }
  }
}
