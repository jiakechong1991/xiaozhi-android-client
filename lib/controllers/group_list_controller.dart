import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/models/message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ai_assistant/services/api_service.dart';

// 这个对应 多agent的对话列表，[每个agent是一个对话项]
class GroupListController extends GetxController {
  // [groupChat1, groupChat2, ...]
  final groupListCacheKey = 'group_chat_list';
  final groupMessageCacheKey = 'group_chat_messages';
  final _groupChatList = <GroupChat>[].obs;
  final _messages =
      <String, List<Message>>{}.obs; // {groupID:[message1, message2, ...]}
  final ApiService _api = Get.find<ApiService>();

  ///封装的快捷方法
  List<GroupChat> get groupChatList => _groupChatList;
  // 置顶的agent会话
  List<GroupChat> get pinnedGroupList =>
      _groupChatList.where((itemGroup) => itemGroup.isPinned).toList();
  // 非置顶的agent会话
  List<GroupChat> get unpinnedGroupList {
    final unpinned_ = _groupChatList.where((conv) => !conv.isPinned).toList();
    // 按 latestActiveAt 倒序排序：最新消息在前
    unpinned_.sort((a, b) => b.latestActiveAt.compareTo(a.latestActiveAt));
    return unpinned_;
  }

  GroupListController() {
    print("---调用GroupListController的构造函数了---");
    _loadGroupList();
  }

  Future<void> _loadGroupList() async {
    bool hasReadServer = false;
    final prefs = await SharedPreferences.getInstance();
    // Load 多agent的对话列表
    // Step 1: 尝试从本地加载会话列表
    final groupListCacheJson = prefs.getStringList(groupListCacheKey) ?? [];
    print("-----GroupListController---的缓存-------111----");
    print(groupListCacheJson);
    if (true || groupListCacheJson.isEmpty) {
      // 本地无会话，从服务器获取 agent 列表
      try {
        final groupListServerRes = await _api.getGroupList();
        print("从服务器拉去的剧场groups列表");
        print(groupListServerRes);
        _groupChatList.value =
            groupListServerRes.map((itemGroup) {
              final defaultTimeStr = '1970-09-25T10:10:10+08:00';
              return GroupChat(
                userId: itemGroup["user_id"].toString(),
                userName: itemGroup["user_name"],
                groupId: itemGroup['group_id'].toString(),
                createHumanAgentId:
                    itemGroup['create_human_agent_id'].toString(),
                createHumanAgentName: itemGroup['create_human_agent_name'],
                title: itemGroup['title'],
                settingContent: itemGroup['setting_content'],
                groupAgents: itemGroup['group_agents'],
                latestActiveAt: DateTime.parse(
                  (itemGroup["latest_active_at"] as String?) ?? defaultTimeStr,
                ),
                latestMsgContent: itemGroup["latest_msg_content"] ?? "",
                avator: _api.getFullUrl(itemGroup["avatar"]),
                backdrop: _api.getFullUrl(itemGroup["backdrop"]),
              );
            }).toList();
        hasReadServer = true;
      } catch (e, stackTrace) {
        print('从服务器加载 groups 列表失败: $e');
        print('堆栈: $stackTrace');
        // 即使失败，也继续（可能用户离线），_conversations 保持为空
      }
    } else {
      // 本地有数据，正常解析
      _groupChatList.value =
          groupListCacheJson
              .map((json) => GroupChat.fromJson(jsonDecode(json)))
              .toList();
    }

    // Load messages for each conversation
    // Step 2: 为每个会话加载消息（本地优先，缺失则从服务器拉取）
    for (final itemGroup in _groupChatList) {
      final messagesJsonByGroup =
          prefs.getStringList('messages_${itemGroup.groupId}') ?? [];

      print("--------77777755555------------222----");
      print(messagesJsonByGroup);
      if (true || messagesJsonByGroup.isEmpty) {
        // 本地无消息，尝试从服务器拉取最近 20 条
        try {
          final messagesData = await _api.getMessageList(itemGroup.groupId, 20);
          final remoteMessages =
              messagesData.map((msgJson) {
                final role_ =
                    (msgJson["sender_agent_id"] == itemGroup.createHumanAgentId)
                        ? MessageRole.user
                        : MessageRole.assistant;
                return Message(
                  messageId: msgJson["msg_id"].toString(),
                  groupId: msgJson["group_id"].toString(),
                  role: role_,
                  content: msgJson["content"],
                  timestamp: DateTime.parse(msgJson["updated_at"] as String),
                  isRead: true,
                );
              }).toList();

          _messages[itemGroup.groupId] = remoteMessages;
          hasReadServer = true;
        } catch (e, stackTrace) {
          print('从服务器加载消息失败 (group: ${itemGroup.groupId}): $e');
          print('堆栈: $stackTrace');
          _messages[itemGroup.groupId] = [];
        }
      } else {
        _messages[itemGroup.groupId] =
            messagesJsonByGroup.map((itemMsg) {
              final decoded = jsonDecode(itemMsg);
              return Message.fromJson(decoded);
            }).toList();
      }

      ////后续流程
      try {
        // 打印图片消息的信息
        for (final message in _messages[itemGroup.groupId] ?? []) {
          if (message.isImage) {
            // 检查图片文件是否存在
            if (message.imageLocalPath != null) {
              final imageFile = File(message.imageLocalPath!);
              final exists = await imageFile.exists();
            }
          }
        }

        // 确保每个会话的图片目录存在
        final appDir = await getApplicationDocumentsDirectory();
        final conversationDir = Directory(
          '${appDir.path}/group/${itemGroup.groupId}/images',
        );
        if (!await conversationDir.exists()) {
          await conversationDir.create(recursive: true);
        }
      } catch (e, stackTrace) {
        print('加载会话 ${itemGroup.groupId} 的消息时出错: $e');
        print('堆栈跟踪: $stackTrace');
        // 如果某个会话的消息加载失败，继续加载其他会话
        _messages[itemGroup.groupId] = [];
      }
    }
    // 如果请求了server，最后就要保存一下对话信息，避免下次继续为空
    if (hasReadServer) await _saveGroupChatList();
  }

