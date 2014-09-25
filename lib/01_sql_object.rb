require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    column_syms = DBConnection.execute(<<-SQL)
      PRAGMA table_info(#{table_name})
    SQL
      .map{ |row| row["name"].to_sym }
    column_syms.each do |sym|
      define_method(sym) { attributes[sym] }

      define_method("#{sym}="){ |value| attributes[sym] = value }
    end

    column_syms
  end

  def self.finalize!
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= name.pluralize.underscore
  end

  def self.all
    parse_all(
      DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL
    )
  end

  def self.parse_all(results)
    results.map do |row|
      new(row)
    end
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    @attributes = Hash.new
    params.each do |key, value|
      if self.class.columns.include?(key.to_sym)
        @attributes[key.to_sym] = value
      else
        raise "unknown attribute '#{key}'"
      end
    end
  end

  def attributes
    @attributes
  end

  def attribute_values
    @attributes.values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
