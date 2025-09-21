// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_assistant_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) => AIMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      userId: json['userId'] as String?,
      sender: $enumDecode(_$MessageSenderEnumMap, json['sender']),
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      quickReplies: (json['quickReplies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      actionId: json['actionId'] as String?,
      requiresConfirmation: json['requiresConfirmation'] as bool? ?? false,
      isConfirmed: json['isConfirmed'] as bool? ?? false,
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
    );

Map<String, dynamic> _$AIMessageToJson(AIMessage instance) => <String, dynamic>{
      'id': instance.id,
      'conversationId': instance.conversationId,
      'userId': instance.userId,
      'sender': _$MessageSenderEnumMap[instance.sender]!,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'metadata': instance.metadata,
      'isRead': instance.isRead,
      'timestamp': instance.timestamp.toIso8601String(),
      'quickReplies': instance.quickReplies,
      'actionId': instance.actionId,
      'requiresConfirmation': instance.requiresConfirmation,
      'isConfirmed': instance.isConfirmed,
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
    };

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.assistant: 'assistant',
  MessageSender.system: 'system',
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.suggestion: 'suggestion',
  MessageType.actionRequired: 'action_required',
  MessageType.transactionUpdate: 'transaction_update',
  MessageType.platformUpdate: 'platform_update',
};
