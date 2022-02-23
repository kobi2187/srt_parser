# .srt parser

## description
A simple .srt file parser that allows you to read a String and convert it to a list of subtitle object.  
Each Subtitle object contains a begin and an end time stamp and a list of subtitle strings. 

### Example 

```dart
import 'package:srt_parser/srt_parser.dart';

const String data = '''1
00:02:26,407 --> 00:02:31,356  X1:100 X2:100 Y1:100 Y2:100
-- Arman I trust you
-- Arrrrrghhhhhh, ja ja 

2
00:02:31,567 --> 00:02:37,164 
-- Lukas is publishing his library.
-- I like the man.
''';

void main() {
  List<Subtitle> subtitles = parseSrt(data);
  for (Subtitle item in subtitles) {
    print('ID is: ${item.id}');
    print('Begin is: ${item.range.begin} and End is: ${item.range.end}');
    for (String line in item.lines) {
      print(line);
    }
    print('----');
  }
}

```