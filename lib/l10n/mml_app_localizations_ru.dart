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
  String errorAuthenticationExpired(String appTitle) {
    return 'Зарегистрируйтесь в $appTitle';
  }
}
