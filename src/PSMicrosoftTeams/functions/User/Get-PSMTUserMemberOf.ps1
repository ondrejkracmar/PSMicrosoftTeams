$MemberOf = Invoke-WebRequest -Headers $AuthHeader -Uri "https://graph.microsoft.com/beta/users/vasil@michev.info/transitiveMemberOf"