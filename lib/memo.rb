# Класс "Заметка", разновидность базового класса "Запись"
class Memo < Post

  # Этот метод пока пустой, он будет спрашивать ввод содержимого Заметки
  # наподобие программы Дневник из "базового блока" курса
  def read_from_console
    # Метод, который спрашивает у пользователя, что он хочет написать в дневнике
    puts 'Я сохраню всё, что ты напишешь до строчки "end" в файл.'

    # Объявим переменную, которая будет содержать текущую введенную строку
    line = nil

    # Запустим цикл, пока не дошли до строчки "end",
    while line != 'end'
      # Читаем очередную строку и записываем в массив @text
      line = $stdin.gets.chomp
      @text << line
    end

    # Теперь удалим последний элемент из массива @text – там служебное слово "end"
    @text.pop
  end

  def to_db_hash
    super.merge(
      {
        'text' => @text.join('\n')
      }
    )
  end

  def to_strings
    time_string = "Создано: #{@created_at.strftime('%Y.%m.%d, %H:%M:%S')}\n"

    @text.unshift(time_string)
  end

  def load_data(data_hash)
    super(data_hash) # сперва дергаем родительский метод для общих полей

    # теперь прописываем свое специфичное поле
    @text = data_hash['text'].split('\n\r')
  end
end
