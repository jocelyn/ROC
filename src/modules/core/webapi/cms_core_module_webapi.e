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
			permissions,
			filters
		end

create
	make

feature -- Security

	permissions: LIST [READABLE_STRING_8]
			-- List of permission ids, used by this module, and declared.
		do
			Result := Precursor
			Result.force ("admin users")
			Result.force ("view users")
		end

feature {NONE} -- Router/administration

	setup_webapi_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		local
			l_root: CMS_CORE_WEBAPI_ROOT_HANDLER
		do
			create l_root.make (a_api)
			a_router.handle ("", l_root, a_router.methods_get)
			a_router.handle ("/", l_root, a_router.methods_get)
			a_router.handle ("/user/{uid}/access_token", create {CMS_CORE_WEBAPI_ACCESS_TOKEN_HANDLER}.make (a_api), a_router.methods_get_post)
			a_router.handle ("/user/{uid}", create {CMS_CORE_WEBAPI_USER_HANDLER}.make (a_api), a_router.methods_get)
		end

feature -- Access: filter

	filters (a_api: CMS_API): detachable LIST [WSF_FILTER]
			-- Possibly list of Filter's module.
		do
			create {ARRAYED_LIST [WSF_FILTER]} Result.make (2)
			Result.extend (create {CMS_CORE_ACCESS_TOKEN_WEBAPI_AUTH_FILTER}.make (a_api))
			Result.extend (create {CMS_CORE_BASIC_WEBAPI_AUTH_FILTER}.make (a_api))
		end

--feature -- Helpers

--	new_webapi_response (req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API): HM_WEBAPI_RESPONSE
--		do
----			create {MD_WEBAPI_RESPONSE} Result.make (req, res, api)
--			create {JSON_WEBAPI_RESPONSE} Result.make (req, res, api)
--		end

--	new_wepapi_error_response (msg: detachable READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API): HM_WEBAPI_RESPONSE
--		do
--			Result := new_webapi_response (req, res, api)
--			if msg /= Void then
--				Result.add_string_field ("error", msg)
--			else
--				Result.add_string_field ("error", "True")
--			end
--		end

--	send_access_denied (m: detachable READABLE_STRING_GENERAL; req: WSF_REQUEST; res: WSF_RESPONSE; api: CMS_API)
--		local
--			rep: HM_WEBAPI_RESPONSE
--		do
--			rep := new_webapi_response (req, res, api)
--			if m /= Void then
--				rep.add_string_field ("error", m)
--			else
--				rep.add_string_field ("error", "Access denied")
--			end
--			rep.execute
--		end

--	add_user_links_to (u: CMS_USER; rep: HM_WEBAPI_RESPONSE)
--		do
--			rep.add_link ("account", "user/" + u.id.out, rep.api.webapi_path ("/user/" + u.id.out))
--		end

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
