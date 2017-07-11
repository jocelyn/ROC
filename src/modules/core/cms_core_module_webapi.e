note
	description: "Summary description for {CMS_CORE_MODULE_WEBAPI}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_CORE_MODULE_WEBAPI

inherit
	CMS_MODULE_WEBAPI [CMS_CORE_MODULE]
		redefine
			permissions
		end

create
	make

feature -- Security

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		do
			Result := Precursor
			Result.force ("admin users")
		end

feature {NONE} -- Router/administration

	setup_webapi_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		do
			a_router.handle ("", create {WSF_URI_AGENT_HANDLER}.make (agent handle_root (?, ?, a_api)), a_router.methods_get)
			a_router.handle ("/access_token", create {WSF_URI_AGENT_HANDLER}.make (agent do_post_access_token (?, ?, a_api)), a_router.methods_post)

			a_router.handle ("/user/{uid}", create {WSF_URI_TEMPLATE_AGENT_HANDLER}.make (agent do_get_user (?, ?, a_api)), a_router.methods_get)
		end

feature -- Request handling

	handle_root (req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API)
		local
			rep: HM_WEBAPI_RESPONSE
		do
			rep := new_webapi_response (req, res, api)
			rep.add_field ("site_name", api.setup.site_name)
			if attached api.user as u then
				add_user_links_to (u, rep)
			end
			rep.add_self (req.percent_encoded_path_info)
			rep.execute
		end

feature -- Access token		

	do_get_access_token (req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API)
		local
			rep: HM_WEBAPI_RESPONSE
--			l_access_token: detachable READABLE_STRING_32
		do
			if
				attached api.user as l_user and then
				attached api.user_api.user_profile_item ("access_token", l_user) as l_access_token
			then
--				l_access_token := new_key (40)
--				api.user_api.save_user_profile_item (l_user, "access_token", l_access_token)

				rep := new_webapi_response (req, res, api)
				rep.add_field ("access_token", l_access_token)
				rep.add_self (req.percent_encoded_path_info)
				add_user_links_to (l_user, rep)
				if attached {WSF_STRING} req.item ("destination") as dest then
					rep.set_redirection (dest.url_encoded_value)
				end
				rep.execute
			else
				send_access_denied (Void, req, res, api)
			end
		end

	do_post_access_token (req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API)
		local
			m: WSF_PAGE_RESPONSE
			l_access_token: detachable READABLE_STRING_32
		do
			if attached api.user as l_user then
				l_access_token := api.user_api.user_profile_item ("access_token", l_user)

				l_access_token := new_key (40)

--				if l_access_token /= Void then
--					l_access_token := "Updated-" + (create {UUID_GENERATOR}).generate_uuid.out
--				else
--					l_access_token := "New-" + (create {UUID_GENERATOR}).generate_uuid.out
--				end
				api.user_api.save_user_profile_item (l_user, "access_token", l_access_token)
				if attached {WSF_STRING} req.item ("destination") as dest then
					res.redirect_now (dest.value.to_string_8)
				else
					create m.make_with_body ("Ok")
					res.send (m)
				end
			else
				send_access_denied (Void, req, res, api)
			end
		end

feature -- Users

	do_get_user (req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API)
		local
			rep: HM_WEBAPI_RESPONSE
		do
			if attached api.user as u then
				rep := new_webapi_response (req, res, api)
				rep.add_field ("uid", u.id.out)

				rep.add_field ("name", u.name)
				if attached u.email as l_email then
					rep.add_field ("email", l_email)
				end
				if attached u.profile_name as l_profile_name then
					rep.add_field ("profile_name", l_profile_name)
				end
				add_user_links_to (u, rep)
				rep.execute
			else
					-- FIXME: use specific Web API response!
				send_access_denied (Void, req, res, api)
			end
		end

feature -- Helpers

	new_webapi_response (req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API): HM_WEBAPI_RESPONSE
		do
--			create {MD_WEBAPI_RESPONSE} Result.make (req, res, api)
			create {JSON_WEBAPI_RESPONSE} Result.make (req, res, api)
		end

	send_access_denied (m: detachable READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API)
		local
			rep: HM_WEBAPI_RESPONSE
		do
			rep := new_webapi_response (req, res, api)
			if m /= Void then
				rep.add_field ("error", m)
			else
				rep.add_field ("error", "Access denied")
			end
			rep.execute
		end

	add_user_links_to (u: CMS_USER; rep: HM_WEBAPI_RESPONSE)
		do
			rep.add_link ("account", "user/" + u.id.out, rep.api.webapi_path ("/user/" + u.id.out))
		end

	new_key (len: INTEGER): STRING_8
		local
			rand: RANDOM
			n: INTEGER
			v: NATURAL_32
		do
			create rand.set_seed ((create {DATE_TIME}.make_now_utc).seconds)
			rand.start
			create Result.make (len)
			from
				n := 1
			until
				n = len
			loop
				rand.forth
				v := (rand.item \\ 16).to_natural_32
				check 0 <= v and v <= 15 end
				if v < 9 then
					Result.append_code (48 + v) -- 48 '0'
				else
					Result.append_code (97 + v - 9) -- 97 'a'
				end
				n := n + 1
			end
		end

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
