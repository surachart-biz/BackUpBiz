using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BizConnect.Models.ViewModels;
using BizConnect.Services;

namespace BizConnect.Controllers
{
    public class AccountController : Controller
    {
        private readonly IAuthenticationService _authService;
        private readonly ILogger<AccountController> _logger;

        public AccountController(
            IAuthenticationService authService,
            ILogger<AccountController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult Login(string? returnUrl = null)
        {
            // If user is already authenticated, redirect to home
            if (User.Identity?.IsAuthenticated == true)
            {
                return RedirectToAction("Index", "Home");
            }

            ViewData["ReturnUrl"] = returnUrl;
            return View(new LoginViewModel { ReturnUrl = returnUrl });
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model, string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            try
            {
                var user = await _authService.ValidateUserAsync(model.Username, model.Password);
                
                if (user == null)
                {
                    ModelState.AddModelError(string.Empty, "Invalid username or password.");
                    _logger.LogWarning("Failed login attempt for username: {Username}", model.Username);
                    return View(model);
                }

                var signInResult = await _authService.SignInAsync(user, model.RememberMe);
                
                if (signInResult)
                {
                    _logger.LogInformation("User {Username} logged in successfully", model.Username);
                    
                    if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
                    {
                        return Redirect(returnUrl);
                    }
                    
                    return RedirectToAction("Index", "Home");
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "An error occurred during sign in. Please try again.");
                    return View(model);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during login for username: {Username}", model.Username);
                ModelState.AddModelError(string.Empty, "An unexpected error occurred. Please try again.");
                return View(model);
            }
        }

        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            try
            {
                var username = User.Identity?.Name;
                await _authService.SignOutAsync();
                _logger.LogInformation("User {Username} logged out successfully", username);
                return RedirectToAction("Login");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during logout");
                return RedirectToAction("Login");
            }
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult AccessDenied()
        {
            return View();
        }

        [HttpGet]
        [Authorize]
        public IActionResult Profile()
        {
            return View();
        }
    }
}
