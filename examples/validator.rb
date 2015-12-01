require 'json-schema'
require 'json'

class Validator
  def initialize(schema)
    @schema = JSON.parse(File.read(schema))
  end

  def validate(json)
    begin
      json = JSON.load(File.read(json))
    rescue
      puts ": Parse error"
      return
    end
    Dir.chdir("../schema") do
      results = JSON::Validator.fully_validate(@schema, json, :errors_as_objects => true)
      if results.length == 0
        puts ": Valid"
      else
        puts ": Invalid: #{results[0].inspect}"
      end
    end
  end
end

validator = Validator.new("../schema/package.json")

Dir.glob("*.json").each do |sample|
  print "Validating #{sample}"
  validator.validate(sample).inspect
end
