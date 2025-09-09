import 'package:flutter/material.dart';
import 'package:ai_assistant/models/xiaozhi_config.dart';
import 'package:ai_assistant/screens/login/widgets/head.dart';
//import 'package:ai_assistant/state/token.dart';
import 'package:ai_assistant/screens/ui/theme.dart';
import 'dart:async';
//import 'package:get/get.dart';

// HACK: 注册界面

class LoginRegister extends StatefulWidget {
  const LoginRegister({Key? key}) : super(key: key);

  @override
  State<LoginRegister> createState() => _RegisterState();
}

class _RegisterState extends State<LoginRegister> {
  // 倒计时相关
  int _countdown = 0;
  Timer? _timer;

  // 验证码输入控制器
  final TextEditingController _verificationCodeController =
      TextEditingController();

  @override
  void dispose() {
    _timer?.cancel(); // 防止内存泄漏
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            margin: const EdgeInsets.only(bottom: 56),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Head(), // 这是手机号输入框，共用组件，所以共用了
                  buildPassWord(),
                  // buildVerificationCode(), 临时关闭验证码空间，以后再弄
                  rigisterButton(),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: Text(
                            "忘记密码?",
                            style: TextStyle(
                              color: WcaoTheme.placeholder,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              '/login/password',
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "有账号，直接登录",
                              style: TextStyle(
                                color: WcaoTheme.primaryFocus,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            //Get.toNamed('/verify-code/reset_password');
                          },
                          child: Text(
                            "忘记密码?",
                            style: TextStyle(
                              color: WcaoTheme.secondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "登录即同意",
                          style: TextStyle(color: WcaoTheme.placeholder),
                        ),
                        InkWell(
                          child: const Text('《用户协议》'),
                          onTap: () {
                            Navigator.pushNamed(context, "/agreement/user");
                          },
                        ),
                        Text(
                          "及",
                          style: TextStyle(color: WcaoTheme.placeholder),
                        ),
                        InkWell(
                          child: const Text('《隐私政策》'),
                          onTap: () {
                            Navigator.pushNamed(context, "/agreement/privacy");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 密码登录
  Column buildPassWord() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          child: Wrap(
            children: [
              Text(
                '密码',
                style: TextStyle(
                  fontSize: 14,
                  color: WcaoTheme.placeholder,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          height: 50,
          child: TextField(
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: "请输入密码",
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: WcaoTheme.outline, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: WcaoTheme.primaryFocus, width: 2),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          height: 50,
          child: TextField(
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: "再次输入密码",
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: WcaoTheme.outline, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: WcaoTheme.primaryFocus, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 验证码输入组件
  /// 验证码输入组件（输入框和按钮同行）
  Widget buildVerificationCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签：验证码
        Container(
          margin: const EdgeInsets.only(top: 24),
          child: Text(
            '验证码',
            style: TextStyle(
              fontSize: 14,
              color: WcaoTheme.placeholder,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // 输入框 + 获取验证码按钮 同行
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              // 验证码输入框（占满剩余空间）
              Expanded(
                child: TextField(
                  controller: _verificationCodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: "请输入6位验证码",
                    counterText: "", // 隐藏字符计数
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: WcaoTheme.outline,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: WcaoTheme.primaryFocus,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // 水平间距
              const SizedBox(width: 12),
              // 获取验证码按钮（固定宽度）
              SizedBox(
                width: 100, // 按钮固定宽度，可根据设计调整
                child:
                    _countdown > 0
                        ? Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: WcaoTheme.placeholder.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_countdown秒',
                            style: TextStyle(
                              color: WcaoTheme.primaryFocus,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        : InkWell(
                          onTap: _startCountdown,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: WcaoTheme.primaryFocus,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '获取验证码',
                              style: TextStyle(
                                color: WcaoTheme.primaryFocus,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 开始倒计时
  void _startCountdown() {
    if (_countdown > 0) return; // 防止重复点击

    setState(() {
      _countdown = 60;
    });

    _timer?.cancel(); // 取消之前的定时器（安全起见）
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
    });
  }

  /// 注册按钮
  InkWell rigisterButton() {
    return InkWell(
      onTap: () {
        //TokenController.to.set();
        //Get.offAllNamed('/home');
      },
      child: Container(
        margin: const EdgeInsets.only(top: 36),
        alignment: Alignment.center,
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: WcaoTheme.primary,
          borderRadius: WcaoTheme.radius,
        ),
        child: const Text(
          '注册新用户',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
