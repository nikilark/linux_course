## Розділ 12: Резервене копіювання та передача файлів по мережі

### Навіщо потрібні резервні копії?

Можливі причини та проблеми:

- Апаратне забезпечення виходить з ладу
- Програмне забезпечення виходить з ладу
- Люди роблять помилки
- Зловмисники можуть завдати навмисної шкоди
- Трапляються незрозумілі події
- Відкат може бути корисним

#### Для чого застосовувати резервне копіювання?

1. Однозначно:
    - Дані, пов`язані з бізнесом.
    - Файли конфігурації системи.
    - Файли користувачів (зазвичай у каталозі `/home`).
2. Можливо:
    - Каталоги спулінгу (для друку, пошти тощо).
    - Файли журналів (знаходяться в `/var/log` та інших місцях).
3. Найімовірніше, ні:
   - Програмне забезпечення, яке можна легко перевстановити; у добре керованій системі це має бути майже все.
   - Каталог `/tmp`
4. Безумовно ні:
   - Псевдофайлові системи, такі як `/proc`, `/dev` і `/sys`, а також `swap`

#### Резервне копіювання системи

Під час створення резервних копій Linux-системи важливо включити певні каталоги, щоб забезпечити можливість відновлення системи та її даних у разі відмови. Ось деякі ключові каталоги, які варто розглянути для створення резервних копій:

1. **/etc**: Містить файли конфігурації системи. Створення резервної копії цього каталогу дозволить відновити конфігурацію системи.

2. **/home**: Містить дані користувачів та особисті файли. Створення резервної копії цього каталогу є важливим для збереження даних користувачів.

3. **/var**: Містить змінні файли даних, такі як логи, бази даних та пошту. Створення резервної копії цього каталогу важливо для збереження стану системи.

4. **/root**: Домашній каталог користувача root. Створення резервної копії цього каталогу дозволить відновити дані та конфігурацію користувача root.

5. **/usr/local**: Містить локально встановлені програми та файли. Створення резервної копії цього каталогу дозволяє відновити локально встановлені додатки.

6. **/opt**: Містить варіантні пакети програмного забезпечення. Створення резервної копії цього каталогу дозволяє відновити варіантні встановлення програмного забезпечення.

7. **/boot**: Містить завантажувач та файли ядра. Створення резервної копії цього каталогу дозволяє відновити конфігурацію завантажувача та ядра.

8. **/srv**: Містить дані, специфічні для служб, такі як веб-сайти або FTP-сервери. Створення резервної копії цього каталогу важливо для збереження даних служб.

9. **/var/lib**: Містить змінну інформацію про стан додатків. Створення резервної копії цього каталогу дозволяє відновити стан додатків.

10. **/var/log**: Містить файли журналу. Створення резервної копії цього каталогу важливо для збереження журналів системи.

11. **/var/spool**: Містить пошту, друк та інші буферизовані дані. Створення резервної копії цього каталогу важливо для збереження буферизованих даних.

12. **/etc/sysconfig**: Містить файли конфігурації для служб системи. Створення резервної копії цього каталогу дозволяє відновити конфігурації служб.

#### Способи резервного копіювання

1. Повний:
    - Створити резервну копію всіх файлів у системі.
2. Інкрементний:
    - Резервне копіювання всіх файлів, які було змінено з часу останнього інкрементного або повного резервного копіювання.
3. Диференціальний:
    - Резервне копіювання всіх файлів, які було змінено з часу останнього повного резервного копіювання.
4. Багаторівневе інкрементне:
    - Резервне копіювання всіх файлів, які змінилися з часу попереднього резервного копіювання на тому самому або попередньому рівні.
5. Користувача:
    - Резервне копіювання лише файлів у каталозі певного користувача.

#### Використання `tar` для резервного копіювання

- Створення архіву: використовуйте -c або просто c

`tar cvf /dev/st0/root`

`tar -cvf /dev/st0 /root`

- Створення з опцією багатотомності: використовуйте -M

`tar -cMf /dev/st0 /root`

Буде запропоновано вставити наступну стрічку

- Перевірка файлів за допомогою опції порівняння: використовується або --compare

`tar -compare -verbose--file /dev/st0`

`tar -dvf /dev/st0`

- Зверніть увагу, що кожна опція має коротку форму (одна літера з -) або довгу форму (з --)
- за замовчуванням `tar` є рекурсивним

#### Використання `tar` для відновлення файлів

Витяг з архіву: використовуйте -x або --extract

`tar --extract --same-permissions --verbose--file /dev/st0`

`tar -xpvf /dev/st0`

`tar xpvf /dev/st0`

Ви можете назвати конкретні файли для відновлення

`tar -xvf /dev/st0 somefile`

- Перерахування вмісту tar-архіву

`tar --list --file /dev/st0`

`tar -tf /dev/st0`

#### Методи стиснення архівів

- Стиснення файлів економить місце на диску та/або час передачі мережею.
- Це досягається за рахунок підвищення ефективності стиснення, що досягається за рахунок збільшення часу стиснення:
**gzip**: Використовує кодування Лемпеля-Зіва (LZ77) і створює файли .gz
**bzip2**: Використовує алгоритм стиснення тексту з блоковим сортуванням Берроуза-Вілера та кодування Хаффмана і створює файли з розширенням .bz2
**xz**: Створює файли .xz, а також підтримує застарілі формати. Формат 1zma
- Сучасні комп`ютери часто вважають цикл стиснення → передача → розпакування швидшим, ніж просто передача (або копіювання) нестисненого файлу.

