note
	description: "Summary description for {CMS_FILE_UPLOAD_FILE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_FILE_UPLOAD_FILE

inherit
	WSF_UPLOADED_FILE
		redefine
			name
		end

	RAW_FILE
		undefine
			make, change_name, is_empty, exists
		end

create
	make_new,
	make_with_path

feature -- Initialization

	make_new (a_name: READABLE_STRING_GENERAL; a_filename: READABLE_STRING_GENERAL; a_content_type: like content_type; a_size: like size; a_user: CMS_USER)
		local
			time: DATE_TIME
		do
			new_name := a_name.as_string_32
			url_encoded_name := url_encoded_string (a_name)
			filename := a_filename.as_string_32
			content_type := a_content_type
			size := a_size

			create time.make_now_utc
			set_uploaded_time (time)
			set_uploaded_by (a_user)
		end

feature -- Access

	uploaded_by: CMS_USER
			-- user who has uploaded the file

	uploaded_time: DATE_TIME
			-- time and date when file was uploaded

feature -- Setter functions

	set_uploaded_by (a_user: CMS_USER)
		do
			uploaded_by := a_user
		end

	set_uploaded_time (a_time: DATE_TIME)
		do
			uploaded_time := a_time
		end
end
