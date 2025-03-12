
import 'dart:async';
import 'dart:io';


Future<void> main() async {

 reminderIn15mins();
}

Future<void> reminderIn15mins() async {

  while (true) {
    if(DateTime.now().minute == 00){
      // play a sound
      await playSound();
      continue;
    }
    if (DateTime.now().minute == 15){

      await playSound();
      continue;
    }

    if (DateTime.now().minute == 30){

      await playSound();
      continue;
    }

    if (DateTime.now().minute == 45){
      await playSound();
      continue;
    }



  }
}


Future<void> playSound() async {

  const filePath = '/Users/michael/Downloads/make-jesus-proud.mp3';

  // Check if the file exists
  if (!await File(filePath).exists()) {
    throw Exception('File does not exist: $filePath');
  }

  try {
    final process = await Process.start('afplay', [filePath]);

    process.stderr.transform(const SystemEncoding().decoder).listen((error) {
      print('Error: $error');
    });

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw Exception('Playback failed with exit code: $exitCode');
    }

    return;
  } catch (e) {
    throw Exception('Error playing sound: $e');
  }
}
