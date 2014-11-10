note
	description: "Summary description for {CMS_LOCAL_MENU}."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_LOCAL_LINK

inherit
	CMS_LINK

	CMS_LINK_COMPOSITE
		rename
			items as children,
			extend as add_link,
			remove as remove_link
		end

create
	make

feature {NONE} -- Initialization

	make (a_title: detachable like title; a_location: like location)
		do
			if a_title /= Void then
				title := a_title
			else
				title := a_location
			end
			location := a_location
		end

feature -- Status report

	is_active: BOOLEAN

	is_expanded: BOOLEAN
		do
			Result := is_expandable and then internal_is_expanded
		end

	is_collapsed: BOOLEAN
			-- Is expanded, but visually collapsed?
		do
			Result := is_expandable and then internal_is_collapsed
		end

	is_expandable: BOOLEAN
		do
			Result := internal_is_expandable or internal_is_expanded or has_children
		end

	has_children: BOOLEAN
		do
			Result := attached children as l_children and then not l_children.is_empty
		end

	permission_arguments: detachable ITERABLE [READABLE_STRING_8]

	children: detachable LIST [CMS_LINK]

	internal_is_expandable: BOOLEAN

	internal_is_expanded: BOOLEAN

	internal_is_collapsed: BOOLEAN

feature -- Element change

	add_link (lnk: CMS_LINK)
		local
			lst: like children
		do
			lst := children
			if lst = Void then
				create {ARRAYED_LIST [CMS_LINK]} lst.make (1)
				children := lst
			end
			lst.force (lnk)
		end

	remove_link (lnk: CMS_LINK)
		local
			lst: like children
		do
			lst := children
			if lst /= Void then
				lst.prune_all (lnk)
				if lst.is_empty then
					children := Void
				end
			end
		end

	set_children (lst: like children)
		do
			children := lst
		end

feature -- Status change

	set_is_active (b: BOOLEAN)
			-- Set `is_active' to `b'.
		do
			is_active := b
		end

	set_expanded (b: like is_expanded)
		do
			if b then
				set_expandable (True)
				set_collapsed (False)
			end
			internal_is_expanded := b
		end

	set_collapsed (b: like is_collapsed)
		do
			if b then
				set_expanded (False)
			end
			internal_is_collapsed := b
		end

	set_expandable (b: like is_expandable)
		do
			internal_is_expandable := b
		end

	set_permission_arguments (args: like permission_arguments)
		do
			permission_arguments := args
		end

end
