import * as admin from 'firebase-admin';
import { Injectable } from 'typedi';
import { PrismaClient, NotificationType, DeviceType } from '@prisma/client';
import { container } from 'typedi';

export interface NotificationPayload {
  title: string;
  message: string;
  type: NotificationType;
  userId: string;
  data?: Record<string, any>;
  priority?: 'high' | 'normal';
  ttl?: number; // Time to live in seconds
}

export interface NotificationResult {
  success: boolean;
  messageId?: string;
  error?: string;
  deviceTokens: string[];
  successfulTokens: string[];
  failedTokens: string[];
}

@Injectable()
export class NotificationService {
  private firebaseApp: admin.app.App;
  private prisma: PrismaClient;

  constructor() {
    this.prisma = container.get<PrismaClient>('PrismaClient');

    // Initialize Firebase Admin SDK
    if (!admin.apps.length) {
      this.initializeFirebase();
    } else {
      this.firebaseApp = admin.apps[0]!;
    }
  }

  private initializeFirebase() {
    try {
      // In a real application, you would load this from environment variables
      // For now, we'll initialize with a placeholder that would need to be configured
      const serviceAccount = {
        type: "service_account",
        project_id: process.env.FIREBASE_PROJECT_ID || "funding-machine",
        private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
        private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        client_email: process.env.FIREBASE_CLIENT_EMAIL,
        client_id: process.env.FIREBASE_CLIENT_ID,
        auth_uri: "https://accounts.google.com/o/oauth2/auth",
        token_uri: "https://oauth2.googleapis.com/token",
        auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
        client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL
      };

      this.firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
        projectId: serviceAccount.project_id
      });

