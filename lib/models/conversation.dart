enum ConversationType { dify, xiaozhi }

enum AgentType {
  human,
  ai,
  npc;

  // 静态方法，从字符串 创建 类型实例
  static AgentType fromString(String value) {
    return AgentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown agent type: $value'),
    );
  }
}

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
  final List<AgentRoleSummary> groupAgents; // 剧场组中的agent演员列表
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
    required dynamic groupAgents,
    required this.latestActiveAt,
    required this.latestMsgContent,
    this.unreadCount = 0,
    this.isPinned = false,
    required this.avator,
    required this.backdrop,
  }) : groupAgents = _normalizeGroupAgents(groupAgents);

  // 私有辅助方法：统一处理 groupAgents 输入
  static List<AgentRoleSummary> _normalizeGroupAgents(dynamic input) {
    if (input is List<AgentRoleSummary>) {
      return List<AgentRoleSummary>.from(input);
    } else if (input is List) {
      return input
          .where((e) => e != null)
          .map((e) => AgentRoleSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // 非 List 类型，返回空列表（或可抛异常）
      return [];
    }
  }

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
      groupAgents: _normalizeGroupAgents(json['groupAgents']),
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
      'groupAgents': groupAgents.map((agent) => agent.toJson()).toList(),
      'latestActiveAt': latestActiveAt.toIso8601String(),
      'latestMsgContent': latestMsgContent,
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'avator': avator,
      'backdrop': backdrop,
    };
  }

  // 其实就是复制一个GroupChat，主要用于设置是否置顶/添加消息
  GroupChat copyWith({
    int? unreadCount,
    String? latestMsgContent,
    DateTime? latestActiveAt, // 最后一条消息的时间
    bool? isPinned,
  }) {
    return GroupChat(
      userId: userId,
      userName: userName,
      groupId: groupId,
      createHumanAgentId: createHumanAgentId,
      createHumanAgentName: createHumanAgentName,
      title: title,
      settingContent: settingContent,
      groupAgents: groupAgents,
      latestActiveAt: latestActiveAt ?? this.latestActiveAt,
      latestMsgContent: latestMsgContent ?? this.latestMsgContent,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      avator: avator,
      backdrop: backdrop,
    );
  }
}

// AgentRoleSummary演员 对应的数据结构
class AgentRoleSummary {
  final String agentId; // agent的ID
  final String agentName; // 创建的agent的Name
  final AgentType agentType; // agent的类型
  AgentRoleSummary({
    // 构造函数
    required this.agentId,
    required this.agentName,
    required this.agentType,
  });

  // 创建GroupChat
  factory AgentRoleSummary.fromJson(Map<String, dynamic> json) {
    return AgentRoleSummary(
      agentId: json['agent_id'].toString(),
      agentName: json['agent_name'],
      agentType: AgentType.fromString(json['agent_type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'agentName': agentName,
      'agentType': agentType.name,
    };
  }
}

// AgentRole演员 对应的数据结构
class AgentRole {
  final String agentId; // agent的ID
  final String agentName; // 创建的agent的Name
  final AgentType agentType; // agent的类型
  final bool isDefault; // 是否是默认角色
  final String avatar; // 演员头像图片
  final String sex; // 性别
  final String voices; // 声音类型
  final String birthday; // 生日
  final int age; // 年龄
  final bool isPinned; // 是否置顶
  final String characterSetting; // 演员设定

  AgentRole({
    // 构造函数
    required this.agentId,
    required this.agentName,
    required this.agentType,
    required this.isDefault,
    required this.avatar,
    required this.sex,
    required this.voices,
    required this.birthday,
    required this.age,
    this.isPinned = false,
    required this.characterSetting,
  });

  // 创建GroupChat
  factory AgentRole.fromJson(Map<String, dynamic> json) {
    return AgentRole(
      agentId: json['agentId'],
      agentName: json['agentName'],
      agentType: json['agentType'],
      isDefault: json['isDefault'],
      avatar: json["avatar"],
      sex: json["sex"],
      voices: json["voices"],
      birthday: json["birthday"],
      age: json["age"],
      isPinned: json['isPinned'] ?? false,
      characterSetting: json["characterSetting"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agentId': agentId,
      'agentName': agentName,
      'agentType': agentType.name,
      'isDefault': isDefault,
      'avatar': avatar,
      'sex': sex,
      'voices': voices,
      'birthday': birthday,
      'age': age,
      'isPinned': isPinned,
      'characterSetting': characterSetting,
    };
  }

  AgentRole copyWith({bool? isPinned}) {
    return AgentRole(
      agentId: agentId,
      agentName: agentName,
      agentType: agentType,
      isDefault: isDefault,
      avatar: avatar,
      sex: sex,
      voices: voices,
      birthday: birthday,
      age: age,
      characterSetting: characterSetting,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
