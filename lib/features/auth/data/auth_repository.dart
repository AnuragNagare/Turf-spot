import 'dart:async';
import '../domain/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });
  Future<void> sendPhoneOtp(String phone);
  Future<UserModel> verifyPhoneOtp(String phone, String otp);
  Future<UserModel> signInWithGoogle();
  Future<void> sendPasswordReset(String email);
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    PreferredSport? preferredSport,
  });
}

class InMemoryAuthRepository implements AuthRepository {
  final _controller = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  InMemoryAuthRepository() {
    // Provide a sample authenticated user for instant preview or start as null
    _currentUser = null;
  }

  @override
  Stream<UserModel?> get authStateChanges => _controller.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters long');
    }
    _currentUser = UserModel(
      id: 'usr_test_1',
      name: email.split('@').first.toUpperCase(),
      email: email,
      preferredSport: PreferredSport.both,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = UserModel(
      id: 'usr_new_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      preferredSport: PreferredSport.both,
      createdAt: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> sendPhoneOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // OTP sent to phone
  }

  @override
  Future<UserModel> verifyPhoneOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp != '123456' && otp.length != 6) {
      throw Exception('Invalid OTP. Please enter 123456 for demo.');
    }
    _currentUser = UserModel(
      id: 'usr_phone_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Player',
      phone: phone,
      preferredSport: PreferredSport.both,
      createdAt: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(
      id: 'usr_google_1',
      name: 'Anurag Player',
      email: 'player@turfspot.com',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      preferredSport: PreferredSport.both,
      createdAt: DateTime.now(),
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    PreferredSport? preferredSport,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      preferredSport: preferredSport,
    );
    _controller.add(_currentUser);
  }
}
