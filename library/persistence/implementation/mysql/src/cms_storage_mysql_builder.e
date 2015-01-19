note
	description: "[
			Objects that ...
		]"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_STORAGE_MYSQL_BUILDER

inherit
	CMS_STORAGE_BUILDER

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		do
		end

feature -- Factory

	storage (a_setup: CMS_SETUP): detachable CMS_STORAGE_MYSQL
		do
			if attached (create {APPLICATION_JSON_CONFIGURATION_HELPER}).new_database_configuration (a_setup.layout.application_config_path) as l_database_config then
				create Result.make (create {DATABASE_CONNECTION_MYSQL}.login_with_connection_string (l_database_config.connection_string))
			end
		end


end
