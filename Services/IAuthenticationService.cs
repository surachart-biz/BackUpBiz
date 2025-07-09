using BizConnect.Models;
using System.Security.Claims;

namespace BizConnect.Services
{
    public interface IAuthenticationService
    {
        Task<User?> ValidateUserAsync(string username, string password);
        Task<bool> SignInAsync(User user, bool rememberMe = false);
        Task SignOutAsync();
        Task<ClaimsPrincipal?> GetCurrentUserAsync();
        Task UpdateLastLoginAsync(int userId);
        bool VerifyPassword(string password, string hashedPassword);
        string HashPassword(string password);
    }
}
