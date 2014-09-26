require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    column_syms = DBConnection.execute(<<-SQL)
      PRAGMA table_info(#{table_name})
    SQL
      .map{ |row| row["name"].underscore.to_sym }
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
    arr = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    new(arr.first)
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
    non_id_columns = self.class.columns - [:id]
    question_marks = Array.new(non_id_columns.count, "?").join(", ")
    values = non_id_columns.map{ |col| attributes[col] }
    DBConnection.execute(<<-SQL, *values)
          INSERT INTO
            #{self.class.table_name} (#{non_id_columns.join(", ")})
          VALUES
            (#{question_marks})
        SQL
    @attributes[:id] = DBConnection.last_insert_row_id
  end

  def update
    attributes_to_update = attributes.keys - [:id]
    values = attributes_to_update.map{ |key| attributes[key] }
    DBConnection.execute(<<-SQL, *values)
          UPDATE
            #{self.class.table_name}
          SET
            #{attributes_to_update.map{ |col| "#{col} = ?"}.join(", ")}
          WHERE
            id = #{id}
        SQL
    @attributes[:id] = DBConnection.last_insert_row_id
  end

  def save
    id ? update : insert
  end
end
