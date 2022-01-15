# Класс Ссылка, разновидность базового класса "Запись"
class Link < Post

  def initialize
    super # вызываем конструктор родителя

    # потом инициализируем специфичное для ссылки поле
    @url = ''
  end

  # Этот метод пока пустой, он будет спрашивать 2 строки — адрес ссылки и описание
  def read_from_console
    # Мы полностью переопределяем метод read_from_console родителя Post

    # Попросим у пользователя адрес ссылки
    puts 'Введите адрес ссылки'
    @url = $stdin.gets.chomp

    # И описание ссылки (одной строчки будет достаточно)
    puts 'Напишите пару слов о том, куда ведёт ссылка'
    @text = $stdin.gets.chomp
  end

  def to_db_hash
    super.merge(
      {
        'text' => @text,
        'url' => @url
      }
    )
  end

  def to_strings
    time_string = "Создано: #{@created_at.strftime('%Y.%m.%d, %H:%M:%S')} \n"

    [@url, @text, time_string]
  end

  def load_data(data_hash)
    super(data_hash) # сперва дергаем родительский метод для общих полей

    # теперь прописываем свое специфичное поле
    @url = data_hash['url']
  end
end
