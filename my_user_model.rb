require 'sqlite3'

$db_filename = "db.sql"
$tablename = "users"
# puts "#{$tablename}"

class ConnectionSqlite
    def new
        @db = nil
    end

    # Open a database
    def get_connection
        if @db == nil
            @db = SQLite3::Database.new($db_filename)
            createdb
        end
        @db
    end

    # Create a table
    def createdb
        rows = self.get_connection().execute <<-SQL
        CREATE TABLE IF NOT EXISTS #{$tablename} (
            id INTEGER PRIMARY KEY,
            firstname varchar(30),
            lastname varchar(30),
            age int,
            password varchar(30),
            email varchar(30)
            );
        SQL

    end
    
    def execute(query) 
        self.get_connection().execute(query)
    end
end

class User
    attr_accessor :id, :firstname, :lastname, :age, :password, :email

    def initialize(array)
        @id        = array[0]
        @firstname = array[1]
        @lastname  = array[2]
        @age       = array[3]
        @password  = array[4]
        @email     = array[5]
    end

    def to_hash
        {id: @id, firstname: @firstname, lastname: @lastname, age: @age, password: @password, email: @email}
    end

    def inspect
        %Q|<User id: #{@id}, firstname: "#{@firstname}", lastname: "#{@lastname}", age: #{@age}, password: "#{@password}", email: "#{@email}"g>|
    end

    def self.create(user_info)
        query = <<-REQUEST 
            INSERT INTO #{$tablename} (firstname, lastname, age, password, email) VALUES (
                "#{user_info[:firstname]}", 
                "#{user_info[:lastname]}", 
                "#{user_info[:age]}", 
                "#{user_info[:password]}", 
                "#{user_info[:email]}"
                );
        REQUEST

        ConnectionSqlite.new.execute(query)
    end

    def self.get(user_id)
        query = <<-REQUEST 
            SELECT * FROM #{$tablename} WHERE id = #{user_id};
        REQUEST

        rows = ConnectionSqlite.new.execute(query)
        if rows.any?
            User.new(rows[0])
        else
            nil
        end
    end

    def self.all
        query = <<-REQUEST 
            SELECT * FROM #{$tablename};
        REQUEST

        rows = ConnectionSqlite.new.execute(query)
        if rows.any?
            rows.collect do |row|
                User.new(row)
            end
        else
            []
        end
    end

    def self.update(user_id, attribute, value)
        query = <<-REQUEST
            UPDATE #{$tablename}
            SET #{attribute.to_s} = '#{value}'
            WHERE id = #{user_id};
        REQUEST

        ConnectionSqlite.new.execute(query)
    end

    def self.destroy(user_id)
        query = <<-REQUEST
            DELETE FROM #{$tablename}
            WHERE id = #{user_id};
        REQUEST

        ConnectionSqlite.new.execute(query)
    end
end

def _main()
    # p User.create(firstname: "Neil", lastname: "Ranada", age: 28, password: "secretpassword", email: "neil.ranada@gmail.com")
    # p User.get(1)    
    # p User.all
    # p User.destroy(13)
    # p User.update(8, :email, 'copper@email.com')
    # p User.update(9, :email, 'oscar@email.com')
    # p User.update(10, :email, 'chris@email.com')
    # p User.update(13, :email, 'admin@email.com')
    # User.all.each do |user| 
    #     User.update(user.id, :password, 'password123')
    # end
    # print User.all
end

_main()
