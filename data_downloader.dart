import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://quranapi.pages.dev/api';

void main() async {
  print('Starting Quran data download...\n');

  try {
    // all surah list
    final allSurahsResponse = await http.get(Uri.parse('$baseUrl/surah.json'));
    if (allSurahsResponse.statusCode != 200) {
      throw Exception('Failed to load Surah list');
    }
    // utf8 encoding for arabic and bengali font 
    final List<dynamic> surahList = jsonDecode(utf8.decode(allSurahsResponse.bodyBytes));

    final List<Map<String, dynamic>> fullQuranData = [];

    // getting each surah details
    for (var i = 0; i < surahList.length; i++) {
      final int surahNumber = i + 1;
      final surahInfo = surahList[i];
      print('Downloading Surah $surahNumber: ${surahInfo['surahName']}...');

      final surahDetailResponse = await http.get(Uri.parse('$baseUrl/$surahNumber.json'));
      final Map<String, dynamic> surahDetail = jsonDecode(utf8.decode(surahDetailResponse.bodyBytes));

      fullQuranData.add({
        'surah_number': surahNumber,
        'name_arabic': surahInfo['surahNameArabic'],
        'name_english': surahInfo['surahName'],
        'name_english_translation': surahInfo['surahNameTranslation'],
        'revelation_place': surahInfo['revelationPlace'],
        'total_ayah': surahInfo['totalAyah'],
        'ayahs_arabic': surahDetail['arabic1'],
        'ayahs_bengali': surahDetail['bengali'],
        'ayahs_english': surahDetail['english'],
      });

      // Delay between each api call
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // output file
    final outputFile = File('quran_data.json');
    final encoder = JsonEncoder.withIndent('  ');
    await outputFile.writeAsString(encoder.convert(fullQuranData), encoding: utf8);

    print('\nSuccess! All data has been downloaded and saved to quran_data.json');
    print('File size: ${(outputFile.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB');
  } catch (e) {
    print('\nAn error occurred: $e');
  }
}
