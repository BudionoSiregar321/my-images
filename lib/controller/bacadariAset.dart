import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List> bacaAssetSebagaiBlob(String assetPath) async {
  ByteData byteData = await rootBundle.load(assetPath);
  return byteData.buffer.asUint8List();
}

Future<Uint8List?> downloadImageFromUrl(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      print('Failed to load image: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error downloading image: $e');
    return null;
  }
}

bool isUrl(String path) {
  return path.startsWith('http://') || path.startsWith('https://');
}

Future<Uint8List?> getImageBytes(String imagePath) async {
  try {
    if (isUrl(imagePath)) {
      return await downloadImageFromUrl(imagePath);
    } else {
      return await bacaAssetSebagaiBlob(imagePath);
    }
  } catch (e) {
    print('Error getting image bytes: $e');
    return null;
  }
}
