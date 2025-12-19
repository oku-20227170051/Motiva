import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();
  
  // ImgBB API Key (ücretsiz - https://api.imgbb.com/)
  static const String _apiKey = '712ed4cb569e2953c6085bb68bf0d7cf'; // Geçici key, kendi key'inizi alın

  // Galeriden resim seç
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Resim seçme hatası: $e');
      return null;
    }
  }

  // Profil fotoğrafını ImgBB'ye yükle
  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      // Dosyayı base64'e çevir
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // ImgBB API'ye yükle
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {
          'key': _apiKey,
          'image': base64Image,
          'name': 'profile_$userId',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Resim URL'ini döndür
          return data['data']['url'];
        }
      }

      print('ImgBB yükleme hatası: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Fotoğraf yükleme hatası: $e');
      return null;
    }
  }

  // Profil fotoğrafını sil (ImgBB'de silme yok, sadece URL'i kaldırıyoruz)
  Future<void> deleteProfilePhoto(String userId) async {
    // ImgBB free tier'da silme özelliği yok
    // Sadece Firestore'dan URL'i kaldırıyoruz
    print('Profil fotoğrafı Firestore\'dan kaldırılacak');
  }
}
