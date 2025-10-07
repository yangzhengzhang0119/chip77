# Add a declarative step here for populating the DB with movies.

# Ensure ApplicationRecord is defined for environments missing the base class.
# class ApplicationRecord < ActiveRecord::Base
#     self.abstract_class = true
#   end

Given(/the following movies exist/) do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(movie)
  end
end

Then(/(.*) seed movies should exist/) do |n_seeds|
  expect(Movie.count).to eq n_seeds.to_i
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When(/^I (un)?check the following ratings:?\s*(.*)$/) do |un, rating_list|
  rating_list.split(',').map(&:strip).each do |rating|
    checkbox_id = "ratings_#{rating}"
    el = find("##{checkbox_id}", visible: :all, match: :first)
    un ? el.uncheck : el.check
  end
end

# Part 2, Step 3
Then(/^I should (not )?see the following movies: (.*)$/) do |no, movie_list|
  movie_list.split(',').map(&:strip).each do |movie|
    if no
      expect(page).not_to have_content(movie)
    else
      expect(page).to have_content(movie)
    end
  end
end

Then(/I should see all the movies/) do
  rows = page.all('#movies tbody tr').count
  expect(rows).to eq(Movie.count)
end

### Utility Steps Just for this assignment.

Then(/^debug$/) do
  # Use this to write "Then debug" in your scenario to open a console.
  require "byebug"
  byebug
  1 # intentionally force debugger context in this method
end

Then(/^debug javascript$/) do
  # Use this to write "Then debug" in your scenario to open a JS console
  page.driver.debugger
  1
end

Then(/complete the rest of of this scenario/) do
  # This shows you what a basic cucumber scenario looks like.
  # You should leave this block inside movie_steps, but replace
  # the line in your scenarios with the appropriate steps.
  raise "Remove this step from your .feature files"
end

Then (/^I should see "(.*)" before "(.*)"$/) do |e1, e2|
  expect(page.body.index(e1)).to be < page.body.index(e2)
end

When(/^I check all the ratings$/) do
  Movie.all.map(&:rating).uniq.each do |rating|
    check("ratings_#{rating}")
  end
end

Then(/^I should see movies rated:?\s*(.*)$/) do |rating_list|
  ratings = rating_list.split(',').map(&:strip)
  Movie.where(rating: ratings).each do |movie|
    expect(page).to have_content(movie.title)
  end
end

Then(/^I should not see movies rated:?\s*(.*)$/) do |rating_list|
  ratings = rating_list.split(',').map(&:strip)
  Movie.where(rating: ratings).each do |movie|
    expect(page).not_to have_content(movie.title)
  end
end
