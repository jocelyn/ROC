note
	description: "Summary description for {CMS_FILE_UPLOAD_MODULE}."
	author: "fmurer"
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_FILE_UPLOAD_MODULE

inherit
	CMS_MODULE
		rename
			module_api as file_upload_api
		end

create
	make

feature {NONE} -- Initialisation
	make
		do
			version := "1.0"
			description := "Service to upload a file"
			package := "demo"
			add_dependency({CMS_NODE_MODULE})
		end

feature -- Access

	name: STRING = "file_uploader"

feature -- Access: router

	setup_router(a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precurser>
		do
			
		end

end
