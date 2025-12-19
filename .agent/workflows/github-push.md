---
description: GitHub'a ilk defa proje yükleme rehberi
---

# GitHub'a İlk Defa Proje Yükleme Rehberi

Bu rehber, Motiva projesini GitHub'a yüklemek için gereken tüm adımları içerir.

## Ön Hazırlık

### 1. Git Kurulumu Kontrolü

Git'in yüklü olup olmadığını kontrol edin:

```bash
git --version
```

Eğer Git yüklü değilse, [git-scm.com](https://git-scm.com/download/win) adresinden indirip kurun.

### 2. Git Yapılandırması

İlk defa kullanıyorsanız, Git'i yapılandırın:

```bash
git config --global user.name "Adınız Soyadınız"
git config --global user.email "email@example.com"
```

## GitHub'da Repository Oluşturma

### 3. GitHub Hesabı

- [github.com](https://github.com) adresine gidin
- Hesabınız yoksa "Sign up" ile kayıt olun
- Hesabınız varsa "Sign in" ile giriş yapın

### 4. Yeni Repository Oluşturma

1. GitHub'da sağ üstteki **"+"** işaretine tıklayın
2. **"New repository"** seçin
3. Repository bilgilerini girin:
   - **Repository name**: `motiva` (veya istediğiniz isim)
   - **Description**: `Kişisel Gelişim ve Alışkanlık Takip Uygulaması`
   - **Public** veya **Private** seçin
   - ⚠️ **"Initialize this repository with a README"** seçeneğini **İŞARETLEMEYİN**
   - ⚠️ **.gitignore** ve **license** eklemeyin (zaten projede var)
4. **"Create repository"** butonuna tıklayın

## Yerel Proje Hazırlığı

### 5. .gitignore Dosyası Kontrolü

Projenizde zaten `.gitignore` dosyası var. Kontrol edin:

```bash
cat .gitignore
```

### 6. Hassas Bilgileri Gizleme

⚠️ **ÖNEMLİ**: Firebase API anahtarlarınızı GitHub'a yüklemeden önce kontrol edin!

`google-services.json` dosyası `.gitignore`'da olmalı. Kontrol edin:

```bash
grep -r "google-services.json" .gitignore
```

Eğer yoksa ekleyin:

```bash
echo "android/app/google-services.json" >> .gitignore
```

## Git Repository Başlatma

### 7. Git Repository'yi Başlatın

Proje klasöründe:

```bash
git init
```

### 8. Tüm Dosyaları Ekleyin

```bash
git add .
```

### 9. İlk Commit'i Yapın

```bash
git commit -m "Initial commit: Motiva projesi eklendi"
```

## GitHub'a Bağlanma ve Yükleme

### 10. Remote Repository Ekleyin

GitHub'da oluşturduğunuz repository'nin URL'ini kullanın:

```bash
git remote add origin https://github.com/KULLANICI_ADINIZ/motiva.git
```

**Not**: `KULLANICI_ADINIZ` yerine kendi GitHub kullanıcı adınızı yazın!

### 11. Ana Branch'i Yeniden Adlandırın (Opsiyonel)

GitHub'ın yeni standartı `main` branch'i kullanmaktır:

```bash
git branch -M main
```

### 12. Projeyi GitHub'a Yükleyin

```bash
git push -u origin main
```

İlk push sırasında GitHub kullanıcı adı ve şifreniz (veya personal access token) istenecektir.

## GitHub Authentication (Kimlik Doğrulama)

### 13. Personal Access Token Oluşturma

GitHub artık şifre ile push'a izin vermiyor. Token oluşturmanız gerekiyor:

1. GitHub'da sağ üstteki profil fotoğrafınıza tıklayın
2. **Settings** > **Developer settings** > **Personal access tokens** > **Tokens (classic)**
3. **Generate new token** > **Generate new token (classic)**
4. Token'a bir isim verin: `Motiva Project`
5. **Expiration**: 90 days veya istediğiniz süre
6. **Scopes**: `repo` seçeneğini işaretleyin
7. **Generate token** butonuna tıklayın
8. ⚠️ **Token'ı kopyalayın** (bir daha gösterilmeyecek!)

### 14. Token ile Push

Push komutu çalıştırıldığında:
- **Username**: GitHub kullanıcı adınız
- **Password**: Oluşturduğunuz token'ı yapıştırın

## Doğrulama

### 15. GitHub'da Kontrol Edin

1. GitHub repository sayfanızı yenileyin
2. Tüm dosyaların yüklendiğini kontrol edin
3. README.md dosyasının düzgün görüntülendiğini kontrol edin

## Gelecekteki Güncellemeler

### 16. Değişiklikleri Yüklemek

Projenizde değişiklik yaptıktan sonra:

```bash
# Değişiklikleri görüntüle
git status

# Tüm değişiklikleri ekle
git add .

# Commit yap
git commit -m "Açıklayıcı commit mesajı"

# GitHub'a yükle
git push
```

## Sorun Giderme

### Hata: "remote origin already exists"

```bash
git remote remove origin
git remote add origin https://github.com/KULLANICI_ADINIZ/motiva.git
```

### Hata: "failed to push some refs"

```bash
git pull origin main --rebase
git push -u origin main
```

### Hata: "Authentication failed"

- Personal access token'ınızı kontrol edin
- Token'ın `repo` yetkisine sahip olduğundan emin olun
- Token'ın süresinin dolmadığından emin olun

## Önemli Notlar

⚠️ **Hassas Bilgiler**
- API anahtarlarını asla GitHub'a yüklemeyin
- `.gitignore` dosyasını kontrol edin
- `google-services.json` dosyası `.gitignore`'da olmalı

✅ **İyi Pratikler**
- Anlamlı commit mesajları yazın
- Sık sık commit yapın
- Her önemli değişiklikten sonra push edin
- README.md dosyanızı güncel tutun

## Tamamlandı! 🎉

Projeniz artık GitHub'da! Repository URL'niz:
```
https://github.com/KULLANICI_ADINIZ/motiva
```
