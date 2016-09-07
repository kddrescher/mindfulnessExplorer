require 'nokogiri'
require 'highline/import'

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
# accessibilizeHTMLPages
#
def accessibilizeHTMLPages
  Dir.glob('./HTML/*.html') do |path|
    pathname = Pathname.new(path)

    # Skip the layout file
    next if pathname.basename.to_s == "layout.html"

    puts "* #{pathname.basename}"
    accessibilized_html = nil

    File.open(path) do |file|
      # Need to read the file into a string so that we can use HTML.fragment.
      # We want to use HTML.fragment so that Nokogiri doesn't wrap document
      # tags around our HTML when we save it back to file.
      raw_html = file.read
      page = Nokogiri::HTML.fragment(raw_html)
      
      # Iterate over every img tag in the document and ask the user
      # for an alt tag description of the image if one is not present.
      page.css("img").each do |image_tag|
        alt = image_tag.get_attribute('alt')
        if alt.blank?
          puts "#{path} -> #{image_tag}"
          image_src = image_tag.get_attribute('src')
          image_src = image_tag.get_attribute('data-lowres') if image_src == "placeholderSlug.png"
          `open HTML/Images/#{image_src}`
          label = ask("> ")
          image_tag.set_attribute("alt", label)
          puts ""
        end
      end

      accessibilized_html = page.to_html
    end
    
    # Save the changes back to disk.
    File.open(path, "w+") { |f| f.write(accessibilized_html) } unless accessibilized_html.blank?
    accessibilized_html = nil
  end
end

#
# main
#
accessibilizeHTMLPages
