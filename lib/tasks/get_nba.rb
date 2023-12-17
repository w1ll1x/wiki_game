# lib/tasks/get_nba.rb

require 'nokogiri'
require 'open-uri'
require 'uri'


def download_image(url, filename)
  if url && !url.empty?
    URI.open(url) do |image|
      File.open(filename, 'wb') { |file| file.write(image.read) }
      puts "Downloaded image: #{filename}"
    end
  else
    puts "Invalid URL for image: #{url}"
  end
rescue OpenURI::HTTPError => e
  puts "HTTP Error downloading image from #{url}: #{e.message}"
rescue StandardError => e
  puts "Failed to download image from #{url}: #{e.message}"
end




directory = Rails.root.join('public', 'images')
Dir.mkdir(directory) unless Dir.exist?(directory)



url = 'https://www.nba.com/players'

begin
  doc = Nokogiri::HTML(URI.open(url))

  doc.css('.players-list tbody tr').each do |row|
    name = row.css('.RosterRow_playerName__G28lg p').map(&:text).join(' ')
    position = row.css('td.text')[3].text.strip
    image_url = row.at_css('div.RosterRow_playerHeadshot__tvZOn img')['src']
    filename = "public/images/#{name.gsub(' ', '_').downcase}.png"

    # Now call the download_image method
    download_image(image_url, filename)

    # Create and save the NBAArticle
    article = NbaArticle.new(title: name, description: "", image_path: filename)
    if article.save
      puts "Saved article for #{name}"
    else
      puts "Failed to save article for #{name}: #{article.errors.full_messages.join(', ')}"
    end
  end

  puts "Import completed successfully."
rescue OpenURI::HTTPError => e
  puts "Failed to open URL: #{e.message}"
end
