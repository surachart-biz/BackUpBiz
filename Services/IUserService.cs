using BizConnect.Models;

namespace BizConnect.Services
{
    public interface IUserService
    {
        Task<User?> GetUserByIdAsync(int userId);
        Task<User?> GetUserByUsernameAsync(string username);
        Task<User?> GetUserByEmailAsync(string email);
        Task<IEnumerable<User>> GetAllUsersAsync();
        Task<User> CreateUserAsync(User user);
        Task<User> UpdateUserAsync(User user);
        Task<bool> DeleteUserAsync(int userId);
        Task<bool> UserExistsAsync(string username);
        Task<bool> EmailExistsAsync(string email);
        Task<bool> IsUserActiveAsync(int userId);
    }
}
