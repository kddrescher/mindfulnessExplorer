require 'nokogiri'
require 'pathname'
require 'mini_magick'

# Add a convenience helper method to the String class
String.class_eval do
  # Returns if the string is nil? or empty?
  def blank? 
    self.nil? || self.empty?
  end
end

NilClass.class_eval do
  def blank? 
    true
  end
end

#
# retinizeHTMLPages
#
def retinizeHTMLPages
  # Iterate over all the HTML files
  Dir.glob('./HTML/*.html') do |path|
    pathname = Pathname.new(path)

    # Skip the layout file
    next if pathname.basename.to_s == "layout.html"

    puts "* #{pathname.basename}"
    retinized_html = nil

    File.open(path) do |file|
      # Need to read the file into a string so that we can use HTML.fragment.
      # We want to use HTML.fragment so that Nokogiri doesn't wrap document
      # tags around our HTML when we save it back to file.
      raw_html = file.read
      page = Nokogiri::HTML.fragment(raw_html)
      
      # Iterate over every img tag in the document and convert it
      # to an HTML5 friendly tab for retinization.
      page.css("img").each do |image_tag|

        # Find the image path for the low-res version.
        image_src = image_tag.get_attribute("src")
        if image_src.blank? || image_src == "placeholderSlug.png"
          image_src = image_tag.get_attribute("data-lowres")
        end

        # If we can't find a valid source for this image, then break
        # as an error so that it can be fixed. There's no reason to 
        # continue because all images should have a valid source.
        if image_src.blank?
          puts "  ERROR: Image tag did not define a source. #{img}"
          return
        end  
        
        # Ensure that the image exists
        image_files = Dir.glob(File.join("**", image_src))
        if image_files.empty?
          puts "  ERROR: Image could not be found. #{image_src}"
          return
        end
        
        # Ensure that we don't have two files with the same name.
        if image_files.length > 1
          puts "  ERROR: More than one image file was found. #{image_src}"
          image_files.each { |i| puts "  #{i}" }
          return
        end
        
        # Try and find the retina version of this image
        retina_name = image_src.sub(".png", "@2x.png")
        retina_files = Dir.glob(File.join("**", retina_name))
        if retina_files.empty? 
          puts "  ERROR: Retina image could not be found. #{retina_name}"
          return
        end
        
        if retina_files.length > 1
          puts "  ERROR: More than one retina file was found. #{retina_name}"
          retina_files.each { |i| puts "  #{i}" }
          return
        end
        
        # Find the actual width and height of the image
        mm = MiniMagick::Image.open(image_files[0])
        image_width = mm[:width].to_s
        image_height = mm[:height].to_s

        # See if a width or height attribute was set
        attr_width = image_tag.get_attribute("width")
        attr_height = image_tag.get_attribute("height")
        
        # If they don't match, then error
        unless attr_width.blank? && attr_height.blank? 
          if image_width != attr_width && image_height != attr_height
            puts "  ERROR: Specified sizes don't match actual sizes."
            puts "         Actual width: #{image_width}, Specified width: #{attr_width || '-'}"
            puts "         Actual height: #{image_height}, Specified height: #{attr_height || '-'}"
            return
          end
        end
        
        # Looks good. Update the image's tags
        image_tag.set_attribute("width", image_width)
        image_tag.set_attribute("height", image_height)
        image_tag.set_attribute("data-lowres", image_src)
        image_tag.set_attribute("data-retina", retina_name)
        image_tag.set_attribute("src", "placeholderSlug.png")
      end
      
      retinized_html = page.to_html
    end
    
    # Save the changes back to disk.
    File.open(path, "w+") { |f| f.write(retinized_html) } unless retinized_html.blank?
    retinized_html = nil
  end
end

#
# main
#
retinizeHTMLPages