require "csv"
require "net/http"
require "json"
require "nokogiri"

Type.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='type';")
Ability.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='ability';")

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

# Seeding Abilities from XML file
xmlfilename = Rails.root.join("db/abilities.xml")
puts "Loading Abilities from the XML file: #{xmlfilename}"
doc = Nokogiri::XML(File.open(xmlfilename))
doc.xpath("//row").each do |abt|
  name = abt.at_xpath("name").text
  description = abt.at_xpath("description").text
  ability = Ability.create(
    name:        name.downcase,
    description:
  )
  puts "Invalid ability #{name}" unless ability&.valid?
end

puts "Created #{Type.count} Types."
puts "Created #{Ability.count} Abilities."
