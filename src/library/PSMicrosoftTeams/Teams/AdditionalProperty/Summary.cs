using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams.AdditionalProperty
{
    /// <summary>
    /// Contains summary information about the team, including the number of owners, members, and guests.
    /// Resource type: microsoft.graph.teamSummary
    /// </summary>
    [DataContract]
    public class Summary
    {
        /// <summary>
        /// Gets or sets the number of guests in the team.
        /// </summary>
        [DataMember(Name = "guestsCount", EmitDefaultValue = false)]
        public int? GuestsCount { get; set; }

        /// <summary>
        /// Gets or sets the number of members in the team.
        /// </summary>
        [DataMember(Name = "membersCount", EmitDefaultValue = false)]
        public int? MembersCount { get; set; }

        /// <summary>
        /// Gets or sets the number of owners in the team.
        /// </summary>
        [DataMember(Name = "ownersCount", EmitDefaultValue = false)]
        public int? OwnersCount { get; set; }
    }
}
