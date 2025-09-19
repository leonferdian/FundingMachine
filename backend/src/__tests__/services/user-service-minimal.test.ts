import 'reflect-metadata';
import { UserService } from '../../services/user.service';

// Minimal test for UserService without any mocks
describe('UserService - Minimal Test', () => {
  it('should be defined', () => {
    // This test verifies we can import the UserService
    expect(UserService).toBeDefined();
  });
});
