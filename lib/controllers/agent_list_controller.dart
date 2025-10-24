import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/services/api_service.dart';

// 这个对应 角色列表 的 角色列表，[每个AgentRole是一个角色]
class AgentRoleListController extends GetxController {
  final agentListCacheKey = "agent_list";
  final _agentRoleList =
      <AgentRole>[].obs; // [conversation1, conversation2, ...]
  // final _messages =
  //     <String, List<Message>>{}.obs; // {agentId:[message1, message2, ...]}
  final ApiService _api = Get.find<ApiService>();

  ///封装的快捷方法
  List<AgentRole> get agentRoleList => _agentRoleList;
  // 置顶的agentRoleList
  List<AgentRole> get pinnedAgentRoleList =>
      _agentRoleList.where((conv) => conv.isPinned).toList();
  // 非置顶的agentRoleList
  List<AgentRole> get unpinnedAgentRoleList {
    final unpinned_ = _agentRoleList.where((conv) => !conv.isPinned).toList();
    // 按 lastMessageTime 倒序排序：最新消息在前
    unpinned_.sort((a, b) => b.agentName.compareTo(a.agentName));
    return unpinned_;
  }

  AgentRoleListController() {
    print("---调用AgentRoleListController的构造函数了---");
    _loadAgentRoleList();
  }

  Future<void> _loadAgentRoleList() async {
    bool hasReadServer = false;
    final prefs = await SharedPreferences.getInstance();
    // Load agent的列表
    // Step 1: 尝试从本地加载agent列表
    final agentRoleListCacheJson = prefs.getStringList(agentListCacheKey) ?? [];
    print("--------77777755555------------111----");
    print(agentRoleListCacheJson);
    if (true || agentRoleListCacheJson.isEmpty) {
      // 本地无结果，从服务器获取 agent 列表
      try {
        final agentListFromServer_ = await _api.getAgentList();
        print("从服务器拉去的agent列表222");
        print(agentListFromServer_);
        _agentRoleList.value =
            agentListFromServer_.map((itemAgent) {
              return AgentRole(
                agentId: itemAgent["id"].toString(),
                agentName: itemAgent["agent_name"],
                agentType: AgentType.fromString(itemAgent["agent_type"]),
                isDefault: itemAgent["is_default"],
                avatar: _api.getFullUrl(itemAgent["avatar"]),
                sex: itemAgent["sex"],
                voices: itemAgent["voices"],
                birthday: itemAgent["birthday"],
                age: itemAgent["age"],
                characterSetting: itemAgent["character_setting"],
              );
            }).toList();
        hasReadServer = true;
      } catch (e, stackTrace) {
        print('从服务器加载 agent 列表失败: $e');
        print('堆栈: $stackTrace');
      }
    } else {
      // 本地有数据，正常解析
      _agentRoleList.value =
          agentRoleListCacheJson
              .map(
                (itemRoleJson) => AgentRole.fromJson(jsonDecode(itemRoleJson)),
              )
              .toList();
    }

    // 如果请求了server，最后就要保存一下对话信息，避免下次继续为空
    if (hasReadServer) {
      // Save agent列表 到本地
      await _saveAgentList();
    }
  }

  Future<void> _saveAgentList() async {
    final prefs = await SharedPreferences.getInstance();
    final agentRoleListCacheJson_ =
        _agentRoleList
            .map((itemRole) => jsonEncode(itemRole.toJson()))
            .toList();
    await prefs.setStringList(agentListCacheKey, agentRoleListCacheJson_);
  }

  Future<AgentRole> createAgentRole({
    required String agentName,
    required String sex,
    required String birthday,
    required String characterSetting, // 角色介绍
    required String age, // 年龄
    required String voices,
    required File? avatarFile,
  }) async {
    // print("请求后端服务器，创建演员agent角色");
    final newAgentRes = await _api.createAgent(
      agentName = agentName,
      sex = sex,
      birthday = birthday,
      characterSetting = characterSetting,
      age = age,
      voices = voices,
      avatarFile = avatarFile,
    );

    final newAgentRole = AgentRole(
      agentId: newAgentRes["id"].toString(),
      agentName: newAgentRes["agent_name"],
      agentType: AgentType.fromString(newAgentRes["agent_type"]),
      isDefault: newAgentRes["is_default"],
      avatar: _api.getFullUrl(newAgentRes["avatar"]),
      sex: newAgentRes["sex"],
      voices: newAgentRes["voices"],
      birthday: newAgentRes["birthday"],
      age: newAgentRes["age"],
      characterSetting: newAgentRes["character_setting"],
    );

    _agentRoleList.add(newAgentRole);

    await _saveAgentList();

    print('创建新角色($agentName)并存储本地');
    return newAgentRole;
  }

  Future<void> deleteAgent(String id) async {
    // 寻找要删除的agent角色
    final agentIndex = _agentRoleList.indexWhere(
      (itemAgent) => itemAgent.agentId == id,
    );

    if (agentIndex != -1) {
      // 找到确实存在这个agent_id
      try {
        // 在服务端标记删除
        _api.deleteAgent(id);
        // 从列表中移除
        _agentRoleList.removeAt(agentIndex);

        await _saveAgentList();
      } catch (e) {
        print("agent删除失败");
      }
    }
  }

  // 设置指定id的角色agent的置顶状态
  Future<void> togglePinAgent(String id) async {
    final agentIndex = _agentRoleList.indexWhere(
      (itemAgent) => itemAgent.agentId == id,
    );
    if (agentIndex != -1) {
      final updatedAgent = _agentRoleList[agentIndex].copyWith(
        isPinned: !_agentRoleList[agentIndex].isPinned,
      );
      _agentRoleList[agentIndex] = updatedAgent;

      await _saveAgentList();
    }
  }
}
