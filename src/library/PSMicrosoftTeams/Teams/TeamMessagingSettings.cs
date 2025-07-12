using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams
{
    /// <summary>
    /// Represents settings to configure messaging and mentions in a team.
    /// Resource type: microsoft.graph.teamMessagingSettings
    /// </summary>
    [DataContract]
    public class TeamMessagingSettings
    {
        /// <summary>
        /// Gets or sets a value indicating whether users can edit their messages.
        /// </summary>
        [DataMember(Name = "allowUserEditMessages", EmitDefaultValue = false)]
        public bool? AllowUserEditMessages { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether users can delete their messages.
        /// </summary>
        [DataMember(Name = "allowUserDeleteMessages", EmitDefaultValue = false)]
        public bool? AllowUserDeleteMessages { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether owners can delete messages.
        /// </summary>
        [DataMember(Name = "allowOwnerDeleteMessages", EmitDefaultValue = false)]
        public bool? AllowOwnerDeleteMessages { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether @team mentions are allowed.
        /// </summary>
        [DataMember(Name = "allowTeamMentions", EmitDefaultValue = false)]
        public bool? AllowTeamMentions { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether @channel mentions are allowed.
        /// </summary>
        [DataMember(Name = "allowChannelMentions", EmitDefaultValue = false)]
        public bool? AllowChannelMentions { get; set; }
    }
}