  Future<void> _saveGroupChatList() async {
    final prefs = await SharedPreferences.getInstance();

    // Save conversations
    final groupChatListCacheJson =
        _groupChatList
            .map((itemGroupChat) => jsonEncode(itemGroupChat.toJson()))
            .toList();
    await prefs.setStringList(groupListCacheKey, groupChatListCacheJson);

    // Save messages for each conversation
    for (final itemGroup in _messages.entries) {
      // agent_entry key 是agentId,value 是 [message1, message2, ...]
      final messagesCacheJson =
          itemGroup.value
              .map((message) => jsonEncode(message.toJson()))
              .toList();
      await prefs.setStringList('messages_${itemGroup.key}', messagesCacheJson);
    }
  }

  Future<GroupChat> createGroupChat({
    required String createHumanAgentId, // 创建group的agent-human ID
    required String title, // 创建group的标题
    required String settingContent,
    required List<AgentRoleSummary> groupAgents, // group的成员列表
    required File avatorFile,
    required File backdropFile,
  }) async {
    final newGroupRes = await _api.createGroup(
      createHumanAgentId,
      groupAgents,
      title,
      settingContent,
      avatorFile,
      backdropFile,
    );
    print("group服务端创建成功：");
    print(newGroupRes);
    final newGroupChatIns = GroupChat(
      userId: newGroupRes["user_id"].toString(),
      userName: newGroupRes["user_name"],
      groupId: newGroupRes["group_id"].toString(),
      createHumanAgentId: newGroupRes["create_human_agent_id"].toString(),
      createHumanAgentName: newGroupRes["create_human_agent_name"],
      title: newGroupRes["title"],
      settingContent: newGroupRes["setting_content"],
      groupAgents: newGroupRes["group_agents"],
      latestActiveAt: DateTime.now(),
      latestMsgContent: '',
      unreadCount: 0,
      isPinned: false,
      avator: newGroupRes["avatar"],
      backdrop: newGroupRes["backdrop"],
    );

    _groupChatList.add(newGroupChatIns);
    _messages[newGroupChatIns.groupId] = [];

    await _saveGroupChatList();

    // print('createGroupChat: 创建新group会话，ID = $newGroupRes["group_id"]');
    return newGroupChatIns;
  }

  Future<void> deleteGroupChat(String groupId) async {
    // 寻找要删除的会话
    final goalGroupIndex = _groupChatList.indexWhere(
      (itemGroup) => itemGroup.groupId == groupId,
    );

    if (goalGroupIndex != -1) {
      // 找到确实存在这个agent_id

      try {
        // 在服务端标记删除
        _api.deleteGroup(groupId);
        // 清理图片文件
        final appDir = await getApplicationDocumentsDirectory();
        final conversationDir = Directory('${appDir.path}/group/$groupId');
        if (await conversationDir.exists()) {
          await conversationDir.delete(recursive: true);
          print('已清理会话相关的图片文件: ${conversationDir.path}');
        }
        // 从列表中移除
        _groupChatList.removeAt(goalGroupIndex);
        _messages.remove(groupId);

        await _saveGroupChatList();
      } catch (e) {
        print("groupChat删除失败");
      }
    }
  }

  Future<void> togglePinGroupChat(String id) async {
    final index = _groupChatList.indexWhere(
      (itemGroup) => itemGroup.groupId == id,
    );
    if (index != -1) {
      final updatedGroupChat = _groupChatList[index].copyWith(
        isPinned: !_groupChatList[index].isPinned,
      );
      _groupChatList[index] = updatedGroupChat;

      await _saveGroupChatList();
    }
  }

