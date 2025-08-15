using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams.AdditionalProperty
{
    /// <summary>
    /// Represents member settings to configure what actions members can perform in a team.
    /// Resource type: microsoft.graph.teamMemberSettings
    /// </summary>
    [DataContract]
    public class MemberSettings
    {
        /// <summary>
        /// Gets or sets a value indicating whether members can add and remove apps.
        /// </summary>
        [DataMember(Name = "allowAddRemoveApps", EmitDefaultValue = false)]
        public bool? AllowAddRemoveApps { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether members can add and update private channels.
        /// </summary>
        [DataMember(Name = "allowCreatePrivateChannels", EmitDefaultValue = false)]
        public bool? AllowCreatePrivateChannels { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether members can add and update channels.
        /// </summary>
        [DataMember(Name = "allowCreateUpdateChannels", EmitDefaultValue = false)]
        public bool? AllowCreateUpdateChannels { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether members can add, update, and remove connectors.
        /// </summary>
        [DataMember(Name = "allowCreateUpdateRemoveConnectors", EmitDefaultValue = false)]
        public bool? AllowCreateUpdateRemoveConnectors { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether members can add, update, and remove tabs.
        /// </summary>
        [DataMember(Name = "allowCreateUpdateRemoveTabs", EmitDefaultValue = false)]
        public bool? AllowCreateUpdateRemoveTabs { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether members can delete channels.
        /// </summary>
        [DataMember(Name = "allowDeleteChannels", EmitDefaultValue = false)]
        public bool? AllowDeleteChannels { get; set; }
    }
}
