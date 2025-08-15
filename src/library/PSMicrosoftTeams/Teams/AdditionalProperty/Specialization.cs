using System.Runtime.Serialization;

namespace PSMicrosoftTeams.Teams.AdditionalProperty
{
    /// <summary>
    /// Indicates whether the team is intended for a particular use case.
    /// Each team specialization has access to unique behaviors and experiences targeted to its use case.
    /// Resource type: microsoft.graph.teamSpecialization (enum)
    /// </summary>
    [DataContract]
    public enum Specialization
    {
        /// <summary>
        /// Default type for a team that gives the standard team experience.
        /// </summary>
        [EnumMember(Value = "none")]
        None = 0,

        /// <summary>
        /// Team created by an education user. All teams created by education user are of type Edu.
        /// </summary>
        [EnumMember(Value = "educationStandard")]
        EducationStandard = 1,

        /// <summary>
        /// Team experience optimized for a class.
        /// </summary>
        [EnumMember(Value = "educationClass")]
        EducationClass = 2,

        /// <summary>
        /// Team experience optimized for a PLC (Professional Learning Community).
        /// </summary>
        [EnumMember(Value = "educationProfessionalLearningCommunity")]
        EducationProfessionalLearningCommunity = 3,

        /// <summary>
        /// Team type for an optimized experience for staff in an organization.
        /// </summary>
        [EnumMember(Value = "educationStaff")]
        EducationStaff = 4,

        /// <summary>
        /// Sentinel value reserved as a placeholder for future expansion of the enum.
        /// </summary>
        [EnumMember(Value = "unknownFutureValue")]
        UnknownFutureValue = 7
    }
}
