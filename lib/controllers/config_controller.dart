import 'dart:convert';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_assistant/models/xiaozhi_config.dart';

class ConfigController extends GetxController {
  // 创建一个默认的XiaozhiConfig
  List<XiaozhiConfig> _xiaozhiConfigs = [];
  bool _isLoaded = false;

  List<XiaozhiConfig> get xiaozhiConfigs => _xiaozhiConfigs;

  bool get isLoaded => _isLoaded;

  ConfigController() {
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    // Load Xiaozhi configs
    final macAddress = await _getDeviceMacAddress();
    final xiaozhiConfigsJson = [
      '''
    {
      "id": "0",
      "name": "default",
      "websocketUrl": "ws://60.205.170.254:8000/xiaozhi/v1/",
      "macAddress": "b4:3a:45:a2:0f:7c",
      "token": "test-token"
    }
    ''',
    ];
    _xiaozhiConfigs =
        xiaozhiConfigsJson
            .map((json) => XiaozhiConfig.fromJson(jsonDecode(json)))
            .toList();
    // 打印当前的xiaozhiConfigs的数量
    print('加载默认的 ${_xiaozhiConfigs.length} 小智服务器配置configs');
    _isLoaded = true;
  }

  // Future<void> _saveConfigs() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // Save Xiaozhi configs
  //   final xiaozhiConfigsJson =
  //       _xiaozhiConfigs.map((config) => jsonEncode(config.toJson())).toList();
  //   await prefs.setStringList('xiaozhiConfigs', xiaozhiConfigsJson);
  // }

  // 简化版的设备ID获取方法，不依赖上下文
  Future<String> _getSimpleDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';

    try {
      // 简单地尝试获取Android或iOS设备ID，不依赖平台判断
      try {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } catch (_) {
        try {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
        } catch (_) {
          final webInfo = await deviceInfo.webBrowserInfo;
          deviceId = webInfo.userAgent ?? '';
        }
      }
    } catch (e) {
      // 出现任何错误，使用时间戳
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    return deviceId;
  }

  String _generateMacFromDeviceId(String deviceId) {
    final bytes = utf8.encode(deviceId);
    final digest = md5.convert(bytes);
    final hash = digest.toString();

    // Format as MAC address (XX:XX:XX:XX:XX:XX)
    final List<String> macParts = [];
    for (int i = 0; i < 6; i++) {
      macParts.add(hash.substring(i * 2, i * 2 + 2));
    }

    return macParts.join(':');
  }

  // 获取设备MAC地址
  Future<String> _getDeviceMacAddress() async {
    final deviceId = await _getSimpleDeviceId();

    // 如果设备ID本身就是MAC地址格式，直接使用
    if (_isMacAddress(deviceId)) {
      return deviceId;
    }

    // 否则生成一个MAC地址
    return _generateMacFromDeviceId(deviceId);
  }

  // 检查字符串是否是MAC地址格式
  bool _isMacAddress(String str) {
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    return macRegex.hasMatch(str);
  }
}
