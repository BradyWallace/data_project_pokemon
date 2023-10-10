require "csv"
require "net/http"
require "json"
require "nokogiri"

# 5 tables are being created from 3 sources.
# The Types table is created from a CSV file, consists of the names of the ~20 Types in the Pokemon series.
# The Abilities table is created from an XML document, holds the info of the ~200 Abilities in the Pokemon series.
# The Pokemons table is created from the PokéAPI through 2 API calls, holds the info of the original 151 Pokemon (Gen 1).
# The PokemonTypes table is created to resolve the many-to-many relationship of pokemon and types.
# The PokemonAbilities table is created to resolve the many-to-many relationship of pokemon and abilities.

PokemonType.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='pokemon_types';")
PokemonAbility.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='pokemon_abilities';")
Type.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='types';")
Ability.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='abilities';")
Pokemon.delete_all
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='pokemons';")

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

  # Seeding pokemon types
  poke_data["types"].each do |type_info|
    type = Type.find_by(name: type_info["type"]["name"])
    PokemonType.create(pokemon:, type:)
  end

  # Seeding pokemon abilities
  poke_data["abilities"].each do |ability_info|
    ability_name = ability_info["ability"]["name"].downcase
    ability_name.sub! "-", " "
    ability = Ability.find_by(name: ability_name)
    PokemonAbility.create(pokemon:, ability:)
  end
end

puts "Created #{Type.count} Types."
puts "Created #{Ability.count} Abilities."
puts "Created #{Pokemon.count} Pokemon."
puts "Created #{PokemonType.count} Pokemon Types."
puts "Created #{PokemonAbility.count} Pokemon Abilities."
