using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams
{
    /// <summary>
    /// Represents a basic Team resource with minimal properties as returned by Microsoft Graph API.
    /// </summary>
    [DataContract]
    public class Team
    {
        /// <summary>
        /// Gets or sets the unique identifier of the team.
        /// </summary>
        [DataMember(Name = "id", EmitDefaultValue = false)]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the display name of the team.
        /// </summary>
        [DataMember(Name = "displayName", EmitDefaultValue = false)]
        public string DisplayName { get; set; }

        /// <summary>
        /// Gets or sets the description of the team.
        /// </summary>
        [DataMember(Name = "description", EmitDefaultValue = false)]
        public string Description { get; set; }
    }
}
