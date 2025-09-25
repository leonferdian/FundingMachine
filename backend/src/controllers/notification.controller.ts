import { JsonController, Get, Post, Put, Delete, Param, Body, Authorized, CurrentUser, BadRequestError } from 'routing-controllers';
import { Inject, Service } from 'typedi';
import { PrismaClient, NotificationType, DeviceType } from '@prisma/client';
import { NotificationService, NotificationPayload } from '../services/notification.service';

@JsonController('/notifications')
@Service()
export class NotificationController {
  @Inject()
  private notificationService!: NotificationService;

  @Inject('PrismaClient')
  private prisma!: PrismaClient;

  /**
   * Get user's notifications
   */
  @Get('/')
  @Authorized()
  async getUserNotifications(
    @CurrentUser() user: any,
    @Body() query: { limit?: number; offset?: number; unreadOnly?: boolean }
  ) {
    try {
      const { limit = 50, offset = 0, unreadOnly = false } = query;

      let whereClause: any = { userId: user.id };
      if (unreadOnly) {
        whereClause.isRead = false;
      }

      const notifications = await this.prisma.notification.findMany({
        where: whereClause,
        orderBy: { createdAt: 'desc' },
        take: limit,
        skip: offset
      });

      const totalCount = await this.prisma.notification.count({
        where: whereClause
      });

      return {
        success: true,
        data: notifications,
        pagination: {
          total: totalCount,
          limit,
          offset,
          hasMore: offset + limit < totalCount
        }
      };
    } catch (error) {
      console.error('Error getting user notifications:', error);
      throw new BadRequestError('Failed to get notifications');
    }
  }

  /**
   * Get notification settings
   */
  @Get('/settings')
  @Authorized()
  async getNotificationSettings(@CurrentUser() user: any) {
    try {
      const settings = await this.notificationService.getNotificationSettings(user.id);

      return {
        success: true,
        data: settings
      };
    } catch (error) {
      console.error('Error getting notification settings:', error);
      throw new BadRequestError('Failed to get notification settings');
    }
  }

  /**
   * Update notification settings
   */
  @Put('/settings')
  @Authorized()
  async updateNotificationSettings(
    @CurrentUser() user: any,
    @Body() settings: {
      pushEnabled?: boolean;
      emailEnabled?: boolean;
      smsEnabled?: boolean;
      fundingUpdates?: boolean;
      transactionAlerts?: boolean;
      systemAlerts?: boolean;
      marketingEmails?: boolean;
    }
  ) {
    try {
      const success = await this.notificationService.updateNotificationSettings(user.id, settings);

      if (!success) {
        throw new BadRequestError('Failed to update notification settings');
      }

      return {
        success: true,
        message: 'Notification settings updated successfully'
      };
    } catch (error) {
      console.error('Error updating notification settings:', error);
      throw new BadRequestError('Failed to update notification settings');
    }
  }

  /**
   * Mark notification as read
   */
  @Put('/:notificationId/read')
  @Authorized()
  async markAsRead(
    @Param('notificationId') notificationId: string,
    @CurrentUser() user: any
  ) {
    try {
      const success = await this.notificationService.markAsRead(notificationId, user.id);

      if (!success) {
        throw new BadRequestError('Notification not found or already read');
      }

      return {
        success: true,
        message: 'Notification marked as read'
      };
    } catch (error) {
      console.error('Error marking notification as read:', error);
      throw new BadRequestError('Failed to mark notification as read');
    }
  }

  /**
   * Mark all notifications as read
   */
  @Put('/mark-all-read')
  @Authorized()
  async markAllAsRead(@CurrentUser() user: any) {
    try {
      const result = await this.prisma.notification.updateMany({
        where: {
          userId: user.id,
          isRead: false
        },
        data: {
          isRead: true,
          readAt: new Date()
        }
      });

      return {
        success: true,
        message: `${result.count} notifications marked as read`
      };
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      throw new BadRequestError('Failed to mark notifications as read');
    }
  }

  /**
   * Delete notification
   */
  @Delete('/:notificationId')
  @Authorized()
  async deleteNotification(
    @Param('notificationId') notificationId: string,
    @CurrentUser() user: any
  ) {
    try {
      const result = await this.prisma.notification.deleteMany({
        where: {
          id: notificationId,
          userId: user.id
        }
      });

      if (result.count === 0) {
        throw new BadRequestError('Notification not found');
      }

      return {
        success: true,
        message: 'Notification deleted successfully'
      };
    } catch (error) {
      console.error('Error deleting notification:', error);
      throw new BadRequestError('Failed to delete notification');
    }
  }

