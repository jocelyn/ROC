note
	description: "Summary description for {CMS_CORE_ACCESS_TOKEN_WEBAPI_AUTH_FILTER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_CORE_ACCESS_TOKEN_WEBAPI_AUTH_FILTER

inherit
	WSF_FILTER

create
	make

feature {NONE} -- Initialization

	make (a_api: CMS_API)
			-- Initialize Current handler with `a_api'.
		do
			api := a_api
		end

feature -- API Service

	api: CMS_API

feature -- Basic operations

	execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute the filter.
		local
			tok: READABLE_STRING_GENERAL
		do
			if
				attached req.http_authorization as l_auth and then
				l_auth.starts_with_general ("Bearer ")
			then
				tok := l_auth.substring (8, l_auth.count)
				if attached api.user_api.users_with_profile_item ("access_token", tok) as lst then
					if lst.count = 1 then
						api.set_user (lst.first)
					end
				end
			end
			execute_next (req, res)
		end

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
