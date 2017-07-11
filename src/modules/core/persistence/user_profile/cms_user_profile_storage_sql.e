note
	description: "Interface for accessing user profile contents from SQL database."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_USER_PROFILE_STORAGE_SQL

inherit
	CMS_USER_PROFILE_STORAGE_I
		redefine
			user_profile_item,
			save_user_profile_item
		end

	CMS_PROXY_STORAGE_SQL

	CMS_STORAGE_SQL_I

create
	make

feature -- Access

	user_profile_item (a_user: CMS_USER; a_item_name: READABLE_STRING_GENERAL): detachable READABLE_STRING_32
			-- User profile for `a_user'.
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			reset_error
			create l_parameters.make (2)
			l_parameters.put (a_user.id, "uid")
			l_parameters.put (a_item_name, "key")
			sql_query (sql_select_user_profile_item, l_parameters)
			if not has_error then
				Result := sql_read_string_32 (2)
			end
			sql_finalize
		end

	user_profile (a_user: CMS_USER): detachable CMS_USER_PROFILE
			-- User profile for `a_user'.
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			reset_error
			create l_parameters.make (1)
			l_parameters.put (a_user.id, "uid")
			sql_query (sql_select_user_profile_items, l_parameters)
			if not has_error then
				create Result.make
				from
					sql_start
				until
					sql_after or has_error
				loop
					if
						attached sql_read_string_32 (1) as l_key and
						attached sql_read_string_32 (2) as l_val
					then
						Result.force (l_val, l_key)
					end
					sql_forth
				end
			end
			sql_finalize
		end

feature -- Change

	save_user_profile_item (a_user: CMS_USER; a_item_name: READABLE_STRING_GENERAL; a_item_value: READABLE_STRING_GENERAL)
			-- Save user profile item `a_item_name:a_item_value` for `a_user'.
		local
			l_parameters: STRING_TABLE [detachable ANY]
			p: detachable CMS_USER_PROFILE
		do
			create l_parameters.make (3)
			l_parameters.put (a_user.id, "uid")
			l_parameters.put (a_item_name, "key")
			l_parameters.put (a_item_value, "value")

			reset_error
			if user_profile_item (a_user, a_item_name) = Void then
				sql_insert (sql_insert_user_profile_item, l_parameters)
			else
				sql_modify (sql_update_user_profile_item, l_parameters)
			end
			sql_finalize
		end

	save_user_profile (a_user: CMS_USER; a_profile: CMS_USER_PROFILE)
			-- Save user profile `a_profile' for `a_user'.
		local
			l_parameters: STRING_TABLE [detachable ANY]
			p: detachable CMS_USER_PROFILE
			l_item: like user_profile_item
			l_is_new: BOOLEAN
			l_has_diff: BOOLEAN
		do
			p := user_profile (a_user)

			create l_parameters.make (3)

			reset_error
			across
				a_profile as ic
			until
				has_error
			loop
				l_item := ic.item
						-- No previous profile, or no item with same name, or same value
				l_has_diff := True
				if p = Void then
					l_is_new := True
				elseif p.has_key (ic.key) then
					l_is_new := False
					l_has_diff := attached p.item (ic.key) as l_prev_item and then not l_prev_item.same_string (l_item)
				else
					l_is_new := True
				end
				if l_has_diff then
					l_parameters.put (a_user.id, "uid")
					l_parameters.put (ic.key, "key")
					l_parameters.put (l_item, "value")

					if l_is_new then
						sql_insert (sql_insert_user_profile_item, l_parameters)
					else
						sql_modify (sql_update_user_profile_item, l_parameters)
					end
					l_parameters.wipe_out
				end
			end
			sql_finalize
		end

feature {NONE} -- Queries

	sql_select_user_profile_items: STRING = "SELECT key, value FROM user_profiles WHERE uid=:uid;"
			-- user profile items for :uid;

	sql_select_user_profile_item: STRING = "SELECT key, value FROM user_profiles WHERE uid=:uid AND key=:key"
			-- user profile items for :uid;

	sql_insert_user_profile_item: STRING = "INSERT INTO user_profiles (uid, key, value) VALUES (:uid, :key, :value);"
			-- new user profile item for :uid;

	sql_update_user_profile_item: STRING = "UPDATE user_profiles SET value = :value WHERE uid = :uid AND key = :key;"
			-- user profile items for :uid;


end

