import 'package:flutter/material.dart';
import 'package:ai_assistant/controllers/group_create_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class GroupChatCreatePage extends StatefulWidget {
  const GroupChatCreatePage({super.key});

  @override
  State<GroupChatCreatePage> createState() => _GroupChatCreateState();
}

class _GroupChatCreateState extends State<GroupChatCreatePage> {
  final createGroupCtlIns = Get.find<CreateGroupController>();

  @override
  void initState() {
    super.initState();
    createGroupCtlIns.getDefaultAvatar();
  }

  @override
  void dispose() {
    super.dispose();
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
          '新建剧场',
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
                  children: [_buildTypeSelectionCard()], // 页面主体
                ),
              ),
            ),
          ),
          _buildBottomButton(), // 底部按钮
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
          _buildAvatarSection(),
          // _buildBackdropSection(),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '场景名称：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: createGroupCtlIns.titleEditCtlIns,
                decoration: InputDecoration(
                  hintText: '请输入场景名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              const Text(
                '我的化身:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Obx(() {
                final selected =
                    createGroupCtlIns.humanAgentUse; // 假设你用 aiAgentsUser 存多选结果
                return Row(
                  children: [
                    // 已选角色头像列表（最多显示3个，可滚动）
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selected.length,
                          itemBuilder: (context, index) {
                            final agent = selected[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(agent.avatar),
                                radius: 20,
                                child: Text(
                                  agent.agentName.characters.take(1).join(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // 下拉三角按钮
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.blue,
                      ),
                      onPressed:
                          () => _showHumanAgentSelectionBottomSheet(context),
                    ),
                  ],
                );
              }),

              const Text(
                '可选聊天角色列表:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Obx(() {
                final selected =
                    createGroupCtlIns.aiAgentsUser; // 假设你用 aiAgentsUser 存多选结果
                return Row(
                  children: [
                    // 已选角色头像列表（最多显示3个，可滚动）
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: selected.length,
                          itemBuilder: (context, index) {
                            final agent = selected[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(agent.avatar),
                                radius: 20,
                                child: Text(
                                  agent.agentName.characters.take(1).join(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // 下拉三角按钮
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_drop_down_circle,
                        color: Colors.blue,
                      ),
                      onPressed:
                          () => _showAiAgentSelectionBottomSheet(context),
                    ),
                  ],
                );
              }),

              const Text(
                '角色设定：',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: createGroupCtlIns.settingEditCtlIns,
                decoration: InputDecoration(
                  hintText: '请输入角色介绍',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHumanAgentSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '选择化身',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: createGroupCtlIns.humanAgentList.length,
                  itemBuilder: (context, index) {
                    final agent = createGroupCtlIns.humanAgentList[index];
                    final isSelected = createGroupCtlIns.humanAgentList.any(
                      (a) => a.agentId == agent.agentId,
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(agent.avatar),
                        radius: 20,
                      ),
                      title: Text(agent.agentName),
                      trailing:
                          isSelected
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                      onTap: () {
                        if (isSelected) {
                          // 取消选择
                          createGroupCtlIns.humanAgentList.removeWhere(
                            (a) => a.agentId == agent.agentId,
                          );
                        } else {
                          // 添加选择
                          createGroupCtlIns.humanAgentList.add(agent);
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAiAgentSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '选择角色',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: createGroupCtlIns.aiAgentList.length,
                  itemBuilder: (context, index) {
                    final agent = createGroupCtlIns.aiAgentList[index];
                    final isSelected = createGroupCtlIns.aiAgentsUser.any(
                      (a) => a.agentId == agent.agentId,
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(agent.avatar),
                        radius: 20,
                      ),
                      title: Text(agent.agentName),
                      trailing:
                          isSelected
                              ? const Icon(Icons.check, color: Colors.blue)
                              : null,
                      onTap: () {
                        if (isSelected) {
                          // 取消选择
                          createGroupCtlIns.aiAgentsUser.removeWhere(
                            (a) => a.agentId == agent.agentId,
                          );
                        } else {
                          // 添加选择
                          createGroupCtlIns.aiAgentsUser.add(agent);
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        );
      },
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
            createGroupCtlIns.isLoading.value
                ? null // 加载中禁用点击
                : () => createGroupCtlIns.create_group(), // 点击 创建group按钮
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
          '创建聊天a',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '点击场景头像：',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // 弹出选择菜单：拍照 or 相册
              _showImagePickerDialog(context);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child:
                  createGroupCtlIns.avatarFile.value == null
                      ? Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                      : Stack(
                        children: [
                          ClipOval(
                            child: Image.file(
                              createGroupCtlIns.avatarFile.value!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildBackdropSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '点击切换聊天背景图片：',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // 弹出选择菜单：拍照 or 相册
              _showImagePickerDialog(context);
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child:
                  createGroupCtlIns.avatarFile.value == null
                      ? Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                      : Stack(
                        children: [
                          ClipOval(
                            child: Image.file(
                              createGroupCtlIns.avatarFile.value!,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context);
                  createGroupCtlIns.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context);
                  createGroupCtlIns.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('随机AI生成'),
                onTap: () => createGroupCtlIns.getDefaultAvatar(),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('取消'),
                textColor: Colors.red,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
