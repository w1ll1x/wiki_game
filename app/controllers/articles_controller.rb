class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def quiz
    # Initialize the counts from the session
    @correct_count = session[:correct_count] || 0
    @incorrect_count = session[:incorrect_count] || 0

    # Determine the category
    if params[:category]
      # Set the category from params and store it in the session
      category_type = params[:category]
      session[:quiz_category] = category_type
    elsif session[:quiz_category]
      # Get the category from the session if not provided in params
      category_type = session[:quiz_category]
    else
      # Default category if none is set
      category_type = 'MusicArticle'
      session[:quiz_category] = category_type
    end

    # Ensure the category is one of the allowed types
    allowed_category_types = %w[MusicArticle BangladeshArticle BirdArticle NbaArticle]
    category_type = 'MusicArticle' unless allowed_category_types.include?(category_type)

    @category_type = category_type

    # Fetch a random article from the selected category
    @article = category_type.constantize.order('RANDOM()').first
    @correct_title = @article.title


    @bird_sound = @article.mp3_file if @article.is_a?(BirdArticle)
    if @category_type == 'NbaArticle'
      @nba_article = NbaArticle.order('RANDOM()').first
      @image_path = @nba_article.image_path.sub(/\Apublic\//, '/') if @nba_article&.image_path.present?
    end


    @possible_titles = category_type.constantize
                                    .where.not(id: @article.id)
                                    .order('RANDOM()')
                                    .limit(3)
                                    .pluck(:title)
    @possible_titles << @correct_title
    @possible_titles.shuffle!



  end

  def quiz_submit
    selected_title = params[:selected_title]
    correct_title = params[:correct_title]

    puts "Comparing: #{selected_title}, and #{correct_title}"
    if selected_title == correct_title
      flash[:notice] = 'Correct!'
      session[:correct_count] = (session[:correct_count] || 0) + 1
    else
      flash[:alert] = "Incorrect, the title was #{correct_title}"
      session[:incorrect_count] = (session[:incorrect_count] || 0) + 1
    end


    puts "The correct count: #{@correct_count}"

    # Redirect to the quiz and display flash messages
    redirect_to quiz_path
  end
  def reset_counts
    # Reset the correct_count and incorrect_count to 0
    session[:correct_count] = 0
    session[:incorrect_count] = 0

    # Redirect back to the quiz page
    redirect_to quiz_path
  end
end
