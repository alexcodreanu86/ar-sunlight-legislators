require_relative '../../db/config'
require_relative 'tweets.rb'
require 'sqlite3'
require 'twitter'
require 'faraday'

class Legislator < ActiveRecord::Base
  has_many :tweets
  def self.state_legislators(state)
    puts "Senators:"
      self.where("state = ? AND title = 'Sen'", state).each {|leg| puts "\t#{leg.firstname} #{leg.lastname} (#{leg.party})" }
    puts "Representatives:"
      self.where("state = ? AND title = 'Rep'", state).each {|leg| puts "\t#{leg.firstname} #{leg.lastname} (#{leg.party})" }
    nil
  end

  def self.gender_percentages(sex)
    sen_number = self.where("gender = ? AND title = 'Sen' AND in_office = '1'", sex.capitalize[0]).count
    sen_percentage = ((sen_number / self.where("title = 'Sen' AND in_office = '1'").count.to_f) * 100).round
    puts "#{sex.capitalize} Senators: #{sen_number} (#{sen_percentage}%)"

    rep_number = self.where("gender = ? AND title = 'Rep' AND in_office = '1'", sex.capitalize[0]).count
    rep_percentage = ((rep_number / self.where("title = 'Rep' AND in_office = '1'").count.to_f) * 100).round
    puts "#{sex.capitalize} Representatives: #{rep_number} (#{rep_percentage}%)"
  end

  def self.active_legislators
    self.where()
    states_numbers =  self.select("state").group("state").order("count(id) DESC").count
    states_numbers.each do |state, count|
      rep_num = self.where(state: state, in_office: "1", title: "Rep").count
      sen_num = self.where(state: state, in_office: "1", title: "Sen").count
      puts "#{state} Senators: #{sen_num}, Representative(s): #{rep_num}" if !(rep_num.zero? || sen_num.zero?)
    end
    true
  end

  def self.all_legislators
    senators = self.where("title = 'Sen'").count
    representatives = self.where("title = 'Rep'").count
    puts "Senators: #{senators}"
    puts "Representatives: #{representatives}"
  end

  def self.delete_inactive_legislators
    self.destroy_all(in_office: 0)
  end


  def self.client
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        =
      config.consumer_secret     =
      config.access_token        =
      config.access_token_secret =
    end
    client
  end

  def self.search(twitter_id, amount)
    tweets = client.search(twitter_id, :result_type => "recent").take(amount)
  end

  def self.grab_twitter_ids
    self.all.map(&:twitter_id)
  end

  def get_last_tweets
    if twitter_id != ""
      tweets = self.class.search(twitter_id, 10)
      save_tweets(tweets)
      tweets
    else
      puts "This Legislator has no twitter id..... Sucker"
    end
  end

  def save_tweets(tweets_container)
    tweets_container.each do |twt|
      self.tweets << Tweet.new(tweet: twt.text, tweet_id: twt.id)
    end
  end
end
# Legislator.select("state, title").group("state","title").order("count(id)").count
