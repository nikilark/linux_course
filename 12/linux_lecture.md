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

#### Making Exact Copies of a Directory Structure

By default, rsync copies files and directories without considering the previous contents of the destination directory. For example, if you transferred directory `d` containing the files `a` and `b` to a machine that already had a file named `d/c`, the destination would contain `d/a`, `d/b`, and `d/c` after the rsync.

To make an exact replica of the source directory, you must delete files in the destination directory that do not exist in the source directory, such as `d/c` in this example. Use the `--delete` option to do that:

```bash
rsync -a --delete dir host:dest_dir
```

> **WARNING**
This operation can be dangerous, so take the time to inspect the destination directory to see if there’s anything that you’ll inadvertently delete. Remember, if you’re not certain about your transfer, use the `-nv` option to perform a dry run so that you’ll know exactly when rsync wants to delete a file.

#### Using the Trailing Slash

Be particularly careful when specifying a directory as the source in an rsync command line. Consider the basic command that we’ve been working with so far:

```bash
rsync -a dir host:dest_dir
```

Upon completion, you’ll have the directory `dir` inside `dest_dir` on `host`. Figure 12-1 shows an example of how rsync normally handles a directory with files named `a` and `b`.

![rsync copy](images/rsync.png)

However, adding a slash (`/`) to the source name significantly changes the behavior:

```bash
rsync -a dir/ host:dest_dir
```

Here, rsync copies everything inside `dir` to `dest_dir` on `host` without actually creating `dir` on the destination host. Therefore, you can think of a transfer of `dir/` as an operation similar to `cp dir/* dest_dir` on the local filesystem.

For example, say you have a directory `dir` containing the files `a` and `b` (`dir/a` and `dir/b`). You run the trailing-slash version of the command to transfer them to the `dest_dir` directory on `host`:

```bash
rsync -a dir/ host:dest_dir
```

When the transfer completes, `dest_dir` contains copies of `a` and `b` but not `dir`.

If, however, you had omitted the trailing `/` on `dir`, `dest_dir` would have gotten a copy of `dir` with `a` and `b` inside. Then, as a result of the transfer, you’d have files and directories named `dest_dir/dir/a` and `dest_dir/dir/b` on the remote host. Figure 12-2 illustrates how rsync handles the directory structure from Figure 12-1 when using a trailing slash.

When transferring files and directories to a remote host, accidentally adding a `/` after a path would normally be nothing more than a nuisance; you could go to the remote host, add the `dir` directory, and put all of the transferred items back in `dir`. Unfortunately, there’s a greater potential for disaster when you combine the trailing `/` with the `--delete` option; be extremely careful because you can easily remove unrelated files this way.

![rsync copy with trailing slash](images/rsync_slash.png)

#### Excluding Files and Directories

One important feature of rsync is its ability to exclude files and directories from a transfer operation. For example, say you’d like to transfer a local directory called `src` to `host`, but you want to exclude anything named `.git`. You can do it like this:

```bash
rsync -a --exclude=.git src host:
```

Note that this command excludes all files and directories named `.git` because `--exclude` takes a pattern, not an absolute filename. To exclude one specific item, specify an absolute path that starts with `/`, as shown here:

```bash
rsync -a --exclude=/src/.git src host:
```

> **NOTE** The first `/` in `/src/.git` in this command is not the root directory of your system but rather the base directory of the transfer.

Here are a few more tips on how to exclude patterns:

- You can have as many `--exclude` parameters as you like.
- If you use the same patterns repeatedly, place them in a plaintext file (one pattern per line) and use `--exclude-from=file`.
- To exclude directories named `item` but include files with this name, use a trailing slash: `--exclude=item/`.
- The exclude pattern is based on a full file or directory name component and may contain simple globs (wildcards). For example, `t*s` matches `this`, but it does not match `ethers`.
- If you exclude a directory or filename but find that your pattern is too restrictive, use `--include` to specifically include another file or directory.

#### Checking Transfers, Adding Safeguards, and Using Verbose Mode

To speed operation, rsync uses a quick check to determine whether any files on the transfer source are already on the destination. The check uses a combination of the file size and its last-modified date. The first time you transfer an entire directory hierarchy to a remote host, rsync sees that none of the files already exist at the destination, and it transfers everything. Testing your transfer with `rsync -n` verifies this for you.

After running rsync once, run it again using `rsync -v`. This time you should see that no files show up in the transfer list because the file set exists on both ends, with the same modification dates.

When the files on the source side are not identical to the files on the destination side, rsync transfers the source files and overwrites any files that exist on the remote side. The default behavior may be inadequate, though, because you may need additional reassurance that files are indeed the same before skipping over them in transfers, or you might want to add some extra safeguards. Here are some options that come in handy:

- `--checksum` (abbreviation: `-c`) Computes checksums (mostly unique signatures) of the files to see if they’re the same. This option consumes a small amount of I/O and CPU resources during transfers, but if you’re dealing with sensitive data or files that often have uniform sizes, this is a must.
- `--ignore-existing` Doesn’t clobber files already on the target side.
- `--backup` (abbreviation: `-b`) Doesn’t clobber files already on the target but rather renames these existing files by adding a `~` suffix to their names before transferring the new files.
- `--suffix=s` Changes the suffix used with `--backup` from `~` to `s`.
- `--update` (abbreviation: `-u`) Doesn’t clobber any file on the target that has a later date than the corresponding file on the source.

With no special options, rsync operates quietly, producing output only when there’s a problem. However, you can use `rsync -v` for verbose mode or `rsync -vv` for even more details. (You can tack on as many `v` options as you like, but two is probably more than you need.) For a comprehensive summary after the transfer, use `rsync --stats`.

#### Compressing Data

Many users like the `-z` option in conjunction with `-a` to compress the data before transmission:

```bash
rsync -az dir host:dest_dir
```

Compression can improve performance in certain situations, such as when you’re uploading a large amount of data across a slow connection (like a slow upstream link) or when the latency between the two hosts is high. However, across a fast local area network, the two endpoint machines can be constrained by the CPU time that it takes to compress and decompress data, so uncompressed transfer may be faster.

#### Limiting Bandwidth

It’s easy to clog the uplink of internet connections when you’re uploading a large amount of data to a remote host. Even though you won’t be using your (normally large) downlink capacity during such a transfer, your connection will still seem quite slow if you let rsync go as fast as it can because outgoing TCP packets such as HTTP requests will have to compete with your transfers for bandwidth on your uplink.

To get around this, use `--bwlimit` to give your uplink a little breathing room. For example, to limit the bandwidth to 100,000Kbps, you might do something like this:

```bash
rsync --bwlimit=100000 -a dir host:dest_dir
```

#### Transferring Files to Your Computer

The rsync command isn’t just for copying files from your local machine to a remote host. You can also transfer files from a remote machine to your local host by placing the remote host and remote source path as the first argument on the command line. For example, to transfer `src_dir` on the remote system to `dest_dir` on the local host, run this command:

```bash
rsync -a host:src_dir dest_dir
```

> **NOTE** As mentioned before, you can use rsync to duplicate directories on your local machine; just omit `host:` on both arguments.
