require 'json'

# This level 0 data markings parser can't even handle object-level markings. Per the conformance requirements it should barf on all of the documents.

# Ability to test whether markings are present
module HasMarkings
  def has_markings?(document)
    (document['marking_refs'] && !document['marking_refs'].empty?) || (document['structured_markings'] && !document['structured_markings'].empty?)
  end
end

class Level0Parser
  include HasMarkings
  attr_accessor :indicators, :errors

  def initialize(path)
    @document = JSON.parse(File.read(path))
    @indicators = []
    if validate(@document)
      @parsed = true
      parse_document
    else
      @parsed = false
    end
  end

  def parsed?
    @parsed
  end

  def validate(document)
    if has_markings?(document)
      add_error "Unable to process package markings"
      return false
    else
      return true
    end
  end

  def parse_document
    @document['indicators'].each do |indicator|
      begin
        @indicators << Indicator.new(indicator)
      rescue Exception => e
        add_error(e.message, indicator)
      end
    end
  end

  def add_error(error, source = @document)
    @errors ||= []
    @errors << [error, source]
  end

  class Indicator
    include HasMarkings
    attr_accessor :id, :title

    def initialize(indicator)
      raise "Unable to process object markings" if has_markings?(indicator)
      self.id = indicator['id']
      self.title = indicator['title']
    end
  end
end
