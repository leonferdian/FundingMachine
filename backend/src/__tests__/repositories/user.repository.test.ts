import { UserRepository } from '../../repositories/user.repository';
import { prismaMock } from '../setup';
import { User } from '@prisma/client';

// Mock data
const mockUser: User = {
  id: '1',
  email: 'test@example.com',
  phone: '+1234567890',
  password: 'hashedpassword',
  firstName: 'Test',
  lastName: 'User',
  isVerified: false,
  isActive: true,
  lastLogin: null,
  createdAt: new Date(),
  updatedAt: new Date(),
  deletedAt: null,
};

describe('UserRepository', () => {
  let userRepository: UserRepository;

  beforeEach(() => {
    userRepository = new UserRepository(prismaMock);
  });

  describe('findByEmail', () => {
    it('should find a user by email', async () => {
      // Arrange
      prismaMock.user.findUnique.mockResolvedValue(mockUser);

      // Act
      const result = await userRepository.findByEmail('test@example.com');

      // Assert
      expect(result).toEqual(mockUser);
      expect(prismaMock.user.findUnique).toHaveBeenCalledWith({
        where: { email: 'test@example.com' },
      });
    });

    it('should return null when user is not found', async () => {
      // Arrange
      prismaMock.user.findUnique.mockResolvedValue(null);

      // Act
      const result = await userRepository.findByEmail('nonexistent@example.com');

      // Assert
      expect(result).toBeNull();
    });
  });

  describe('updatePassword', () => {
    it('should update user password', async () => {
      // Arrange
      const updatedUser = { ...mockUser, password: 'newhashedpassword' };
      prismaMock.user.update.mockResolvedValue(updatedUser);

      // Act
      const result = await userRepository.updatePassword('1', 'newhashedpassword');

      // Assert
      expect(result).toEqual(updatedUser);
      expect(prismaMock.user.update).toHaveBeenCalledWith({
        where: { id: '1' },
        data: { password: 'newhashedpassword' },
      });
    });
  });

  describe('markAsVerified', () => {
    it('should mark user as verified', async () => {
      // Arrange
      const verifiedUser = { ...mockUser, isVerified: true };
      prismaMock.user.update.mockResolvedValue(verifiedUser);

      // Act
      const result = await userRepository.markAsVerified('1');

      // Assert
      expect(result).toEqual(verifiedUser);
      expect(prismaMock.user.update).toHaveBeenCalledWith({
        where: { id: '1' },
        data: { isVerified: true },
      });
    });
  });
});
