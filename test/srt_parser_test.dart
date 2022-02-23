import 'dart:async';

import 'package:test/test.dart'; 

import '../lib/srt_parser.dart';

void main() {
  const String data = '''1
00:02:26,407 --> 00:02:31,356  X1:100 X2:100 Y1:100 Y2:100
<font color="#00ff00">Detta handlar om min storebrors</font>
<b><i><u>kriminella beteende och foersvinnade.</u></i></b>

2
00:02:31,567 --> 00:02:37,164 
Vi talar inte laengre om Wade. Det aer 
som om han aldrig hade existerat.
''';
  test('testing line splitter', () {
    final List<String> lines = splitIntoLines(data);
    expect(lines.length, 9);
    expect(lines.first, '1');
    expect(lines.last,
        allOf(['som om han aldrig hade existerat.', isNotNull, const TypeMatcher<String>()]));
  });
  test('chunks', () {
    final List<List<String>> chunks =
        splitIntoSubtitleChunks(['a', 'b', 'c', '', '123', 'adfasfdsa']);
    expect(chunks.length, 2);
    expect(chunks[0][2], 'c');
    expect(chunks[1][0], '123');
  });
  test('parseBeginEnd', () {
    final Range? result = parseBeginEnd('00:02:31,567 --> 00:02:37,164');
    expect(result?.begin, 151567);
    expect(result?.end, 157164);
  });

  test('out of range timeStamp', () {
    expect(Future<void>(() {
      timeStampToMillis(24, 59, 59, 999);
    }), throwsA(isRangeError));
  });

  test('out of range minus', () {
    expect(Future<void>(() {
      timeStampToMillis(-1, 59, 59, 999);
    }), throwsA(isRangeError));
  });

  test('parseSrt', () {
    final List<Subtitle> parsedSubtitle = parseSrt(data);
    expect(parsedSubtitle.length, 2);
    expect(parsedSubtitle[1].range.begin, 151567);
  });
}
