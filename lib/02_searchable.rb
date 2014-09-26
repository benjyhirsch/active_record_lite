require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    keys, values = params.to_a.transpose
    where_str = keys.map{ |key| "#{key} = ?"}.join(" AND ")

    arr = DBConnection.execute(<<-SQL, *values)
          SELECT
            *
          FROM
            #{table_name}
          WHERE
            #{where_str}
        SQL

    parse_all(arr)
  end
end

class SQLObject
  extend Searchable
end
