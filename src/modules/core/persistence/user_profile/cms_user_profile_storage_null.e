note
	description: "Summary description for {CMS_USER_PROFILE_STORAGE_NULL}."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_USER_PROFILE_STORAGE_NULL

inherit
	CMS_USER_PROFILE_STORAGE_I

feature -- Error handler

	error_handler: ERROR_HANDLER
			-- Error handler.
		do
			create Result.make
		end

feature -- Access

	user_profile (a_user: CMS_USER): detachable CMS_USER_PROFILE
			-- <Precursor>
		do
		end

feature -- Change

	save_user_profile (a_user: CMS_USER; a_profile: CMS_USER_PROFILE)
			-- <Precursor>
		do
		end

end
