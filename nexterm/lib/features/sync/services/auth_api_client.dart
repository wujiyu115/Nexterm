import 'package:dio/dio.dart';

class AuthApiClient {
  final Dio _dio;
  AuthApiClient(this._dio);

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await _dio.post('/auth/register', data: {'email': email, 'password': password});
    return response.data;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    return response.data;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
    return response.data;
  }

  Future<void> deleteAccount(String accessToken) async {
    await _dio.delete('/auth/account', options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
  }
}
