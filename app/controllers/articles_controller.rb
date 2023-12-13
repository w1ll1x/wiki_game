class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def quiz
    @correct_count = 0
    @incorrect_count = 0


    # Select a random category to use for this quiz instance.
    # This assumes you have a 'type' column in your 'articles' table for STI.
    category_types = %w[MusicArticle] #HistoryArticle TechnologyArticle ArtsArticle GeographyArticle
    category_type = category_types.sample

    # Fetch a random article from the selected category.
    # Since we are using STI, Rails will automatically query the 'type' column.
    @article = category_type.constantize.order('RANDOM()').first
    @correct_title = @article.title
    puts "Correct Title: #{@correct_title}"

    # Fetch three more titles from the same category for the options.
    @possible_titles = category_type.constantize
                                    .where.not(id: @article.id)
                                    .order('RANDOM()')
                                    .limit(3)
                                    .pluck(:title)
    @possible_titles << @correct_title
    @possible_titles.shuffle!

    # Reset or initialize the counts.
    @correct_count = session[:correct_count] || 0
    @incorrect_count = session[:incorrect_count] || 0


  end

  def quiz_submit
    selected_title = params[:selected_title]
    correct_title = params[:correct_title]

    puts "Comparing: #{selected_title}, and #{correct_title}"
    if selected_title == correct_title
      flash[:notice] = 'Correct!'
      @correct_count ||= 0
      @correct_count += 1
    else
      flash[:alert] = "Incorrect, the title was #{correct_title}"
      @incorrect_count ||= 0
      @incorrect_count += 1
    end

    puts "The correct count: #{@correct_count}"

    # Redirect to the quiz and display flash messages
    redirect_to quiz_path
  end
end
