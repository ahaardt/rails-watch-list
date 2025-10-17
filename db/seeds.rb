# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


require 'httparty'

puts 'Cleaning DB'
Movie.destroy_all
puts 'DB clean'

API_KEY = ENV.fetch('TMBD_API_KEY')
IMAGE_BASE_URL = 'https://image.tmdb.org/t/p/w500'

(1..50).each do |page|
  url = "https://api.themoviedb.org/3/movie/top_rated?api_key=#{API_KEY}&language=en-US&page=#{page}"
  response = HTTParty.get(url)

  if response.success?
    movies = response.parsed_response['results']
    movies.each do |movie_data|
      Movie.create!(
          title: movie_data['title'],
          overview: movie_data['overview'],
          poster_url: "#{IMAGE_BASE_URL}#{movie_data['poster_path']}",
          rating: movie_data['vote_average']
        )
    end
  else
    puts 'Error fetching movie'
  end
end
