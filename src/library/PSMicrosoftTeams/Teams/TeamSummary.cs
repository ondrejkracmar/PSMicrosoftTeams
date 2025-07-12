using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams
{
    /// <summary>
    /// Contains summary information about the team, including the number of owners, members, and guests.
    /// Resource type: microsoft.graph.teamSummary
    /// </summary>
    [DataContract]
    public class TeamSummary
    {
        /// <summary>
        /// Gets or sets the number of guests in the team.
        /// </summary>
        [DataMember(Name = "guestCount", EmitDefaultValue = false)]
        public int? GuestCount { get; set; }

        /// <summary>
        /// Gets or sets the number of members in the team.
        /// </summary>
        [DataMember(Name = "memberCount", EmitDefaultValue = false)]
        public int? MemberCount { get; set; }

        /// <summary>
        /// Gets or sets the number of owners in the team.
        /// </summary>
        [DataMember(Name = "ownerCount", EmitDefaultValue = false)]
        public int? OwnerCount { get; set; }
    }
}
