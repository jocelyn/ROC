note
	description: "Common ancestor for Authentication modules."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_AUTH_MODULE_I

inherit
	CMS_MODULE
		redefine
			setup_hooks
		end

	CMS_HOOK_AUTO_REGISTER

	CMS_HOOK_MENU_SYSTEM_ALTER

	CMS_HOOK_BLOCK_HELPER

	SHARED_LOGGER

feature {NONE} -- Initialization

	make
		do
			package := "authentication"
			add_dependency ({CMS_AUTHENTICATION_MODULE})
		end

feature -- Access: auth strategy

	login_title: READABLE_STRING_GENERAL
			-- Module specific login title.
		deferred
		end

	login_location: STRING
			-- Login cms location for Current module.
		deferred
		end

	logout_location: STRING
			-- Logout cms location for Current module.
		deferred
		end

	is_authenticating (a_response: CMS_RESPONSE): BOOLEAN
			-- Is Current module strategy currently authenticating active user?
		deferred
		ensure
			Result implies a_response.is_authenticated
		end

feature -- Hooks configuration

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
			-- Module hooks configuration.
		do
			auto_subscribe_to_hooks (a_hooks)
			a_hooks.subscribe_to_menu_system_alter_hook (Current)
		end

feature -- Hooks

	menu_system_alter (a_menu_system: CMS_MENU_SYSTEM; a_response: CMS_RESPONSE)
			-- <Precursor>
		local
			lnk: CMS_LOCAL_LINK
			l_destination: READABLE_STRING_8
		do
			if attached {WSF_STRING} a_response.request.query_parameter ("destination") as p_destination then
				l_destination := p_destination.value
			else
				l_destination := a_response.location
			end
			if is_authenticating (a_response) then

			else
				if a_response.location.starts_with ("account/auth/") then
					create lnk.make (login_title, login_location)
					if not l_destination.starts_with ("account/auth/") then
						lnk.add_query_parameter ("destination", l_destination)
					end
					lnk.set_expandable (True)
					a_response.add_to_primary_tabs (lnk)
				end
			end
		end

end
