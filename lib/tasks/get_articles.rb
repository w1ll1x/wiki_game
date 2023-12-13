require 'open-uri'
require 'json'
require 'nokogiri'

# Function to determine the category of an article based on its title
# def determine_category(title)
#
#   # return 'MusicArticle' if title.include?('Physics') || title.include?('Biology')
#   # return 'HistoryArticle' if title.include?('History') || title.include?('War')
#   # return 'TechnologyArticle' if title.include?('Computer') || title.include?('Engineering')
#   # return 'ArtsArticle' if title.include?('Literature') || title.include?('Music')
#   # return 'GeographyArticle' if title.include?('River') || title.include?('Mountain')
#   # return 'PopCultureArticle' if title.include?('Movie') || title.include?('Celebrity')
#   'MusicArticle' # Default category
# end


# Set a counter to keep track of the number of entries created
counter = 0

while counter < 1000
  begin
    # URL to fetch HTML content
    url_to_fetch = "https://magnustools.toolforge.org/randomarticle.php?lang=en&project=wikipedia&categories=Music&d=3"

    # Fetch and read the HTML content from the URL
    html_content = URI.open(url_to_fetch).read

    # Parse the HTML content
    doc = Nokogiri::HTML(html_content)

    # Find the meta tag and extract the URL
    meta_tag = doc.at('meta[http-equiv="refresh"]')
    if meta_tag
      url_content = meta_tag['content']
      url = url_content.split('url=')[1]

      # Extract the title from the URL
      title = url.split('/wiki/').last
    end

    url = "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&titles=#{title}"

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
          # category_class = determine_category(description).constantize
          # Create a new Article subclass instance and save it to the database
          article = MusicArticle.create(title: title, description: description_text)


          if article.persisted?
            puts "Created Article ##{counter + 1}: #{title}, Music"
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