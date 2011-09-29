#
# Gives all the Ruby base types (String, Hash, nil, etc.) a "blank?" method.
#

class Float
  #
  # 'true' if the float is 0.0
  #
  def blank?; self == 0.0; end
end

class NilClass
  #
  # Always 'true'; nil is considered blank.
  #
  def blank?; true; end
end

class Symbol
  #
  # Symbols are never blank.
  #
  def blank?; false; end
end

class Integer
  #
  # 'true' if the integer is 0
  #
  def blank?; self == 0; end
end

class String
  #
  # 'true' if the string's length is 0 (after whitespace has been stripped from the ends)
  #
  def blank?; strip.size == 0; end
end

module Enumerable
  #
  # 'true' if the Enumerable has no elements
  #
  def blank?; not any?; end
end

