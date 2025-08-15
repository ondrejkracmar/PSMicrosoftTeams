using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PSMicrosoftTeams.Channels
{
    /// <summary>
    /// Contains summary information about the channel.
    /// </summary>
    [DataContract]
    public class Summary
    {
        /// <summary>
        /// Number of owners of the channel.
        /// </summary>
        [DataMember(Name = "ownersCount", EmitDefaultValue = false)]
        public int? OwnersCount { get; set; }

        /// <summary>
        /// Number of members of the channel.
        /// </summary>
        [DataMember(Name = "membersCount", EmitDefaultValue = false)]
        public int? MembersCount { get; set; }

        /// <summary>
        /// Number of guests in the channel.
        /// </summary>
        [DataMember(Name = "guestsCount", EmitDefaultValue = false)]
        public int? GuestsCount { get; set; }

        /// <summary>
        /// Indicator for members from other tenants.
        /// </summary>
        [DataMember(Name = "crossTenantMemberCount", EmitDefaultValue = false)]
        public int? CrossTenantMemberCount { get; set; }
    }
}
