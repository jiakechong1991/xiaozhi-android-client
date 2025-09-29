// lib/services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:ai_assistant/services/token_storage.dart'; // 替换为你的包名
import 'package:ai_assistant/state/token.dart'; // 你的 TokenController
import 'dart:io';
import 'package:path/path.dart' as path;

class ApiService {
  final Dio _dio = Dio();
  // final String baseUrl = "http://192.168.0.102:5609"; //
  final String baseUrl = "http://a2.richudongfang1642.cn:7902";
  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // 👇 添加拦截器：请求前自动加 token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // 👇 如果是 401，尝试刷新 token
          if (error.response?.statusCode == 401) {
            try {
              final newTokens = await _refreshToken();
              if (newTokens != null) {
                // 重试原请求
                error.requestOptions.headers['Authorization'] =
                    'Bearer ${newTokens['access']}';
                return handler.resolve(await _dio.fetch(error.requestOptions));
              }
            } catch (e) {
              // 刷新失败，清除 token 并跳转登录
              await _clearAndRedirect();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // 👇 刷新 token 的私有方法
  Future<Map<String, dynamic>?> _refreshToken() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        '/api/auth/refresh/', // 通常是这个路径，根据你的 simplejwt 配置调整
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access'];
        final newRefreshToken =
            data['refresh'] ?? refreshToken; // 有些后端不返回新的 refresh

        // 保存新 token
        await TokenStorage.saveTokens(newAccessToken, newRefreshToken);
        // 同步更新 GetX 状态（触发 UI 监听）
        TokenController.to.set(newAccessToken);

        return data;
      }
    } catch (e) {
      print("刷新 token 失败: $e");
    }
    return null;
  }

  // 👇 清除 token 并跳转登录
  Future<void> _clearAndRedirect() async {
    await TokenStorage.deleteTokens();
    TokenController.to.delete();
    // 跳转登录（确保不在登录页时才跳转）
    if (Get.currentRoute != '/login/password') {
      Get.offAllNamed('/login/password'); // 强制重定向，清空栈
    }
  }

  // 👇 登录接口
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post(
      '/api/auth/login/',
      data: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      // 保存 tokens
      await TokenStorage.saveTokens(accessToken, refreshToken);
      // 更新 GetX 状态
      TokenController.to.set(accessToken);

      return data;
    } else {
      throw Exception('登录失败: ${response.statusMessage}');
    }
  }

  // 👇 create_agent接口
  Future<Map<String, dynamic>> create_agent(
    String agent_name,
    String sex,
    String birthday,
    String character_setting, // 角色介绍
    String age, // 年龄
    String voices,
    File? avatarFile,
  ) async {
    final formData = FormData();

    // 添加文本字段
    formData.fields.addAll([
      MapEntry('agent_name', agent_name),
      MapEntry('sex', sex),
      MapEntry('birthday', birthday),
      MapEntry('character_setting', character_setting),
      MapEntry('age', age),
      MapEntry('voices', voices),
    ]);

    if (avatarFile != null) {
      final filename = path.basename(avatarFile.path); // ✅ 动态获取
      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(avatarFile.path, filename: filename),
        ),
      );
    }

    final response = await _dio.post(
      '/api/agents/',
      data: formData,
      options: Options(
        contentType: "multipart/form-data", // 显式指定（dio 通常自动设）
      ),
    );

    if (response.statusCode == 201) {
      print("创建agent成功");
      final data = response.data as Map<String, dynamic>;
      // 打印data
      print(data);
      return data;
    } else {
      print("创建agent失败---");
      final data = response.data as Map<String, dynamic>;
      print(data);
      throw Exception('创建agent失败: ${response.statusMessage}');
    }
  }

  // 👇 登出接口
  Future<void> logout() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) return;

    try {
      await _dio.post('/api/auth/logout/', data: {'refresh': refreshToken});
    } catch (e) {
      print("登出失败: $e");
    } finally {
      await _clearAndRedirect();
    }
  }

  // 👇 获取用户信息
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/api/accounts/profile/');
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('获取用户信息失败');
    }
  }

  // 👇 获取用户的agent列表
  Future<List<dynamic>> getAgentList() async {
    final response = await _dio.get('/api/agents/');
    if (response.statusCode == 200) {
      print("-------88888-------------");
      print(response.data);
      return response.data as List<dynamic>? ?? [];
    } else {
      throw Exception('获取agent列表信息失败');
    }
  }

  // 👇 获取 指定agent的最近N条消息的列表
  Future<List<dynamic>> getMessageList(String agentId, int limit) async {
    final response = await _dio.get(
      '/api/msg/query',
      queryParameters: {'agent_id': agentId, 'limit': limit},
    );
    if (response.statusCode == 200) {
      return response.data as List<dynamic>;
    } else {
      throw Exception('获取agent($agentId)的msg信息列表 失败');
    }
  }

  // 👇 通用 GET 请求
  Future<dynamic> get(String path) async {
    final response = await _dio.get(path);
    return response.data;
  }

  // 👇 通用 POST 请求
  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    final response = await _dio.post(path, data: data);
    return response.data;
  }

  // 👇 你可以继续扩展 put, delete 等...
}
