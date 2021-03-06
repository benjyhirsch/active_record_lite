require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_str = params.keys.map{ |key| "#{key} = ?"}.join(" AND ")

    arr = DBConnection.execute(<<-SQL, *params.values)
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
