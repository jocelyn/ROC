note
	description: "Summary description for {CMS_USER_VIEW_RESPONSE}."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_USER_VIEW_RESPONSE

inherit
	CMS_RESPONSE

create
	make

feature -- Query

	user_id_path_parameter (req: WSF_REQUEST): INTEGER_64
			-- User id passed as path parameter for request `req'.
		local
			s: STRING
		do
			if attached {WSF_STRING} req.path_parameter ("uid") as p_nid then
				s := p_nid.value
				if s.is_integer_64 then
					Result := s.to_integer_64
				end
			end
		end

feature -- Process

	process
			-- Computed response message.
		local
			b: STRING_8
			uid: INTEGER_64
			user_api: CMS_USER_API
			f: CMS_FORM
		do
			user_api := api.user_api
			create b.make_empty
			uid := user_id_path_parameter (request)
			if
				uid > 0 and then
				attached user_api.user_by_id (uid) as l_user
			then
				if
					api.has_permission ("view user")
					or l_user.same_as (user) -- Same user
				then
					f := new_view_form (l_user, request.request_uri, "view-user")
					f.append_to_html (wsf_theme, b)
				else
					b.append ("You don't have the permission to view this user!")
				end
			else
				b.append ("User not found!")
			end
			set_main_content (b)
		end

feature -- Process Edit

	new_view_form (a_user: detachable CMS_USER; a_url: READABLE_STRING_8; a_name: STRING): CMS_FORM
			-- Create a web form named `a_name' for user `a_user' (if set), using form action url `a_url'.
		local
			th: WSF_FORM_HIDDEN_INPUT
		do
			create Result.make (a_url, a_name)

			create th.make ("user-id")
			if a_user /= Void then
				th.set_text_value (a_user.id.out)
			else
				th.set_text_value ("0")
			end
			Result.extend (th)

			populate_form (Result, a_user)
		end

	populate_form (a_form: WSF_FORM; a_user: detachable CMS_USER)
			-- Fill the web form `a_form' with data from `a_node' if set,
			-- and apply this to content type `a_content_type'.
		local
			ti: WSF_FORM_TEXT_INPUT
			fs: WSF_FORM_FIELD_SET
		do
			if a_user /= Void then
				create fs.make
				fs.set_legend ("User Information")
				create ti.make_with_text ("profile_name", a_user.name)
				if attached a_user.profile_name as l_profile_name then
					ti.set_text_value (l_profile_name)
				end
				ti.set_label ("Profile name")
				ti.set_is_readonly (True)
				fs.extend (ti)
				a_form.extend (fs)
			end
		end

end
