note
	description: "Summary description for {EWF_ROC_SERVER_EXECUTION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_ROC_SERVER_EXECUTION

inherit
	WSF_EXECUTION
		redefine
			initialize
		end

	REFACTORING_HELPER

	SHARED_LOGGER

create
	make

feature {NONE} -- Initialization

	initialize
		do
			Precursor
			initialize_cms (cms_setup)
		end

feature -- Access

	cms_service: CMS_SERVICE
			-- cms service.

	layout: CMS_LAYOUT
			-- cms layout.

feature -- Execution		

	execute
		local
		do
			cms_service.execute (request, response)
		end

feature -- CMS Initialization

	cms_setup: CMS_DEFAULT_SETUP
		local
			utf: UTF_CONVERTER
		do
			if attached execution_environment.arguments.separate_character_option_value ('d') as l_dir then
				create layout.make_with_directory_name (l_dir)
			else
				create layout.make_default
			end
			initialize_logger (layout)
			write_debug_log (generator + ".cms_setup based directory %"" + utf.escaped_utf_32_string_to_utf_8_string_8 (layout.path.name) + "%"")
			create Result.make (layout)
			setup_storage (Result)
		end

	initialize_cms (a_setup: CMS_SETUP)
		local
			cms: CMS_SERVICE
			api: CMS_API
		do
			write_debug_log (generator + ".initialize_cms")
			setup_modules (a_setup)
			create api.make (a_setup)
			create cms.make (api)
			cms_service := cms
		end

feature -- CMS setup

	setup_modules (a_setup: CMS_SETUP)
			-- Setup additional modules.
		local
			m: CMS_MODULE
		do
			create {BASIC_AUTH_MODULE} m.make
			if not a_setup.module_with_same_type_registered (m) then
				m.enable
				a_setup.register_module (m)
			end

			create {CMS_DEMO_MODULE} m.make
			m.enable
			a_setup.register_module (m)
		end

	setup_storage (a_setup: CMS_SETUP)
		do
			debug ("refactor_fixme")
				to_implement ("To implement custom storage")
			end
--			a_setup.storage_drivers.force (create {CMS_STORAGE_MYSQL_BUILDER}.make, "mysql")
			a_setup.storage_drivers.force (create {CMS_STORAGE_SQLITE_BUILDER}.make, "sqlite")
		end

end
