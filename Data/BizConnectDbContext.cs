using Microsoft.EntityFrameworkCore;
using BizConnect.Models;
using System.Net;

namespace BizConnect.Data
{
    public class BizConnectDbContext : DbContext
    {
        public BizConnectDbContext(DbContextOptions<BizConnectDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<UserSession> UserSessions { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>(entity =>
            {
                entity.ToTable("Users");
                entity.HasKey(e => e.UserId);
                
                entity.Property(e => e.UserId)
                    .HasColumnName("UserId")
                    .ValueGeneratedOnAdd();

                entity.Property(e => e.Username)
                    .HasColumnName("Username")
                    .HasMaxLength(50)
                    .IsRequired();

                entity.Property(e => e.PasswordHash)
                    .HasColumnName("PasswordHash")
                    .HasMaxLength(255)
                    .IsRequired();

                entity.Property(e => e.Email)
                    .HasColumnName("Email")
                    .HasMaxLength(100);

                entity.Property(e => e.FirstName)
                    .HasColumnName("FirstName")
                    .HasMaxLength(50);

                entity.Property(e => e.LastName)
                    .HasColumnName("LastName")
                    .HasMaxLength(50);

                entity.Property(e => e.IsActive)
                    .HasColumnName("IsActive")
                    .HasDefaultValue(true);

                entity.Property(e => e.CreatedAt)
                    .HasColumnName("CreatedAt")
                    .HasColumnType("timestamp with time zone")
                    .HasDefaultValueSql("CURRENT_TIMESTAMP");

                entity.Property(e => e.UpdatedAt)
                    .HasColumnName("UpdatedAt")
                    .HasColumnType("timestamp with time zone")
                    .HasDefaultValueSql("CURRENT_TIMESTAMP");

                entity.Property(e => e.LastLoginAt)
                    .HasColumnName("LastLoginAt")
                    .HasColumnType("timestamp with time zone");

                // Indexes
                entity.HasIndex(e => e.Username)
                    .HasDatabaseName("IX_Users_Username")
                    .IsUnique();

                entity.HasIndex(e => e.Email)
                    .HasDatabaseName("IX_Users_Email");

                entity.HasIndex(e => e.IsActive)
                    .HasDatabaseName("IX_Users_IsActive");
            });

            // Configure UserSession entity
            modelBuilder.Entity<UserSession>(entity =>
            {
                entity.ToTable("UserSessions");
                entity.HasKey(e => e.SessionId);

                entity.Property(e => e.SessionId)
                    .HasColumnName("SessionId")
                    .HasDefaultValueSql("gen_random_uuid()");

                entity.Property(e => e.UserId)
                    .HasColumnName("UserId")
                    .IsRequired();

                entity.Property(e => e.SessionToken)
                    .HasColumnName("SessionToken")
                    .HasMaxLength(255)
                    .IsRequired();

                entity.Property(e => e.CreatedAt)
                    .HasColumnName("CreatedAt")
                    .HasColumnType("timestamp with time zone")
                    .HasDefaultValueSql("CURRENT_TIMESTAMP");

                entity.Property(e => e.ExpiresAt)
                    .HasColumnName("ExpiresAt")
                    .HasColumnType("timestamp with time zone")
                    .IsRequired();

                entity.Property(e => e.IsActive)
                    .HasColumnName("IsActive")
                    .HasDefaultValue(true);

                entity.Property(e => e.IpAddress)
                    .HasColumnName("IpAddress");

                entity.Property(e => e.UserAgent)
                    .HasColumnName("UserAgent")
                    .HasColumnType("text");

                // Foreign key relationship
                entity.HasOne(e => e.User)
                    .WithMany(u => u.UserSessions)
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                // Indexes
                entity.HasIndex(e => e.UserId)
                    .HasDatabaseName("IX_UserSessions_UserId");

                entity.HasIndex(e => e.SessionToken)
                    .HasDatabaseName("IX_UserSessions_SessionToken")
                    .IsUnique();

                entity.HasIndex(e => e.ExpiresAt)
                    .HasDatabaseName("IX_UserSessions_ExpiresAt");

                entity.HasIndex(e => e.IsActive)
                    .HasDatabaseName("IX_UserSessions_IsActive");
            });

            // Configure IPAddress conversion for PostgreSQL
            modelBuilder.Entity<UserSession>()
                .Property(e => e.IpAddress)
                .HasConversion(
                    v => v == null ? null : v.ToString(),
                    v => v == null ? null : IPAddress.Parse(v));
        }

        public override int SaveChanges()
        {
            UpdateTimestamps();
            return base.SaveChanges();
        }

        public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            UpdateTimestamps();
            return await base.SaveChangesAsync(cancellationToken);
        }

        private void UpdateTimestamps()
        {
            var entries = ChangeTracker.Entries()
                .Where(e => e.Entity is User && e.State == EntityState.Modified);

            foreach (var entry in entries)
            {
                if (entry.Entity is User user)
                {
                    user.UpdatedAt = DateTime.UtcNow;
                }
            }
        }
    }
}
