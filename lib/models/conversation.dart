// enum ConversationType { dify, xiaozhi }

// 剧场Group 对应的数据结构
class GroupChat {
  final String userId;
  final String userName; // 所属账户
  final String groupId; // 剧场group_id
  final String createHumanAgentId; // 创建的agent的ID
  final String createHumanAgentName; // 创建的agent的Name
  final String title; // 剧场group的title
  final String settingContent; // 房间描述文本
  // final ConversationType type; // 没用，固定是ConversationType.xiaozhi
  // final String configId; // server类型 现在固定是Xiaozhi[0], 这是描述服务器配置的
  final List groupAgents; // 剧场组中的agent演员列表
  final DateTime latestActiveAt; // 最后一条消息的时间
  final String latestMsgContent; // 最后一条消息内容
  final int unreadCount; //未读消息数
  final bool isPinned; // 是否置顶
  final String avator; // 头像图片
  final String backdrop; // 背景图片

  GroupChat({
    // 构造函数
    required this.userId,
    required this.userName,
    required this.groupId,
    required this.createHumanAgentId,
    required this.createHumanAgentName,
    // this.type = ConversationType.xiaozhi,
    // this.configId = '0',
    required this.title,
    required this.settingContent,
    required this.groupAgents,
    required this.latestActiveAt,
    required this.latestMsgContent,
    this.unreadCount = 0,
    this.isPinned = false,
    required this.avator,
    required this.backdrop,
  });

  // 创建GroupChat
  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      userId: json['userId'],
      userName: json['userName'],
      groupId: json["groupId"],
      createHumanAgentId: json['createHumanAgentId'],
      createHumanAgentName: json['createHumanAgentName'],
      title: json['title'],
      settingContent: json['settingContent'],
      groupAgents: json['groupAgents'],
      latestActiveAt: DateTime.parse(json['latestActiveAt']),
      latestMsgContent: json['latestMsgContent'],
      unreadCount: json['unreadCount'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      avator: json["avator"] ?? "",
      backdrop: json["backdrop"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'groupId': groupId,
      'createHumanAgentId': createHumanAgentId,
      'createHumanAgentName': createHumanAgentName,
      'title': title,
      'settingContent': settingContent,
      'groupAgents': groupAgents,
      'latestActiveAt': latestActiveAt.toIso8601String(),
      'latestMsgContent': latestMsgContent,
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'avator': avator,
      'backdrop': backdrop,
    };
  }

  GroupChat copyWith({
    String? title,
    DateTime? latestActiveAt,
    String? latestMsgContent,
    int? unreadCount,
    bool? isPinned,
    String? avatar,
  }) {
    return GroupChat(
      userId: userId,
      userName: userName,
      groupId: groupId,
      createHumanAgentId: createHumanAgentId,
      createHumanAgentName: createHumanAgentName,
      title: title ?? this.title,
      settingContent: settingContent,
      groupAgents: groupAgents,
      latestActiveAt: latestActiveAt ?? this.latestActiveAt,
      latestMsgContent: latestMsgContent ?? this.latestMsgContent,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      avator: avatar ?? avator,
      backdrop: backdrop,
    );
  }
}