  /**
   * Register device token for push notifications
   */
  @Post('/register-device')
  @Authorized()
  async registerDeviceToken(
    @CurrentUser() user: any,
    @Body() body: { deviceToken: string; deviceType: DeviceType }
  ) {
    try {
      const { deviceToken, deviceType } = body;

      if (!deviceToken) {
        throw new BadRequestError('Device token is required');
      }

      const success = await this.notificationService.registerDeviceToken(
        user.id,
        deviceToken,
        deviceType
      );

      if (!success) {
        throw new BadRequestError('Failed to register device token');
      }

      return {
        success: true,
        message: 'Device token registered successfully'
      };
    } catch (error) {
      console.error('Error registering device token:', error);
      throw new BadRequestError('Failed to register device token');
    }
  }

  /**
   * Unregister device token
   */
  @Post('/unregister-device')
  @Authorized()
  async unregisterDeviceToken(
    @CurrentUser() user: any,
    @Body() body: { deviceToken: string }
  ) {
    try {
      const { deviceToken } = body;

      if (!deviceToken) {
        throw new BadRequestError('Device token is required');
      }

      const success = await this.notificationService.unregisterDeviceToken(
        user.id,
        deviceToken
      );

      if (!success) {
        throw new BadRequestError('Failed to unregister device token');
      }

      return {
        success: true,
        message: 'Device token unregistered successfully'
      };
    } catch (error) {
      console.error('Error unregistering device token:', error);
      throw new BadRequestError('Failed to unregister device token');
    }
  }

  /**
   * Send test notification (for development)
   */
  @Post('/test')
  @Authorized()
  async sendTestNotification(
    @CurrentUser() user: any,
    @Body() body: { title?: string; message?: string; type?: NotificationType }
  ) {
    try {
      const { title = 'Test Notification', message = 'This is a test notification', type = 'SYSTEM_ALERT' } = body;

      const payload: NotificationPayload = {
        title,
        message,
        type,
        userId: user.id,
        priority: 'high'
      };

      const result = await this.notificationService.sendToUser(payload);

      return {
        success: true,
        message: 'Test notification sent',
        data: result
      };
    } catch (error) {
      console.error('Error sending test notification:', error);
      throw new BadRequestError('Failed to send test notification');
    }
  }

  /**
   * Get notification statistics (for admin)
   */
  @Get('/admin/stats')
  @Authorized(['ADMIN', 'SUPER_ADMIN'])
  async getNotificationStats() {
    try {
      const [
        totalNotifications,
        unreadNotifications,
        notificationsByType,
        recentNotifications
      ] = await Promise.all([
        this.prisma.notification.count(),
        this.prisma.notification.count({ where: { isRead: false } }),
        this.prisma.notification.groupBy({
          by: ['type'],
          _count: { id: true }
        }),
        this.prisma.notification.findMany({
          take: 10,
          orderBy: { createdAt: 'desc' },
          include: { user: { select: { id: true, name: true, email: true } } }
        })
      ]);

      return {
        success: true,
        data: {
          total: totalNotifications,
          unread: unreadNotifications,
          byType: notificationsByType,
          recent: recentNotifications
        }
      };
    } catch (error) {
      console.error('Error getting notification stats:', error);
      throw new BadRequestError('Failed to get notification statistics');
    }
  }

  /**
   * Broadcast notification to all users (for admin)
   */
  @Post('/admin/broadcast')
  @Authorized(['ADMIN', 'SUPER_ADMIN'])
  async broadcastNotification(
    @Body() body: {
      title: string;
      message: string;
      type: NotificationType;
      priority?: 'high' | 'normal';
      ttl?: number;
    }
  ) {
    try {
      const { title, message, type, priority = 'normal', ttl } = body;

      const payload: NotificationPayload = {
        title,
        message,
        type,
        userId: '', // Will be set for each user
        priority,
        ttl
      };

      const result = await this.notificationService.broadcastToAllUsers(payload);

      return {
        success: true,
        message: 'Notification broadcast initiated',
        data: result
      };
    } catch (error) {
      console.error('Error broadcasting notification:', error);
      throw new BadRequestError('Failed to broadcast notification');
    }
  }
}
