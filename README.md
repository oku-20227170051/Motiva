# 🎯 Motiva - Kişisel Gelişim ve Alışkanlık Takip Uygulaması

**Motiva**, kullanıcıların hedeflerini takip etmelerine, alışkanlıklar oluşturmalarına ve kişisel gelişimlerini izlemelerine yardımcı olan kapsamlı bir Flutter mobil uygulamasıdır. Gamification özellikleri, sosyal etkileşim ve detaylı analitiklerle kullanıcıları motive eder.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)

---

## 📱 Özellikler

### 🎯 Alışkanlık Yönetimi
- **Alışkanlık Oluşturma**: Başlangıç ve bitiş tarihleriyle özelleştirilebilir alışkanlıklar
- **Günlük Takip**: Alışkanlıkları her gün işaretleme ve tamamlama
- **Streak Sistemi**: Ardışık gün sayacı ile motivasyon artırma
- **İlerleme Takibi**: Yüzdelik dilimlerle görsel ilerleme gösterimi
- **Renkli Kategoriler**: Her alışkanlık için özel renk seçimi

### 📅 Takvim ve Planlama
- **İnteraktif Takvim**: Alışkanlıkları takvim üzerinde görüntüleme
- **Çoklu Alışkanlık Desteği**: Tek bir günde birden fazla alışkanlık takibi
- **Tarih Aralığı Belirleme**: Alışkanlıklar için esnek tarih aralıkları
- **Görsel Gösterimler**: Renkli işaretlerle tamamlanan günleri görme

### 🏆 Gamification
- **Puan Sistemi**: Her tamamlanan alışkanlık için puan kazanma
- **Seviye Sistemi**: Puanlara göre otomatik seviye atlama
- **Başarım Rozetleri**: 7 farklı başarım kategorisi
  - İlk Adım (İlk alışkanlık)
  - 7 Gün Streak
  - 30 Gün Streak
  - Çalışkan (10 saat)
  - Süper Çalışkan (50 saat)
  - Yükselen Yıldız (100 puan)
  - Süper Yıldız (500 puan)

### 👥 Sosyal Özellikler
- **Arkadaş Sistemi**: Kullanıcı adı ile arkadaş arama ve ekleme
- **Arkadaşlık İstekleri**: İstek gönderme, kabul/red etme sistemi
- **Mesajlaşma**: Arkadaşlarla birebir sohbet
- **Profil Görüntüleme**: Arkadaşların profillerini ve başarımlarını görme
- **Gerçek Zamanlı Bildirimler**: Yeni istek ve mesajlar için anlık bildirimler

### 📊 İlerleme ve Analitik
- **Günlük İlerleme**: Her gün için detaylı ilerleme kayıtları
- **Grafik Gösterimleri**: fl_chart ile görsel analitikler
- **İstatistikler**: Toplam puan, seviye ve streak bilgileri
- **Geçmiş Veriler**: 30 günlük ilerleme geçmişi

### 🎓 Hedef Yönetimi
- **Hedef Oluşturma**: Açıklama ve hedef tarihli hedefler
- **Kategori Sistemi**: TYT, AYT, YDT gibi kategoriler
- **İlerleme Yüzdesi**: 0-100 arası ilerleme takibi
- **Hedef Tamamlama**: Otomatik tamamlanma sistemi

### 🛠️ Destek Sistemi
- **Destek Talepleri**: Kullanıcıların sorun bildirimi
- **Admin Paneli**: Talepleri yönetme ve yanıtlama
- **Durum Takibi**: Açık, İşlemde, Çözüldü durumları
- **Kullanıcı Yönetimi**: Admin tarafından kullanıcı görüntüleme

### 🔔 Bildirim Sistemi
- **Yerel Bildirimler**: flutter_local_notifications ile günlük hatırlatmalar
- **Bildirim Geçmişi**: Tüm bildirimleri görüntüleme
- **Özelleştirilebilir Bildirimler**: Farklı bildirim tipleri
- **Timezone Desteği**: Türkiye saati ile uyumlu bildirimler

### 👤 Profil Yönetimi
- **Profil Düzenleme**: İsim, kullanıcı adı ve profil fotoğrafı güncelleme
- **Profil Fotoğrafı**: Firebase Storage ile görsel yükleme
- **Kullanıcı İstatistikleri**: Toplam puan, seviye ve başarımlar
- **Benzersiz Kullanıcı Adı**: Sistem genelinde benzersiz username

