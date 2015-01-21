note
	description: "Summary description for {CMS_NODE_STORAGE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_NODE_STORAGE

inherit
	SHARED_LOGGER

feature -- Error Handling

	error_handler: ERROR_HANDLER
			-- Error handler.
		deferred
		end

feature -- Access		

	nodes: LIST [CMS_NODE]
			-- List of nodes.
		deferred
		end

	recent_nodes (a_lower: INTEGER; a_count: INTEGER): LIST [CMS_NODE]
			-- List of recent `a_count' nodes with an offset of `lower'.
		deferred
		end

	node (a_id: INTEGER_64): detachable CMS_NODE
			-- Retrieve node by id `a_id', if any.
		require
			a_id > 0
		deferred
		end

	node_author (a_id: like {CMS_NODE}.id): detachable CMS_USER
			-- Node's author. if any.
		require
			valid_node: a_id >0
		deferred
		end

feature -- Change: Node

	save_node (a_node: CMS_NODE)
			-- Save node `a_node'.
		require
			valid_user: attached a_node.author as l_author implies l_author.id > 0
		deferred
		end

	delete_node (a_id: INTEGER_64)
			-- Remove node by id `a_id'.
		require
			valid_node_id: a_id > 0
		deferred
		end

	update_node (a_id: like {CMS_USER}.id; a_node: CMS_NODE)
			-- Update node content `a_node'.
			-- The user `a_id' is an existing or new collaborator.
		require
			valid_node_id: a_node.id > 0
			valid_user_id: a_id > 0
		deferred
		end

	update_node_title (a_id: like {CMS_USER}.id; a_node_id: like {CMS_NODE}.id; a_title: READABLE_STRING_32)
			-- Update node title to `a_title', node identified by id `a_node_id'.
			-- The user `a_id' is an existing or new collaborator.
		require
			valid_node_id: a_node_id > 0
			valid_user_id: a_id > 0
		deferred
		end

	update_node_summary (a_id: like {CMS_USER}.id; a_node_id: like {CMS_NODE}.id; a_summary: READABLE_STRING_32)
			-- Update node summary to `a_summary', node identified by id `a_node_id'.
			-- The user `a_id' is an existing or new collaborator.
		require
			valid_id: a_node_id > 0
		deferred
		end

	update_node_content (a_id: like {CMS_USER}.id; a_node_id: like {CMS_NODE}.id; a_content: READABLE_STRING_32)
			-- Update node content to `a_content', node identified by id `a_node_id'.
			-- The user `a_id' is an existing or new collaborator.
		require
			valid_id: a_node_id > 0
			valid_user_id: a_id > 0
		deferred
		end

end
