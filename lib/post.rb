require 'sqlite3'

# базовый класс "Запись"
class Post

  @@SQL_DB_FILE = 'notepad.sqlite'

  def self.post_types
    { 'Memo' => Memo, 'Task'=> Task, 'Link' => Link }
  end

  # Динамическое создание объекта нужного класса из набора возможных детей
  def self.create(type)
    post_types[type].new
  end

  def initialize
    @created_at = Time.now # дата создания записи
    @text = [] # массив строк записи, по умолчанию пустой
  end

  def save_to_db
    # открываем соединение с БД
    db = SQLite3::Database.open(@@SQL_DB_FILE)
    # возвращаемый результат в формате hash
    db.results_as_hash = true

    # добавляем новую запись в БД
    db.execute(
      "INSERT INTO posts (#{to_db_hash.keys.join(',')})" \
      "VALUES (#{('?,' * to_db_hash.keys.size).chomp(',')})",
      to_db_hash.values
    )

    insert_row_id = db.last_insert_row_id

    db.close

    insert_row_id
  end

  def to_db_hash
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
  end
end
