using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams.AdditionalProperty
{
    /// <summary>
    /// Represents settings to configure what guests can do in the team.
    /// Resource type: microsoft.graph.teamGuestSettings
    /// </summary>
    [DataContract]
    public class GuestSettings
    {
        /// <summary>
        /// Gets or sets a value indicating whether guests can create or update channels.
        /// </summary>
        [DataMember(Name = "allowCreateUpdateChannels", EmitDefaultValue = false)]
        public bool? AllowCreateUpdateChannels { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether guests can delete channels.
        /// </summary>
        [DataMember(Name = "allowDeleteChannels", EmitDefaultValue = false)]
        public bool? AllowDeleteChannels { get; set; }
    }
}
