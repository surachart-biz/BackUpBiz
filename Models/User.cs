using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BizConnect.Models
{
    [Table("Users")]
    public class User
    {
        [Key]
        [Column("UserId")]
        public int UserId { get; set; }

        [Required]
        [StringLength(50)]
        [Column("Username")]
        public string Username { get; set; } = string.Empty;

        [Required]
        [StringLength(255)]
        [Column("PasswordHash")]
        public string PasswordHash { get; set; } = string.Empty;

        [StringLength(100)]
        [Column("Email")]
        public string? Email { get; set; }

        [StringLength(50)]
        [Column("FirstName")]
        public string? FirstName { get; set; }

        [StringLength(50)]
        [Column("LastName")]
        public string? LastName { get; set; }

        [Column("IsActive")]
        public bool IsActive { get; set; } = true;

        [Column("CreatedAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("UpdatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [Column("LastLoginAt")]
        public DateTime? LastLoginAt { get; set; }

        // Navigation properties
        public virtual ICollection<UserSession> UserSessions { get; set; } = new List<UserSession>();

        // Display properties
        [NotMapped]
        public string FullName => $"{FirstName} {LastName}".Trim();
    }
}
