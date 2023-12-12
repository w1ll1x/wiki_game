require 'open-uri'
require 'json'
require 'nokogiri'

# Wikipedia API URL for a random article
url = "https://en.wikipedia.org/w/api.php?format=json&action=query&generator=random&grnnamespace=0&prop=extracts&exintro=true&explaintext=true&grnlimit=1"


# Set a counter to keep track of the number of entries created
counter = 0

while counter < 1000
  begin
    response = URI.open(url).read

    # Parse the JSON response
    data = JSON.parse(response)

    # Extract the article information
    page = data['query']['pages'].values[0]
    title = page['title']
    description = page['extract']

    if title.empty? || description.nil? || description.strip.empty?
      puts "Skipping article with empty title or description."
    else
      if description.length < 100 || description.length > 1500
        puts "Article is too short or maybe actuall too long"
      else
        # Replace instances of the title with underscores, including variations
        description_text = description.gsub(/\b(#{Regexp.escape(title)})\b/i, '_____')
        # Replace instances of bracketed numbers like [1] or [4]
        description_text = description_text.gsub(/\[\d+\]/, '')

        # Split the title into keywords
        title_keywords = title.split(/\s+/)

        # Check if any title keywords are still present in the description_text
        if title_keywords.any? { |keyword| description_text.include?(keyword) }
          puts "Skipping article with keywords in the description: #{title}"
        else
          # Create a new Article instance and save it to the database
          article = Article.create(title: title, description: description_text)

          if article.persisted?
            puts "Created Article ##{counter + 1}: #{title}"
            counter += 1
          else
            puts "Failed to save Article ##{counter + 1}: #{title}"
          end
        end
      end
    end
  rescue StandardError => e
    puts "An error occurred: #{e.message}"
  end
end