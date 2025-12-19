import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Auth state değişikliklerini dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email ve şifre ile kayıt ol
  Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String username, // YENİ
  }) async {
    try {
      // Firebase Authentication ile kullanıcı oluştur
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı modeli oluştur
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        username: username.toLowerCase(), // YENİ
        createdAt: DateTime.now(),
      );

      // Firestore'a kullanıcı bilgilerini kaydet
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Kayıt sırasında bir hata oluştu: $e';
    }
  }

  // Email ve şifre ile giriş yap
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase Authentication ile giriş yap
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'dan kullanıcı bilgilerini al
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Kullanıcı dokümanı yoksa oluştur (manuel eklenen hesaplar için)
        // Özellikle admin hesabı için
        final isAdminEmail = email.toLowerCase() == 'admin@admin.com';
        
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          name: isAdminEmail ? 'Admin' : email.split('@')[0],
          username: isAdminEmail ? 'admin' : email.split('@')[0].toLowerCase(),
          createdAt: DateTime.now(),
          isAdmin: isAdminEmail,
        );

        // Firestore'a kaydet
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toFirestore());

        // Başarılar oluştur (admin değilse)
        if (!isAdminEmail) {
          final firestoreService = FirestoreService();
          await firestoreService.initializeUserAchievements(userCredential.user!.uid);
        }

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Giriş sırasında bir hata oluştu: $e';
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Çıkış sırasında bir hata oluştu: $e';
    }
  }

  // Şifre sıfırlama e-postası gönder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Şifre sıfırlama e-postası gönderilemedi: $e';
    }
  }

  // Kullanıcı bilgilerini al
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }

      return null;
    } catch (e) {
      throw 'Kullanıcı bilgileri alınamadı: $e';
    }
  }

  // Firebase Auth hatalarını işle
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda kullanılamıyor.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }
}