### Швидке копіювання через мережу

Припустімо, ви хочете скопіювати файл (або файли) зі своєї машини Linux на іншу машину у вашій особистій мережі, і вас не хвилює копіювання його назад чи щось інше — ви просто хочете швидко передати свої файли в одну сторону.

Є зручний спосіб зробити це за допомогою Python. Просто перейдіть до каталогу, що містить файл(и), і запустіть:

```bash
python -m SimpleHTTPServer
```

Це запускає базовий веб-сервер, який робить поточний каталог доступним для будь-якого браузера в мережі. За замовчуванням він працює на порту 8000, тому, якщо комп’ютер, на якому ви запускаєте це, має адресу 10.1.2.4, у веб-переглядачі в цільовій системі перейдіть на <http://10.1.2.4:8000>, і ви зможете скачати те, що вам потрібно.

> **УВАГА**
Цей метод передбачає, що ваша локальна мережа безпечна. Не робіть цього в публічній мережі чи будь-якому іншому мережевому середовищі, якому ви не довіряєте.

### rsync

Якщо ви хочете скопіювати більше, ніж просто файл або два, ви можете звернутися до інструментів, які потребують підтримки сервера на місці призначення. Наприклад, ви можете скопіювати всю структуру каталогу в інше місце за допомогою `scp -r`, за умови, що віддалений пункт призначення підтримує сервер SSH і SCP (це доступно для Windows і macOS).

```bash
scp -r directory user@remote_host[:dest_dir]
```

Цей метод справиться із завданням, але не дуже гнучкий. Зокрема, після завершення передачі віддалений хост може не мати точної копії каталогу. Якщо `directory` вже існує на віддаленій машині та містить деякі сторонні файли, ці файли залишаться після передачі.

Якщо ви плануєте робити подібні речі регулярно (і особливо якщо плануєте автоматизувати процес), вам слід використовувати спеціальну систему синхронізатора, яка також може виконувати аналіз і перевірку, таку як `rsync`.

`rsync` корисний також для створення резервних копій. Наприклад, ви можете під’єднати інтернет-сховище, таке як Amazon S3, до вашої системи Linux, а потім використовувати `rsync --delete` для періодичної синхронізації файлової системи з мережевим сховищем для реалізації дуже ефективної системи резервного копіювання.

#### Початок роботи з rsync

Щоб змусити `rsync` працювати між двома хостами, ви повинні встановити програму `rsync` як на джерелі, так і на місці призначення, і вам знадобиться спосіб доступу до однієї машини з іншої.

Зовні команда `rsync` мало чим відрізняється від `scp`. Фактично, ви можете запустити `rsync` з тими самими аргументами. Наприклад, щоб скопіювати групу файлів у свій домашній каталог на `host`, введіть:

```bash
rsync file1 file2 ... host:
```

У будь-якій сучасній системі `rsync` передбачає, що ви використовуєте SSH для підключення до віддаленого хосту.

Остерігайтеся цього повідомлення про помилку:

