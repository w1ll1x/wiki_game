class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def quiz
    @correct_count = 0
    @incorrect_count = 0
    @article = Article.order("RANDOM()").first
    @correct_title = @article.title
    puts "Correct Title: #{@correct_title}"
    @possible_titles = Article.where.not(title: @correct_title).sample(3).pluck(:title)
    @possible_titles << @correct_title
    @possible_titles.shuffle!
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
