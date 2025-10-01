// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineQueueItemAdapter extends TypeAdapter<OfflineQueueItem> {
  @override
  final int typeId = 1;

  @override
  OfflineQueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineQueueItem(
      id: fields[0] as String,
      userId: fields[1] as String,
      entityType: fields[2] as String,
      entityId: fields[3] as String,
      operation: fields[4] as String,
      data: (fields[5] as Map).cast<String, dynamic>(),
      timestamp: fields[6] as DateTime,
      synced: fields[7] as bool,
      syncedAt: fields[8] as DateTime?,
      retryCount: fields[9] as int,
      maxRetries: fields[10] as int,
      nextRetryAt: fields[11] as DateTime?,
      lastError: fields[12] as String?,
      priority: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineQueueItem obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.entityType)
      ..writeByte(3)
      ..write(obj.entityId)
      ..writeByte(4)
      ..write(obj.operation)
      ..writeByte(5)
      ..write(obj.data)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.synced)
      ..writeByte(8)
      ..write(obj.syncedAt)
      ..writeByte(9)
      ..write(obj.retryCount)
      ..writeByte(10)
      ..write(obj.maxRetries)
      ..writeByte(11)
      ..write(obj.nextRetryAt)
      ..writeByte(12)
      ..write(obj.lastError)
      ..writeByte(13)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineQueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflineDataAdapter extends TypeAdapter<OfflineData> {
  @override
  final int typeId = 2;

  @override
  OfflineData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineData(
      id: fields[0] as String,
      userId: fields[1] as String,
      dataType: fields[2] as String,
      data: (fields[3] as Map).cast<String, dynamic>(),
      storedAt: fields[4] as DateTime,
      expiresAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.dataType)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.storedAt)
      ..writeByte(5)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 3;

  @override
  SyncStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncStatus(
      id: fields[0] as String,
      userId: fields[1] as String,
      deviceId: fields[2] as String,
      status: fields[3] as String,
      lastSyncAt: fields[4] as DateTime,
      totalOperations: fields[5] as int,
      successfulOperations: fields[6] as int,
      failedOperations: fields[7] as int,
      errorMessage: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.deviceId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.lastSyncAt)
      ..writeByte(5)
      ..write(obj.totalOperations)
      ..writeByte(6)
      ..write(obj.successfulOperations)
      ..writeByte(7)
      ..write(obj.failedOperations)
      ..writeByte(8)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConflictResolutionStrategyAdapter
    extends TypeAdapter<ConflictResolutionStrategy> {
  @override
  final int typeId = 4;

  @override
  ConflictResolutionStrategy read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConflictResolutionStrategy.serverWins;
      case 1:
        return ConflictResolutionStrategy.clientWins;
      case 2:
        return ConflictResolutionStrategy.merge;
      case 3:
        return ConflictResolutionStrategy.manual;
      default:
        return ConflictResolutionStrategy.serverWins;
    }
  }

  @override
  void write(BinaryWriter writer, ConflictResolutionStrategy obj) {
    switch (obj) {
      case ConflictResolutionStrategy.serverWins:
        writer.writeByte(0);
        break;
      case ConflictResolutionStrategy.clientWins:
        writer.writeByte(1);
        break;
      case ConflictResolutionStrategy.merge:
        writer.writeByte(2);
        break;
      case ConflictResolutionStrategy.manual:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConflictResolutionStrategyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
