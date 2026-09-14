import 'package:dio/dio.dart';
import 'package:trotxi_client/trotxi_client.dart';

/// Durable requests; the existing client supplies auth, refresh and transport.
class CommuteRepository {
  CommuteRepository(TrotxiApiClient client) : _dio = client.dio;
  final Dio _dio;

  Future<List<CommuteRequest>> list() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me/commute-requests',
    );
    return (response.data!['requests'] as List)
        .map((row) => CommuteRequest.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> submit(Map<String, Object> input) async {
    await _dio.post<void>('/me/commute-requests', data: input);
  }

  Future<void> withdraw(String id) async {
    await _dio.post<void>('/me/commute-requests/$id/withdraw');
  }
}

class CommuteRequest {
  CommuteRequest.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      routeName = json['routeName'] as String,
      status = json['status'] as String,
      paused = json['paused'] as bool,
      requestedDate = json['requestedDate'] as String,
      effectiveDate = json['effectiveDate'] as String?,
      decisionNote = json['decisionNote'] as String?;
  final String id, routeName, status, requestedDate;
  final String? effectiveDate, decisionNote;
  final bool paused;
  bool get isOpen =>
      const ['pending', 'waitlisted', 'approved'].contains(status);
}

String commuteError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    if (error.error is OfflineException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection unavailable. Refresh your requests before retrying; your request may already have reached operations.';
    }
  }
  return 'Could not complete the request. Refresh and try again, or contact operations.';
}
