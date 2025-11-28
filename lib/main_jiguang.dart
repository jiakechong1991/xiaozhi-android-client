import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http; // 导入 http
import 'dart:convert'; // 导入 jsonEncode / jsonDecode
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jverify/jverify.dart';

import 'load.dart';

void main() => runApp(
  new MaterialApp(
    title: "demo",
    theme: new ThemeData(primaryColor: Colors.white),
    home: MyApp(),
  ),
);

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 统一 key
  final String f_result_key = "result";

  /// 额外信息
  final String f_extra_key = "extra";

  /// 错误码
  final String f_code_key = "code";

  /// 回调的提示信息，统一返回 flutter 为 message
  final String f_msg_key = "message";

  /// 运营商信息
  final String f_opr_key = "operator";

  String _result = "token=";
  var controllerPHone = new TextEditingController();
  final Jverify jverify = new Jverify();
  String? _token;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('JVerify example')),
        body: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      widthFactor: 2,
      child: new Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
            color: Colors.brown,
            child: Text(_result),
            width: 300,
            height: 100,
          ),
          new Container(
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new CustomButton(
                  onPressed: () {
                    isInitSuccess();
                  },
                  title: "初始化状态",
                ),
                new Text("   "),
                new CustomButton(
                  onPressed: () {
                    checkVerifyEnable();
                  },
                  title: "网络环境是否支持",
                ),
              ],
            ),
          ),
          new Container(
            child: SizedBox(
              child: new CustomButton(
                onPressed: () {
                  getToken();
                },
                title: "获取号码认证 Token",
              ),
              width: double.infinity,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
          new Container(
            child: TextField(
              autofocus: false,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "手机号码",
                hintStyle: TextStyle(color: Colors.black),
              ),
              controller: controllerPHone,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
          new Container(
            child: SizedBox(
              child: new CustomButton(
                onPressed: () {
                  preLogin();
                },
                title: "预取号",
              ),
              width: double.infinity,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
          new Container(
            child: SizedBox(
              child: new CustomButton(
                onPressed: () {
                  checkPreLoginCache();
                },
                title: "是否存在预取号缓存",
              ),
              width: double.infinity,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
          new Container(
            child: SizedBox(
              child: new CustomButton(
                onPressed: () {
                  loginAuth(false);
                },
                title: "一键登录",
              ),
              width: double.infinity,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
          new Container(
            child: SizedBox(
              child: new CustomButton(
                onPressed: () {
                  loginAuth(true);
                },
                title: "短信登录",
              ),
              width: double.infinity,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
          new Container(
            child: SizedBox(
              child: new CustomButton(
                onPressed: () {
                  getSMSCode();
                },
                title: "获取验证码",
              ),
              width: double.infinity,
            ),
            margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }

  /// sdk 初始化是否完成
  void isInitSuccess() {
    jverify.isInitSuccess().then((map) {
      bool result = map[f_result_key];
      setState(() {
        if (result) {
          _result = "sdk 初始换成功";
        } else {
          _result = "sdk 初始换失败";
        }
      });
    });
  }

  /// 判断当前网络环境是否可以发起认证
  void checkVerifyEnable() {
    jverify.checkVerifyEnable().then((map) {
      bool result = map[f_result_key];
      Map extra = map[f_extra_key];
      setState(() {
        if (result) {
          _result = "当前网络环境【支持认证】！" + extra.toString();
        } else {
          _result = "当前网络环境【不支持认证】！" + extra.toString();
        }
      });
    });
  }

  /// 获取号码认证token
  void getToken() {
    setState(() {
      _showLoading(context);
    });
    jverify.checkVerifyEnable().then((map) {
      bool result = map[f_result_key];
      if (result) {
        jverify.getToken().then((map) {
          int code = map[f_code_key];
          _token = map[f_msg_key];
          String operator = map[f_opr_key];
          setState(() {
            _hideLoading();
            _result = "[$code] message = $_token, operator = $operator";
          });
        });
      } else {
        setState(() {
          _hideLoading();
          _result = "[2016],msg = 当前网络环境不支持认证";
        });
      }
    });
  }

  /// 获取短信验证码
  void getSMSCode() {
    setState(() {
      _showLoading(context);
    });
    String phoneNum = controllerPHone.text;
    if (phoneNum.isEmpty) {
      setState(() {
        _hideLoading();
        _result = "[3002],msg = 没有输入手机号码";
      });
      return;
    }
    jverify.checkVerifyEnable().then((map) {
      bool result = map[f_result_key];
      if (result) {
        jverify.getSMSCode(phoneNum: phoneNum).then((map) {
          print("获取短信验证码：${map.toString()}");
          int code = map[f_code_key];
          String message = map[f_msg_key];
          setState(() {
            _hideLoading();
            _result = "[$code] message = $message";
          });
        });
      } else {
        setState(() {
          _hideLoading();
          _result = "[3004],msg = 获取短信验证码异常";
        });
      }
    });
  }

  /// 预取号缓存
  void checkPreLoginCache() {
    jverify.validPreloginCache().then((map) {
      bool result = map[f_result_key];
      setState(() {
        if (result) {
          _result = "预取号缓存有效";
        } else {
          _result = "预取号缓存无效";
        }
      });
    });
  }

  void preLogin() {
    setState(() {
      _showLoading(context);
    });
    jverify.checkVerifyEnable().then((map) {
      bool result = map[f_result_key];
      if (result) {
        jverify.preLogin(enableSms: true).then((map) {
          print("预取号接口回调：${map.toString()}");
          int code = map[f_code_key];
          String message = map[f_msg_key];
          setState(() {
            _hideLoading();
            _result = "[$code] message = $message";
          });
        });
      } else {
        setState(() {
          _hideLoading();
          _result = "[2016],msg = 当前网络环境不支持认证";
        });
      }
    });
  }

  void _showLoading(BuildContext context) {
    LoadingDialog.show(context);
  }

  void _hideLoading() {
    LoadingDialog.hidden();
  }

  Future<void> _sendTokenToMyServer(String token) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://a2.richudongfang1642.cn:7902/api/accounts/phone_login/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 登录成功！可能返回 JWT、用户信息等
        String jwt = data['access_token'];
        // 保存 jwt，跳转主页...
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => HomePage()),
        // );
      } else {
        // 后端验证失败
        _result = "服务器验证失败";
      }
    } catch (e) {
      _result = "网络错误: $e";
    }
  }

  /// SDK 请求授权一键登录
  void loginAuth(bool isSms) {
    setState(() {
      _showLoading(context);
    });
    jverify.checkVerifyEnable().then((map) {
      bool result = map[f_result_key];
      print("checkVerifyEnable $map");
      //需要使用sms的时候不检查result
      // if (result) {
      if (true) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;
        bool isiOS = Platform.isIOS;

        /// 自定义授权的 UI 界面，以下设置的图片必须添加到资源文件里，
        /// android项目将图片存放至drawable文件夹下，可使用图片选择器的文件名,例如：btn_login.xml,入参为"btn_login"。
        /// ios项目存放在 Assets.xcassets。
        ///
        JVUIConfig uiConfig = JVUIConfig();
        // uiConfig.authBGGifPath = "main_gif";
        uiConfig.authBGVideoPath = "videoBg";
        // uiConfig.authBGVideoPath =
        //     "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
        uiConfig.authBGVideoImgPath = "cmBackground";

        uiConfig.navHidden = !isiOS;
        // uiConfig.navColor = Colors.red.value;
        // uiConfig.navText = "登录";
        // uiConfig.navTextColor = Colors.blue.value;
        // uiConfig.navReturnImgPath = "return_bg"; //图片必须存在

        uiConfig.logoWidth = 100;
        uiConfig.logoHeight = 80;
        //uiConfig.logoOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.logoWidth/2).toInt();
        uiConfig.logoOffsetY = 10;
        uiConfig.logoVerticalLayoutItem = JVIOSLayoutItem.ItemSuper;
        uiConfig.logoHidden = false;
        uiConfig.logoImgPath = "logo";

        uiConfig.numberFieldWidth = 200;
        uiConfig.numberFieldHeight = 40;
        //uiConfig.numFieldOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.numberFieldWidth/2).toInt();
        uiConfig.numFieldOffsetY = isiOS ? 20 : 120;
        uiConfig.numberVerticalLayoutItem = JVIOSLayoutItem.ItemLogo;
        uiConfig.numberColor = Colors.blue.value;
        uiConfig.numberSize = 18;

        uiConfig.sloganOffsetY = isiOS ? 20 : 160;
        uiConfig.sloganVerticalLayoutItem = JVIOSLayoutItem.ItemNumber;
        uiConfig.sloganTextColor = Colors.black.value;
        uiConfig.sloganTextSize = 15;
        uiConfig.sloganWidth = 100;
        //        uiConfig.slogan
        //uiConfig.sloganHidden = 0;

        uiConfig.logBtnWidth = 220;
        uiConfig.logBtnHeight = 50;
        //uiConfig.logBtnOffsetX = isiOS ? 0 : null;//(screenWidth/2 - uiConfig.logBtnWidth/2).toInt();
        uiConfig.logBtnOffsetY = isiOS ? 20 : 230;
        uiConfig.logBtnVerticalLayoutItem = JVIOSLayoutItem.ItemSlogan;
        uiConfig.logBtnText = "登录按钮";
        uiConfig.logBtnTextColor = Colors.brown.value;
        uiConfig.logBtnTextSize = 16;
        uiConfig.logBtnTextBold = true;
        uiConfig.loginBtnNormalImage = "login_btn_normal"; //图片必须存在
        uiConfig.loginBtnPressedImage = "login_btn_press"; //图片必须存在
        uiConfig.loginBtnUnableImage = "login_btn_unable"; //图片必须存在

        uiConfig.privacyHintToast =
            true; //only android 设置隐私条款不选中时点击登录按钮默认显示toast。

        uiConfig.privacyState = false; //设置默认勾选
        uiConfig.privacyCheckboxSize = 20;
        uiConfig.privacyCheckboxOffsetY = 5;
        uiConfig.checkedImgPath = "check_image"; //图片必须存在
        uiConfig.uncheckedImgPath = "uncheck_image"; //图片必须存在
        uiConfig.privacyCheckboxInCenter = true;
        uiConfig.privacyCheckboxHidden = false;
        uiConfig.isAlertPrivacyVc = true;

        //uiConfig.privacyOffsetX = isiOS ? (20 + uiConfig.privacyCheckboxSize) : null;
        uiConfig.privacyOffsetY = 50; // 距离底部距离
        uiConfig.privacyOffsetX = 50; // 距离底部距离
        uiConfig.privacyMarginR = 50;
        uiConfig.privacyVerticalLayoutItem = JVIOSLayoutItem.ItemSuper;
        uiConfig.clauseName = "协议1";
        uiConfig.clauseUrl = "http://www.baidu.com";
        uiConfig.clauseBaseColor =
            const Color.fromARGB(255, 236, 216, 216).value;
        uiConfig.clauseNameTwo = "协议二";
        uiConfig.clauseUrlTwo = "http://www.hao123.com";
        uiConfig.clauseColor = const Color.fromARGB(255, 128, 120, 89).value;
        uiConfig.privacyText = ["我已阅读并同意", ""];
        uiConfig.privacyTextSize = 10;
        uiConfig.privacyItem = [
          JVPrivacy(
            "自定义协议1",
            "http://www.baidu.com",
            beforeName: "==",
            afterName: "++",
            separator: "、",
          ),
          // JVPrivacy("自定义", "http://www.baidu.com", separator: "、"),
          // JVPrivacy("自定义协议3", "http://www.baidu.com", separator: "、"),
          // JVPrivacy("自定义协议4", "http://www.baidu.com", separator: "、"),
          // JVPrivacy("自定义协议5", "http://www.baidu.com", separator: "、")
        ];
        uiConfig.textVerAlignment = 1;
        //uiConfig.privacyWithBookTitleMark = true;
        //uiConfig.privacyTextCenterGravity = false;
        uiConfig.authStatusBarStyle = JVIOSBarStyle.StatusBarStyleDarkContent;
        uiConfig.privacyStatusBarStyle = JVIOSBarStyle.StatusBarStyleDefault;
        uiConfig.modelTransitionStyle =
            JVIOSUIModalTransitionStyle.CrossDissolve;

        uiConfig.statusBarColorWithNav = true;
        // uiConfig.virtualButtonTransparent = true;

        uiConfig.privacyStatusBarColorWithNav = true;
        uiConfig.privacyVirtualButtonTransparent = true;

        uiConfig.needStartAnim = true;
        uiConfig.needCloseAnim = true;
        uiConfig.enterAnim = "activity_slide_enter_bottom";
        uiConfig.exitAnim = "activity_slide_exit_bottom";

        uiConfig.privacyNavColor = Colors.red.value;
        uiConfig.privacyNavTitleTextColor = Colors.blue.value;
        uiConfig.privacyNavTitleTextSize = 16;

        uiConfig.privacyNavTitleTitle = "ios lai le"; //only ios
        uiConfig.privacyNavReturnBtnImage = "umcsdk_return_bg"; //图片必须存在;

        //协议二次弹窗内容设置 -iOS
        uiConfig.isAlertPrivacyVc = true;
        uiConfig.agreementAlertViewCornerRadius = 15;
        uiConfig.agreementAlertViewBackgroundColor =
            const Color.fromARGB(255, 28, 27, 32).value;
        uiConfig.agreementAlertViewTitleTextColor = Colors.white.value;
        uiConfig.agreementAlertViewTitleText =
            "Please Read And Agree to The Following Terms";
        uiConfig.agreementAlertViewTitleTexSize = 16;
        uiConfig.agreementAlertViewContentTextAlignment =
            JVTextAlignmentType.center;
        uiConfig.agreementAlertViewContentTextFontSize = 13;
        // uiConfig.agreementAlertViewLoginBtnNormalImagePath = "login_btn_normal";
        // uiConfig.agreementAlertViewLoginBtnPressedImagePath = "login_btn_press";
        // uiConfig.agreementAlertViewLoginBtnUnableImagePath = "login_btn_unable";
        uiConfig.agreementAlertViewLoginBtnNormalImagePath =
            "login_btn_normal_dark";
        uiConfig.agreementAlertViewLoginBtnPressedImagePath =
            "login_btn_normal_dark";
        uiConfig.agreementAlertViewLoginBtnUnableImagePath =
            "login_btn_normal_dark";
        uiConfig.agreementAlertViewLogBtnText = "同意";
        uiConfig.agreementAlertViewLogBtnTextFontSize = 13;
        uiConfig.agreementAlertViewLogBtnTextColor =
            const Color.fromARGB(255, 128, 120, 89).value;

        uiConfig.appLanguageType = "1";
        uiConfig.navReturnBtnOffsetX = 10;
        uiConfig.navReturnBtnOffsetY = 10;
        uiConfig.navReturnBtnHidden = false;
        uiConfig.navReturnImgPath = "umcsdk_return_bg"; //图片必须存在
        uiConfig.navHidden = false;
        uiConfig.navTransparent = false;
        uiConfig.statusBarTransparent = true;
        uiConfig.navText = "";
        // uiConfig.openPrivacyInBrowser = true;

        //协议二次弹窗内容设置 -Android
        JVPrivacyCheckDialogConfig privacyCheckDialogConfig =
            JVPrivacyCheckDialogConfig();
        // privacyCheckDialogConfig.width = 250;
        // privacyCheckDialogConfig.height = 100;
        privacyCheckDialogConfig.title = "测试协议标题";
        privacyCheckDialogConfig.offsetX = 0;
        privacyCheckDialogConfig.offsetY = 0;
        privacyCheckDialogConfig.logBtnText = "同11意";
        privacyCheckDialogConfig.titleTextSize = 22;
        privacyCheckDialogConfig.gravity = "center";
        privacyCheckDialogConfig.titleTextColor = Colors.black.value;
        privacyCheckDialogConfig.contentTextGravity = "left";
        privacyCheckDialogConfig.contentTextSize = 14;
        privacyCheckDialogConfig.logBtnImgPath = "login_btn_normal";
        privacyCheckDialogConfig.logBtnTextColor = Colors.black.value;
        privacyCheckDialogConfig.logBtnMarginT = 20;
        privacyCheckDialogConfig.logBtnMarginB = 20;
        privacyCheckDialogConfig.logBtnMarginL = 10;
        privacyCheckDialogConfig.logBtnWidth = 140;
        privacyCheckDialogConfig.logBtnHeight = 40;
        privacyCheckDialogConfig.contentTextPaddingL = 10;
        privacyCheckDialogConfig.privacyBackgroundColor = Colors.red.value;

        /// 添加自定义的 控件 到dialog
        List<JVCustomWidget> dialogWidgetList = [];
        final String btn_dialog_widgetId =
            "jv_add_custom_dialog_button"; // 标识控件 id
        JVCustomWidget buttonDialogWidget = JVCustomWidget(
          btn_dialog_widgetId,
          JVCustomWidgetType.button,
        );
        buttonDialogWidget.title = "取消";
        buttonDialogWidget.titleColor = Colors.white.value;
        buttonDialogWidget.left = 0;
        buttonDialogWidget.top = 160;
        buttonDialogWidget.width = 140;
        buttonDialogWidget.height = 40;
        buttonDialogWidget.textAlignment = JVTextAlignmentType.center;
        buttonDialogWidget.btnNormalImageName = "main_btn_other";
        buttonDialogWidget.btnPressedImageName = "main_btn_other";
        // buttonDialogWidget.backgroundColor = Colors.yellow.value;
        //buttonWidget.textAlignment = JVTextAlignmentType.left;

        // 添加点击事件监听
        jverify.addClikWidgetEventListener(btn_dialog_widgetId, (eventId) {
          print("receive listener - click dialog widget event :$eventId");
          if (btn_dialog_widgetId == eventId) {
            print("receive listener - 点击【新加 dialog button】");
          }
        });
        dialogWidgetList.add(buttonDialogWidget);
        privacyCheckDialogConfig.widgets = dialogWidgetList;
        uiConfig.privacyCheckDialogConfig = privacyCheckDialogConfig;

        //sms
        JVSMSUIConfig smsConfig = JVSMSUIConfig();
        smsConfig.smsLogBtnBackgroundPath = "main_btn_other";
        smsConfig.smsPrivacyBeanList = [
          JVPrivacy(
            "自定义协议1",
            "http://www.baidu.com",
            beforeName: "==",
            afterName: "++",
            separator: "*",
          ),
        ];
        smsConfig.smsPrivacyClauseStart = "开头";
        smsConfig.smsPrivacyClauseEnd = "结尾";
        smsConfig.enableSMSService = true;
        smsConfig.smsPrivacyOffsetY = 50;
        smsConfig.smsPrivacyOffsetX = 20;
        uiConfig.smsUIConfig = smsConfig;

        uiConfig.setIsPrivacyViewDarkMode = false; //协议页面是否支持暗黑模式

        //弹框模式
        // JVPopViewConfig popViewConfig = JVPopViewConfig();
        // popViewConfig.width = (screenWidth - 100.0).toInt();
        // popViewConfig.height = (screenHeight - 150.0).toInt();

        // uiConfig.popViewConfig = popViewConfig;

        /// 添加自定义的 控件 到授权界面
        List<JVCustomWidget> widgetList = [];

        final String text_widgetId = "jv_add_custom_text"; // 标识控件 id
        JVCustomWidget textWidget = JVCustomWidget(
          text_widgetId,
          JVCustomWidgetType.textView,
        );
        textWidget.title = "新加 text view 控件";
        textWidget.left = 20;
        textWidget.top = 360;
        textWidget.width = 200;
        textWidget.height = 40;
        textWidget.backgroundColor = Colors.yellow.value;
        textWidget.isShowUnderline = true;
        textWidget.textAlignment = JVTextAlignmentType.center;
        textWidget.isClickEnable = true;

        // 添加点击事件监听
        jverify.addClikWidgetEventListener(text_widgetId, (eventId) {
          print("receive listener - click widget event :$eventId");
          if (text_widgetId == eventId) {
            print("receive listener - 点击【新加 text】");
          }
        });
        widgetList.add(textWidget);

        final String btn_widgetId = "jv_add_custom_button"; // 标识控件 id
        JVCustomWidget buttonWidget = JVCustomWidget(
          btn_widgetId,
          JVCustomWidgetType.button,
        );
        buttonWidget.title = "新加 button 控件";
        buttonWidget.left = 100;
        buttonWidget.top = 400;
        buttonWidget.width = 150;
        buttonWidget.height = 40;
        buttonWidget.isShowUnderline = true;
        buttonWidget.backgroundColor = Colors.brown.value;
        //buttonWidget.btnNormalImageName = "";
        //buttonWidget.btnPressedImageName = "";
        //buttonWidget.textAlignment = JVTextAlignmentType.left;

        // 添加点击事件监听
        jverify.addClikWidgetEventListener(btn_widgetId, (eventId) {
          print("receive listener - click widget event :$eventId");
          if (btn_widgetId == eventId) {
            print("receive listener - 点击【新加 button】");
          }
        });
        widgetList.add(buttonWidget);

        // 设置iOS的二次弹窗按钮
        uiConfig.agreementAlertViewWidgets = dialogWidgetList;
        uiConfig.agreementAlertViewUIFrames = {
          "superViewFrame": [
            (screenWidth ~/ 2).toInt() - 140,
            (screenHeight ~/ 2).toInt() - 150,
            280,
            200,
          ],
          "alertViewFrame": [0, 0, 280, 200],
          "titleFrame": [10, 10, 260, 60],
          "contentFrame": [15, 70, 250, 110],
          "buttonFrame": [140, 160, 140, 40],
        };

        /// 步骤 1：调用接口设置 UI
        jverify.setCustomAuthorizationView(
          true,
          uiConfig,
          landscapeConfig: uiConfig,
          widgets: widgetList,
        );
        if (!isSms) {
          /// 步骤 2：调用一键登录接口
          jverify.loginAuthSyncApi2(
            autoDismiss: true,
            enableSms: true,
            loginAuthcallback: (event) {
              setState(() {
                _hideLoading();
                _result = "获取返回数据：[${event.code}] message = ${event.message}";
                final token = event.message; // 👇👇👇 这里是你需要补充的代码：调用你的后端！
                _sendTokenToMyServer(token!);
              });
              print(
                "获取到 loginAuthSyncApi 接口返回数据，code=${event.code},message = ${event.message},operator = ${event.operator}",
              );
            },
          );
        } else {
          /// 步骤 2：调用短信登录接口
          jverify.smsAuth(
            autoDismiss: true,
            smsCallback: (event) {
              setState(() {
                _hideLoading();
                _result = "获取返回数据：[${event.code}] message = ${event.message}";
              });
              print(
                "获取到 smsAuth 接口返回数据，code=${event.code},message = ${event.message},phone = ${event.phone}",
              );
            },
          );
        }
      } else {
        setState(() {
          _hideLoading();
          _result = "[2016],msg = 当前网络环境不支持认证";
        });

        /* 弹框模式
        JVPopViewConfig popViewConfig = JVPopViewConfig();
        popViewConfig.width = (screenWidth - 100.0).toInt();
        popViewConfig.height = (screenHeight - 150.0).toInt();

        uiConfig.popViewConfig = popViewConfig;
        */

        /*

        /// 方式二：使用异步接口 （如果想使用异步接口，则忽略此步骤，看方式二）

        /// 先，执行异步的一键登录接口
        jverify.loginAuth(true).then((map) {

          /// 再，在回调里获取 loginAuth 接口异步返回数据（如果是通过添加 JVLoginAuthCallBackListener 监听来获取返回数据，则忽略此步骤）
          int code = map[f_code_key];
          String content = map[f_msg_key];
          String operator = map[f_opr_key];
          setState(() {
           _hideLoading();
            _result = "接口异步返回数据：[$code] message = $content";
          });
          print("通过接口异步返回，获取到 loginAuth 接口返回数据，code=$code,message = $content,operator = $operator");
        });

        */
      }
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // 初始化 SDK 之前添加监听
    jverify.addSDKSetupCallBackListener((JVSDKSetupEvent event) {
      print("receive sdk setup call back event :${event.toMap()}");
    });

    jverify.setDebugMode(true); // 打开调试模式
    jverify.setCollectionAuth(true);
    jverify.setup(
      appKey: "429e098ff4eabb22f780efd0", //"你自己应用的 AppKey",
      channel: "devloper-default",
    ); // 初始化sdk,  appKey 和 channel 只对ios设置有效
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    /// 授权页面点击时间监听
    jverify.addAuthPageEventListener((JVAuthPageEvent event) {
      print("receive auth page event :${event.toMap()}");
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('f_result_key', f_result_key));
  }
}

/// 封装 按钮
class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? title;

  const CustomButton({@required this.onPressed, this.title});

  @override
  Widget build(BuildContext context) {
    return new TextButton(
      onPressed: onPressed,
      child: new Text("$title"),
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Color(0xff888888)),
        backgroundColor: MaterialStateProperty.all(Color(0xff585858)),
        padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(10, 5, 10, 5)),
      ),
    );
  }
}
