/**
 * Sync-related types and interfaces
 */

export type ConflictResolutionStrategy = 'server_wins' | 'client_wins' | 'merge' | 'manual';

export type SyncStatus = 'synced' | 'pending' | 'conflict' | 'error' | 'offline';

export type SyncEntityType = 'funding' | 'transaction' | 'payment_method' | 'user_profile' | 'notification_settings';

export interface SyncMetadata {
  lastSyncTimestamp: Date;
  deviceId: string;
  userId: string;
  syncVersion: number;
  totalChanges: number;
  resolvedConflicts: number;
}

export interface SyncConflict {
  id: string;
  entityType: SyncEntityType;
  entityId: string;
  serverData: any;
  clientData: any;
  conflictFields: string[];
  detectedAt: Date;
  resolved: boolean;
  resolution?: ConflictResolutionStrategy;
  resolvedData?: any;
  resolvedAt?: Date;
  resolvedBy?: string;
}

export interface LocalChange {
  id: string;
  entityType: SyncEntityType;
  entityId: string;
  operation: 'create' | 'update' | 'delete';
  data: any;
  timestamp: Date;
  synced: boolean;
  retryCount: number;
  lastError?: string;
}

export interface SyncRequest {
  userId: string;
  deviceId: string;
  lastSyncTimestamp: Date;
  localChanges: LocalChange[];
  conflictResolution: ConflictResolutionStrategy;
  includeDeleted: boolean;
}

export interface SyncResponse {
  success: boolean;
  syncTimestamp: Date;
  serverChanges: ServerChange[];
  conflicts: SyncConflict[];
  stats: SyncStats;
  error?: string;
}

export interface ServerChange {
  entityType: SyncEntityType;
  entityId: string;
  operation: 'create' | 'update' | 'delete';
  data: any;
  timestamp: Date;
  version: number;
}

export interface SyncStats {
  totalEntities: number;
  syncedEntities: number;
  conflictsResolved: number;
  errors: number;
  syncDuration: number;
}

export interface OfflineQueueItem {
  id: string;
  userId: string;
  deviceId: string;
  operation: 'create' | 'update' | 'delete';
  entityType: SyncEntityType;
  entityId: string;
  data: any;
  timestamp: Date;
  retryCount: number;
  maxRetries: number;
  nextRetryAt: Date;
  lastError?: string;
  priority: 'low' | 'medium' | 'high';
}

export interface SyncStatusInfo {
  userId: string;
  deviceId: string;
  lastSyncAt: Date | null;
  lastSyncStatus: SyncStatus;
  pendingChanges: number;
  unresolvedConflicts: number;
  offlineQueueSize: number;
  syncVersion: number;
  connectionStatus: 'online' | 'offline';
  lastError?: string;
}

export interface DataSyncOptions {
  forceFullSync?: boolean;
  includeDeleted?: boolean;
  conflictResolution?: ConflictResolutionStrategy;
  batchSize?: number;
  timeout?: number;
}

export interface SyncProgress {
  total: number;
  completed: number;
  currentEntity: string;
  currentOperation: string;
  estimatedTimeRemaining: number;
  errors: string[];
}

export interface SyncConfiguration {
  maxRetries: number;
  retryDelayMs: number;
  maxConflictAge: number; // hours
  batchSize: number;
  enableBackgroundSync: boolean;
  syncIntervalMinutes: number;
  maxOfflineQueueSize: number;
  conflictAutoResolve: boolean;
  autoResolveStrategy: ConflictResolutionStrategy;
}

export interface DeviceSyncInfo {
  deviceId: string;
  userId: string;
  deviceType: 'android' | 'ios' | 'web' | 'desktop';
  lastSeen: Date;
  syncStatus: SyncStatus;
  appVersion: string;
  platformVersion: string;
  isActive: boolean;
}
