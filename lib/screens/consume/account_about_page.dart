import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai_assistant/screens/consume/account_about_controller.dart';
import 'package:ai_assistant/utils/value_util.dart';

class AccountAboutPage extends StatefulWidget {
  const AccountAboutPage({super.key});

  @override
  State<AccountAboutPage> createState() => _AccountAboutState();
}

class _AccountAboutState extends State<AccountAboutPage> {
  final accountAboutPageCtlIns = Get.find<AccountAboutPageController>();
  @override
  void initState() {
    super.initState();
    // 加载账户当前积分信息
    accountAboutPageCtlIns.getAccountPonit();
    // 加载账户今日消费积分信息
    accountAboutPageCtlIns.getTodayConsumePoint();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("查询账户信息了，进入build页面");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 70,
        leading: IconButton(
          // 返回按钮
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '新建角色',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildBody()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 账户积分余额
        Obx(() {
          return Text(
            '账户余额：${ValueUtil.formatPoints(accountAboutPageCtlIns.nowAccountPoint.value)} 饼干',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        }),
        const SizedBox(height: 16),

        // 今日截止当前的积分消耗
        Obx(() {
          return Text(
            '今天已消耗：${ValueUtil.formatPoints(accountAboutPageCtlIns.todayConsumePoint_.value)} 饼干',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        }),
        const SizedBox(height: 32),

        // 消费明细 & 充值按钮（并列）
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/account/consume/info');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '消费明细',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/account/consume/rechange');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '充值',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
