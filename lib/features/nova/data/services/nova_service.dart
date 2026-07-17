import 'package:dio/dio.dart';
import 'package:mental_mantra/core/network/api_client.dart';

class NovaService {
  Future<Response> callChatApi(List<Map<String, dynamic>> apiMessages) async {
    return await ApiClient.post(
      '/ai/chat',
      data: {'messages': apiMessages},
    );
  }
}