```bash
rsync not found
rsync: connection unexpectedly closed (0 bytes read so far)
rsync error: error in rsync protocol data stream (code 12) at io.c(165)
```

Це повідомлення говорить, що ваша віддалена оболонка не може знайти rsync у своїй системі. Якщо rsync знаходиться у віддаленій системі, але його немає в `$PATH` для користувача в цій системі, використовуйте `--rsync-path=path`, щоб вручну вказати його розташування.

Якщо ім’я користувача відрізняється на двох хостах, додайте `user@` до імені віддаленого хосту в аргументах команди, де `user` — ваше ім’я користувача на `host`:

```bash
rsync file1 file2 ... user@host:
```

Якщо ви не вкажете додаткові параметри, `rsync` копіює лише файли. Щоб передати всю ієрархію каталогів разом із символічними посиланнями, дозволами, режимами та пристроями, використовуйте опцію `-a`.

Крім того, якщо ви хочете скопіювати до каталогу, відмінного від вашого домашнього каталогу на віддаленому хості, розмістіть його ім’я після віддаленого хосту, як це:

```bash
rsync -a dir host:dest_dir
```

Копіювання каталогів може бути складним, тому, якщо ви не зовсім впевнені, що станеться після перенесення файлів, скористайтеся комбінацією параметрів `-nv`.

Опція `-n` вказує `rsync` працювати в режимі «сухого запуску», тобто запускати пробну версію без фактичного копіювання файлів. Параметр `-v` призначений для детального режиму, який показує подробиці про передачу та задіяні файли:

```bash
rsync -nva dir host:dest_dir

# output
building file list ... done
ml/nftrans/nftrans.html
[more files]
wrote 2183 bytes read 24 bytes 401.27 bytes/sec
```

#### Створення точної копії структури каталогу

За замовчуванням `rsync` копіює файли та каталоги без урахування попереднього вмісту цільового каталогу. Наприклад, якщо ви передали каталог `d`, що містить файли `a` і `b`, на машину, яка вже мала файл з назвою `d/c`, місце призначення міститиме `d/a`, `d/b` і `d/c` після `rsync`.

Щоб створити точну копію вихідного каталогу, ви повинні видалити файли в цільовому каталозі, які не існують у вихідному каталозі, наприклад `d/c` у цьому прикладі. Для цього використовуйте опцію `--delete`:

```bash
rsync -a --delete dir host:dest_dir
```

> **УВАГА**
Ця операція може бути небезпечною. Пам’ятайте: якщо ви не впевнені щодо передачі, скористайтеся опцією `-nv`, щоб виконати сухий прогін, щоб точно знати, коли `rsync` хоче видалити файл.

#### Використання слешу

Будьте особливо обережні, вказуючи каталог як джерело в командному рядку `rsync`. Розглянемо базову команду, з якою ми працювали досі:

```bash
rsync -a dir host:dest_dir
```

Після завершення ви матимете каталог `dir` всередині `dest_dir` на `host`.

![rsync copy](images/rsync.png)

Однак додавання слешу (`/`) до імені джерела суттєво змінює поведінку:

```bash
rsync -a dir/ host:dest_dir
```

Тут rsync копіює все всередині `dir` до `dest_dir` на `host` без фактичного створення `dir` на цільовому хості. Тому ви можете розглядати передачу `dir/` як операцію, подібну до `cp dir/* dest_dir` у локальній файловій системі.

Під час передачі файлів і каталогів на віддалений хост випадкове додавання `/` після шляху зазвичай буде не більш ніж незручністю; ви можете перейти на віддалений хост, додати каталог `dir` і помістити всі передані елементи назад у `dir`. На жаль, є більший потенціал для катастрофи, якщо ви поєднуєте кінцевий `/` з опцією `--delete`; оскільки таким чином ви можете легко видалити непов’язані файли.

![rsync copy with trailing slash](images/rsync_slash.png)

#### Виключення файлів і каталогів

Важливою особливістю `rsync` є його здатність виключати файли та каталоги з операції передачі. Наприклад, скажімо, ви хочете перенести локальний каталог під назвою `src` до `host`, але ви хочете виключити все під назвою `.git`. Ви можете зробити це так:

```bash
rsync -a --exclude=.git src host:
```

