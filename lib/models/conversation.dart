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

// agent对话的数据结构
class Conversation {
  final String userName;
  final String agentId; // agent_id
  final String agentName; // 与agent_name的对话
  final ConversationType type; // 没用，固定是ConversationType.xiaozhi
  final String configId; // server类型 现在固定是Xiaozhi[0], 这是描述服务器配置的
  final DateTime lastMessageTime;
  final String lastMessage; // 最后一条消息
  final int unreadCount;
  final bool isPinned;
  final String avatorImgUrl; // 头像图片

  Conversation({
    // 构造函数
    required this.userName,
    required this.agentId,
    required this.agentName,
    this.type = ConversationType.xiaozhi,
    this.configId = '0',
    required this.lastMessageTime,
    required this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    required this.avatorImgUrl,
  });

  // 下面是几种 常用方法：
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userName: json['userName'],
      agentId: json['agentId'],
      agentName: json['agentName'],
      type: ConversationType.values.byName(json['type']),
      configId: json['configId'] ?? '',
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      lastMessage: json['lastMessage'],
      unreadCount: json['unreadCount'] ?? 0,
      isPinned: json['isPinned'] ?? false,
      avatorImgUrl: json["avatorImgUrl"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'agentId': agentId,
      'agentName': agentName,
      'type': type.name,
      'configId': configId,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'isPinned': isPinned,
      'avatarImgUrl': avatorImgUrl,
    };
  }

  Conversation copyWith({
    String? title,
    ConversationType? type,
    String? configId,
    DateTime? lastMessageTime,
    String? lastMessage,
    int? unreadCount,
    bool? isPinned,
    String? avatarImgUrl,
  }) {
    return Conversation(
      userName: userName,
      agentId: agentId,
      agentName: title ?? this.agentName,
      type: type ?? this.type,
      configId: configId ?? this.configId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      avatorImgUrl: avatorImgUrl,
    );
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
