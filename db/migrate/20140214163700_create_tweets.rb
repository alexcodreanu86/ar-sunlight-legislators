class CreateTweets < ActiveRecord::Migration
  create_table :tweets do |t|
    t.integer :legislator_id
    t.string :tweet
  end
end

