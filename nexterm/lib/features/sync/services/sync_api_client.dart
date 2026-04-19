import 'package:dio/dio.dart';

class SyncApiClient {
  final Dio _dio;
  SyncApiClient(this._dio);

  Future<Map<String, dynamic>> pullChanges(String since, String accessToken) async {
    final response = await _dio.get('/sync', queryParameters: {'since': since},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
    return response.data;
  }

  Future<Map<String, dynamic>> pullFull(String accessToken) async {
    final response = await _dio.get('/sync/full',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
    return response.data;
  }

  Future<void> pushChanges(List<Map<String, dynamic>> records, String deviceId, String accessToken) async {
    await _dio.post('/sync', data: {'records': records, 'device_id': deviceId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}));
  }
}
