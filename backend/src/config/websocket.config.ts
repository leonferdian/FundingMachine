import { Server as SocketServer } from 'socket.io';
import { Socket } from 'socket.io';
import { Server as HTTPServer } from 'http';
import { PrismaClient } from '@prisma/client';
import { container } from 'typedi';
import jwt from 'jsonwebtoken';
import config from './config';

export interface AuthenticatedSocket extends Socket {
  userId?: string;
  userEmail?: string;
}

class WebSocketManager {
  private io: SocketServer;
  private prisma: PrismaClient;

  constructor(server: HTTPServer) {
    this.prisma = container.get<PrismaClient>('PrismaClient');

    // Initialize Socket.IO with CORS configuration
    this.io = new SocketServer(server, {
      cors: {
        origin: config.cors.allowedOrigins,
        credentials: config.cors.credentials,
        methods: config.cors.methods,
        allowedHeaders: config.cors.allowedHeaders
      },
      transports: ['websocket', 'polling'] // Support both WebSocket and polling
    });

    this.setupMiddleware();
    this.setupEventHandlers();
    this.setupConnectionLogging();

    console.log('🔌 WebSocket server initialized');
  }

  private setupMiddleware() {
    // Authentication middleware for Socket.IO
    this.io.use(async (socket: AuthenticatedSocket, next) => {
      try {
        const token = socket.handshake.auth.token || socket.handshake.query.token as string;

        if (!token) {
          return next(new Error('Authentication token required'));
        }

        // Verify JWT token
        const decoded = jwt.verify(token, config.jwt.secret) as any;

        // Get user from database to verify they still exist
        const user = await this.prisma.user.findUnique({
          where: { id: decoded.id },
          select: { id: true, email: true, name: true }
        });

        if (!user) {
          return next(new Error('User not found'));
        }

        // Attach user info to socket
        socket.userId = user.id;
        socket.userEmail = user.email;

        console.log(`🔐 WebSocket authenticated for user: ${user.email}`);
        next();
      } catch (error) {
        console.error('WebSocket authentication error:', error);
        next(new Error('Authentication failed'));
      }
    });
  }

  private setupEventHandlers() {
    // Handle client connections
    this.io.on('connection', (socket: AuthenticatedSocket) => {
      console.log(`📱 Client connected: ${socket.id} (User: ${socket.userEmail})`);

      // Join user to their personal room
      if (socket.userId) {
        socket.join(`user_${socket.userId}`);
        console.log(`👥 User ${socket.userEmail} joined personal room`);
      }

      // Handle client disconnections
      socket.on('disconnect', (reason) => {
        console.log(`📱 Client disconnected: ${socket.id} (${socket.userEmail}) - Reason: ${reason}`);
      });

      // Handle ping/pong for connection health
      socket.on('ping', () => {
        socket.emit('pong', { timestamp: new Date().toISOString() });
      });

      // Handle custom events
      this.setupCustomEvents(socket);
    });
  }

  private setupCustomEvents(socket: AuthenticatedSocket) {
    // Real-time funding updates
    socket.on('subscribe_to_funding_updates', async () => {
      if (!socket.userId) return;

      socket.join('funding_updates');
      socket.emit('subscribed_to_funding_updates', {
        message: 'Successfully subscribed to funding updates',
        timestamp: new Date().toISOString()
      });
    });

    socket.on('unsubscribe_from_funding_updates', () => {
      socket.leave('funding_updates');
      socket.emit('unsubscribed_from_funding_updates', {
        message: 'Successfully unsubscribed from funding updates',
        timestamp: new Date().toISOString()
      });
    });

    // Real-time notification updates
    socket.on('subscribe_to_notifications', async () => {
      if (!socket.userId) return;

      socket.join(`notifications_${socket.userId}`);
      socket.emit('subscribed_to_notifications', {
        message: 'Successfully subscribed to notifications',
        timestamp: new Date().toISOString()
      });
    });

    // User activity tracking
    socket.on('user_activity', async (data: { action: string; details?: any }) => {
      if (!socket.userId || !socket.userEmail) return;

      console.log(`👤 User activity: ${socket.userEmail} - ${data.action}`);

      // Here you could store user activity in database for analytics
      // await this.prisma.userActivity.create({
      //   data: {
      //     userId: socket.userId,
      //     action: data.action,
      //     details: data.details,
      //     timestamp: new Date()
      //   }
      // });
    });
  }

  private setupConnectionLogging() {
    // Log connection statistics every 30 seconds
    setInterval(() => {
      const connectedClients = this.io.sockets.sockets.size;
      const rooms = this.io.sockets.adapter.rooms;

      console.log(`📊 WebSocket Stats: ${connectedClients} connected clients`);
      console.log(`🏠 Active rooms: ${Array.from(rooms.keys()).length}`);
    }, 30000);
  }

  // Method to emit events to specific users or rooms
  public emitToUser(userId: string, event: string, data: any) {
    this.io.to(`user_${userId}`).emit(event, {
      ...data,
      timestamp: new Date().toISOString()
    });
  }

  public emitToRoom(room: string, event: string, data: any) {
    this.io.to(room).emit(event, {
      ...data,
      timestamp: new Date().toISOString()
    });
  }

  public emitToAll(event: string, data: any) {
    this.io.emit(event, {
      ...data,
      timestamp: new Date().toISOString()
    });
  }

  // Method to broadcast funding updates
  public broadcastFundingUpdate(updateData: {
    type: 'new_platform' | 'platform_updated' | 'transaction_completed' | 'status_changed';
    platformId?: string;
    userId?: string;
    data: any;
  }) {
    this.emitToRoom('funding_updates', 'funding_update', updateData);

    // Also notify specific user if applicable
    if (updateData.userId) {
      this.emitToUser(updateData.userId, 'personal_funding_update', updateData);
    }
  }

  // Method to send notifications
  public sendNotification(userId: string, notification: {
    type: 'info' | 'success' | 'warning' | 'error';
    title: string;
    message: string;
    data?: any;
  }) {
    this.emitToUser(userId, 'notification', notification);
    this.emitToRoom(`notifications_${userId}`, 'notification', notification);
  }

  // Get connected clients count
  public getConnectedClientsCount(): number {
    return this.io.sockets.sockets.size;
  }

  // Get socket instance for testing or direct access
  public getIO(): SocketServer {
    return this.io;
  }
}
