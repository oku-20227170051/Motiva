import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final UserProfileModel? currentProfile;

  const EditProfileScreen({
    super.key,
    required this.userId,
    this.currentProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _storageService = StorageService();
  final _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  
  String? _selectedGender;
  File? _selectedImage;
  String? _currentPhotoUrl;
  bool _loading = false;

  final List<String> _genderOptions = [
    'Erkek',
    'Kadın',
    'Belirtmek İstemiyorum',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.currentProfile != null) {
      _ageController.text = widget.currentProfile!.age?.toString() ?? '';
      _bioController.text = widget.currentProfile!.bio ?? '';
      _selectedGender = widget.currentProfile!.gender;
      _currentPhotoUrl = widget.currentProfile!.photoUrl;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _storageService.pickImageFromGallery();
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      String? photoUrl = _currentPhotoUrl;

      // Yeni fotoğraf seçildiyse yükle
      if (_selectedImage != null) {
        // EKRANDA GÖSTER: Yükleme başladı
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📸 Fotoğraf yükleniyor...'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        photoUrl = await _storageService.uploadProfilePhoto(
          widget.userId,
          _selectedImage!,
        );

        // EKRANDA GÖSTER: Yükleme sonucu
        if (photoUrl == null) {
          throw 'Fotoğraf yüklenemedi! Storage izinlerini kontrol edin.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Fotoğraf yüklendi!\nURL: ${photoUrl.substring(0, 50)}...'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Profil modelini oluştur
      final profile = UserProfileModel(
        userId: widget.userId,
        age: _ageController.text.isNotEmpty
            ? int.tryParse(_ageController.text)
            : null,
        gender: _selectedGender,
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
        photoUrl: photoUrl,
      );

      // Kaydet
      await _firestoreService.saveUserProfile(profile);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil güncellendi!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // DETAYLI HATA MESAJI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ HATA:\n$e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // DIALOG İLE DAHA DETAYLI GÖSTER
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Profil Kaydetme Hatası'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hata Detayı:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('$e'),
                  const SizedBox(height: 16),
                  const Text(
                    'Kontrol Edin:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Firebase Storage başlatıldı mı?'),
                  const Text('2. Storage Rules publish edildi mi?'),
                  const Text('3. İnternet bağlantısı var mı?'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profil Fotoğrafı
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_currentPhotoUrl != null
                              ? NetworkImage(_currentPhotoUrl!)
                              : null) as ImageProvider?,
                      child: _selectedImage == null && _currentPhotoUrl == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Yaş
              CustomTextField(
                controller: _ageController,
                label: 'Yaş (İsteğe Bağlı)',
                hint: 'Örn: 25',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null || age < 13 || age > 120) {
                      return 'Geçerli bir yaş girin (13-120)';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Cinsiyet
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cinsiyet (İsteğe Bağlı)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        hint: const Text('Seçiniz'),
                        isExpanded: true,
                        items: _genderOptions.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedGender = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Biyografi
              CustomTextField(
                controller: _bioController,
                label: 'Biyografi (İsteğe Bağlı)',
                hint: 'Kendiniz hakkında birkaç kelime...',
                maxLines: 4,
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return 'Biyografi en fazla 200 karakter olabilir';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 8),
              Text(
                '${_bioController.text.length}/200',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.right,
              ),
              
              const SizedBox(height: 32),
              
              // Kaydet Butonu
              CustomButton(
                text: 'Kaydet',
                onPressed: _saveProfile,
                isLoading: _loading,
              ),
              
              const SizedBox(height: 16),
              
              // İptal Butonu
              CustomButton(
                text: 'İptal',
                onPressed: () => Navigator.pop(context),
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
