# lib/tasks/del_n.rb

# Assuming you are using Single Table Inheritance (STI) and the type for NBA articles is 'NBAArticle'

# You can remove the desc line and task block, just keep the content to run
NbaArticle.where(type: 'NbaArticle').destroy_all
puts "All NBA articles have been deleted."
