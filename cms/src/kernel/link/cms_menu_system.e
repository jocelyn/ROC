note
	description: "Describe the navigation menus."
	date: "$Date: 2014-08-28 08:21:49 -0300 (ju. 28 de ago. de 2014) $"
	revision: "$Revision: 95708 $"

class
	CMS_MENU_SYSTEM

inherit
	ITERABLE [CMS_MENU]

	REFACTORING_HELPER
create
	make

feature {NONE} -- Initialization

	make
			-- Create a predefined manu system
		do
			to_implement ("Refactor, take the info from a Database or Configuration file.")
			create items.make (5)
			force (create {CMS_MENU}.make ("primary", 3)) -- primary menu
			force (create {CMS_MENU}.make_with_title ("management", "Management", 3)) -- secondary in admin view.
			force (create {CMS_MENU}.make_with_title ("secondary", "Navigation", 3)) -- secondary
			force (create {CMS_MENU}.make_with_title ("user", "User", 3)) -- first_side_bar
		end

feature -- Access

	item (n: like {CMS_MENU}.name): CMS_MENU
		local
			m: detachable CMS_MENU
		do
			m := items.item (n)
			if m = Void then
				create m.make (n, 3)
				force (m)
			end
			Result := m
		end

	main_menu: CMS_MENU
		obsolete
			"Use `primary_menu' [Nov/2014]"
		do
			Result := primary_menu
		end

	primary_menu: CMS_MENU
		do
			Result := item ("primary")
		end

	secondary_menu: CMS_MENU
		do
			Result := item ("secondary")
		end

	management_menu: CMS_MENU
		do
			Result := item ("management")
		end

	navigation_menu: CMS_MENU
		do
			Result := item ("navigation")
		end

	user_menu: CMS_MENU
		do
			Result := item ("user")
		end

	primary_tabs: CMS_MENU
		do
			Result := item ("primary-tabs")
		end

feature -- Change

	force (m: CMS_MENU)
		do
			items.force (m, m.name)
		end

feature -- Access

	new_cursor: ITERATION_CURSOR [CMS_MENU]
			-- Fresh cursor associated with current structure.
		do
			Result := items.new_cursor
		end

feature {NONE} -- Implementation

	items: HASH_TABLE [CMS_MENU, like {CMS_MENU}.name]
--	items: ARRAYED_LIST [CMS_MENU]

end
