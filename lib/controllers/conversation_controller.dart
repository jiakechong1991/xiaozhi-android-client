import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_assistant/models/conversation.dart';
import 'package:ai_assistant/models/message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ai_assistant/services/api_service.dart';

// 这个对应 聊天页 的 剧场group列表，[每个group是一个对话项]
class GroupChatController extends GetxController {
  // 聊天页面的 剧场group的列表(类似聊天群组列表)
  final _groupChatList =
      <GroupChat>[].obs; // [conversation1, conversation2, ...]
  final _messages =
      <String, List<Message>>{}.obs; // {groupId:[message1, message2, ...]}
  final ApiService _api = Get.find<ApiService>();

  ///封装的快捷方法
  List<GroupChat> get groupConversations => _groupChatList;
  // 置顶的剧场group会话
  List<GroupChat> get pinnedGroupConversations =>
      _groupChatList.where((conv) => conv.isPinned).toList();
  // 非置顶的剧场group会话
  List<GroupChat> get unpinnedGroupConversations {
    final unpinned_ = _groupChatList.where((conv) => !conv.isPinned).toList();
    // 按 lastMessageTime 倒序排序：最新消息在前
    unpinned_.sort((a, b) => b.latestActiveAt.compareTo(a.latestActiveAt));
    return unpinned_;
  }

