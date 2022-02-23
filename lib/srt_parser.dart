import 'dart:convert';
import 'package:intl/intl.dart';

class Range {
  Range(this.begin, this.end);
  Range.empty() : this(0, 0);
  bool get isValid => begin >= 0 && end >= 0 && begin < end;
  int begin;
  int end;
  String get beginStr {
    return fromMs(begin);
  }

  String get endStr {
    return fromMs(end);
  }

  String fromMs(int ms) {
    var d = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    var res = DateFormat.Hms().format(d);
    res += "," + d.millisecond.toString().padLeft(3, '0');
    return res;
  }

  @override
  String toString() {
    // example: 01:52:45,000 --> 01:53:00,400
    return beginStr + " --> " + endStr;
  }
}

class Subtitle {
  int id = 0;
  Range range = Range.empty();
  List<String> lines = [];

  @override
  String toString() {
    var res = id.toString() + "\n" + range.toString() + "\n" + lines.join("\n");
    return res;
  }
}

String toSrt(List<Subtitle> subtitles) {
  var res = "";
  for (var sub in subtitles) {
    res += sub.toString() + "\n\n";
  }
  return res.trim();
}

List<String> splitIntoLines(String data) {
  return const LineSplitter().convert(data);
}

List<List<String>> splitIntoSubtitleChunks(List<String> lines) {
  final List<List<String>> result = [];
  List<String> chunk = [];

  for (String line in lines) {
    if (line.isEmpty) {
      result.add(chunk);
      chunk = [];
    } else {
      chunk.add(line);
    }
  }
  if (chunk.isNotEmpty) {
    result.add(chunk);
  }

  return result;
}

List<Subtitle> parseSrt(String srt) {
  final List<Subtitle> result = [];

  final List<String> split = splitIntoLines(srt);
  final List<List<String>> splitChunk = splitIntoSubtitleChunks(split);

  for (List<String> chunk in splitChunk) {
    final Subtitle subtitle = Subtitle();
    subtitle.id = int.parse(chunk[0]);
    subtitle.range = parseBeginEnd(chunk[1]);
    subtitle.lines = chunk.sublist(2);

    result.add(subtitle);
  }

  return result;
}

int timeStampToMillis(int hour, int minute, int sec, int ms) {
  if (hour <= 23 &&
      hour >= 0 &&
      minute <= 59 &&
      minute >= 0 &&
      sec <= 59 &&
      sec >= 0 &&
      ms <= 999 &&
      ms >= 0) {
    int result = ms;
    result += sec * 1000;
    result += minute * 60 * 1000;
    result += hour * 60 * 60 * 1000;
    return result;
  } else {
    throw RangeError('sth. is outa range');
  }
}

Range parseBeginEnd(String line) {
  final RegExp pattern =
      RegExp(r'(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d\d):(\d\d):(\d\d),(\d\d\d).*');
  Match match;
  var x = pattern.firstMatch(line);
  if (x == null)
    throw FormatException('no match');
  else {
    match = x;
    if (int.parse(match.group(1)!) > 23 ||
        int.parse(match.group(2)!) > 59 ||
        int.parse(match.group(3)!) > 59 ||
        int.parse(match.group(4)!) > 999 ||
        int.parse(match.group(5)!) > 23 ||
        int.parse(match.group(6)!) > 59 ||
        int.parse(match.group(7)!) > 59 ||
        int.parse(match.group(8)!) > 999) {
      throw RangeError('time components are out of range. Please modify the .srt file.');
    } else {
      final int begin = timeStampToMillis(int.parse(match.group(1)!), int.parse(match.group(2)!),
          int.parse(match.group(3)!), int.parse(match.group(4)!));
      final int end = timeStampToMillis(int.parse(match.group(5)!), int.parse(match.group(6)!),
          int.parse(match.group(7)!), int.parse(match.group(8)!));
      return Range(begin, end);
    }
  }
}
