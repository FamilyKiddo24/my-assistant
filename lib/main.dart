import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Utilities',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController promptController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

 /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      promptController.text =  promptController.text + _lastWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 2.5,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'My Assistant',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 200, // Keep the size of the image in line with the button
                  width: 200,
                  child: FittedBox(
                    child: FloatingActionButton(
                      onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
                      child: Ink.image(
                        image: const AssetImage('assets/Microphone-Logo.png'),                     
                        fit: BoxFit.cover,
                      ),
                      elevation: 0, // Remove button shadow
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: TextField(
                controller: promptController,
                decoration: InputDecoration(
                  hintText: 'Enter Ai Prompt',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  labelText: 'Enter Ai Prompt',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    promptController.text = 'Text Cleared!';
                    await Future.delayed(const Duration(milliseconds: 750));
                    promptController.text = '';
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () {
                    _speechToText.isNotListening ? _startListening : _stopListening;
                  },
                  child: const Text(
                    'Generate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            // FloatingActionButton(
            //   onPressed:
            //       // If not yet listening for speech start, otherwise stop
            //       _speechToText.isNotListening ? _startListening : _stopListening,
            //   tooltip: 'Listen',
            //   child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            // ),
          ],
        ),
      ),
    );
  }
}