require "csv"
require "net/http"
require "json"
require "nokogiri"

Type.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='type';")
Ability.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='ability';")
Pokemon.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='pokemon';")

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

# Seeding Pokemon names and dex numbers
url = "https://pokeapi.co/api/v2/generation/1"
uri = URI(url)
puts "Loading generation 1 Pokemon from the PokéAPI: https://pokeapi.co/api/v2/generation/1"
response = Net::HTTP.get(uri)
gen_data = JSON.parse(response)
all_pokemon = gen_data["pokemon_species"]

# Getting the name and dex data on each pokemon
all_pokemon.each do |poke_call|
  poke_url = "https://pokeapi.co/api/v2/pokemon/#{poke_call['name']}"
  poke_uri = URI(poke_url)
  poke_resp = Net::HTTP.get(poke_uri)
  poke_data = JSON.parse(poke_resp)

  pokemon = Pokemon.create(
    name: poke_data["name"].capitalize,
    dex:  poke_data["id"]
  )
  puts "Invalid pokemon #{poke_data['name']}" unless pokemon&.valid?
end

# rails g model PokemonType pokemon:references type:references
# rails g model PokemonAbility pokemon:references ability:references

puts "Created #{Type.count} Types."
puts "Created #{Ability.count} Abilities."
puts "Created #{Pokemon.count} Pokemon."
