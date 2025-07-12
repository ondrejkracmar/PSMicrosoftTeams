using System;
using System.Runtime.Serialization;
using PSMicrosoftTeams.Teams;

namespace PSMicrosoftTeams.Teams
{
    /// <summary>
    /// Represents additional properties of a Team in Microsoft Teams (Graph API resource type: microsoft.graph.team).
    /// </summary>
    [DataContract]
    public class TeamAdditionalProperty
    {
        /// <summary>
        /// Gets or sets the unique identifier of the team. The group has the same ID as the team. Read-only.
        /// </summary>
        [DataMember(Name = "id", EmitDefaultValue = false)]
        public string Id { get; set; }

        /// <summary>
        /// Gets or sets the optional label describing the data or business sensitivity of the team.
        /// </summary>
        [DataMember(Name = "classification", EmitDefaultValue = false)]
        public string Classification { get; set; }

        /// <summary>
        /// Gets or sets the class settings. Available only when the team represents a class.
        /// </summary>
        [DataMember(Name = "classSettings", EmitDefaultValue = false)]
        public TeamClassSettings ClassSettings { get; set; }

        /// <summary>
        /// Gets or sets the timestamp at which the team was created.
        /// </summary>
        [DataMember(Name = "createdDateTime", EmitDefaultValue = false)]
        public DateTimeOffset? CreatedDateTime { get; set; }

        /// <summary>
        /// Gets or sets an optional description for the team. Maximum length: 1,024 characters.
        /// </summary>
        [DataMember(Name = "description", EmitDefaultValue = false)]
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the name of the team.
        /// </summary>
        [DataMember(Name = "displayName", EmitDefaultValue = false)]
        public string DisplayName { get; set; }

        /// <summary>
        /// Gets or sets the name of the first channel in the team. Used only during creation.
        /// </summary>
        [DataMember(Name = "firstChannelName", EmitDefaultValue = false)]
        public string FirstChannelName { get; set; }

        /// <summary>
        /// Gets or sets the settings to configure use of Giphy, memes, and stickers in the team.
        /// </summary>
        [DataMember(Name = "funSettings", EmitDefaultValue = false)]
        public TeamFunSettings FunSettings { get; set; }

        /// <summary>
        /// Gets or sets the settings to configure whether guests can create, update, or delete channels in the team.
        /// </summary>
        [DataMember(Name = "guestSettings", EmitDefaultValue = false)]
        public TeamGuestSettings GuestSettings { get; set; }

        /// <summary>
        /// Gets or sets a unique ID for the team used in some places such as the audit log.
        /// </summary>
        [DataMember(Name = "internalId", EmitDefaultValue = false)]
        public string InternalId { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this team is in read-only mode.
        /// </summary>
        [DataMember(Name = "isArchived", EmitDefaultValue = false)]
        public bool? IsArchived { get; set; }

        /// <summary>
        /// Gets or sets the settings to configure whether members can perform certain actions in the team.
        /// </summary>
        [DataMember(Name = "memberSettings", EmitDefaultValue = false)]
        public TeamMemberSettings MemberSettings { get; set; }

        /// <summary>
        /// Gets or sets the settings to configure messaging and mentions in the team.
        /// </summary>
        [DataMember(Name = "messagingSettings", EmitDefaultValue = false)]
        public TeamMessagingSettings MessagingSettings { get; set; }

        /// <summary>
        /// Gets or sets the team specialization.
        /// </summary>
        [DataMember(Name = "specialization", EmitDefaultValue = false)]
        public TeamSpecialization? Specialization { get; set; }

        /// <summary>
        /// Gets or sets the summary information about the team, including number of owners, members, and guests.
        /// </summary>
        [DataMember(Name = "summary", EmitDefaultValue = false)]
        public TeamSummary Summary { get; set; }

        /// <summary>
        /// Gets or sets the ID of the Microsoft Entra tenant.
        /// </summary>
        [DataMember(Name = "tenantId", EmitDefaultValue = false)]
        public string TenantId { get; set; }

        /// <summary>
        /// Gets or sets the visibility of the group and team. Defaults to Public.
        /// </summary>
        [DataMember(Name = "visibility", EmitDefaultValue = false)]
        public string Visibility { get; set; }

        /// <summary>
        /// Gets or sets the hyperlink to the team in the Microsoft Teams client.
        /// </summary>
        [DataMember(Name = "webUrl", EmitDefaultValue = false)]
        public string WebUrl { get; set; }
    }
}
