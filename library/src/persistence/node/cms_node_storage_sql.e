note
	description: "Summary description for {CMS_NODE_STORAGE_SQL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_NODE_STORAGE_SQL

inherit
	CMS_NODE_STORAGE

	CMS_STORAGE_SQL

	REFACTORING_HELPER

	SHARED_LOGGER

feature -- Access		

	nodes: LIST [CMS_NODE]
			-- List of nodes.
		do
			create {ARRAYED_LIST [CMS_NODE]} Result.make (0)

			error_handler.reset
			log.write_information (generator + ".nodes")

			from
				sql_query (select_nodes, Void)
				sql_post_execution
			until
				sql_after
			loop
				if attached fetch_node as l_node then
					Result.force (l_node)
				end
				sql_forth
			end
			sql_post_execution
		end

	recent_nodes (a_lower: INTEGER; a_count: INTEGER): LIST [CMS_NODE]
			-- List of recent `a_count' nodes with an offset of `lower'.
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			create {ARRAYED_LIST [CMS_NODE]} Result.make (0)

			error_handler.reset
			log.write_information (generator + ".nodes")

			from
				create l_parameters.make (2)
				l_parameters.put (a_count, "rows")
				l_parameters.put (a_lower, "offset")
				sql_query (select_recent_nodes, l_parameters)
				sql_post_execution
			until
				sql_after
			loop
				if attached fetch_node as l_node then
					Result.force (l_node)
				end
				sql_forth
			end
			sql_post_execution
		end

	node (a_id: INTEGER_64): detachable CMS_NODE
			-- Retrieve node by id `a_id', if any.
		local
			l_parameters: STRING_TABLE [ANY]
		do
			error_handler.reset
			log.write_information (generator + ".node")
			create l_parameters.make (1)
			l_parameters.put (a_id,"id")
			sql_query (select_node_by_id, l_parameters)
			if sql_rows_count = 1 then
				Result := fetch_node
			end
			sql_post_execution
		end

	node_author (a_id: like {CMS_NODE}.id): detachable CMS_USER
			-- Node's author for the given node id.
		local
			l_parameters: STRING_TABLE [ANY]
		do
			error_handler.reset
			log.write_information (generator + ".node_author")
			create l_parameters.make (1)
			l_parameters.put (a_id, "node_id")
			sql_query (select_node_author, l_parameters)
			if sql_rows_count >= 1 then
				Result := fetch_author
			end
			sql_post_execution
		end

	nodes_count: INTEGER
			-- Number of items nodes.
		do
			error_handler.reset
			log.write_information (generator + ".nodes_count")
			sql_query (select_nodes_count, Void)
			if sql_rows_count = 1 then
				Result := sql_read_integer_32 (1)
			end
			sql_post_execution
		end

	last_inserted_node_id: INTEGER
			-- Last insert node id.
		do
			error_handler.reset
			log.write_information (generator + ".last_inserted_node_id")
			sql_query (Sql_last_insert_node_id, Void)
			if sql_rows_count = 1 then
				Result := sql_read_integer_32 (1)
			end
			sql_post_execution
		end

feature -- Change: Node

	save_node (a_node: CMS_NODE)
			-- Save node `a_node'.
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			if a_node.has_id and attached a_node.author as l_author and then l_author.has_id then
				update_node (l_author.id, a_node)
			else
				error_handler.reset
				log.write_information (generator + ".save_node")
				create l_parameters.make (7)
				l_parameters.put (a_node.title, "title")
				l_parameters.put (a_node.summary, "summary")
				l_parameters.put (a_node.content, "content")
				l_parameters.put (a_node.publication_date, "publication_date")
				l_parameters.put (a_node.creation_date, "creation_date")
				l_parameters.put (a_node.modification_date, "modification_date")
				if
					attached a_node.author as l_author and then
				 	l_author.id > 0
				then
					l_parameters.put (l_author.id, "author_id")
				else
					l_parameters.put (0, "author_id")
				end
				sql_change (sql_insert_node, l_parameters)
				a_node.set_id (last_inserted_node_id)
				sql_post_execution
			end
		end

	delete_node (a_id: INTEGER_64)
			-- Remove node by id `a_id'.
		local
			l_parameters: STRING_TABLE [ANY]
		do
			log.write_information (generator + ".delete_node")

			error_handler.reset
			create l_parameters.make (1)
			l_parameters.put (a_id, "id")
			sql_change (sql_delete_node, l_parameters)
			sql_post_execution

				-- Delete from user nodes.  FIXME: what is that ???
			sql_change (sql_delete_from_user_node, l_parameters)
			sql_post_execution
		end

	update_node (a_user_id: like {CMS_USER}.id; a_node: CMS_NODE)
			-- Update node content `a_node'.
			-- The user `a_user_id' is an existing or new collaborator.
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			error_handler.reset
			log.write_information (generator + ".update_node")
			create l_parameters.make (7)
			l_parameters.put (a_node.title, "title")
			l_parameters.put (a_node.summary, "summary")
			l_parameters.put (a_node.content, "content")
			l_parameters.put (a_node.publication_date, "publication_date")
			l_parameters.put (create {DATE_TIME}.make_now_utc, "modification_date")
			l_parameters.put (a_node.id, "id")
			l_parameters.put (a_user_id, "editor")
			sql_change (sql_update_node, l_parameters)
			sql_post_execution
		end

	update_node_title (a_id: like {CMS_USER}.id; a_node_id: like {CMS_NODE}.id; a_title: READABLE_STRING_32)
			-- Update node title to `a_title', node identified by id `a_node_id'.
			-- The user `a_id' is an existing or new collaborator.
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			error_handler.reset
			log.write_information (generator + ".update_node_title")
			create l_parameters.make (3)
			l_parameters.put (a_title, "title")
			l_parameters.put (create {DATE_TIME}.make_now_utc, "modification_date")
			l_parameters.put (a_id, "id")
			sql_change (sql_update_node_title, l_parameters)
			sql_post_execution
		end

	update_node_summary (a_id: like {CMS_USER}.id; a_node_id: like {CMS_NODE}.id; a_summary: READABLE_STRING_32)
			-- Update node summary to `a_summary', node identified by id `a_node_id'.
			-- The user `a_id' is an existing or new collaborator.
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			error_handler.reset
			log.write_information (generator + ".update_node_summary")
			create l_parameters.make (3)
			l_parameters.put (a_summary, "summary")
			l_parameters.put (create {DATE_TIME}.make_now_utc, "modification_date")
			l_parameters.put (a_id, "id")
			sql_change (sql_update_node_summary, l_parameters)
			sql_post_execution
		end

	update_node_content (a_id: like {CMS_USER}.id; a_node_id: like {CMS_NODE}.id; a_content: READABLE_STRING_32)
			-- Update node content to `a_content', node identified by id `a_node_id'.
			-- The user `a_id' is an existing or new collaborator.
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			error_handler.reset
			log.write_information (generator + ".update_node_content")
			create l_parameters.make (3)
			l_parameters.put (a_content, "content")
			l_parameters.put (create {DATE_TIME}.make_now_utc, "modification_date")
			l_parameters.put (a_id, "id")
			sql_change (sql_update_node_content, l_parameters)
			sql_post_execution
		end

feature {NONE} -- Queries

	Select_nodes_count: STRING = "select count(*) from Nodes;"

	Select_nodes: STRING = "select * from Nodes;"
		-- SQL Query to retrieve all nodes.

	Select_node_by_id: STRING = "select * from Nodes where id =:id order by id desc, publication_date desc;"

	Select_recent_nodes: STRING = "select * from Nodes order by id desc, publication_date desc LIMIT :rows OFFSET :offset ;"

	SQL_Insert_node: STRING = "insert into nodes (title, summary, content, publication_date, creation_date, modification_date, author_id) values (:title, :summary, :content, :publication_date, :creation_date, :modification_date, :author_id);"
		-- SQL Insert to add a new node.

	SQL_Update_node_title: STRING ="update nodes SET title=:title, modification_date=:modification_date, version = version + 1 where id=:id;"
		-- SQL update node title.

	SQL_Update_node_summary: STRING ="update nodes SET summary=:summary, modification_date=:modification_date, version = version + 1 where id=:id;"
		-- SQL update node summary.

	SQL_Update_node_content: STRING ="update nodes SET content=:content, modification_date=:modification_date, version = version + 1 where id=:id;"
		-- SQL node content.

	Slq_update_editor: STRING ="update nodes SET editor_id=:users_id  where id=:nodes_id;"
		-- SQL node content.	

	SQL_Update_node : STRING = "update nodes SET title=:title, summary=:summary, content=:content, publication_date=:publication_date,  modification_date=:modification_date, version = version + 1, editor_id=:editor where id=:id;"
		-- SQL node.

	SQL_Delete_node: STRING = "delete from nodes where id=:id;"

	Sql_update_node_author: STRING  = "update nodes SET author_id=:user_id where id=:id;"

	Sql_last_insert_node_id: STRING = "SELECT MAX(id) from nodes;"

feature {NONE} -- Sql Queries: USER_ROLES collaborators, author

	Sql_insert_users_nodes: STRING = "insert into users_nodes (users_id, nodes_id) values (:users_id, :nodes_id);"

	select_node_collaborators:  STRING = "SELECT * FROM Users INNER JOIN users_nodes ON users.id=users_nodes.users_id and users_nodes.nodes_id = :node_id;"

	Select_user_author: STRING = "SELECT * FROM Nodes INNER JOIN users ON nodes.author_id=users.id and users.id = :user_id;"

	Select_node_author: STRING = "SELECT * FROM Users INNER JOIN nodes ON nodes.author_id=users.id and nodes.id =:node_id;"

	Select_user_collaborator: STRING = "SELECT * FROM Nodes INNER JOIN users_nodes ON users_nodes.nodes_id = nodes.id and users_nodes.users_id = :user_id;"

	Select_exist_user_node: STRING= "Select Count(*) from Users_nodes where users_id=:user_id and nodes_id=:node_id;"

	sql_delete_from_user_node: STRING = "delete from users_nodes where nodes_id=:id"

feature {NONE} -- Implementation

	fetch_node: CMS_NODE
		do
			create Result.make ("", "", "")
			if attached sql_read_integer_32 (1) as l_id then
				Result.set_id (l_id)
			end
			if attached sql_read_date_time (2) as l_publication_date then
				Result.set_publication_date (l_publication_date)
			end
			if attached sql_read_date_time (3) as l_creation_date then
				Result.set_creation_date (l_creation_date)
			end
			if attached sql_read_date_time (4) as l_modif_date then
				Result.set_modification_date (l_modif_date)
			end
			if attached sql_read_string_32 (5) as l_title then
				Result.set_title (l_title)
			end
			if attached sql_read_string_32 (6) as l_summary then
				Result.set_summary (l_summary)
			end
			if attached sql_read_string (7) as l_content then
				Result.set_content (l_content)
			end
		end

	fetch_author: detachable CMS_USER
		do
			if attached sql_read_string_32 (2) as l_name and then not l_name.is_whitespace then
				create Result.make (l_name)
				if attached sql_read_integer_32 (1) as l_id then
					Result.set_id (l_id)
				end
				if attached sql_read_string (3) as l_password then
						-- FIXME: should we return the password here ???
					Result.set_hashed_password (l_password)
				end
				if attached sql_read_string (5) as l_email then
					Result.set_email (l_email)
				end
			else
				check expected_valid_user: False end
			end
		end

end
