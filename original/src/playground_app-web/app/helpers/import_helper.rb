module ImportHelper

	# This function creates a hash of green link info given 
	# a proteopedia article ID
	#
	def green_from_xml(article_id)
    require('open-uri')
    xml_url = "http://proteopedia.org/cgi-bin/send2MolecularPlayground?" + article_id
    xml_data = open(xml_url).read
    scene_hash = Hash.from_xml(xml_data)
    @scenes = []
    if scene_hash["proteopedia"]["scene"].is_a? Hash
    	item = {}
    	item[:title] = scene_hash["proteopedia"]["scene"]["HOT"]
    	item[:url] = scene_hash["proteopedia"]["scene"]["URL"]
        item[:png] = scene_hash["proteopedia"]["scene"]["PNG"]
    	@scenes << item
    end
    if scene_hash["proteopedia"]["scene"].is_a? Array
        scene_hash["proteopedia"]["scene"].each do |scene|
		  item = {}
		  item[:title] = scene["HOT"]
		  item[:url] = scene["URL"]
          item[:png] = scene["PNG"]
      	  @scenes << item
    	end
    end

    @scenes
  end

 end