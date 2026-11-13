import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mml_app/components/shimmer_cover.dart';
import 'package:mml_app/extensions/datetime.dart';
import 'package:mml_app/extensions/duration_double.dart';
import 'package:mml_app/extensions/flag.dart';
import 'package:mml_app/manager/image_cache_manager.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_base.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/models/subfilter.dart';

part 'record.g.dart';

/// Record model that holds all information of a record.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Record extends ModelBase {
  /// Id of the client.
  final String? recordId;

  /// Title of the record.
  String? title;

  /// Track number of the record.
  int? trackNumber;

  /// The date the record was created..
  DateTime? date;

  /// The duration of the record in milliseconds.
  double? duration;

  /// The artists or null if no one provided.
  String? artist;

  /// Genre of the record or null if no one provided.
  String? genre;

  /// Album of the record or null if no one provided.
  String? album;

  /// Id of the album or null if no one provided or the server does not send it.
  @JsonKey(includeToJson: false)
  String? albumId;

  /// Language of the record or null if no one provided.
  String? language;

  /// Group of the record, formatted once since lists read it for every tile.
  String? _group;

  /// Checksum of the record data.
  String? checksum;

  /// The cover image of the record.
  String? cover;

  RecordViewSettings? _viewSettings;

  /// Creates a new record instance with the given values.
  Record({
    required this.recordId,
    required this.checksum,
    this.title,
    this.trackNumber,
    this.date,
    this.duration = 0,
    this.album,
    this.albumId,
    this.artist,
    this.genre,
    this.language,
    this.cover,
    super.isDeletable,
  });

  /// Converts a json object/map to the record model.
  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);

  set viewSettings(RecordViewSettings viewSettings) {
    _viewSettings = viewSettings;
  }

  /// Converts the current record model to a json object/map.
  Map<String, dynamic> toJson() => _$RecordToJson(this);

  @override
  String getDisplayDescription() {
    final tn =
        _viewSettings != null &&
            _viewSettings!.tracknumber &&
            trackNumber != null
        ? '$trackNumber - '
        : '';
    return "$tn$title";
  }

  @override
  dynamic getIdentifier() {
    return recordId;
  }

  @override
  String? getSubtitle(BuildContext context) {
    var locales = AppLocalizations.of(context)!;
    return artist ?? locales.unknown;
  }

  @override
  String? getMetadata(BuildContext context) {
    return duration?.asFormattedDuration();
  }

  @override
  String? getSubMetadata(BuildContext context) {
    if (_viewSettings == null) {
      return null;
    }
    var g = _viewSettings!.genre && genre != null ? genre : '';

    var lang = '';
    if (_viewSettings!.language && language != null) {
      lang = "${language?.asFlag().join(' ')}";
    }

    return "$g${lang.isEmpty ? '' : ' '}$lang";
  }

  @override
  String? getAvatarString() {
    return cover;
  }

  @override
  Widget? getAvatar(BuildContext? context) {
    if (_viewSettings == null || !_viewSettings!.cover) {
      return null;
    }

    if (cover != null && cover!.isNotEmpty) {
      return CachedNetworkImage(
        cacheKey: cover,
        imageUrl: cover!,
        placeholder: (context, url) => const ShimmerCover(),
        errorWidget: (context, url, error) => const Icon(Symbols.music_note_2),
        cacheManager: ImageCacheManager(),
      );
    }

    return const Icon(Symbols.music_note);
  }

  @override
  String? getGroup(BuildContext context) {
    return _group ??= _formatGroup();
  }

  String _formatGroup() {
    final day = date ?? DateTime.now();
    final suffix = album?.isNotEmpty ?? false ? ': $album' : '';
    return '${DateFormat.yMd().format(day)} - ${day.weekdayName()}$suffix';
  }

  @override
  Subfilter? getGroupFilter() {
    final hasAlbum = album?.isNotEmpty ?? false;
    if (date == null || (hasAlbum && albumId == null)) {
      return null;
    }

    final day = DateTime.utc(date!.year, date!.month, date!.day);
    return ID3TagFilter(
      albums: hasAlbum ? [albumId!] : null,
      startDate: day,
      endDate: day,
    );
  }
}
