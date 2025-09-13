import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_assistant/providers/config_provider.dart';
import 'package:ai_assistant/providers/conversation_provider.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/models/xiaozhi_config.dart';
import 'package:ai_assistant/models/dify_config.dart';
import 'package:ai_assistant/screens/chat_screen.dart';
import 'package:ai_assistant/controllers/agent_create_controller.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

class ConversationTypeCreate extends StatefulWidget {
  const ConversationTypeCreate({super.key});

  @override
  State<ConversationTypeCreate> createState() => _ConversationTypeCreateState();
}

class _ConversationTypeCreateState extends State<ConversationTypeCreate> {
  XiaozhiConfig? _selectedXiaozhiConfig;

  final CreateAgentController createAgentController = Get.put(
    CreateAgentController(),
  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  children: [_buildTypeSelectionCard()],
                ),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTypeSelectionCard() {
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '请填写角色基本信息',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '名字：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: createAgentController.agentNameController,
                decoration: InputDecoration(
                  hintText: '请输入名字',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                '可选性别a：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: createAgentController.sex.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    // 可选：添加 label 或 hint
                    // labelText: '性别',
                  ),
                  items: [
                    DropdownMenuItem<String>(value: 'm', child: Text('男')),
                    DropdownMenuItem<String>(value: 'f', child: Text('女')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      createAgentController.sex.value =
                          newValue; // ✅ 同步到 controller
                    }
                  },
                  // 可选：添加验证
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请选择性别';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                '生日：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: createAgentController.birthdayController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '请输入生日',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                '职业：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: createAgentController.signatureController,
                decoration: InputDecoration(
                  hintText: '请输入职业',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                '性格：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: createAgentController.hobbyController,
                decoration: InputDecoration(
                  hintText: '请输入性格',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20,
        top: 20,
        right: 20,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            createAgentController.isLoading.value
                ? null // 加载中禁用点击
                : () => createAgentController.create_agent(), // 点击 创建角色按钮
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: const Text(
          '创建角色a',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
