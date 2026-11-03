// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mml_app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Моя Медиатека';

  @override
  String get badCertificate => 'Произошла ошибка с сертификатом!';

  @override
  String get unknownError => 'Произошла неизвестная ошибка!';

  @override
  String offlineErrorTitle(String appTitle) {
    return '$appTitle недоступна';
  }

  @override
  String get offlineError => 'Подключитесь к интернету и повторите попытку';

  @override
  String unexpectedError(String message) {
    return 'Произошла непредвиденная ошибка: $message';
  }

  @override
  String get forbidden =>
      'У вас нет необходимых прав, чтобы выполнить это действие!';

  @override
  String get done => 'Далее';

  @override
  String get skip => 'Пропустить';

  @override
  String get registrationTitle => 'Регистрация';

  @override
  String get registrationScan =>
      'Отсканируйте QR-код в администрации, чтобы зарегистрировать своё устройство.';

  @override
  String get registrationError =>
      'Произошла ошибка при регистрации. Попробуйте ещё раз!';

  @override
  String get registrationSuccess => 'Устройство успешно зарегистрировано!';

  @override
  String get registrationProgress => 'Регистрация устройства...';

  @override
  String get registrationEnterName =>
      'Введите своё имя, чтобы зарегистрироваться.';

  @override
  String get registrationRSA =>
      'Генерируется ключ безопасности. Это может занять некоторое время.';

  @override
  String get reRegister =>
      'Ваша регистрация истекла. Зарегистрируйте своё устройство заново!';

  @override
  String get records => 'Записи';

  @override
  String get settings => 'Настройки';

  @override
  String get playlist => 'Сохранённые треки';

  @override
  String get next => 'Далее';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get invalidFirstName => 'Пожалуйста, введите имя!';

  @override
  String get invalidLastName => 'Пожалуйста, введите фамилию!';

  @override
  String get notReachable =>
      'Не удалось подключиться к серверу! Пожалуйста, проверьте вашу соединение к сети!';

  @override
  String get changeServerConnection => 'Изменить подключение к серверу';

  @override
  String get removeRegistration => 'Удалить регистрацию';

  @override
  String get info => 'Инфо';

  @override
  String get privacyPolicy => 'Политика Конфиденциальности';

  @override
  String get legalInformation => 'Правовая Информация';

  @override
  String get licenses => 'Лицензии';

  @override
  String get updateConnectionSettingsTitle => 'Изменить подключение к серверу';

  @override
  String get updateConnectionSettingsScan =>
      'Чтобы изменить настройки, отсканируйте QR-код в администрации.';

  @override
  String get updateConnectionSettingsError =>
      'Во время смены произошла ошибка. Пожалуйста, повторите попытку ещё раз!';

  @override
  String get updateConnectionSettingsSuccess =>
      'Настройки были успешно изменены!';

  @override
  String get updateConnectionSettingsProgress => 'Смена настроек...';

  @override
  String get introTitleRegister => 'Регистрироваться';

  @override
  String get introTextRegister =>
      'Отсканируйте QR-код в администрации, чтобы зарегистрировать свое устройство.';

  @override
  String get introTitleRecords => 'Слушать';

  @override
  String get introTextRecords =>
      'Получите доступ к доступным аудиозаписям, отфильтруйте их по своему усмотрению и прослушайте их.';

  @override
  String get introTitlePlaylist => 'Брать с собой';

  @override
  String get introTextPlaylist =>
      'Добавляйте любимые записи в офлайн-плейлисты и слушайте их, даже если в данный момент нет интернета.';

  @override
  String get unknown => 'Неизвестный';

  @override
  String get save => 'Применить';

  @override
  String get cancel => 'Отменить';

  @override
  String get noData => 'Никаких записей найдено не было!';

  @override
  String get reload => 'Перезагрузить';

  @override
  String get date => 'Дата';

  @override
  String get artist => 'Исполнитель';

  @override
  String get genre => 'Жанр';

  @override
  String get album => 'Альбом';

  @override
  String get filter => 'Фильтр';

  @override
  String get add => 'Добавить';

  @override
  String get notFound => 'Запрошенная запись не найдена!';

  @override
  String get editPlaylist => 'Изменить Плейлист';

  @override
  String get addPlaylist => 'Добавить Плейлист';

  @override
  String get invalidDisplayName => 'Пожалуйста введите имя!';

  @override
  String get playlistUniqueConstraintFailed => 'Плейлист уже существует.';

  @override
  String get remove => 'Удалить';

  @override
  String get yes => 'Да';

  @override
  String get deleteConfirmation =>
      'Вы действительно хотите удалить выбранные записи?';

  @override
  String get download => 'Загрузка';

  @override
  String get fileNotFound =>
      'Файл не удалось найти. Снова добавьте запись в список воспроизведения.';

  @override
  String get downloadError =>
      'Загрузка не удалась. Проверьте свое соединение и место на диске и повторите попытку.';

  @override
  String get back => 'назад';

  @override
  String get folder => 'Папка';

  @override
  String get language => 'Язык';

  @override
  String get notReachableRecord =>
      'Запись не может быть загружена! Пожалуйста, повторите попытку позже.';

  @override
  String get faq => 'Помощь';

  @override
  String get faqAddFavorites => 'Как мне сохранить записи?';

  @override
  String get sendFeedback => 'Отправить отзыв/Сообщить проблему';

  @override
  String get display => 'Отображение';

  @override
  String get displayDescription =>
      'Какие элементы вы хотите отобразить в списке записи?';

  @override
  String get showGenre => 'Жанр';

  @override
  String get showLanguage => 'Язык';

  @override
  String get showTrackNumber => 'Номер трека';

  @override
  String get faqAddFavoritesDescription =>
      'Можно создать несколько папок, в которых хранятся записи. Чтобы сделать это, нажмите на символ плюса в окне \'Сохраненные записи\' в правом нижнем углу и укажите имя папки. Записи можно сохранить длительным нажатием на запись в списке. Появится возможность выбрать несколько элементов одновременно. Нажмите на звездочку в правом верхнем углу, а затем выберите папку, в которую вы хотите сохранить записи. Воспроизводимую в данный момент запись можно сохранить в проигрывателе в правом нижнем углу.';

  @override
  String get faqRemoveFavorites => 'Как мне удалить сохраненные записи?';

  @override
  String get faqRemoveFavoritesDescription =>
      'Чтобы удалить одну или несколько сохраненных записей, нажмите и удерживайте запись или всю папку в списке. Появится возможность выбрать несколько элементов. Нажмите на значок корзины в правом верхнем углу, чтобы удалить выбранные элементы.';

  @override
  String get development => 'Разработка';

  @override
  String get clearLogs => 'Очистить лог';

  @override
  String get showLogs => 'Показывать лог';

  @override
  String get livestreams => 'Трансляции';

  @override
  String get saveFilters => 'Сохранить фильтры';

  @override
  String get cover => 'Обложка';

  @override
  String get notCompatibleFile =>
      'Файл невозможно расшифровать. Неправильный формат.';

  @override
  String fileTooLarge(int size) {
    return 'Файл слишком большой для импорта (макс. $size МБ).';
  }

  @override
  String get notDownloaded => 'Не загружено';

  @override
  String get notDownloadedRecords =>
      'Следующие записи больше недоступны или вы не имеете права их загружать.';

  @override
  String get overview => 'Обзор';

  @override
  String get favorites => 'Избранное';

  @override
  String get livestreamShort => 'Трансляции';

  @override
  String get discover => 'Искать';

  @override
  String get artists => 'Исполнители';

  @override
  String get genres => 'Жанры';

  @override
  String get albums => 'Альбомы';

  @override
  String get languages => 'Языки';

  @override
  String get newest => 'Новые';

  @override
  String get newestArtists => 'Новые исполнители';

  @override
  String get commonArtists => 'Распространённые исполнители';

  @override
  String get commonGenres => 'Распространённые жанры';

  @override
  String get shuffle => 'Случайное воспроизведение';

  @override
  String get repeat => 'Повторение';

  @override
  String get stop => 'Стоп';

  @override
  String errorAuthenticationExpired(String appTitle) {
    return 'Зарегистрируйтесь в $appTitle';
  }

  @override
  String get cacheSettings => 'Управление памятью';

  @override
  String get cacheRemove => 'Очистить кэш';

  @override
  String get cacheRemoveTime => 'Очистить через';

  @override
  String get cacheRangeWeek => '1 неделя';

  @override
  String get cacheRangeMonth => '1 месяц';

  @override
  String get cacheRangeYear => '1 год';

  @override
  String get cacheRangeNever => 'Никогда';

  @override
  String get cacheCleared => 'Кэш был успешно очищен.';

  @override
  String get cacheClearedFailed => 'Кэш не может быть очищен.';

  @override
  String get announcements => 'Объявления';

  @override
  String get showAnnouncementsOnStart => 'Показывать объявления при запуске';

  @override
  String get noAnnouncements => 'Актуальных объявлений нет.';

  @override
  String get doNotShowAgain => 'Больше не показывать';

  @override
  String get close => 'Закрыть';

  @override
  String announcementPosition(int index, int count) {
    return '$index из $count';
  }

  @override
  String get previous => 'Назад';

  @override
  String get showAnnouncements => 'Показать текущие объявления';

  @override
  String get share => 'Поделиться';

  @override
  String get shareSearchLink => 'Поделиться ссылкой на поиск';

  @override
  String get sharePlayLink => 'Поделиться ссылкой на воспроизведение';

  @override
  String get shareDownloadLink => 'Поделиться ссылкой для скачивания';

  @override
  String get shareValidFor => 'Срок действия';

  @override
  String get shareValid1Hour => '1 час';

  @override
  String get shareValid1Day => '1 день';

  @override
  String get shareValid7Days => '7 дней';

  @override
  String get shareValid30Days => '30 дней';

  @override
  String get shareValid90Days => '90 дней';

  @override
  String get shareSingleUse => 'Одноразовая ссылка';

  @override
  String get shareSingleUseHint =>
      'Ссылку можно открыть для скачивания только один раз.';

  @override
  String get shareUseAsDefault =>
      'Использовать по умолчанию и больше не спрашивать';

  @override
  String get shareSettings => 'Ссылки для скачивания';

  @override
  String get shareMyLinks => 'Мои активные ссылки';

  @override
  String get shareNoLinks => 'Нет активных ссылок.';

  @override
  String shareLinkRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '1 запись',
    );
    return '$_temp0';
  }

  @override
  String shareLinkCreatedAt(String date) {
    return 'Создана $date';
  }

  @override
  String shareLinkExpiresAt(String date) {
    return 'Действительна до $date';
  }

  @override
  String get shareLinkDeleteInfo =>
      'Ссылка сразу станет недействительной. Тот, кто уже получил её, больше ничего не сможет скачать.';

  @override
  String get shareSettingsInfo =>
      'Эти настройки действуют для создаваемых вами ссылок. Они применяются, только если вы можете делиться записями и администратор разрешил выбор.';

  @override
  String get shareAskBeforeSharing => 'Спрашивать перед отправкой';

  @override
  String sharePartial(int shareable, int total) {
    return 'Вы можете поделиться только $shareable из $total выбранных записей. Будут отправлены только они.';
  }

  @override
  String get shareLinkOtherServer => 'Ссылка относится к другому серверу.';

  @override
  String shareSearchTooLarge(int max) {
    return 'Поиск содержит слишком много значений фильтров и не может быть отправлен. Допускается не более $max.';
  }

  @override
  String get resumePlayback => 'Продолжить воспроизведение';

  @override
  String get faqShareLinks =>
      'Как поделиться поиском или текущим воспроизведением?';

  @override
  String get faqShareLinksDescription =>
      'В списке записей нажмите значок ссылки вверху справа, чтобы отправить текущий поиск со всеми фильтрами. Значок появляется, только если задан текст поиска или фильтр. В плеере значок отправляет играющую запись с текущей позиции. Тот, кто откроет ссылку, попадёт в приложение с тем же поиском или услышит запись с того же места. Приложение должно быть установлено и настроено для того же сервера. Записи, на которые нет прав, не отображаются и не воспроизводятся.';

  @override
  String get faqShareDownload => 'Как поделиться записями для скачивания?';

  @override
  String get faqShareDownloadDescription =>
      'В списке записей удерживайте запись или папку и выберите другие. Затем нажмите вверху справа значок отправки ссылки для скачивания. Открывший ссылку скачивает записи в браузере, даже без приложения: одну запись как аудиофайл, несколько как ZIP-архив, названия файлов совпадают с названиями записей. Ссылка может содержать не более 100 записей. Значок появляется, только если вы можете делиться выбранными записями. Если можно поделиться только частью, вы получите уведомление, и будет отправлена только эта часть. Можно ли выбирать срок и одноразовость в настройках «Ссылки для скачивания», решает администратор. Активные ссылки для скачивания можно посмотреть и удалить в настройках в разделе «Мои активные ссылки». Удалённая ссылка перестаёт работать сразу.';

  @override
  String get faqResumePlayback =>
      'Как продолжить воспроизведение после открытия приложения?';

  @override
  String get faqResumePlaybackDescription =>
      'Включите в настройках «Продолжить воспроизведение». При следующем открытии приложения последняя прослушанная запись будет подготовлена на том месте, где вы остановились. Запустите её кнопкой воспроизведения. По умолчанию функция выключена.';

  @override
  String shareTooMany(int limit) {
    return 'Ссылка может содержать не более $limit записей. Выберите меньше записей или меньшую папку и при необходимости создайте несколько ссылок.';
  }
}
