note
	description: "Summary description for JSON {JSON_WEBAPI_RESPONSE}."
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_WEBAPI_RESPONSE

inherit
	HM_WEBAPI_RESPONSE
		redefine
			initialize
		end

create
	make

feature {NONE} -- Initialization

	initialize
		do
			Precursor
			create resource.make_empty
		end

feature -- Access

	resource: JSON_OBJECT

feature -- Element change

	add_self (a_href: READABLE_STRING_8)
		do
			add_field ("self", a_href)
		end

	add_field (a_name: READABLE_STRING_GENERAL; a_value: READABLE_STRING_GENERAL)
		do
			resource.put_string (a_value, a_name)
		end

	add_link (rel: READABLE_STRING_8; a_attname: READABLE_STRING_8 ; a_att_href: READABLE_STRING_8)
		local
			lnks: JSON_OBJECT
			lnk: JSON_OBJECT
		do
			if attached {JSON_OBJECT} resource.item ("links") as j_links then
				lnks := j_links
			else
				create lnks.make_with_capacity (1)
			end
			create lnk.make_with_capacity (2)
			lnk.put_string (a_attname, "name")
			lnk.put_string (a_att_href, "href")
			lnks.put (lnk, rel)
		end

feature -- Execution

	execute
		local
			m: WSF_PAGE_RESPONSE
		do
			create m.make_with_body (resource.representation)
			m.header.put_content_type ("application/json")
			response.send (m)
		end

invariant

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
