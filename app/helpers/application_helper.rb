module ApplicationHelper

	def page_title
		base_title = "RoR tutorial app"
		if @title.nil?
			base_title
		else
			"#{base_title} | #{@title}"
		end
	end

end
