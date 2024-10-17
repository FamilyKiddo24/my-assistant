import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My Assistant',
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
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
      promptController.text = promptController.text + _wordsSpoken;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: promptController,
                    decoration: InputDecoration(
                      hintText: 'Enter Ai Prompt',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: 'Enter Ai Prompt',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(  // Adds some spacing between the text field and the confidence text
                    child: Text(
                      "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ],
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
          ],
        ),
      ),
    );
  }
}