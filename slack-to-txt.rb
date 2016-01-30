require 'date'
require 'json'

channel = ARGV[0]
raise "Provide a channel as an argument!" unless channel

users = JSON.parse(File.read('users.json')).map do |user|
  [user["id"], user]
end.to_h
days =
  Dir.glob("#{channel}/*.json").map(&File.method(:read)).map(&JSON.method(:parse))


def replace_users(message, users)
  users.reduce(message) do |message, (id, user)|
    message.gsub(user["id"], user["name"])
  end
end

messages = days.flat_map do |messages|
  messages.select { |m| m["type"] == "message" }.map do |m|
    {
      user: users.fetch(m.fetch("user",""),{}).fetch("name", "Unknown"),
      time: DateTime.strptime(m["ts"], "%s"),
      text: replace_users(m["text"], users),
    }
  end
end

messages.each do |message|
  print "<#{message[:time].strftime("%Y-%m-%d %H:%M:%S")}:#{message[:user]}>"
  print message[:text]
  print "\n"
end
