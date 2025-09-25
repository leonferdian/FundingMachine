import { Router } from 'express';
import { container } from 'typedi';
import { NotificationController } from '../controllers/notification.controller';

const router = Router();

// Get notification controller instance
const notificationController = container.get(NotificationController);

// User notification routes
router.get('/', (req, res) => notificationController.getUserNotifications(req, res));
router.get('/settings', (req, res) => notificationController.getNotificationSettings(req, res));
router.put('/settings', (req, res) => notificationController.updateNotificationSettings(req, res));
router.put('/:notificationId/read', (req, res) => notificationController.markAsRead(req, res));
router.put('/mark-all-read', (req, res) => notificationController.markAllAsRead(req, res));
router.delete('/:notificationId', (req, res) => notificationController.deleteNotification(req, res));

// Device registration routes
router.post('/register-device', (req, res) => notificationController.registerDeviceToken(req, res));
router.post('/unregister-device', (req, res) => notificationController.unregisterDeviceToken(req, res));

// Test route (development only)
router.post('/test', (req, res) => notificationController.sendTestNotification(req, res));

// Admin routes
router.get('/admin/stats', (req, res) => notificationController.getNotificationStats(req, res));
router.post('/admin/broadcast', (req, res) => notificationController.broadcastNotification(req, res));

export default router;
