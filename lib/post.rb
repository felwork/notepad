require 'sqlite3'

# базовый класс "Запись"
class Post

  @@SQL_DB_FILE = 'notepad.sqlite'

  def self.post_types
    { 'Memo' => Memo, 'Task' => Task, 'Link' => Link }
  end

  # Динамическое создание объекта нужного класса из набора возможных детей
  def self.create(type)
    post_types[type].new
  end

  def self.find_by_id(id)
    # Открываем «соединение» с базой SQLite, вызывая метод open класса
    # SQLite3::Database, и сохраняем результат в переменную db
    db = SQLite3::Database.open(@@SQL_DB_FILE)

    # Настройка для объекта db, которая говорит, что результаты из базы должны
    # быть преобразованы в хэш руби.
    db.results_as_hash = true

    # Выполняем наш запрос, вызывая метод execute у объекта db. Он возвращает
    # массив результатов, в нашем случае из одного элемента, т.к. только одна
    # запись в таблице будет соответствовать условию «идентификатор
    # соответствует заданному». Результат сохраняем в переменную result.
    result = db.execute('SELECT * FROM posts WHERE  rowid = ?', id)

    # Закрываем соединение с базой. Оно нам больше не нужно, результат запроса
    # у нас сохранен. Обратите внимание, что это аналогично файлам. Важно
    # закрыть соединение с базой как можно скорее, чтобы другие программы
    # могли пользоваться базой.
    db.close

    if result.empty?
      # Если массив результатов пуст, это означает, что запись не найдена,
      # надо сообщить об этом пользователю и вернуть nil.
      puts "Такой id #{id} не найден в базе :("
      nil
    else
      # Если массив не пустой, значит пост нашелся и лежит первым элементом.
      result = result[0]

      # Вспомним, какая структура у нашего поста в базе. Хэш в переменной
      # result может выглядеть, например, вот так:
      #
      # {
      #   'type' => 'Memo',
      #   'created_at' => '2015-07-26 15:38:26 +0300',
      #   'text' => 'Удачи в прохождении курса!',
      #   'url' => nil,
      #   'due_date' => nil
      # }
      #
      # Самое главное для нас — значение ключа type, т.к. именно там лежит
      # название класса, который нам нужно создать. Создаем с помощью нашего
      # же метода create экземпляр поста, передавая тип поста из ключа массива
      post = create(result['type'])

      # Теперь, когда мы создали экземпляр нужного класса, заполним его
      # содержимым, передав методу load_data хэш result. Обратите внимание,
      # что каждый из детей класса Post сам знает, как ему быть с такими
      # данными.
      post.load_data(result)

      # Возвращаем объект
      post
    end
  end

  def self.find_all(limit, type)
    # Открываем «соединение» с базой SQLite, вызывая метод open класса
    # SQLite3::Database, и сохраняем результат в переменную db
    db = SQLite3::Database.open(@@SQL_DB_FILE)

    db.results_as_hash = false

    # Формируем запрос в базу с нужными условиями: начнем с того, что нам
    # нужны все посты, включая идентификатор из таблицы posts.
    query = 'SELECT rowid, * FROM posts '

    # Если задан тип постов, надо добавить условие на значение поля type
    query += 'WHERE type = :type ' unless type.nil?

    # Сортировка — самые свежие в начале
    query += 'ORDER by rowid DESC '

    # Если задано ограничение на количество постов, добавляем условие LIMIT в
    # самом конце
    query += 'LIMIT :limit ' unless limit.nil?

    # Готовим запрос в базу, как плов :)
    statement = db.prepare query

    # Загружаем в запрос тип вместо плейсхолдера :type, добавляем лук :)
    statement.bind_param('type', type) unless type.nil?

    # Загружаем лимит вместо плейсхолдера :limit, добавляем морковь :)
    statement.bind_param('limit', limit) unless limit.nil?

    # Выполняем запрос и записываем его в переменную result. Там будет массив
    # с данными из базы.
    result = statement.execute!

    # Закрываем запрос
    statement.close

    # Закрываем базу
    db.close

    # Возвращаем результат
    result
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

  # Получает на вход хэш массив данных и должен заполнить свои поля
  def load_data(data_hash)
    @created_at = Time.parse(data_hash['created_at'])
  end

  def to_db_hash
    {
      'type' => self.class.name,
      'created_at' => @created_at.to_s
    }
  end
end
