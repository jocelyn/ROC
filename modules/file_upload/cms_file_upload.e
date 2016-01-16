note
	description: "file_upload application root class"
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_FILE_UPLOAD

inherit
	CMS_MODULE
		redefine
			install,
			initialize,
			setup_hooks
		end

	CMS_HOOK_BLOCK

	CMS_HOOK_MENU_SYSTEM_ALTER

	SHARED_EXECUTION_ENVIRONMENT

create
	make

feature {NONE} -- Initialization

	make
		do
			name := "file_uploader"
			version := "1.0"
			description := "Service to upload some files"
			package := "file upload"
		end

feature -- Access

	name: STRING

feature {CMS_API} -- Module Initialization

	initialize (api: CMS_API)
			-- <Precursor>
		do
			Precursor (api)
		end

feature {CMS_API}-- Module management

	install (api: CMS_API)
			-- install the module
		local
			sql: STRING
		do
			-- create a database table
			if attached {CMS_STORAGE_SQL_I} api.storage as l_sql_storage then
				if not l_sql_storage.sql_table_exists ("file_upload_table") then
					sql := "[
CREATE TABLE file_upload_table(
  `id` INTEGER PRIMARY KEY AUTO_INCREMENT NOT NULL CHECK("id">=0),
  `name` VARCHAR(100) NOT NULL,
  `uploaded_date` DATE,
  `size` INTEGER
);
					]"
					l_sql_storage.sql_execute_script (sql, Void)
					if l_sql_storage.has_error then
						api.logger.put_error ("Could not initialize database for file uploader module", generating_type)
					end
				end
				Precursor {CMS_MODULE}(api)
			end
		end

feature -- Access: router


	setup_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		local
			www: WSF_FILE_SYSTEM_HANDLER
		do

			map_uri_template_agent (a_router, "/upload/", agent execute_upload, void)

			create www.make_with_path (document_root)
			www.set_directory_index (<<"index.html">>)
			www.set_not_found_handler (agent execute_not_found_handler)
			a_router.handle("", www, a_router.methods_get)
		end

feature -- Hooks

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
		do
			a_hooks.subscribe_to_menu_system_alter_hook (Current)
			a_hooks.subscribe_to_block_hook (Current)
		end

	block_list: ITERABLE [like {CMS_BLOCK}.name]
		do
			Result := <<"?uploader">>
		end

	get_block_view (a_block_id: READABLE_STRING_8; a_response: CMS_RESPONSE)
		local
			menu: CMS_MENU
			menu_block: CMS_MENU_BLOCK
			menu_entries_count: INTEGER
		do
			if a_block_id.same_string ("uploader") then
				-- create menu_block.make ({CMS_MENU_SYSTEM}.primary_menu)
				-- a_response.add_block (menu_block, "page_top")
			end
		end

	menu_system_alter (a_menu_system: CMS_MENU_SYSTEM; a_response: CMS_RESPONSE)
		local
			link: CMS_LOCAL_LINK
			second_link: CMS_LOCAL_LINK
		do
			create link.make ("Upload", "upload/")
			a_menu_system.primary_menu.extend (link)
		end

feature -- Configuration		

	document_root: PATH
			-- Document root to look for files or directories
		once
			Result := execution_environment.current_working_path.extended ("site")
		end

	files_root: PATH
			-- Uploaded files will be stored in `files_root' folder
		local
			tmp: PATH
		once
			tmp := document_root.extended ("files")
			Result := tmp.extended ("uploaded_files")
		end

feature -- Handler

	execute_not_found_handler (uri: READABLE_STRING_8; req: WSF_REQUEST; res: WSF_RESPONSE)
			-- `uri' is not found, redirect to default page
		do
			res.redirect_now_with_content (req.script_url ("/"), uri + ": not found. %N Redirectioin to" + req.script_url ("/"), "text/html")
		end

	execute_upload (req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			body: STRING_8
		do
			-- create body
			create body.make_empty
			body.append ("<h1> EWF: Upload files </h1>%N")
			body.append ("<p>Please choose some file(s) to upload.</p>")

			-- create form to choose files and upload them
			body.append ("<form action=%"" + req.script_url ("/upload/") + "%" enctype=%"multipart/form-data%" method=%"POST%"> %N")
			body.append ("<input name=%"file-name[]%" type=%"file%" multiple> %N")
			body.append ("<button type=submit>Upload</button>%N")
			body.append ("</form>%N")

			-- put the body to the response
			res.put_string (body)

			show_and_store_files (req, res)

		end

	show_and_store_files (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- show all uploaded files
		local
			file_path: PATH
			file_name: STRING_8
			stored: BOOLEAN
			file_system_handler: WSF_FILE_SYSTEM_HANDLER

		do
			-- if has uploaded files, then store them
			if req.has_uploaded_file then
				across
					req.uploaded_files as uf
				loop
					file_name := uf.item.safe_filename

					-- check if file is already in folder
					if not files_root.has_extension (file_name) then
						file_path := files_root.extended (file_name)

						-- move file to path
						stored := uf.item.move_to(file_path.name)
					end
				end
			end

			-- create file_system_handler and show the uploaded files
			create file_system_handler.make_with_path (document_root)
			file_system_handler.enable_index
			file_system_handler.process_index ("/uploaded_files", files_root, req, res)

		end
		

feature -- Mapping helper: uri template agent (analogue to the demo-module)

	map_uri_template (a_router: WSF_ROUTER; a_tpl: STRING; h: WSF_URI_TEMPLATE_HANDLER; rqst_methods: detachable WSF_REQUEST_METHODS)
			-- Map `h' as handler for `a_tpl', according to `rqst_methods'.
		require
			a_tpl_attached: a_tpl /= Void
			h_attached: h /= Void
		do
			a_router.map (create {WSF_URI_TEMPLATE_MAPPING}.make (a_tpl, h), rqst_methods)
		end

	map_uri_template_agent (a_router: WSF_ROUTER; a_tpl: READABLE_STRING_8; proc: PROCEDURE [TUPLE [req: WSF_REQUEST; res: WSF_RESPONSE]]; rqst_methods: detachable WSF_REQUEST_METHODS)
			-- Map `proc' as handler for `a_tpl', according to `rqst_methods'.
		require
			a_tpl_attached: a_tpl /= Void
			proc_attached: proc /= Void
		do
			map_uri_template (a_router, a_tpl, create {WSF_URI_TEMPLATE_AGENT_HANDLER}.make (proc), rqst_methods)
		end
end
