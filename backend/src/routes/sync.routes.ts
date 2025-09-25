import { Router } from 'express';
import { SyncController } from '../controllers/sync.controller';

const router = Router();
const syncController = new SyncController();

// Sync routes
router.post('/sync', syncController.syncData.bind(syncController));
router.get('/status', syncController.getSyncStatus.bind(syncController));
router.get('/pending-changes', syncController.getPendingChanges.bind(syncController));
router.post('/force-sync', syncController.forceSync.bind(syncController));
router.get('/conflicts', syncController.getSyncConflicts.bind(syncController));
router.put('/conflicts/:conflictId/resolve', syncController.resolveConflict.bind(syncController));
router.get('/queue/status', syncController.getQueueStatus.bind(syncController));
router.delete('/queue/clear', syncController.clearOfflineQueue.bind(syncController));

export default router;
