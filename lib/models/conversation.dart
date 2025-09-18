enum ConversationType { dify, xiaozhi }

// agent对话的数据结构
class Conversation {
  final String userName;
  final String agentId; // agent_id
  final String agentName; // 与agent_name的对话
  final ConversationType type;
  final String configId; // server类型 现在固定是Xiaozhi
  final DateTime lastMessageTime;
  final String lastMessage; // 最后一条消息
  final int unreadCount;
  final bool isPinned;

  Conversation({
    // 构造函数
    required this.userName,
    required this.agentId,
    required this.agentName,
    required this.type,
    this.configId = '',
    required this.lastMessageTime,
    required this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
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
    );
  }
}
