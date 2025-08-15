using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Channels
{
    /// <summary>
    /// Represents a Microsoft Teams channel, as defined by Microsoft Graph API.
    /// </summary>
    [DataContract]
    public class Channel
    {
        /// <summary>
        /// The channel's unique identifier. Read-only.
        /// </summary>
        [DataMember(Name = "id", EmitDefaultValue = false)]
        public string Id { get; set; }

        /// <summary>
        /// Channel name as it will appear to the user in Microsoft Teams. The maximum length is 50 characters.
        /// </summary>
        [DataMember(Name = "displayName", EmitDefaultValue = false)]
        public string DisplayName { get; set; }

        /// <summary>
        /// Optional textual description for the channel.
        /// </summary>
        [DataMember(Name = "description", EmitDefaultValue = false)]
        public string Description { get; set; }

        /// <summary>
        /// The email address for sending messages to the channel. Read-only.
        /// </summary>
        [DataMember(Name = "email", EmitDefaultValue = false)]
        public string Email { get; set; }

        /// <summary>
        /// Read only. Timestamp at which the channel was created (ISO 8601 string).
        /// </summary>
        [DataMember(Name = "createdDateTime", EmitDefaultValue = false)]
        public string CreatedDateTime { get; set; }

        /// <summary>
        /// Indicates whether the channel is archived. Read-only.
        /// </summary>
        [DataMember(Name = "isArchived", EmitDefaultValue = false)]
        public bool? IsArchived { get; set; }

        /// <summary>
        /// Indicates whether the channel should be marked as recommended for all members of the team to show in their channel list.
        /// The property can only be set programmatically via the Create team method. The default value is false.
        /// </summary>
        [DataMember(Name = "isFavoriteByDefault", EmitDefaultValue = false)]
        public bool? IsFavoriteByDefault { get; set; }

        /// <summary>
        /// The type of the channel. Can be set during creation and can't be changed. 
        /// The possible values are: standard, private, unknownFutureValue, shared. The default value is standard.
        /// </summary>
        [DataMember(Name = "membershipType", EmitDefaultValue = false)]
        public string MembershipType { get; set; }

        /// <summary>
        /// The ID of the Microsoft Entra tenant.
        /// </summary>
        [DataMember(Name = "tenantId", EmitDefaultValue = false)]
        public string TenantId { get; set; }

        /// <summary>
        /// A hyperlink that will go to the channel in Microsoft Teams. Read-only.
        /// </summary>
        [DataMember(Name = "webUrl", EmitDefaultValue = false)]
        public string WebUrl { get; set; }

        /// <summary>
        /// Contains summary information about the channel, including number of owners, members, guests, and cross-tenant members.
        /// </summary>
        [DataMember(Name = "summary", EmitDefaultValue = false)]
        public Summary Summary { get; set; }
    }
}

