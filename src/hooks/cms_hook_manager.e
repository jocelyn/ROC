note
	description: "Hooks manager."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_HOOK_MANAGER

create
	make

feature {NONE} -- Initialization	

	make
		do
			create all_subscribers.make (0)
		end

feature -- Access

	subscribers (a_type: TYPE [CMS_HOOK]): detachable LIST [CMS_HOOK]
			-- Subscribers of hook typed `a_type'.
		do
			Result := all_subscribers.item (a_type)
		end

--feature -- Invocation

--	invoke_module_hook (args: TUPLE; a_type: TYPE [CMS_HOOK])
--			-- Invoke module hook typed `a_type' with argument `args'.
--		do
--			if attached subscribers (a_type) as lst then
--				across
--					lst as ic
--				loop
--					if
--						attached {CMS_HOOK_WITH_WRAPPER} ic.item as hw and then
--						attached hw.wrapper as w
--					then
--						if w.valid_arguments (args) then
--							w.invoke (args)
--						end
--					end
--				end
--			end
--		end

feature -- Change

	subscribe_to_hook (h: CMS_HOOK; a_hook_type: TYPE [CMS_HOOK])
			-- Subscribe `h' to hooks identified by `a_hook_type'.
		local
			lst: detachable LIST [CMS_HOOK]
		do
			lst := all_subscribers.item (a_hook_type)
			if lst = Void then
				create {ARRAYED_LIST [CMS_HOOK]} lst.make (1)
				all_subscribers.force (lst, a_hook_type)
			end
			if not lst.has (h) then
				lst.force (h)
			end
		end

feature {NONE} -- Implementation

	all_subscribers: HASH_TABLE [LIST [CMS_HOOK], TYPE [CMS_HOOK]]

invariant
	all_subscribers /= Void

note
	copyright: "2011-2015, Jocelyn Fiat, Javier Velilla, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
end

