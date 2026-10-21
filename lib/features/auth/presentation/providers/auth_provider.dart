import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return InMemoryAuthRepository();
});

// Emits the current user first, so listeners that start after a login still
// see the signed-in user, then every later change.
final authStateProvider = StreamProvider<UserModel?>((ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.currentUser;
  yield* repo.authStateChanges;
});

class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(AsyncValue.data(_repo.currentUser));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signInWithEmailAndPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signUpWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendOtp(String phone) async {
    await _repo.sendPhoneOtp(phone);
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.verifyPhoneOtp(phone, otp);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await _repo.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    await _repo.deleteAccount();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    PreferredSport? preferredSport,
  }) async {
    await _repo.updateUserProfile(
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      preferredSport: preferredSport,
    );
    state = AsyncValue.data(_repo.currentUser);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
