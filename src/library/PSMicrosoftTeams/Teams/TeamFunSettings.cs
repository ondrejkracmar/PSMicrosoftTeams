using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams
{
    /// <summary>
    /// Represents fun settings to configure use of Giphy, memes, and stickers in a team.
    /// Resource type: microsoft.graph.teamFunSettings
    /// </summary>
    [DataContract]
    public class TeamFunSettings
    {
        /// <summary>
        /// Gets or sets a value indicating whether users can include custom memes.
        /// </summary>
        [DataMember(Name = "allowCustomMemes", EmitDefaultValue = false)]
        public bool? AllowCustomMemes { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether Giphy is allowed in the team.
        /// </summary>
        [DataMember(Name = "allowGiphy", EmitDefaultValue = false)]
        public bool? AllowGiphy { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether users can include stickers and memes.
        /// </summary>
        [DataMember(Name = "allowStickersAndMemes", EmitDefaultValue = false)]
        public bool? AllowStickersAndMemes { get; set; }

        /// <summary>
        /// Gets or sets the Giphy content rating. Possible values: "moderate", "strict".
        /// </summary>
        [DataMember(Name = "giphyContentRating", EmitDefaultValue = false)]
        public string GiphyContentRating { get; set; }
    }
}
