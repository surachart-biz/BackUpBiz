using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.Cookies;
using BizConnect.Data;
using BizConnect.Services;

var builder = WebApplication.CreateBuilder(args);

// Add Local configuration file if it exists
builder.Configuration.AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: true);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Configure Entity Framework with PostgreSQL
builder.Services.AddDbContext<BizConnectDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseNpgsql(connectionString);

    // Enable sensitive data logging in development
    if (builder.Environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging();
        options.EnableDetailedErrors();
    }
});

// Configure Authentication
var authConfig = builder.Configuration.GetSection("Authentication");
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.Cookie.Name = authConfig["CookieName"] ?? "BizConnect.Auth";
        options.LoginPath = authConfig["LoginPath"] ?? "/Account/Login";
        options.LogoutPath = authConfig["LogoutPath"] ?? "/Account/Logout";
        options.AccessDeniedPath = authConfig["AccessDeniedPath"] ?? "/Account/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.Parse(authConfig["ExpireTimeSpan"] ?? "01:00:00");
        options.SlidingExpiration = bool.Parse(authConfig["SlidingExpiration"] ?? "true");
        options.Cookie.HttpOnly = true;
        options.Cookie.SecurePolicy = bool.Parse(authConfig["RequireHttps"] ?? "false")
            ? CookieSecurePolicy.Always
            : CookieSecurePolicy.SameAsRequest;
        options.Cookie.SameSite = SameSiteMode.Strict;
    });

// Add HTTP context accessor
builder.Services.AddHttpContextAccessor();

// Add custom services
builder.Services.AddScoped<IAuthenticationService, AuthenticationService>();
builder.Services.AddScoped<IUserService, UserService>();

// Add logging
builder.Services.AddLogging();

var app = builder.Build();

// Auto-migrate database on startup (for CI/CD)
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<BizConnectDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();

    try
    {
        logger.LogInformation("Checking for pending database migrations...");

        // Ensure database is created
        await context.Database.EnsureCreatedAsync();

        // Apply any pending migrations
        var pendingMigrations = await context.Database.GetPendingMigrationsAsync();
        if (pendingMigrations.Any())
        {
            logger.LogInformation("Applying {Count} pending migrations: {Migrations}",
                pendingMigrations.Count(), string.Join(", ", pendingMigrations));
            await context.Database.MigrateAsync();
            logger.LogInformation("Database migrations applied successfully");
        }
        else
        {
            logger.LogInformation("No pending migrations found");
        }
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Error during database migration");
        // In production, you might want to fail fast here
        // throw;
    }
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

// Authentication must come before Authorization
app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Account}/{action=Login}/{id?}");

app.MapControllerRoute(
    name: "home",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
