require_relative "../config/environment.rb"

class Student
attr_accessor :name, :grade, :id


  def initialize(name,grade,id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  
  
  def self.new_from_db(row)
    student = self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end




end
