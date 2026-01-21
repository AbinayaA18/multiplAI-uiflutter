class ChatMessage {
  final String id;
  final String agentId;
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.agentId,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'agentId': agentId,
        'text': text,
        'isUser': isUser,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        agentId: json['agentId'] as String,
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
