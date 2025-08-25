using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Members
{
    /// <summary>
    /// Represents a conversation member as defined in Microsoft Graph API, including the mail property (for AAD members).
    /// </summary>
    [DataContract]
    public class ConversationMember
    {
        /// <summary>
        /// Gets or sets the unique identifier of the user.
        /// </summary>
        [DataMember(Name = "id", EmitDefaultValue = false)]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the user's id guid address.
        /// </summary>
        [DataMember(Name = "userId", EmitDefaultValue = false)]
        public string UserId { get; set; }

        /// <summary>
        /// Gets or sets the display name of the user.
        /// </summary>
        [DataMember(Name = "displayName", EmitDefaultValue = false)]
        public string DisplayName { get; set; }

        /// <summary>
        /// Gets or sets the user's email address (present in AAD members).
        /// </summary>
        [DataMember(Name = "email", EmitDefaultValue = false)]
        public string Mail { get; set; }


        /// <summary>
        /// Gets or sets the user's tenantid.
        /// </summary>
        [DataMember(Name = "tenantId", EmitDefaultValue = false)]
        public string TenantId { get; set; }

        /// <summary>
        /// Gets or sets the roles assigned to the user. 
        /// May include 'owner', 'guest', or other role qualifiers relevant to the member.
        /// For a basic member, this should be empty.
        /// </summary>
        [DataMember(Name = "roles", EmitDefaultValue = false)]
        public IList<string> Roles { get; set; }
    }
}
