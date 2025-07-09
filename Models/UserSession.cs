using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Net;

namespace BizConnect.Models
{
    [Table("UserSessions")]
    public class UserSession
    {
        [Key]
        [Column("SessionId")]
        public Guid SessionId { get; set; } = Guid.NewGuid();

        [Required]
        [Column("UserId")]
        public int UserId { get; set; }

        [Required]
        [StringLength(255)]
        [Column("SessionToken")]
        public string SessionToken { get; set; } = string.Empty;

        [Column("CreatedAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("ExpiresAt")]
        public DateTime ExpiresAt { get; set; }

        [Column("IsActive")]
        public bool IsActive { get; set; } = true;

        [Column("IpAddress")]
        public IPAddress? IpAddress { get; set; }

        [Column("UserAgent")]
        public string? UserAgent { get; set; }

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;

        // Helper properties
        [NotMapped]
        public bool IsExpired => DateTime.UtcNow > ExpiresAt;

        [NotMapped]
        public bool IsValid => IsActive && !IsExpired;
    }
}
