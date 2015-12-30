note
	description: "Summary description for {CMS_FILE_UPLOAD_API}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_FILE_UPLOAD_API

inherit
	CMS_MODULE_API
		rename
			make as make_with_cms_api
		redefine
			initialize
		end

create
	make

feature {NONE} -- Initialization

	make (a_api: CMS_API; a_node_api: CMS_NODE_API)
			-- (from CMS_MODULE_API)
		do
			node_api := a_node_api
			make_with_cms_api(a_api)
		end

	initialize
		do
			Precursor

			-- create the storage of type file
			if attached storage.as_sql_storage as l_storage_sql then
				create {CMS_FILE_UPLOAD_STORAGE_SQL} file_storage.make (l_storage_sql)
			end
		end

		
feature -- Access

	nod_api: CMS_NODE_API

	file_storage: CMS_FILE_UPLOAD_STORAGE_I
end
