# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Identity.Platform'              = "Microsoft Teams"
	'Identity.Connect.Failed'        = "Establish a connection to '{0}' failed"
	'Identity.Disconnect'            = "Disconnect from '{0}'"

	'User.Get'                       = "Get user '{0}'"
	'User.Get.Failed'                = "Get user '{0}' failed"
	'User.Filter'                    = "List users with filter '{0}'"
	'User.List'                      = "List users '{0}'"
	'User.Name'                      = "List users by name '{0}'"

	'Team.Get'                       = "Get team '{0}'"
	'Team.AdditionalProperty'        = "Get team additional properties '{0}'"
	'Team.Get.Failed'                = "Get team '{0}' failed"
	'Team.Filter'                    = "List teams with filter '{0}'"
	'Team.List'                      = "List teams '{0}'"
	'Team.New'                       = "Create new team '{0}'"
	'Team.Set'                       = "Set team '{0}'"
	'Team.NewTeamFromGroup'          = "Create new team from group '{0}'"
	'Team.Delete'                    = "Delete team '{0}'"
	'Team.Archive'                   = "Archive/Protext team '{0}'"
	'Team.Unarchive'                 = "Unarchive/Unprotext team '{0}'"

	'TeamMember.Add'                 = "Add member '{0}' with the following roles {1}"
	'TeamMember.Remove.MembershipId' = "Remove member from team '{0}' with the following MembershipId '{1}'"
	'TeamMember.Remove'              = "Remove member from team '{0}' with the following MembershipId '{1}'"
	'TeamMember.List'                = "List members from the team '{0}'"

	'TeamChannel.Add'                = "Add channel '{0}' to team '{1}'"
	'TeamChannel.Remove'             = "Remove channel '{0}' from team '{1}'"
	'TeamChannel.Get'                = "Get channel '{0}' from team '{1}'"
	'TeamChannel.List'               = "List channels from team '{0}'"

	'TeamChannel.New'                = "Create new channel '{0}'"
	"TeamChannelMember.Add"          = "Add user '{0}' to channel"
	'TeamChannelMember.Remove'       = "Remove membershipid '{0}'"
	'TeamChannelCahnnelMember.Get'   = "Get members from channel '{0}'"
	'TeamChannelAllMember.Get'       = "Get all members from channel '{0}'"

	'TeamChannel.Message.Send'       = "Send message with content '{1}'"

	'Batch.Invoke'                   = 'Invoke batch command with the following Ids {0}'

}
