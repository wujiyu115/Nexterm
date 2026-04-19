import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:nexterm/features/sync/services/auth_api_client.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final String? email;
  final bool isLoggedIn;

  const AuthState({this.accessToken, this.refreshToken, this.email, this.isLoggedIn = false});

  AuthState copyWith({String? accessToken, String? refreshToken, String? email, bool? isLoggedIn}) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      email: email ?? this.email,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApiClient _api;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._api, this._storage) : super(const AuthState());

  Future<void> loadSavedAuth() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    final email = await _storage.read(key: 'email');
    if (accessToken != null && refreshToken != null) {
      state = AuthState(accessToken: accessToken, refreshToken: refreshToken, email: email, isLoggedIn: true);
    }
  }

  Future<void> register(String email, String password) async {
    final tokens = await _api.register(email, password);
    await _saveTokens(tokens, email);
  }

  Future<void> login(String email, String password) async {
    final tokens = await _api.login(email, password);
    await _saveTokens(tokens, email);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }

  Future<void> refreshTokens() async {
    if (state.refreshToken == null) return;
    final tokens = await _api.refresh(state.refreshToken!);
    await _saveTokens(tokens, state.email);
  }

  Future<void> _saveTokens(Map<String, dynamic> tokens, String? email) async {
    final access = tokens['access_token'] as String;
    final refresh = tokens['refresh_token'] as String;
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    if (email != null) await _storage.write(key: 'email', value: email);
    state = AuthState(accessToken: access, refreshToken: refresh, email: email, isLoggedIn: true);
  }
}

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.nexterm.app'));
  return AuthApiClient(dio);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(authApiClientProvider);
  const storage = FlutterSecureStorage();
  return AuthNotifier(api, storage);
});
