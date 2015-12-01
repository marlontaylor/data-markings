require 'json'

# This level 1 data markings parser handles L1 markings but not L2 markings.

# Ability to test whether markings are present
module HasMarkings
  def has_level2_markings?(document)
    document['structured_markings'] && !document['structured_markings'].empty?
  end
end

class Level1Parser
  include HasMarkings
  attr_accessor :indicators, :errors, :markings

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
    if has_level2_markings?(document)
      add_error "Unable to process package markings"
      return false
    else
      return true
    end
  end

  def parse_document
    self.markings = resolve_markings(@document['marking_refs'])
    @document['indicators'].each do |indicator|
      begin
        @indicators << Indicator.new(indicator, merge_markings(resolve_markings(indicator['marking_refs']), self.markings))
      rescue MarkingException => e
        add_error(e.message, indicator)
      end
    end
  end

  def resolve_markings(markings)
    if markings.nil?
      []
    else
      markings.map {|m| resolve_marking(m)}
    end
  end

  def merge_markings(own, default)
    default.each do |default_marking|
      own << default_marking unless own.find {|marking| marking['marking_type'] == default_marking['marking_type']}
    end
    return own
  end

  def resolve_marking(marking)
    marking = @document['marking_definitions'].find {|m| m['id'] == marking}
    raise MarkingException, "Unable to resolve marking #{marking}" if marking.nil?
    return marking
  end

  def add_error(error, source = @document)
    @errors ||= []
    @errors << [error, source]
  end

  class Indicator
    include HasMarkings
    attr_accessor :id, :title, :markings

    # Accept markings as a constructor argument so the document can resolve them
    def initialize(indicator, markings)
      raise MarkingException, "Unable to process object markings" if has_level2_markings?(indicator)
      self.markings = markings
      self.id = indicator['id']
      self.title = indicator['title']
    end
  end
end

class MarkingException < StandardError; end