---

## 🛠️ Teknoloji Stack

### Framework & Dil
- **Flutter**: 3.9.2
- **Dart**: 3.9.2

### Backend & Veritabanı
- **Firebase Core**: 3.8.1
- **Firebase Auth**: 5.3.3 - Kullanıcı kimlik doğrulama
- **Cloud Firestore**: 5.5.2 - NoSQL veritabanı
- **Firebase Storage**: 12.3.6 - Dosya depolama

### State Management
- **Provider**: 6.1.2 - Durum yönetimi

### UI Kütüphaneleri
- **table_calendar**: 3.1.2 - Takvim widget'ı
- **fl_chart**: 0.69.0 - Grafik ve chart'lar
- **cupertino_icons**: 1.0.8 - iOS stil ikonlar

### Yardımcı Paketler
- **intl**: 0.19.0 - Uluslararasılaştırma ve tarih formatı
- **shared_preferences**: 2.3.3 - Yerel veri saklama
- **flutter_local_notifications**: 18.0.1 - Yerel bildirimler
- **timezone**: 0.9.4 - Saat dilimi yönetimi
- **http**: 1.2.0 - HTTP istekleri
- **permission_handler**: 11.0.0 - İzin yönetimi
- **image_picker**: 1.1.2 - Görsel seçimi

---

## 📁 Proje Yapısı

```
motiva/
├── lib/
│   ├── main.dart                          # Uygulama giriş noktası
│   ├── firebase_options.dart              # Firebase yapılandırması
│   │
│   ├── models/                            # Veri modelleri
│   │   ├── achievement_model.dart         # Başarım modeli
│   │   ├── conversation_model.dart        # Konuşma modeli
│   │   ├── friend_request_model.dart      # Arkadaşlık isteği modeli
│   │   ├── friendship_model.dart          # Arkadaşlık modeli
│   │   ├── goal_model.dart                # Hedef modeli
│   │   ├── habit_model.dart               # Alışkanlık modeli
│   │   ├── message_model.dart             # Mesaj modeli
│   │   ├── notification_model.dart        # Bildirim modeli
│   │   ├── progress_model.dart            # İlerleme modeli
│   │   ├── support_ticket_model.dart      # Destek talebi modeli
│   │   ├── user_model.dart                # Kullanıcı modeli
│   │   └── user_profile_model.dart        # Kullanıcı profil modeli
│   │
│   ├── screens/                           # Ekranlar
│   │   ├── achievement_screen.dart        # Başarımlar ekranı
│   │   ├── calendar_screen.dart           # Takvim ekranı
│   │   ├── chat_screen.dart               # Sohbet ekranı
│   │   ├── conversations_screen.dart      # Konuşmalar listesi
│   │   ├── edit_profile_screen.dart       # Profil düzenleme
│   │   ├── habit_screen.dart              # Alışkanlıklar ekranı
│   │   ├── home_screen.dart               # Ana ekran
│   │   ├── login_screen.dart              # Giriş ekranı
│   │   ├── notification_history_screen.dart # Bildirim geçmişi
│   │   ├── profile_screen.dart            # Profil ekranı
│   │   ├── register_screen.dart           # Kayıt ekranı
│   │   ├── social_screen.dart             # Sosyal ekran
│   │   ├── support_screen.dart            # Destek ekranı
│   │   ├── user_detail_screen.dart        # Kullanıcı detay ekranı
│   │   └── admin/                         # Admin ekranları
│   │       ├── admin_dashboard_screen.dart
│   │       ├── admin_ticket_detail_screen.dart
│   │       ├── admin_tickets_screen.dart
│   │       └── admin_users_screen.dart
│   │
│   ├── services/                          # Servis katmanı
│   │   ├── auth_service.dart              # Kimlik doğrulama servisi
│   │   ├── firestore_service.dart         # Firestore veritabanı servisi
│   │   ├── gamification_service.dart      # Gamification servisi
│   │   ├── notification_service.dart      # Bildirim servisi
│   │   └── storage_service.dart           # Depolama servisi
│   │
│   ├── utils/                             # Yardımcı dosyalar
│   │   ├── constants.dart                 # Sabitler (renkler, stiller, boyutlar)
│   │   └── validators.dart                # Form validasyonları
│   │
│   └── widgets/                           # Özel widget'lar
│       ├── custom_button.dart             # Özel buton widget'ı
│       └── custom_text_field.dart         # Özel metin alanı widget'ı
│
├── android/                               # Android yapılandırması
│   └── app/
│       └── google-services.json           # Firebase Android yapılandırması
│
├── pubspec.yaml                           # Bağımlılıklar
├── firebase.json                          # Firebase yapılandırması
└── README.md                              # Bu dosya
```

