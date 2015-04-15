note
	description: "Summary description for {CMS_NODE_CONTENT_TYPE_WEBFORM_MANAGER}."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_NODE_CONTENT_TYPE_WEBFORM_MANAGER [G -> CMS_NODE]

inherit
	CMS_CONTENT_TYPE_WEBFORM_MANAGER
		redefine
			content_type
		end

create
	make

feature -- Access

	content_type: CMS_CONTENT_TYPE
			-- Associated content type.	

feature -- Forms ...		

	fill_edit_form (response: NODE_RESPONSE; f: CMS_FORM; a_node: detachable like new_node)
		local
			ti: WSF_FORM_TEXT_INPUT
			fset: WSF_FORM_FIELD_SET
			ta: WSF_FORM_TEXTAREA
			tselect: WSF_FORM_SELECT
			opt: WSF_FORM_SELECT_OPTION
		do
			create ti.make ("title")
			ti.set_label ("Title")
			ti.set_size (70)
			if a_node /= Void then
				ti.set_text_value (a_node.title)
			end
			ti.set_is_required (True)
			f.extend (ti)

			f.extend_html_text ("<br/>")

			create ta.make ("body")
			ta.set_rows (10)
			ta.set_cols (70)
			if a_node /= Void then
				ta.set_text_value (a_node.content)
			end
--			ta.set_label ("Body")
			ta.set_description ("This is the main content")
			ta.set_is_required (False)

			create fset.make
			fset.set_legend ("Body")
			fset.extend (ta)

			fset.extend_html_text ("<br/>")

			create tselect.make ("format")
			tselect.set_label ("Body's format")
			tselect.set_is_required (True)
			across
				 content_type.available_formats as c
			loop
				create opt.make (c.item.name, c.item.title)
				if attached c.item.html_help as f_help then
					opt.set_description ("<ul>" + f_help + "</ul>")
				end
				tselect.add_option (opt)
			end
			if a_node /= Void and then attached a_node.format as l_format then
				tselect.set_text_by_value (l_format)
			end

			fset.extend (tselect)

			f.extend (fset)

		end

	change_node	(response: NODE_RESPONSE; fd: WSF_FORM_DATA; a_node: like new_node)
		local
			b: detachable READABLE_STRING_8
			f: detachable CONTENT_FORMAT
		do
			if attached fd.integer_item ("id") as l_id and then l_id > 0 then
				check a_node.id = l_id end
			end
			if attached fd.string_item ("title") as l_title then
				a_node.set_title (l_title)
			end

			if attached fd.string_item ("body") as l_body then
				b := l_body
			end
			if attached fd.string_item ("format") as s_format and then attached response.api.format (s_format) as f_format then
				f := f_format
			elseif a_node /= Void and then attached a_node.format as s_format and then attached response.api.format (s_format) as f_format then
				f := f_format
			else
				f := response.api.formats.default_format
			end
			if b /= Void then
				a_node.set_content (b, Void, f.name) -- FIXME: summary
			end
		end

	new_node (response: NODE_RESPONSE; fd: WSF_FORM_DATA; a_node: detachable like new_node): like content_type.new_node
			-- <Precursor>
		local
			b: detachable READABLE_STRING_8
			f: detachable CONTENT_FORMAT
			l_node: detachable like new_node
		do
			l_node := a_node
			if attached fd.integer_item ("id") as l_id and then l_id > 0 then
				if l_node /= Void then
					check l_node.id = l_id end
				else
					if attached {like new_node} response.node_api.node (l_id) as n then
						l_node := n
					else
						-- FIXME: Error
					end
				end
			end
			if attached fd.string_item ("title") as l_title then
				if l_node = Void then
					l_node := content_type.new_node (Void)
					l_node.set_title (l_title)
				else
					l_node.set_title (l_title)
				end
			else
				if l_node = Void then
					l_node := content_type.new_node_with_title ("...", Void)
				end
			end
			l_node.set_author (response.user)

			if attached fd.string_item ("body") as l_body then
				b := l_body
			end
			if attached fd.string_item ("format") as s_format and then attached response.api.format (s_format) as f_format then
				f := f_format
			elseif a_node /= Void and then attached a_node.format as s_format and then attached response.api.format (s_format) as f_format then
				f := f_format
			else
				f := response.api.formats.default_format
			end
			if b /= Void then
				l_node.set_content (b, Void, f.name)
			end
			Result := l_node
		end

end