      console.log('✅ Firebase Admin SDK initialized for notifications');
    } catch (error) {
      console.error('❌ Failed to initialize Firebase Admin SDK:', error);
      // For development/testing, we'll create a mock implementation
      this.firebaseApp = admin.initializeApp({
        projectId: "funding-machine-dev"
      }, 'mock-app');
      console.log('✅ Using mock Firebase app for development');
    }
  }

  /**
   * Send push notification to a specific user
   */
  async sendToUser(payload: NotificationPayload): Promise<NotificationResult> {
    try {
      // Get user's active device tokens
      const userDevices = await this.prisma.userDevice.findMany({
        where: {
          userId: payload.userId,
          isActive: true
        }
      });

      if (userDevices.length === 0) {
        console.log(`No active devices found for user ${payload.userId}`);
        return {
          success: false,
          error: 'No active devices found for user',
          deviceTokens: [],
          successfulTokens: [],
          failedTokens: []
        };
      }

      const deviceTokens = userDevices.map(device => device.deviceToken);

      // Prepare notification payload
      const message = this.buildNotificationMessage(payload, deviceTokens);

      // Send notification
      const result = await this.sendMulticastNotification(message);

      // Store notification in database
      await this.storeNotification(payload, result);

      // Update device last seen
      await this.updateDeviceLastSeen(payload.userId);

      return result;
    } catch (error) {
      console.error('Error sending notification to user:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        deviceTokens: [],
        successfulTokens: [],
        failedTokens: []
      };
    }
  }

  /**
   * Send notification to multiple users
   */
  async sendToMultipleUsers(payload: NotificationPayload, userIds: string[]): Promise<NotificationResult[]> {
    const results: NotificationResult[] = [];

    for (const userId of userIds) {
      const userPayload = { ...payload, userId };
      const result = await this.sendToUser(userPayload);
      results.push(result);
    }

    return results;
  }

  /**
   * Send notification to all users (broadcast)
   */
  async broadcastToAllUsers(payload: NotificationPayload): Promise<NotificationResult> {
    try {
      // Get all active device tokens
      const allDevices = await this.prisma.userDevice.findMany({
        where: { isActive: true },
        include: { user: true }
      });

      if (allDevices.length === 0) {
        return {
          success: false,
          error: 'No active devices found',
          deviceTokens: [],
          successfulTokens: [],
          failedTokens: []
        };
      }

      const deviceTokens = allDevices.map(device => device.deviceToken);

      // Prepare notification payload
      const message = this.buildNotificationMessage(payload, deviceTokens);

      // Send notification
      const result = await this.sendMulticastNotification(message);

      // Store notification for all users
      for (const device of allDevices) {
        const userPayload = { ...payload, userId: device.userId };
        await this.storeNotification(userPayload, result);
      }

      return result;
    } catch (error) {
      console.error('Error broadcasting notification:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        deviceTokens: [],
        successfulTokens: [],
        failedTokens: []
      };
    }
  }

  /**
   * Register device token for push notifications
   */
  async registerDeviceToken(userId: string, deviceToken: string, deviceType: DeviceType): Promise<boolean> {
    try {
      // Check if device already exists
      const existingDevice = await this.prisma.userDevice.findUnique({
        where: {
          userId_deviceToken: {
            userId,
            deviceToken
          }
        }
      });

      if (existingDevice) {
        // Update last seen and mark as active
        await this.prisma.userDevice.update({
          where: { id: existingDevice.id },
          data: {
            isActive: true,
            lastSeen: new Date()
          }
        });
        return true;
      }

      // Create new device record
      await this.prisma.userDevice.create({
        data: {
          userId,
          deviceToken,
          deviceType,
          isActive: true,
          lastSeen: new Date()
        }
      });

      console.log(`✅ Device registered for user ${userId}: ${deviceType}`);
      return true;
    } catch (error) {
      console.error('Error registering device token:', error);
      return false;
    }
  }

  /**
   * Unregister device token
   */
  async unregisterDeviceToken(userId: string, deviceToken: string): Promise<boolean> {
    try {
      const result = await this.prisma.userDevice.updateMany({
        where: {
          userId,
          deviceToken
        },
        data: {
          isActive: false
        }
      });

      console.log(`✅ Device unregistered for user ${userId}`);
      return result.count > 0;
    } catch (error) {
      console.error('Error unregistering device token:', error);
      return false;
    }
  }

  /**
   * Update user's notification settings
   */
  async updateNotificationSettings(
    userId: string,
    settings: {
      pushEnabled?: boolean;
      emailEnabled?: boolean;
      smsEnabled?: boolean;
      fundingUpdates?: boolean;
      transactionAlerts?: boolean;
      systemAlerts?: boolean;
      marketingEmails?: boolean;
    }
  ): Promise<boolean> {
    try {
      // Check if settings exist
      const existingSettings = await this.prisma.notificationSettings.findUnique({
        where: { userId }
      });

      if (existingSettings) {
        // Update existing settings
        await this.prisma.notificationSettings.update({
          where: { userId },
          data: settings
        });
      } else {
        // Create new settings
        await this.prisma.notificationSettings.create({
          data: {
            userId,
            ...settings
          }
        });
      }

      console.log(`✅ Notification settings updated for user ${userId}`);
      return true;
    } catch (error) {
      console.error('Error updating notification settings:', error);
      return false;
    }
  }

  /**
   * Get user's notification settings
   */
  async getNotificationSettings(userId: string) {
    try {
      const settings = await this.prisma.notificationSettings.findUnique({
        where: { userId }
      });

      if (!settings) {
        // Return default settings
        return {
          pushEnabled: true,
          emailEnabled: true,
          smsEnabled: false,
          fundingUpdates: true,
          transactionAlerts: true,
          systemAlerts: true,
          marketingEmails: false
        };
      }

      return settings;
    } catch (error) {
      console.error('Error getting notification settings:', error);
      return null;
    }
  }

  /**
   * Mark notification as read
   */
  async markAsRead(notificationId: string, userId: string): Promise<boolean> {
    try {
      const result = await this.prisma.notification.updateMany({
        where: {
          id: notificationId,
          userId
        },
        data: {
          isRead: true,
          readAt: new Date()
        }
      });

      return result.count > 0;
    } catch (error) {
      console.error('Error marking notification as read:', error);
      return false;
    }
  }

  /**
   * Get user's notifications
   */
  async getUserNotifications(userId: string, limit: number = 50, offset: number = 0) {
    try {
      return await this.prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset
      });
    } catch (error) {
      console.error('Error getting user notifications:', error);
      return [];
    }
  }

  /**
   * Clean up expired notifications
   */
  async cleanupExpiredNotifications(): Promise<number> {
    try {
      const result = await this.prisma.notification.deleteMany({
        where: {
          expiresAt: {
            lt: new Date()
          }
        }
      });

      console.log(`✅ Cleaned up ${result.count} expired notifications`);
      return result.count;
    } catch (error) {
      console.error('Error cleaning up expired notifications:', error);
      return 0;
    }
  }

  /**
   * Clean up inactive devices (older than 30 days)
   */
  async cleanupInactiveDevices(): Promise<number> {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const result = await this.prisma.userDevice.updateMany({
        where: {
          isActive: true,
          lastSeen: {
            lt: thirtyDaysAgo
          }
        },
        data: {
          isActive: false
        }
      });

      console.log(`✅ Marked ${result.count} inactive devices as inactive`);
      return result.count;
    } catch (error) {
      console.error('Error cleaning up inactive devices:', error);
      return 0;
    }
  }

  // Private helper methods

  private buildNotificationMessage(payload: NotificationPayload, tokens: string[]) {
    const message: admin.messaging.MulticastMessage = {
      tokens,
      notification: {
        title: payload.title,
        body: payload.message
      },
      data: {
        type: payload.type,
        userId: payload.userId,
        timestamp: new Date().toISOString(),
        ...payload.data
      },
      android: {
        priority: payload.priority || 'high',
        ttl: payload.ttl || 3600000, // 1 hour default
        notification: {
          channelId: 'funding_machine_notifications',
          priority: payload.priority === 'high' ? 'high' : 'default',
          defaultSound: true,
          defaultVibrateTimings: true
        }
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: payload.title,
              body: payload.message
            },
            sound: 'default',
            badge: 1
          }
        }
      }
    };

    return message;
  }

  private async sendMulticastNotification(message: admin.messaging.MulticastMessage): Promise<NotificationResult> {
    try {
      const result = await this.firebaseApp.messaging().sendMulticast(message);

      const successfulTokens: string[] = [];
      const failedTokens: string[] = [];

      // Process responses
      result.responses.forEach((response, index) => {
        if (response.success) {
          successfulTokens.push(message.tokens![index]);
        } else {
          failedTokens.push(message.tokens![index]);
          console.error(`Failed to send to token ${message.tokens![index]}:`, response.error);
        }
      });

      return {
        success: failedTokens.length === 0,
        messageId: result.responses[0]?.messageId,
        deviceTokens: message.tokens || [],
        successfulTokens,
        failedTokens
      };
    } catch (error) {
      console.error('Error sending multicast notification:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        deviceTokens: message.tokens || [],
        successfulTokens: [],
        failedTokens: message.tokens || []
      };
    }
  }

  private async storeNotification(payload: NotificationPayload, result: NotificationResult): Promise<void> {
    try {
      const expiresAt = payload.ttl ? new Date(Date.now() + payload.ttl * 1000) : null;

      await this.prisma.notification.create({
        data: {
          userId: payload.userId,
          type: payload.type,
          title: payload.title,
          message: payload.message,
          data: payload.data || {},
          isDelivered: result.successfulTokens.length > 0,
          deliveredAt: result.success ? new Date() : null,
          expiresAt
        }
      });
    } catch (error) {
      console.error('Error storing notification:', error);
    }
  }

  private async updateDeviceLastSeen(userId: string): Promise<void> {
    try {
      await this.prisma.userDevice.updateMany({
        where: { userId, isActive: true },
        data: { lastSeen: new Date() }
      });
    } catch (error) {
      console.error('Error updating device last seen:', error);
    }
  }
}
