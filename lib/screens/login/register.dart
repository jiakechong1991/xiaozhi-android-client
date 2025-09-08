import 'package:flutter/material.dart';
import 'package:ai_assistant/models/xiaozhi_config.dart';
import 'package:ai_assistant/screens/login/widgets/head.dart';
//import 'package:ai_assistant/state/token.dart';
import 'package:ai_assistant/screens/ui/theme.dart';

//import 'package:get/get.dart';

// HACK: 注册界面

class LoginRegister extends StatefulWidget {
  const LoginRegister({Key? key}) : super(key: key);

  @override
  State<LoginRegister> createState() => _RegisterState();
}

class _RegisterState extends State<LoginRegister> {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Head(),
                buildPassWord(),
                loginButton(),
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
                      Text("及", style: TextStyle(color: WcaoTheme.placeholder)),
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
      ],
    );
  }

  /// 登录按钮
  InkWell loginButton() {
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
