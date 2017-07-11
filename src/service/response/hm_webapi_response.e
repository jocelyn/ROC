note
	description: "Summary description for Hyper media {HM_WEBAPI_RESPONSE}."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HM_WEBAPI_RESPONSE

inherit
	WEBAPI_RESPONSE

feature -- Element change

	add_self (a_href: READABLE_STRING_8)
		deferred
		end

	add_field (a_name: READABLE_STRING_GENERAL; a_value: READABLE_STRING_GENERAL)
		deferred
		end

	add_link (rel: READABLE_STRING_8; a_attname: READABLE_STRING_8 ; a_att_href: READABLE_STRING_8)
		deferred
		end

feature -- Execution

	execute
		deferred
		end

invariant

note
	copyright: "2011-2017, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end
