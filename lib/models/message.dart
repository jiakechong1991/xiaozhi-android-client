enum MessageRole { user, assistant, system }

class Message {
  // 代表agent和agent之间发送的消息
  final String messageId;
  final String conversationId;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isImage;
  final String? imageLocalPath;
  final String? fileId;

  Message({
    required this.messageId, // 消息id
    required this.conversationId, // 聊天的agent
    required this.role, // 角色（user or assistant or system）
    required this.content, // 消息内容
    required this.timestamp, // 时间戳
    this.isRead = false,
    this.isImage = false,
    this.imageLocalPath,
    this.fileId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      conversationId: json['conversationId'],
      role: MessageRole.values.byName(json['role']),
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      isImage: json['isImage'] ?? false,
      imageLocalPath: json['imageLocalPath'],
      fileId: json['fileId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'conversationId': conversationId,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isImage': isImage,
      'imageLocalPath': imageLocalPath,
      'fileId': fileId,
    };
  }
}
