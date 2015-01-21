note
	description: "Summary description for {CMS_STORAGE_SQL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_STORAGE_SQL

feature -- Error handler

	error_handler: ERROR_HANDLER
		deferred
		end

feature -- Execution

	sql_begin_transaction
		deferred
		end

	sql_commit_transaction
		deferred
		end

	sql_post_execution
			-- Post database execution.
		deferred
		end

feature -- Operation

	sql_query (a_sql_statement: STRING; a_params: detachable STRING_TABLE [detachable ANY])
		deferred
		end

	sql_change (a_sql_statement: STRING; a_params: detachable STRING_TABLE [detachable ANY])
		deferred
		end

feature -- Access		

	sql_rows_count: INTEGER
			-- Number of rows for last sql execution.	
		deferred
		end

	sql_after: BOOLEAN
			-- Are there no more items to iterate over?	
		deferred
		end

	sql_forth
			-- Fetch next row from last sql execution, if any.
		deferred
		end

	sql_item (a_index: INTEGER): detachable ANY
		deferred
		end

	sql_read_integer_64 (a_index: INTEGER): INTEGER_64
			-- Retrieved value at `a_index' position in `item'.
		local
			l_item: like sql_item
		do
			l_item := sql_item (a_index)
			if attached {INTEGER_64} l_item as i then
				Result := i
			elseif attached {INTEGER_64_REF} l_item as l_value then
				Result := l_value.item
			else
				Result := sql_read_integer_32 (a_index).to_integer_64
			end
		end

	sql_read_integer_32 (a_index: INTEGER): INTEGER_32
			-- Retrieved value at `a_index' position in `item'.
		local
			l_item: like sql_item
		do
			l_item := sql_item (a_index)
			if attached {INTEGER_32} l_item as i then
				Result := i
			elseif attached {INTEGER_32_REF} l_item as l_value then
				Result := l_value.item
			else
--				check is_integer_32: False end
			end
		end

	sql_read_string (a_index: INTEGER): detachable STRING
			-- Retrieved value at `a_index' position in `item'.
		local
			l_item: like sql_item
		do
			l_item := sql_item (a_index)
			if attached {READABLE_STRING_8} l_item as l_string then
				Result := l_string
			elseif attached {BOOLEAN} l_item as l_boolean then
				Result := l_boolean.out
			elseif attached {BOOLEAN_REF} l_item as l_boolean_ref then
				Result := l_boolean_ref.item.out
			else
--				check is_string: False end
			end
		end

	sql_read_string_32 (a_index: INTEGER): detachable STRING_32
			-- Retrieved value at `a_index' position in `item'.
		local
			l_item: like sql_item
		do
			-- FIXME: handle string_32 !
			l_item := sql_item (a_index)
			if attached {READABLE_STRING_32} l_item as l_string then
				Result := l_string
			else
				if attached sql_read_string (a_index) as s8 then
					Result := s8.to_string_32 -- FIXME
				end
			end
		end

	sql_read_date_time (a_index: INTEGER): detachable DATE_TIME
			-- Retrieved value at `a_index' position in `item'.
		local
			l_item: like sql_item
		do
			l_item := sql_item (a_index)
			if attached {DATE_TIME} l_item as dt then
				Result := dt
			else
--				check is_date_time: False end
			end
		end

	sql_read_boolean (a_index: INTEGER): detachable BOOLEAN
			-- Retrieved value at `a_index' position in `item'.
		local
			l_item: like sql_item
		do
			l_item := sql_item (a_index)
			if attached {BOOLEAN} l_item as l_boolean then
				Result := l_boolean
			elseif attached {BOOLEAN_REF} l_item as l_boolean_ref then
				Result := l_boolean_ref.item
			else
				check is_boolean: False end
			end
		end

end
