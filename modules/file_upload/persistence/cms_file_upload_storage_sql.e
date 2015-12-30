note
	description: "Summary description for {CMS_FILE_UPLOAD_STORAGE_SQL}."
	author: "fmurer"
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_FILE_UPLOAD_STORAGE_SQL

inherit
	CMS_NODE_STORAGE_SQL
	CMS_FILE_UPLOAD_STORAGE_I

create
	make

feature

	files_count: INTEGER_64
			-- Precursor
		do

		end

	files: LIST [CMS_NODE]
		do
			
		end

end
