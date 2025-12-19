class Validators {
  // Email validasyonu
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gereklidir';
    }
    
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }
  
  // Şifre validasyonu
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    
    return null;
  }
  
  // Şifre onayı validasyonu
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Şifre onayı gereklidir';
    }
    
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }
  
  // İsim validasyonu
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim gereklidir';
    }
    
    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalıdır';
    }
    
    return null;
  }
  
  // Genel metin validasyonu
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gereklidir';
    }
    
    return null;
  }
  
  // Sayı validasyonu
  static String? validateNumber(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return 'Bu alan gereklidir';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Geçerli bir sayı girin';
    }
    
    if (min != null && number < min) {
      return 'Değer en az $min olmalıdır';
    }
    
    if (max != null && number > max) {
      return 'Değer en fazla $max olmalıdır';
    }
    
    return null;
  }
}
