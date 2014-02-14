class AddTweetIdColumn < ActiveRecord::Migration
  def up
    add_column :tweets, :tweet_id, :integer
  end
end