  List<Message> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  Future<void> addMessage({
    required String groupId,
    required MessageRole role,
    required String content,
    String? id,
    bool isImage = false,
    String? imageLocalPath,
    String? fileId,
  }) async {
    final messageId = id ?? const Uuid().v4(); // 如果指定id，则使用指定的id,否则随机生成

    // 如果是图片消息，确保目录存在
    if (isImage && imageLocalPath != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final conversationDir = Directory(
          '${appDir.path}/group/$groupId/images',
        );
        if (!await conversationDir.exists()) {
          await conversationDir.create(recursive: true);
        }

        // 检查图片文件是否存在
        final imageFile = File(imageLocalPath);
        if (!await imageFile.exists()) {
          print('警告：添加图片消息时文件不存在: $imageLocalPath');
        }
      } catch (e) {
        print('创建图片目录失败: $e');
      }
    }

    final newMessage = Message(
      messageId: messageId,
      groupId: groupId,
      role: role,
      content: content,
      timestamp: DateTime.now(),
      isRead: role == MessageRole.user,
      isImage: isImage,
      imageLocalPath: imageLocalPath,
      fileId: fileId,
    );

    _messages[groupId] = [...(_messages[groupId] ?? []), newMessage];

    // Update conversation last message
    final index = _groupChatList.indexWhere(
      (itemGroup) => itemGroup.groupId == groupId,
    );
    if (index != -1) {
      final updatedGroup = _groupChatList[index].copyWith(
        latestMsgContent: content,
        latestActiveAt: DateTime.now(),
        unreadCount:
            role == MessageRole.assistant
                ? _groupChatList[index].unreadCount + 1
                : _groupChatList[index].unreadCount,
      );
      _groupChatList[index] = updatedGroup;
    }

    await _saveGroupChatList();
  }

  // // 更新最后一条用户消息，用于图片上传后更新fileId等信息
  // Future<void> updateLastUserMessage({
  //   required String conversationId,
  //   required String content,
  //   bool isImage = false,
  //   String? imageLocalPath,
  //   String? fileId,
  // }) async {
  //   if (!_messages.containsKey(conversationId) ||
  //       _messages[conversationId]!.isEmpty) {
  //     print('警告：找不到会话 $conversationId 或会话为空');
  //     return;
  //   }

  //   // 找到最后一条用户消息
  //   final messages = _messages[conversationId]!;
  //   int lastUserMessageIndex = -1;

  //   // 从后向前找最后一条用户消息
  //   for (int i = messages.length - 1; i >= 0; i--) {
  //     if (messages[i].role == MessageRole.user) {
  //       lastUserMessageIndex = i;
  //       break;
  //     }
  //   }

  //   // 如果找到了用户消息，则更新它
  //   if (lastUserMessageIndex != -1) {
  //     final oldMessage = messages[lastUserMessageIndex];

  //     // 如果是图片消息，保留原有的图片相关字段
  //     final updatedMessage = Message(
  //       messageId: oldMessage.messageId,
  //       conversationId: oldMessage.conversationId,
  //       role: oldMessage.role,
  //       content: content,
  //       timestamp: oldMessage.timestamp,
  //       isRead: oldMessage.isRead,
  //       isImage: isImage || oldMessage.isImage,
  //       imageLocalPath: imageLocalPath ?? oldMessage.imageLocalPath,
  //       fileId: fileId ?? oldMessage.fileId,
  //     );

  //     // 替换消息
  //     _messages[conversationId]![lastUserMessageIndex] = updatedMessage;

  //     // 如果这是最后一条消息，也更新会话的lastMessage
  //     if (lastUserMessageIndex == messages.length - 1) {
  //       final conversationIndex = _groupChatList.indexWhere(
  //         (conversation) => conversation.agentId == conversationId,
  //       );

  //       if (conversationIndex != -1) {
  //         final updatedConversation = _groupChatList[conversationIndex]
  //             .copyWith(lastMessage: content);
  //         _groupChatList[conversationIndex] = updatedConversation;
  //       }
  //     }

  //     await _saveGroupChatList();
  //   } else {
  //     print('警告：在会话 $conversationId 中找不到用户消息');
  //   }
  // }

  // 标记会话为已读
  Future<void> markConversationAsRead(String groupId) async {
    final index = _groupChatList.indexWhere(
      (itemGroup) => itemGroup.groupId == groupId,
    );
    if (index != -1) {
      final updatedConversation = _groupChatList[index].copyWith(
        unreadCount: 0,
      );
      _groupChatList[index] = updatedConversation;

      // Mark all messages as read
      if (_messages.containsKey(groupId)) {
        _messages[groupId] =
            _messages[groupId]!.map((message) {
              return Message(
                messageId: message.messageId,
                groupId: message.groupId,
                role: message.role,
                content: message.content,
                timestamp: message.timestamp,
                isRead: true,
                isImage: message.isImage,
                imageLocalPath: message.imageLocalPath,
                fileId: message.fileId,
              );
            }).toList();
      }

      await _saveGroupChatList();
    }
  }
}