Зауважте, що ця команда виключає всі файли та каталоги з назвою `.git`, оскільки `--exclude` приймає шаблон, а не абсолютну назву файлу. Щоб виключити один конкретний елемент, укажіть абсолютний шлях, який починається з "/":

```bash
rsync -a --exclude=/src/.git src host:
```

> Перший `/` у `/src/.git` у цій команді є не кореневим каталогом вашої системи, а скоріше основним каталогом передачі.

- Ви можете мати скільки завгодно параметрів `--exclude`.
- Якщо ви використовуєте ті самі шаблони неодноразово, розмістіть їх у відкритому текстовому файлі (один шаблон на рядок) і використовуйте `--exclude-from=file`.
- Щоб виключити каталоги з назвою `item`, але включити файли з такою назвою, використовуйте скісну риску в кінці: `--exclude=item/`.
- Шаблон виключення базується на компоненті повної назви файлу чи каталогу та може містити прості символи підстановки. Наприклад, `t*s` відповідає `this`, але не відповідає `ethers`.
- Якщо ви виключили каталог або ім’я файлу, але виявили, що ваш шаблон надто суворий, використовуйте `--include`, щоб конкретно включити інший файл або каталог.

#### Перевірка переказів, додавання захисних заходів і використання докладного режиму

Щоб пришвидшити роботу, `rsync` використовує швидку перевірку, щоб визначити, чи є якісь файли на джерелі передачі вже на місці призначення. Для перевірки використовується комбінація розміру файлу та дати його останньої зміни.

Після одного запуску rsync запустіть його знову за допомогою `rsync -v`. Цього разу ви побачите, що файли не відображаються у списку передачі, оскільки набір файлів існує на обох кінцях із однаковими датами змін.

Якщо файли на стороні джерела не ідентичні файлам на стороні призначення, `rsync` передає вихідні файли та перезаписує всі файли, які існують на віддаленій стороні.

Однак ви можете додати деякі додаткові заходи безпеки. Ось кілька варіантів, які стануть у нагоді:

- `--checksum` (абревіатура: `-c`) Обчислює контрольні суми (здебільшого унікальні підписи) файлів, щоб перевірити, чи вони однакові.
- `--ignore-existing` Не збиває файли, які вже знаходяться на цільовій стороні.
- `--backup` (абревіатура: `-b`) Не знищує файли, які вже є в цільовому файлі, а перейменовує ці існуючі файли, додаючи до їхніх імен суфікс `~` перед передачею нових файлів.
- `--suffix=s` Змінює суфікс, який використовується з `--backup` з `~` на `s`.
- `--update` (абревіатура: `-u`) Не збиває будь-який файл у цільовому файлі, який має пізнішу дату, ніж відповідний файл у джерелі.

#### Стиснення даних

Багатьом користувачам подобається параметр `-z` у поєднанні з `-a`, щоб стиснути дані перед передачею:

```bash
rsync -az dir host:dest_dir
```

Стиснення може покращити продуктивність у певних ситуаціях, наприклад, коли ви завантажуєте великий обсяг даних через повільне з’єднання (наприклад, повільне висхідне з’єднання) або коли затримка між двома хостами велика.

Однак у швидкісній локальній мережі два кінцеві комп’ютери можуть бути обмежені процесорним часом, який потрібен для стиснення та розпакування даних, тому передача без стиснення може бути швидшою.

#### Обмеження пропускної здатності

Коли ви завантажуєте великий обсяг даних на віддалений хост, можна легко заблокувати висхідне з’єднання з Інтернетом.

Щоб обійти це, використовуйте `--bwlimit`, щоб надати вашому висхідному каналу трохи передишки. Наприклад, щоб обмежити пропускну здатність до 100 000 Кбіт/с, ви можете зробити щось на зразок цього:

```bash
rsync --bwlimit=100000 -a dir host:dest_dir
```

#### Перенесення файлів на комп'ютер

Команда `rsync` призначена не лише для копіювання файлів із локальної машини на віддалений хост, але і в інший бік. Наприклад, щоб перенести `src_dir` на віддаленій системі в `dest_dir` на локальному хості, виконайте цю команду:

```bash
rsync -a host:src_dir dest_dir
```

> Ви також можете використовувати `rsync` для дублювання каталогів на вашій локальній машині; просто пропустіть `host:` в обох аргументах.