import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';

class PerformanceInterceptor extends Interceptor {
  final _metrics = <RequestOptions, HttpMetric>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final metric = FirebasePerformance.instance.newHttpMetric(
      options.uri.toString(),
      _mapMethod(options.method),
    );
    await metric.start();
    _metrics[options] = metric;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final metric = _metrics.remove(response.requestOptions);
    if (metric != null) {
      metric.httpResponseCode = response.statusCode;
      await metric.stop();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final metric = _metrics.remove(err.requestOptions);
    if (metric != null) {
      metric.httpResponseCode = err.response?.statusCode ?? -1;
      await metric.stop();
    }
    handler.next(err);
  }

  HttpMethod _mapMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET': return HttpMethod.Get;
      case 'POST': return HttpMethod.Post;
      case 'PUT': return HttpMethod.Put;
      case 'DELETE': return HttpMethod.Delete;
      case 'PATCH': return HttpMethod.Patch;
      default: return HttpMethod.Get;
    }
  }
}
