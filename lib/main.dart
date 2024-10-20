import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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

const apiKey = 'AIzaSyArJL_wdCbYZh5acXnCJKzjssvuDFXWjk0';

class _HomePageState extends State<HomePage> {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey
  );

  String confidenceText = "Start Talking!";

  TextEditingController promptController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  List<Widget> bubbles = [];

  void respondToText(String message) async {
    var prompt = message;
    var responce = await model.generateContent([Content.text(prompt)]);
    sendGreyBubbles(responce.text);
    print(responce.text);
  }

  void sendGreyBubbles(text) {
    setState(() {
      bubbles.add(BubbleSpecialThree(
        text: text,
        color: const Color.fromARGB(255, 161, 161, 170),
        tail: true,
        isSender: false,
        textStyle: const TextStyle(
          color:  Color.fromARGB(255, 255, 255, 255),
          fontSize: 16,
        )
      ));
    });
  }

  void sendBlueBubbles(String text) {
    setState(() {
      bubbles.add(BubbleSpecialThree(
        text: text,
        color: const Color.fromARGB(255, 27, 149, 243),
        tail: true,
        isSender: true,
        textStyle: const TextStyle(
          color:  Color.fromARGB(255, 255, 255, 255),
          fontSize: 16,
        )
      ));
    });
  }

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
    final player = AudioPlayer();
    player.play(AssetSource('sounds/assistant-on.mp3'));
    setState(() {
      _confidenceLevel = 0;
      confidenceText = "Listening!";
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    final player = AudioPlayer();
    player.play(AssetSource('sounds/assistant-end.mp3'));
    setState(() {
      confidenceText = "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%";
    });
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
      promptController.text = _wordsSpoken;
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
                      elevation: 0,
                      child: Ink.image(
                        image: const AssetImage('assets/Microphone-Logo.png'),                     
                        fit: BoxFit.cover,
                      ), // Remove button shadow
                    ),
                  ),
                ),
              ),
            ),
            //const SizedBox(height: 3),
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
                  const SizedBox(height: 3),
                  Center(  // Adds some spacing between the text field and the confidence text
                    child: Text(
                      confidenceText,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                    if (promptController.text.isNotEmpty) {
                        sendBlueBubbles(promptController.text);
                        respondToText(promptController.text);
                        promptController.text = ''; // Clear the text field
                      }
                  },
                  child: const Text(
                    'Generate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5,),
             // Fade effect just before the scrollable area
            Container(
              height: 10, // Adjust the height of the fade effect
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,    // Start with a solid color
                    Colors.grey    // Fade out to white
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: bubbles, // Use the bubbles list directly
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}