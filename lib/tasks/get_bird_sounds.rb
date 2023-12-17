require 'open-uri'
require 'active_record'
require_relative '../../config/environment'

url = 'https://www.mbr-pwrc.usgs.gov/id/htmwav2/h3680sh.mp3'
filename = 'Barred-owl.mp3'


URI.open(url) do |file|
  File.open(filename, 'wb') do |output|
    output.write(file.read)
  end
end

puts "Downloaded #{filename}"


class CreateBirdArticle
  def self.run(mp3_path)
    bird_article = BirdArticle.new(title: 'Barred Owl', description: 'Song')

    if File.exist?(mp3_path) && File.extname(mp3_path).downcase == '.mp3'
      bird_article.mp3_file.attach(io: File.open(mp3_path), filename: File.basename(mp3_path))
      if bird_article.save
        puts "BirdArticle with MP3 file was successfully created."
      else
        puts "Failed to create BirdArticle. Errors: #{bird_article.errors.full_messages.join(', ')}"
      end
    else
      puts "Invalid file path or the file is not an MP3."
    end
  end
end

if ARGV.length != 1
  puts "Usage: ruby script/create_bird_article.rb <mp3_path>"
else
  CreateBirdArticle.run(ARGV[0])
end

