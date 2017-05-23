require "pry"

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name: name, breed: breed, id: nil)
    @name, @breed, @id = name, breed, id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(dog_hash)
    dog = Dog.new
    dog.name = dog_hash[:name]
    dog.breed = dog_hash[:breed]
    dog.save
  end

  def self.new_from_db(row)
    id, name, breed = row
    new_dog = Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql,id)[0]
    new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql,name)[0]
    new_from_db(row)
  end

  def self.find_or_create_by(name: name, breed: breed)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
       if !dog.empty?
         dog_data = dog[0]
         dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
       else
         dog = self.create(name: name, breed: breed)
       end
       dog
     end



end
