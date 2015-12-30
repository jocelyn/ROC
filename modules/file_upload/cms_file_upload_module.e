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
		redefine
			install,
			register_hooks
		end

	CMS_HOOK_BLOCK
	CMS_HOOK_MENU_SYSTEM_ALTER

create
	make

feature {NONE} -- Initialisation
	make
		do
			version := "1.0"
			description := "Service to upload a file"
			package := "file_upload"
			add_dependency({CMS_NODE_MODULE})
		end

feature -- Access

	name: STRING = "file_uploader"


feature -- Access: router

	setup_router(a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precurser>
		do

		end

feature -- Module Management

	install (api: CMS_API)
			-- install the module
		local
			sql_query: STRING
		do
				-- create the database
			if attached api.storage.as_sql_storage as l_sql_storage then
				if not l_sql_storage.sql_table_exists ("file_nodes") then
					sql := "[
					CREATE TABLE file_nodes(
						`nid` INTEGER NOT NULL CHECK("nid">=0),
						`type` VARCHAR(255) NOT NULL,
						CONSTRAINT unique_id PRIMARY KEY nid
					);
					]"

					l_sql_storage.sql_execute_script (sql, void)
					if l_sql_storage.has_error then
						api.logger.put_error ("Could not initialize database for file_uploader module", generating_type)

					end
				end
				Precursor (api)
			end
		end

feature -- Hooks

	register_hooks (a_response: CMS_RESPONSE)
			-- register the hooks
		do
			a_response.subscribe_to_menu_system_alter_block(Current)
			a_response.subscribe_to_block_hook(Current)
		end

	block_list: ITERABLE [like {CMS_BLOCK}.name]
        do
            -- List of block names, managed by current object.
        end

    get_block_view (a_block_id: READABLE_STRING_8; a_response: CMS_RESPONSE)
        do
            -- Get block object identified by `a_block_id' and associate with `a_response'.
        end

    menu_system_alter (a_menu_system: CMS_MENU_SYSTEM; a_response: CMS_RESPONSE)
        local
            link: CMS_LOCAL_LINK
        do
            create link.make ("Files", "/uploaded_files")
            a_menu_system.primary_menu.extend (link)
        end
end
