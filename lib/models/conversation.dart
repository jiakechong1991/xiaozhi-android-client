enum ConversationType { dify, xiaozhi }

// agent对话的数据结构
class Conversation {
  final String agent_id; // agent_id
  final String title; // 与agent_name的对话
  final ConversationType type;
  final String configId; // server类型 现在固定是Xiaozhi
  final DateTime lastMessageTime;
  final String lastMessage; // 最后一条消息
  final int unreadCount;
  final bool isPinned;

  Conversation({
    // 构造函数
    required this.agent_id,
    required this.title,
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
      agent_id: json['agent_id'],
      title: json['title'],
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
      'agent_id': agent_id,
      'title': title,
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
      agent_id: agent_id,
      title: title ?? this.title,
      type: type ?? this.type,
      configId: configId ?? this.configId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
