import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:ai_assistant/screens/base/ui/theme.dart';
import 'dart:math';

const assetHost = 'https://rao.pics/r';

class WcaoUtils {
  /// toast
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

  /// https://pub.flutter-io.cn/packages/cached_network_image
  /// 缓存图片
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
    // return '$assetHost?t=${DateTime.now()}';
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
