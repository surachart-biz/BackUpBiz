using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using BizConnect.Data;
using BizConnect.Models;
using BCrypt.Net;

namespace BizConnect.Services
{
    public class AuthenticationService : IAuthenticationService
    {
        private readonly BizConnectDbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly ILogger<AuthenticationService> _logger;

        public AuthenticationService(
            BizConnectDbContext context,
            IHttpContextAccessor httpContextAccessor,
            ILogger<AuthenticationService> logger)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _logger = logger;
        }

        public async Task<User?> ValidateUserAsync(string username, string password)
        {
            try
            {
                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.Username == username && u.IsActive);

                if (user == null)
                {
                    _logger.LogWarning("Login attempt failed: User {Username} not found or inactive", username);
                    return null;
                }

                if (!VerifyPassword(password, user.PasswordHash))
                {
                    _logger.LogWarning("Login attempt failed: Invalid password for user {Username}", username);
                    return null;
                }

                _logger.LogInformation("User {Username} validated successfully", username);
                return user;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating user {Username}", username);
                return null;
            }
        }

        public async Task<bool> SignInAsync(User user, bool rememberMe = false)
        {
            try
            {
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                    new Claim(ClaimTypes.Name, user.Username),
                    new Claim(ClaimTypes.Email, user.Email ?? string.Empty),
                    new Claim(ClaimTypes.GivenName, user.FirstName ?? string.Empty),
                    new Claim(ClaimTypes.Surname, user.LastName ?? string.Empty),
                    new Claim("FullName", user.FullName)
                };

                var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

                var authProperties = new AuthenticationProperties
                {
                    IsPersistent = rememberMe,
                    ExpiresUtc = rememberMe ? DateTimeOffset.UtcNow.AddDays(30) : DateTimeOffset.UtcNow.AddHours(1)
                };

                var httpContext = _httpContextAccessor.HttpContext;
                if (httpContext != null)
                {
                    await httpContext.SignInAsync(
                        CookieAuthenticationDefaults.AuthenticationScheme,
                        claimsPrincipal,
                        authProperties);

                    await UpdateLastLoginAsync(user.UserId);
                    _logger.LogInformation("User {Username} signed in successfully", user.Username);
                    return true;
                }

                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error signing in user {Username}", user.Username);
                return false;
            }
        }

        public async Task SignOutAsync()
        {
            try
            {
                var httpContext = _httpContextAccessor.HttpContext;
                if (httpContext != null)
                {
                    var username = httpContext.User.Identity?.Name;
                    await httpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                    _logger.LogInformation("User {Username} signed out successfully", username);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error signing out user");
            }
        }

        public Task<ClaimsPrincipal?> GetCurrentUserAsync()
        {
            var httpContext = _httpContextAccessor.HttpContext;
            return Task.FromResult(httpContext?.User);
        }

        public async Task UpdateLastLoginAsync(int userId)
        {
            try
            {
                var user = await _context.Users.FindAsync(userId);
                if (user != null)
                {
                    user.LastLoginAt = DateTime.UtcNow;
                    await _context.SaveChangesAsync();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating last login for user {UserId}", userId);
            }
        }

        public bool VerifyPassword(string password, string hashedPassword)
        {
            try
            {
                return BCrypt.Net.BCrypt.Verify(password, hashedPassword);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying password");
                return false;
            }
        }

        public string HashPassword(string password)
        {
            try
            {
                return BCrypt.Net.BCrypt.HashPassword(password, BCrypt.Net.BCrypt.GenerateSalt(12));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error hashing password");
                throw;
            }
        }
    }
}
