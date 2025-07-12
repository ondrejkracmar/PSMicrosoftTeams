using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams
{
    /// <summary>
    /// Describes the visibility of a team.
    /// Resource type: microsoft.graph.teamVisibilityType (enum)
    /// </summary>
    [DataContract]
    public enum TeamVisibilityType
    {
        /// <summary>
        /// Anyone can see the team, but only the owner can add a user to the team.
        /// </summary>
        [EnumMember(Value = "private")]
        Private = 0,

        /// <summary>
        /// Anyone can join the team.
        /// </summary>
        [EnumMember(Value = "public")]
        Public = 1,

        /// <summary>
        /// Only administrators (global, company, user, and helpdesk) can view the members of a team.
        /// Owner permissions are required to join a team.
        /// </summary>
        [EnumMember(Value = "hiddenMembership")]
        HiddenMembership = 2
    }
}
