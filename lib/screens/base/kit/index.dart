import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ai_assistant/screens/base/ui/theme.dart';
import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class WcaoUtils {
  late Directory _cacheDir;

  Future<WcaoUtils> init() async {
    _cacheDir = await getApplicationDocumentsDirectory();
    // 可选：创建子目录如 avatars/
    final avatarDir = Directory('${_cacheDir.path}/avatars');
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    _cacheDir = avatarDir;
    return this;
  }

  String _generateFileName(String url) {
    // 移除空格并生成 hash
    final cleanUrl = url.trim();
    final bytes = utf8.encode(cleanUrl);
    final hash = md5.convert(bytes).toString();
    return 'avatar_$hash.jpg'; // 或根据 URL 后缀判断格式
  }

  Future<File?> _getCachedFile(String url) async {
    final fileName = _generateFileName(url);
    final file = File('${_cacheDir.path}/$fileName');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<File?> downloadAndCache(String url) async {
    try {
      final cached = await _getCachedFile(url);
      if (cached != null) {
        return cached; // 已缓存，直接返回
      }

      final response = await http.get(Uri.parse(url.trim()));
      if (response.statusCode == 200) {
        final fileName = _generateFileName(url);
        final file = File('${_cacheDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print(
          'Failed to download avatar: $url, status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('Error caching avatar: $e');
      return null;
    }
  }

  /// 弹窗提示
  static toast(String msg) async {
    await EasyLoading.showToast(msg); //显示短时间的文本提示
  }

  /// loading
  static loading({String? msg}) async {
    await EasyLoading.show(status: msg ?? "loading..."); //loding等待指示器的提示
  }

  /// 关闭loading
  static dismiss() {
    EasyLoading.dismiss();
  }

  /// 展示图片(带缓存)，但是不保存成file,一般用于浏览图片
  static Widget imageCache(String url, {BoxFit? fit}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit ?? BoxFit.fill,
      placeholder:
          (context, url) =>
              CupertinoActivityIndicator(color: WcaoTheme.primary),
      errorWidget: // 错误时，使用这个图片
          (context, url, error) =>
              const Icon(Icons.error, color: Colors.redAccent),
    );
  }

  static String getRandomImage() {
    List<String> images = [
      "https://pic.rmb.bdstatic.com/bjh/43eb2f1c813a02b30c609e9d7aaa54e9.jpeg",
      "https://q2.itc.cn/q_70/images03/20250225/e8117dd40aae4db5a64461f1ea0d16fc.jpeg",
      "https://pic.rmb.bdstatic.com/bjh/a0c53141530c70da1bde0ddc3f973947.jpeg",
      "https://img2.woyaogexing.com/2022/04/25/bbe4a9dc325b4e33a1f96dd89cc3556f!400x400.jpeg",
      "https://q9.itc.cn/q_70/images03/20241013/facec60b28dc4e46b3863bf6c41e670f.jpeg",
    ];
    return images[Random().nextInt(images.length)];
  }
}
