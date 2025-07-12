using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams
{
    /// <summary>
    /// Represents class-specific settings for a Microsoft Teams team.
    /// </summary>
    [DataContract]
    public class TeamClassSettings
    {
        /// <summary>
        /// Gets or sets a value indicating whether sending of weekly assignments digest emails to parents/guardians is enabled.
        /// This requires the tenant admin to have enabled the setting globally.
        /// </summary>
        [DataMember(Name = "notifyGuardiansAboutAssignments", EmitDefaultValue = false)]
        public bool? NotifyGuardiansAboutAssignments { get; set; }
    }
}
