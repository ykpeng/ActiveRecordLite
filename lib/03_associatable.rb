require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = "#{name}_id".to_sym
    end
    if options[:primary_key]
      @primary_key = options[:primary_key]
    else
      @primary_key = :id
    end
    if options[:class_name]
      @class_name = options[:class_name]
    else
      @class_name = name.to_s.camelcase
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options[:foreign_key]
      @foreign_key = options[:foreign_key]
    else
      @foreign_key = "#{self_class_name.to_s.underscore}_id".to_sym
    end
    if options[:primary_key]
      @primary_key = options[:primary_key]
    else
      @primary_key = :id
    end
    if options[:class_name]
      @class_name = options[:class_name]
    else
      @class_name = name.to_s.camelcase.singularize
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options
    define_method(name) do
      foreign_key_value = send(options.foreign_key)
      options.model_class.where(options.primary_key => foreign_key_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      primary_key_value = send(options.primary_key)
      options.model_class.where(options.foreign_key => primary_key_value)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