  GroupChatController() {
    print("---调用ConversationController的构造函数了---");
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    bool hasReadServer = false;
    final prefs = await SharedPreferences.getInstance();
    // Load 多agent的对话列表
    // Step 1: 尝试从本地加载会话列表
    final groupConversationsJson =
        prefs.getStringList('groupConversations') ?? [];
    print("--------77777755555------------111----");
    print(groupConversationsJson);
    if (true || groupConversationsJson.isEmpty) {
      // 本地无会话，从服务器获取 agent 列表
      try {
        final groups_ = await _api.getGroupList();
        print("从服务器拉去的剧场groups列表");
        print(groups_);
        _groupChatList.value =
            groups_.map((itemGroup) {
              final defaultTimeStr = '1970-09-25T10:10:10+08:00';
              return GroupChat(
                userId: itemGroup["user_id"],
                userName: itemGroup["user_name"],
                groupId: itemGroup['group_id'],
                createHumanAgentId: itemGroup['human_agent_id'],
                createHumanAgentName: itemGroup['human_agent_name'],
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
        print('从服务器加载 agent 列表失败: $e');
        print('堆栈: $stackTrace');
        // 即使失败，也继续（可能用户离线），_conversations 保持为空
      }
    } else {
      // 本地有数据，正常解析
      _groupChatList.value =
          groupConversationsJson
              .map((json) => GroupChat.fromJson(jsonDecode(json)))
              .toList();
    }

    // Load messages for each 剧场group
    // Step 2: 为每个会话加载消息（本地优先，缺失则从服务器拉取）
    for (final itemGroupConversation in _groupChatList) {
      // 从
      final messagesByGroupId =
          prefs.getStringList('messages_${itemGroupConversation.groupId}') ??
          [];

      print("--------77777755555------------222----");
      print(messagesByGroupId);
      if (true || messagesByGroupId.isEmpty) {
        // 本地无消息，尝试从服务器拉取该group的最近 20 条
        try {
          final messagesData = await _api.getMessageList(
            itemGroupConversation.groupId,
            20,
          );
          final remoteMessages =
              messagesData.map((itemMsgJson) {
                final msgID_ = (itemMsgJson["msg_id"] as dynamic).toString();
                final agentID_ =
                    (itemMsgJson["agent_id"] as dynamic).toString();
                // msg发送者和创建group的ID一致，则 role就是user角色
                final role_ =
                    (itemMsgJson["sender_id"] ==
                            itemGroupConversation.createHumanAgentId)
                        ? MessageRole.user
                        : MessageRole.assistant;
                final content_ = itemMsgJson["msg_content"] as String;
                return Message(
                  messageId: msgID_,
                  conversationId: agentID_,
                  role: role_,
                  content: content_,
                  timestamp: DateTime.parse(
                    itemMsgJson["updated_at"] as String,
                  ),
                  isRead: true,
                );
              }).toList();

          _messages[itemGroupConversation.groupId] = remoteMessages;
          hasReadServer = true;
        } catch (e, stackTrace) {
          print('从服务器加载消息失败 (agent: ${itemGroupConversation.groupId}): $e');
          print('堆栈: $stackTrace');
          _messages[itemGroupConversation.groupId] = [];
        }
      } else {
        _messages[itemGroupConversation.groupId] =
            messagesByGroupId.map((json) {
              final decoded = jsonDecode(json);
              return Message.fromJson(decoded);
            }).toList();
      }

      ////后续流程
      try {
        // 打印图片消息的信息
        for (final message in _messages[itemGroupConversation.groupId] ?? []) {
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
          '${appDir.path}/conversations/${itemGroupConversation.groupId}/images',
        );
        if (!await conversationDir.exists()) {
          await conversationDir.create(recursive: true);
        }
      } catch (e, stackTrace) {
        print('加载会话 ${itemGroupConversation.groupId} 的消息时出错: $e');
        print('堆栈跟踪: $stackTrace');
        // 如果某个会话的消息加载失败，继续加载其他会话
        _messages[itemGroupConversation.groupId] = [];
      }
    }
    // 如果请求了server，最后就要保存一下对话信息，避免下次继续为空
    // if (hasReadServer) await _saveConversations();
  }

  Future<void> _saveConversations() async {
    final prefs = await SharedPreferences.getInstance();

    // Save conversations
    final groupConversationsJson =
        _groupChatList
            .map(
              (itemGroupConversation) =>
                  jsonEncode(itemGroupConversation.toJson()),
            )
            .toList();
    await prefs.setStringList('groupConversations', groupConversationsJson);

    // Save messages for each conversation
    for (final groupMsgEntry in _messages.entries) {
      // agent_entry key 是agentId,value 是 [message1, message2, ...]
      final messagesJson =
          groupMsgEntry.value
              .map((message) => jsonEncode(message.toJson()))
              .toList();
      await prefs.setStringList('messages_${groupMsgEntry.key}', messagesJson);
    }
  }

  Future<GroupChat> createGroupChat({
    required String createHumanAgentId, // 创建group的agent-human ID
    required String createHumanAgentName,
    required String title, // 创建group的标题
    required String settingContent,
    required List groupAgents, // group的成员列表
    required avator,
    required backdrop,
  }) async {
    final uuid = const Uuid();

    // 这里请求服务器，创建剧组groupChat，然后从返回中获得groupId
    final resJson_ = await _api.createGroup(
      createHumanAgentId = createHumanAgentId,
      groupAgents = groupAgents,
      title = title,
      settingContent = settingContent,
      avator = avator,
      backdrop = backdrop,
    );
    final newConversation = GroupChat(
      userId: resJson_["user_id"],
      userName: resJson_["user_name"],
      groupId: resJson_["groupId"],
      createHumanAgentId: createHumanAgentId,
      createHumanAgentName: createHumanAgentName,
      title: title,
      settingContent: settingContent,
      groupAgents: groupAgents,
      latestActiveAt: DateTime.now(),
      latestMsgContent: '',
      unreadCount: 0,
      isPinned: false,
      avator: avator,
      backdrop: backdrop,
    );

    _groupChatList.add(newConversation);
    _messages[newConversation.groupId] = [];

    await _saveConversations();

    print('ConversationProvider: 创建新会话，ID = $resJson_["groupId"]');
    return newConversation;
  }

  Future<void> deleteConversation(String id) async {
    // 寻找要删除的会话
    final itemGroupChatIndex = _groupChatList.indexWhere(
      (itemGroupChat) => itemGroupChat.groupId == id,
    );

    if (itemGroupChatIndex != -1) {
      // 找到确实存在这个agent_id

      try {
        // 在服务端标记删除
        _api.deleteAgent(id);
        // 清理图片文件
        final appDir = await getApplicationDocumentsDirectory();
        final conversationDir = Directory('${appDir.path}/conversations/$id');
        if (await conversationDir.exists()) {
          await conversationDir.delete(recursive: true);
          print('已清理会话相关的图片文件: ${conversationDir.path}');
        }

        // 从列表中移除
        _groupChatList.removeAt(itemGroupChatIndex);
        _messages.remove(id);

        await _saveConversations();
      } catch (e) {
        print("agent删除失败");
      }
    }
  }

  Future<void> togglePinConversation(String id) async {
    final index = _groupChatList.indexWhere(
      (itemGroupChat) => itemGroupChat.groupId == id,
    );
    if (index != -1) {
      final updatedConversation = _groupChatList[index].copyWith(
        isPinned: !_groupChatList[index].isPinned,
      );
      _groupChatList[index] = updatedConversation;

      await _saveConversations();
    }
  }

  List<Message> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  Future<void> addMessage({
    required String conversationId,
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
          '${appDir.path}/conversations/$conversationId/images',
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
      conversationId: conversationId,
      role: role,
      content: content,
      timestamp: DateTime.now(),
      isRead: role == MessageRole.user,
      isImage: isImage,
      imageLocalPath: imageLocalPath,
      fileId: fileId,
    );

    _messages[conversationId] = [
      ...(_messages[conversationId] ?? []),
      newMessage,
    ];

    // Update conversation last message
    final index = _groupChatList.indexWhere(
      (itemGroupChat) => itemGroupChat.groupId == conversationId,
    );
    if (index != -1) {
      final updatedConversation = _groupChatList[index].copyWith(
        latestMsgContent: content,
        latestActiveAt: DateTime.now(),
        unreadCount:
            role == MessageRole.assistant
                ? _groupChatList[index].unreadCount + 1
                : _groupChatList[index].unreadCount,
      );
      _groupChatList[index] = updatedConversation;
    }

    await _saveConversations();
  }

  // 更新最后一条用户消息，用于图片上传后更新fileId等信息
  Future<void> updateLastUserMessage({
    required String conversationId,
    required String content,
    bool isImage = false,
    String? imageLocalPath,
    String? fileId,
  }) async {
    if (!_messages.containsKey(conversationId) ||
        _messages[conversationId]!.isEmpty) {
      print('警告：找不到会话 $conversationId 或会话为空');
      return;
    }

    // 找到最后一条用户消息
    final messages = _messages[conversationId]!;
    int lastUserMessageIndex = -1;

    // 从后向前找最后一条用户消息
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == MessageRole.user) {
        lastUserMessageIndex = i;
        break;
      }
    }

    // 如果找到了用户消息，则更新它
    if (lastUserMessageIndex != -1) {
      final oldMessage = messages[lastUserMessageIndex];

      // 如果是图片消息，保留原有的图片相关字段
      final updatedMessage = Message(
        messageId: oldMessage.messageId,
        conversationId: oldMessage.conversationId,
        role: oldMessage.role,
        content: content,
        timestamp: oldMessage.timestamp,
        isRead: oldMessage.isRead,
        isImage: isImage || oldMessage.isImage,
        imageLocalPath: imageLocalPath ?? oldMessage.imageLocalPath,
        fileId: fileId ?? oldMessage.fileId,
      );

      // 替换消息
      _messages[conversationId]![lastUserMessageIndex] = updatedMessage;

      // 如果这是最后一条消息，也更新会话的lastMessage
      if (lastUserMessageIndex == messages.length - 1) {
        final conversationIndex = _groupChatList.indexWhere(
          (itemGroupChat) => itemGroupChat.groupId == conversationId,
        );

        if (conversationIndex != -1) {
          final updatedConversation = _groupChatList[conversationIndex]
              .copyWith(latestMsgContent: content);
          _groupChatList[conversationIndex] = updatedConversation;
        }
      }

      await _saveConversations();
    } else {
      print('警告：在会话 $conversationId 中找不到用户消息');
    }
  }

  // 标记会话为已读
  Future<void> markConversationAsRead(String conversationId) async {
    final index = _groupChatList.indexWhere(
      (itemChatGroup) => itemChatGroup.groupId == conversationId,
    );
    if (index != -1) {
      final updatedConversation = _groupChatList[index].copyWith(
        unreadCount: 0,
      );
      _groupChatList[index] = updatedConversation;

      // Mark all messages as read
      if (_messages.containsKey(conversationId)) {
        _messages[conversationId] =
            _messages[conversationId]!.map((message) {
              return Message(
                messageId: message.messageId,
                conversationId: message.conversationId,
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

      await _saveConversations();
    }
  }
}
