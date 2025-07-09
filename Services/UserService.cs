using Microsoft.EntityFrameworkCore;
using BizConnect.Data;
using BizConnect.Models;

namespace BizConnect.Services
{
    public class UserService : IUserService
    {
        private readonly BizConnectDbContext _context;
        private readonly ILogger<UserService> _logger;

        public UserService(BizConnectDbContext context, ILogger<UserService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<User?> GetUserByIdAsync(int userId)
        {
            try
            {
                return await _context.Users
                    .FirstOrDefaultAsync(u => u.UserId == userId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user by ID {UserId}", userId);
                return null;
            }
        }

        public async Task<User?> GetUserByUsernameAsync(string username)
        {
            try
            {
                return await _context.Users
                    .FirstOrDefaultAsync(u => u.Username == username);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user by username {Username}", username);
                return null;
            }
        }

        public async Task<User?> GetUserByEmailAsync(string email)
        {
            try
            {
                return await _context.Users
                    .FirstOrDefaultAsync(u => u.Email == email);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user by email {Email}", email);
                return null;
            }
        }

        public async Task<IEnumerable<User>> GetAllUsersAsync()
        {
            try
            {
                return await _context.Users
                    .OrderBy(u => u.Username)
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting all users");
                return new List<User>();
            }
        }

        public async Task<User> CreateUserAsync(User user)
        {
            try
            {
                user.CreatedAt = DateTime.UtcNow;
                user.UpdatedAt = DateTime.UtcNow;
                
                _context.Users.Add(user);
                await _context.SaveChangesAsync();
                
                _logger.LogInformation("User {Username} created successfully", user.Username);
                return user;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating user {Username}", user.Username);
                throw;
            }
        }

        public async Task<User> UpdateUserAsync(User user)
        {
            try
            {
                user.UpdatedAt = DateTime.UtcNow;
                
                _context.Users.Update(user);
                await _context.SaveChangesAsync();
                
                _logger.LogInformation("User {Username} updated successfully", user.Username);
                return user;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating user {Username}", user.Username);
                throw;
            }
        }

        public async Task<bool> DeleteUserAsync(int userId)
        {
            try
            {
                var user = await _context.Users.FindAsync(userId);
                if (user == null)
                {
                    return false;
                }

                // Soft delete by setting IsActive to false
                user.IsActive = false;
                user.UpdatedAt = DateTime.UtcNow;
                
                await _context.SaveChangesAsync();
                
                _logger.LogInformation("User {Username} deleted successfully", user.Username);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting user {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> UserExistsAsync(string username)
        {
            try
            {
                return await _context.Users
                    .AnyAsync(u => u.Username == username);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if user exists {Username}", username);
                return false;
            }
        }

        public async Task<bool> EmailExistsAsync(string email)
        {
            try
            {
                return await _context.Users
                    .AnyAsync(u => u.Email == email);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if email exists {Email}", email);
                return false;
            }
        }

        public async Task<bool> IsUserActiveAsync(int userId)
        {
            try
            {
                var user = await _context.Users.FindAsync(userId);
                return user?.IsActive ?? false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking if user is active {UserId}", userId);
                return false;
            }
        }
    }
}
