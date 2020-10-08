class Dog
  attr_accessor :name, :breed, :id
  
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end
  
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  
  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs(name, breed) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  end
  
  
  def self.create(name:, breed:)
    dog = self.new(name, breed)
    dog.save
    dog
  end
  
  
  def self.new_from_db(row)
    dog = self.new(id: [0], name: [1], breed: [2])
    dog
  end
  
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.id = ?
    SQL
    returns = DB[:conn].execute(sql, id)[0]
    self.new_from_db(returns[0], returns[1], returns[2])
  end
  
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      dog = dog[0]
      dog = self.new(dog[0], dog[1], dog[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  
  
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE dogs.name = ?
    SQL
    returns = DB[:conn].execute(sql, name)[0]
    self.new_from_db(returns)
  end
  
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end



