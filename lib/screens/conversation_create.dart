import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_assistant/providers/config_provider.dart';
import 'package:ai_assistant/providers/conversation_provider.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/models/xiaozhi_config.dart';
import 'package:ai_assistant/models/dify_config.dart';
import 'package:ai_assistant/screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversationTypeCreate extends StatefulWidget {
  const ConversationTypeCreate({super.key});

  @override
  State<ConversationTypeCreate> createState() => _ConversationTypeCreateState();
}

class _ConversationTypeCreateState extends State<ConversationTypeCreate> {
  XiaozhiConfig? _selectedXiaozhiConfig;
  String? default_gender = '女';

    // 表单控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _personalityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _jobController.dispose();
    _personalityController.dispose();
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
        leading: IconButton(  // 返回按钮
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
                  children: [
                    _buildTypeSelectionCard()
                  ],
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
                const SizedBox(height: 6)
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('名字：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '请输入名字',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              const Text('可选性别：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: default_gender,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  // 可选：添加 label 或 hint
                  // labelText: '性别',
                ),
                items: ['男', '女']
                    .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    default_gender = newValue; // 更新选中的性别
                  });
                },
                // 可选：添加验证
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请选择性别';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              const Text('年龄：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '请输入年龄',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              const Text('职业：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _jobController,
                decoration: InputDecoration(
                  hintText: '请输入职业',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              const Text('性格：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextField(
                controller: _personalityController,
                decoration: InputDecoration(
                  hintText: '请输入性格',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          )
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
        onPressed: _createConversation,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation:  4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: const Text(
          '创建角色a',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _createConversation() async {
      _createXiaozhiConversation();
  }


  Future<void> _createXiaozhiConversation() async {
      // 获取输入值
    final String name = _nameController.text.trim();
    final String ageStr = _ageController.text.trim();
    final String job = _jobController.text.trim();
    final String personality = _personalityController.text.trim();
    final String gender = default_gender ?? '女';

    // 简单验证
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写名字')),
      );
      return;
    }
    if (ageStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写年龄')),
      );
      return;
    }
    int? age = int.tryParse(ageStr);
    if (age == null || age < 0 || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效的年龄')),
      );
      return;
    }

    // 构造请求，向服务端发送 创建角色的请求
      // 构造请求体
    final Map<String, dynamic> requestBody = {
      "name": name,
      "age": age,
      "gender": gender,
      "job": job,
      "personality": personality,
    };

    try{
      final response = await http.post(
        Uri.parse('http://192.168.1.22:7865/create_role'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 创建成功
        final responseData = jsonDecode(response.body);
        String? roleId = responseData['id']?.toString(); // 假设返回中有 id 字段
        String roleName = responseData['name'] ?? name;

        // 可以在这里保存到本地（比如 ConversationProvider）

        //////////////////////////////
        final conversation = await Provider.of<ConversationProvider>(
          context,
          listen: false,
        ).createConversation(
          title: '与 ${roleName} 的对话',
          type: ConversationType.xiaozhi,
          configId: roleId!,
        );

        // 跳转到聊天界面
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversation: conversation),
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('角色 "$roleName" 创建成功！')),
        );
    } else {
      // 服务器返回错误
      final errorMsg = jsonDecode(response.body)['message'] ?? '创建失败，请重试';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('创建失败：$errorMsg')),
      );
    }

    } catch (e) {
      // 网络异常等
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('网络错误：$e')),
      );
    }
  




  }
}