---

## 🚀 Kurulum

### Ön Gereksinimler

- **Flutter SDK**: 3.9.2 veya üzeri
- **Dart SDK**: 3.9.2 veya üzeri
- **Android Studio** veya **VS Code** (Flutter eklentileriyle)
- **Firebase Hesabı**
- **Android Emulator** veya **Fiziksel Android Cihaz**

### Adım 1: Projeyi Klonlayın

```bash
git clone https://github.com/kullaniciadi/motiva.git
cd motiva
```

### Adım 2: Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### Adım 3: Firebase Yapılandırması

1. **Firebase Console'da Proje Oluşturun**
   - [Firebase Console](https://console.firebase.google.com/) adresine gidin
   - Yeni proje oluşturun veya mevcut projeyi kullanın

2. **Android Uygulaması Ekleyin**
   - Paket adı: `com.example.motiva`
   - `google-services.json` dosyasını indirin
   - `android/app/` dizinine yerleştirin

3. **Firebase Servislerini Etkinleştirin**
   - **Authentication**: Email/Password yöntemini etkinleştirin
   - **Cloud Firestore**: Veritabanını oluşturun
   - **Firebase Storage**: Depolama servisini etkinleştirin

4. **Firestore Güvenlik Kuralları**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcılar
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      
      // Kullanıcı profili
      match /profile/{document=**} {
        allow read: if request.auth != null;
        allow write: if request.auth.uid == userId;
      }
      
      // Başarımlar
      match /achievements/{document=**} {
        allow read: if request.auth != null;
        allow write: if request.auth.uid == userId;
      }
    }
    
    // Alışkanlıklar
    match /habits/{habitId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Hedefler
    match /goals/{goalId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // İlerleme
    match /progress/{progressId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    
    // Arkadaşlıklar
    match /friendships/{friendshipId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow delete: if request.auth.uid == resource.data.userId;
    }
    
    // Arkadaşlık istekleri
    match /friend_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.receiverId || 
                      request.auth.uid == resource.data.senderId;
    }
    
    // Konuşmalar
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid in resource.data.participants;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
    
    // Bildirimler
    match /notifications/{notificationId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.userId;
    }
    
    // Destek talepleri
    match /support_tickets/{ticketId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.userId || 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

5. **Storage Güvenlik Kuralları**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### Adım 4: Uygulamayı Çalıştırın

```bash
# Android emulator veya cihazda çalıştırın
flutter run

# Release modda derleyin
flutter build apk --release
```

---

## 📖 Kullanım

### İlk Kullanım

1. **Kayıt Olun**
   - Uygulamayı açın
   - "Kayıt Ol" butonuna tıklayın
   - Ad, email, kullanıcı adı ve şifre bilgilerinizi girin
   - Kullanıcı adı benzersiz olmalıdır

2. **Giriş Yapın**
   - Email ve şifrenizle giriş yapın
   - Ana ekrana yönlendirileceksiniz

### Alışkanlık Oluşturma

1. Alt menüden **"Alışkanlıklar"** sekmesine gidin
2. **"+"** butonuna tıklayın
3. Alışkanlık bilgilerini girin:
   - Başlık (zorunlu)
   - Açıklama (opsiyonel)
   - Başlangıç tarihi
   - Bitiş tarihi
   - Renk seçimi
4. **"Kaydet"** butonuna tıklayın

### Alışkanlık Takibi

- Ana ekranda bugünün alışkanlıklarını görürsünüz
- Tamamlamak için yanındaki daireye tıklayın
- Her tamamlama için puan kazanırsınız
- Ardışık günler streak sayacınızı artırır

### Arkadaş Ekleme

1. **"Sosyal"** sekmesine gidin
2. **"Arkadaş İstekleri"** sekmesini seçin
3. Arama çubuğuna kullanıcı adı yazın
4. **"İstek Gönder"** butonuna tıklayın
5. Karşı taraf isteği kabul edince arkadaş olursunuz

### Mesajlaşma

1. Üst menüdeki **sohbet ikonu**na tıklayın
2. Konuşma listesinden bir arkadaş seçin
3. Mesajınızı yazıp gönderin
4. Gerçek zamanlı mesajlaşma yapabilirsiniz

### Başarımları Görüntüleme

1. Alt menüden **"Başarılar"** sekmesine gidin
2. Açılan ve kilitli başarımları görün
3. Her başarım için gerekli koşulları kontrol edin

---

## 🎨 Ekran Görüntüleri

> **Not**: Ekran görüntülerini `screenshots/` klasörüne ekleyebilirsiniz.

```
screenshots/
├── login.png
├── home.png
├── habits.png
├── calendar.png
├── achievements.png
├── social.png
├── chat.png
└── profile.png
```

---

## 🏗️ Mimari

### Katmanlı Mimari

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│      (Screens & Widgets)            │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         Business Logic Layer        │
│         (Services)                  │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│         Data Layer                  │
│    (Models & Firebase)              │
└─────────────────────────────────────┘
```

### Veri Akışı

1. **Kullanıcı Etkileşimi** → Screen
2. **Screen** → Service (İş mantığı)
3. **Service** → Firebase (Veri işlemleri)
4. **Firebase** → Model (Veri dönüşümü)
5. **Model** → Screen (UI güncelleme)

### State Management

- **Provider** pattern kullanılmaktadır
- **StreamBuilder** ile gerçek zamanlı veri akışı
- **FutureBuilder** ile asenkron veri yükleme

---

## 🔐 Güvenlik

- **Firebase Authentication** ile güvenli kimlik doğrulama
- **Firestore Security Rules** ile veri güvenliği
- **Storage Rules** ile dosya erişim kontrolü
- Şifreler Firebase tarafından hash'lenerek saklanır
- Kullanıcı verileri sadece yetkili kişiler tarafından erişilebilir

---

## 🧪 Test

### Unit Test Çalıştırma

```bash
flutter test
```

### Widget Test

```bash
flutter test test/widget_test.dart
```

---

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen şu adımları izleyin:

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'inizi push edin (`git push origin feature/AmazingFeature`)
5. Pull Request oluşturun

### Kod Standartları

- **Dart** kod standartlarına uyun
- **flutter analyze** ile kod analizi yapın
- **flutter format** ile kod formatlayın
- Anlamlı commit mesajları yazın
- Yorum satırları Türkçe olmalıdır

---

## 📝 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 👨‍💻 Geliştirici

**Motiva Development Team**

- 📧 Email: [email@example.com](mailto:email@example.com)
- 🌐 Website: [https://motiva-app.com](https://motiva-app.com)
- 💼 LinkedIn: [Motiva](https://linkedin.com/company/motiva)

---

## 🙏 Teşekkürler

- [Flutter](https://flutter.dev) - Harika bir framework
- [Firebase](https://firebase.google.com) - Backend altyapısı
- [Material Design](https://material.io) - UI/UX tasarım ilkeleri
- Tüm açık kaynak katkıda bulunanlara

---

## 📚 Ek Kaynaklar

- [Flutter Dokümantasyonu](https://docs.flutter.dev/)
- [Firebase Dokümantasyonu](https://firebase.google.com/docs)
- [Dart Dokümantasyonu](https://dart.dev/guides)
- [Material Design Guidelines](https://material.io/design)

---

## 🐛 Bilinen Sorunlar

Şu anda bilinen kritik bir sorun bulunmamaktadır. Sorun bildirmek için [Issues](https://github.com/kullaniciadi/motiva/issues) sayfasını kullanabilirsiniz.

---

## 📊 Versiyon Geçmişi

### v1.0.0 (Mevcut)
- ✅ Alışkanlık yönetimi
- ✅ Takvim entegrasyonu
- ✅ Gamification sistemi
- ✅ Sosyal özellikler
- ✅ Mesajlaşma sistemi
- ✅ Admin paneli
- ✅ Bildirim sistemi
- ✅ Profil yönetimi

---

<div align="center">

**⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın! ⭐**

Made with ❤️ by Motiva Team

</div>
