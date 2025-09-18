import 'package:json_annotation/json_annotation.dart';

part 'ai_assistant_message_model.g.dart';

enum MessageSender {
  @JsonValue('user')
  user,
  @JsonValue('assistant')
  assistant,
  @JsonValue('system')
  system,
}

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('suggestion')
  suggestion,
  @JsonValue('action_required')
  actionRequired,
  @JsonValue('transaction_update')
  transactionUpdate,
  @JsonValue('platform_update')
  platformUpdate,
}

@JsonSerializable()
class AIMessage {
  final String id;
  final String conversationId;
  final String? userId;
  final MessageSender sender;
  final MessageType type;
  final String content;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final String? actionId;
  final bool requiresConfirmation;
  final bool isConfirmed;
  final DateTime? confirmedAt;

  AIMessage({
    required this.id,
    required this.conversationId,
    this.userId,
    required this.sender,
    this.type = MessageType.text,
    required this.content,
    this.metadata,
    this.isRead = false,
    DateTime? timestamp,
    this.quickReplies,
    this.actionId,
    this.requiresConfirmation = false,
    this.isConfirmed = false,
    this.confirmedAt,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AIMessage.fromJson(Map<String, dynamic> json) => _$AIMessageFromJson(json);
  Map<String, dynamic> toJson() => _$AIMessageToJson(this);

  AIMessage copyWith({
    String? id,
    String? conversationId,
    String? userId,
    MessageSender? sender,
    MessageType? type,
    String? content,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? timestamp,
    List<String>? quickReplies,
    String? actionId,
    bool? requiresConfirmation,
    bool? isConfirmed,
    DateTime? confirmedAt,
  }) {
    return AIMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      quickReplies: quickReplies ?? this.quickReplies,
      actionId: actionId ?? this.actionId,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      confirmedAt: confirmedAt ?? this.confirmedAt,
    );
  }

  bool get isFromUser => sender == MessageSender.user;
  bool get isFromAssistant => sender == MessageSender.assistant;
  bool get isSystemMessage => sender == MessageSender.system;
  bool get hasQuickReplies => quickReplies?.isNotEmpty ?? false;
  bool get isActionRequired => requiresConfirmation && !isConfirmed;
}
