import 'package:flutter/material.dart';
import 'package:ai_assistant/screens/chat/mac_setting_controller.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:get/get.dart';

// 本页面用于 根据硬件激活码，将硬件绑定到这个聊天组上
class MacSettingPage extends StatefulWidget {
  final GroupChat groupChatIns; //  groupChatIns,代表一个聊天对话组

  const MacSettingPage({super.key, required this.groupChatIns});

  @override
  State<MacSettingPage> createState() => _MacSettingState();
}

class _MacSettingState extends State<MacSettingPage> {
  final macSettingCtlIns = Get.find<MacSettingController>();

  @override
  void initState() {
    super.initState();
    // 创建页面时，查询当前group的硬件绑定信息
    macSettingCtlIns.getBandingInfo(widget.groupChatIns);
  }

  @override
  void dispose() {
    super.dispose();
    macSettingCtlIns.clearActivateCode();
  }

  @override
  Widget build(BuildContext context) {
    print("新建剧场group了，进入build页面");
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
          '绑定硬件',
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
                  children: [_buildBody()], // 页面主体
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              Text(
                '绑定的人类角色: ${widget.groupChatIns.createHumanAgentName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // 根据 macSettingCtlIns.activateCode.value 是否为空，显示不同的内容
              // 如果激活码为空，就显示输入框，让和用户输入激活码, 并显示 绑定激活码的按钮
              // 如果激活码不为空，就显示激活码，并显示 删除绑定的按钮
              // 头像和名称

              // 根据 macSettingCtlIns.activateCode.value 是否为空，显示不同的内容
              Obx(() {
                final activateCode = macSettingCtlIns.activateCode.value;
                if (activateCode.isEmpty) {
                  // 如果激活码为空，就显示输入框，让用户输入激活码，并显示绑定激活码的按钮
                  return Column(
                    children: [
                      TextField(
                        controller: macSettingCtlIns.codeEditCtlIns,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '请输入硬件上提示的数字激活码',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            macSettingCtlIns.doBanding(widget.groupChatIns);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '添加绑定',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // 如果激活码不为空，就显示激活码，并显示删除绑定的按钮
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // 添加这行，让子组件左对齐
                    children: [
                      const Text(
                        '已绑定的激活码：',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          activateCode,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            macSettingCtlIns.deleteBanding(widget.groupChatIns);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '删除绑定',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ],
      ),
    );
  }
}
