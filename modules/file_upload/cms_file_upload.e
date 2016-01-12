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

			map_uri_template_agent (a_router, "/upload{?nb}", agent execute_upload, void)

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
			Result := <<"Uploader info TODO">>
		end

	get_block_view (a_block_id: READABLE_STRING_8; a_response: CMS_RESPONSE)
		do

		end

	menu_system_alter (a_menu_system: CMS_MENU_SYSTEM; a_response: CMS_RESPONSE)
		local
			link: CMS_LOCAL_LINK
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
			answer: STRING_8
			file_name: STRING_8
			file_path: PATH
			page: WSF_HTML_PAGE_RESPONSE
			tmp: BOOLEAN
		do
			if req.is_request_method ("GET") or else not req.has_uploaded_file then
				-- create page
				create page.make
				page.set_title ("EWF: Upload file")
				page.add_style (req.script_url ("style.css"), "all")
				-- page.set_status_code ({HTTP_STATUS_CODE}.ok)

				-- create body
				create body.make_empty
				body.append ("<h1> EWF: Upload files </h1>%N")
				body.append ("<form action=%"" + req.script_url ("/upload") + "%" enctype=%"multipart/form-data%" method=%"POST%" %N")
				body.append ("<fieldset> <legend>Upload files</legend> %N")
				body.append ("<div><label>File %N")
				body.append ("<input name=%"file-name[]%" type=%"file%" multiple %N")
				body.append ("</label></div> %N")
				body.append ("<div><button type=submit>Upload</button></div></fieldset> %N")
				body.append ("</form>%N")

				-- connect the body with the page
				page.set_body (body)

				-- set response
				-- res.put_header ({HTTP_STATUS_CODE}.ok, <<["Content-type", "text/html"], ["Content-length", body.count.out]>>)
				res.send (page)
			else
				-- create page
				create page.make
				page.set_title ("Uploaded files")
				page.add_style (req.script_url ("style.css"), "all")

				-- create answer
				create answer.make_empty
				answer.append ("<h1>Uploaded Files</h1> %N")
				answer.append ("<table> %N")
				answer.append ("<tr><th>Filename</th><th>Type</th><th>Size</th></tr>")
				across
					req.uploaded_files as uf
				loop
					file_name := uf.item.safe_filename

					-- add file to table
					answer.append ("<tr>")
					answer.append ("<td> %N")
					answer.append ("<a href=%"../files/uploaded_files/" + file_name + "%">" + uf.item.filename + "</a> ")
					answer.append ("</td>")
					answer.append ("<td>")
					answer.append (uf.item.content_type)
					answer.append ("</td>%N")
					answer.append ("<td>")
					answer.append (uf.item.size.out + " Bytes")
					answer.append ("</td>%N")
					answer.append ("</tr>")

					-- check if file is already in folder
					if not files_root.has_extension (file_name) then
						file_path := files_root.extended (file_name)

						-- move file to path
						tmp := uf.item.move_to(file_path.name)
					end

				end
				answer.append ("</table>%N")

				-- connect the body with the page
				page.set_body (answer)

				-- set response
				-- res.put_header ({HTTP_STATUS_CODE}.ok, <<["Content-type", "text/html"], ["Content-length", answer.count.out]>>)
				res.send (page)
			end
		end

		execute_upload_handler(req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			body: STRING_8
			safe_filename: STRING_8
			path: PATH
			page: WSF_HTML_PAGE_RESPONSE
			n: INTEGER
		do
			if req.is_request_method ("GET") or else not req.has_uploaded_file then
				-- create page
				create page.make
				page.set_title ("EWF: Upload file")
				page.add_style (req.script_url ("style.css"), "all")

				-- create the body
				create body.make_empty
				body.append ("<h1> EWF: Upload files </h1>%N")
				body.append ("<form action=%"" + req.script_url ("/upload") + "%" method=%"POST%" enctype=%"multipart/form-data%">%N")

				-- tetermine how many files to upload by a query parameter ?nb=number_of_files
				if attached {WSF_STRING} req.query_parameter ("nb") as p_nb and then p_nb.is_integer then
					n := p_nb.integer_value
				else
					n := 1
				end

				-- llist for the number of wanted files a upload button
				from
				until
					n = 0
				loop
					body.append ("<input type=%"file%" name=%"uploaded_file[]%" size=%"60%"></br> %N")
					n := n-1
				end

				-- set the submit button
				body.append ("<button type=%"submit%">UPLOAD</button>%N")
				res.put_header ({HTTP_STATUS_CODE}.ok, <<["Content-type", "text/html"], ["Content-length", body.count.out]>>)
				res.send (page)
			else
				create body.make_empty
				body.append ("<h1>EWF: Uploaded files</h1>%N")
				body.append ("<ul>%N")

				n := 0

				across
					req.uploaded_files as u_file
				loop
					body.append ("<li>%N")
					body.append ("<div>" + u_file.item.name + "=" + html_encode (u_file.item.filename) + " size=" + u_file.item.size.out + " type" + u_file.item.content_type + "</div> %N")
					safe_filename := u_file.item.safe_filename
					path := files_root.extended (safe_filename)

					-- TODO: list dhe uploaded items

					body.append ("</li> %N")
				end

				body.append ("</ul> %N")

				-- create page
				create page.make
				page.add_style ("../style.css", "all")
				page.set_body (body)
				res.put_header ({HTTP_STATUS_CODE}.ok, <<["Content-type", "text/html"], ["Content-length", body.count.out]>>)
				res.send (page)
			end
		end

feature {NONE} -- Encoder

	url_encode (s: READABLE_STRING_32): STRING_8
		-- URL Encode `s' as Result
	do
		Result := url_encoder.encoded_string (s)
	end

	url_encoder: URL_ENCODER
		once
			create Result
		end

	html_encode (s: READABLE_STRING_32): STRING_8
			-- HTML Encode `s' as Result	
		do
			Result := html_encoder.encoded_string (s)
		end

	html_encoder: HTML_ENCODER
		once
			create Result
		end

feature -- Mapping helper: uri template agent

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
