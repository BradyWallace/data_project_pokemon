require "csv"
require "net/http"
require "json"

Type.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='type';")

# Seeding Types from CSV file
filename = Rails.root.join("db/types.csv")
puts "Loading Types from the CSV file: #{filename}"
csv_data = File.read(filename)
types = CSV.parse(csv_data, headers: true, encoding: "utf-8")
types.each do |t|
  type = Type.create(
    name: t["name"]
  )
  puts "Invalid type #{t['name']}" unless type&.valid?
end

puts "Created #{Type.count} Types."
