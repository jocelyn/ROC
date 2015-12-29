note
	description: "Summary description for {CMS_FILE_UPLOAD_STORAGE_I}."
	author: "fmurer"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_FILE_UPLOAD_STORAGE_I

feature -- Access

	files_count: INTEGER_64
			-- count of files
		deferred
		end

	files: LIST [CMS_NODE]
			-- List of files
		deferred
		end

end
