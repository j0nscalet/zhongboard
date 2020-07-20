import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void main() => runApp(App());

class App extends StatefulWidget {    
  @override
  State<StatefulWidget> createState() {    
    return AppState();
  }  
}

class AppState extends State<App> {
  TranslationService translationService;

  @override
  void initState() {
    translationService = TranslationService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(this),
    );
  }
}

class HomePage extends StatefulWidget {
  final AppState appState;

  HomePage(this.appState);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> messages;

  @override
  void initState() {
    messages = [
      {
        'direction': 'incoming',
        'contents': 'I think you would like this place...'
      },
      {
        'direction': 'outgoing',
        'contents': 'Hey man! What are you up to this afternoon?'
      },
    ];
    simulateIncomingMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      border: Border(
                          bottom: BorderSide(
                              style: BorderStyle.solid,
                              color: Colors.grey,
                              width: .5))),
                  child: Container(
                    color: Colors.white12,
                    child: Center(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: messages.length,
                        itemBuilder: (context, itemIndex) {
                          var message = messages[itemIndex];

                          if (message['direction'] == 'incoming') {
                            return
                                // Incoming
                              Container(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    flex: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                          message['contents']),
                                    ),
                                  ),
                                  Flexible(flex: 2, child: Container())
                                ],
                              ),
                            );
                          }

                          return
                              // Outgoing
                              Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Flexible(
                                flex: 2,
                                child: Container(),
                              ),
                              Flexible(
                                flex: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xff0394DD),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Hey man! What are you up to this afternoon?',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  )),
            ),
            // Download model
            FlatButton(
              padding: EdgeInsets.all(0.0),              
              color: Color(0xff55BEF2),
              child: Text('Download Model'),
              onPressed: () async => await widget.appState.translationService.downloadModel()
            ),
            // Keyboard
            KeyboardWrapper(widget.appState.translationService)
          ],
        ),
      ),
    );
  }

  void simulateIncomingMessages() {
    var simulatedMessages = [
      "Nothing much man! How are you doing?",
      "Do you want to go grab some lunch later this week?",
      "Hey! I think I left my backpack at your place the other day? Can you check for me?",
      "Really fun hanging out today man. Let's try to plan tennis again sometime soon.",
      "Can we chat later? I need to talk to you about something"
    ];
    Timer.periodic(Duration(seconds: 45), (timer){
      var index = timer.tick % 5;
      print(simulatedMessages[index]);

      setState(() {
        messages.add({
          'direction': 'incoming',
          'contents': simulatedMessages[index]
        });
      });
    });
  }
}

class KeyboardWrapper extends StatefulWidget {    
  final TranslationService translationService;

  KeyboardWrapper(this.translationService);

  @override
  State<StatefulWidget> createState() {
    return KeyboardWrapperState();
  }
}

class KeyboardWrapperState extends State<KeyboardWrapper> {
  TextEditingController textController;
  String translation;

  KeyboardWrapperState()
    : textController = TextEditingController(text: null)
    , translation = '';

  @override
  void initState() {        
    textController.addListener(onTextChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // translation
        Container(
          padding: EdgeInsets.all(8.0),
          color: Color(0xff064D70),
          child: Center(
              child: Text(translation,
                  style: TextStyle(color: Colors.white, fontSize: 14.0))),
        ),
        Container(
            padding: EdgeInsets.all(8.0),
            child: CupertinoTextField(
              padding: EdgeInsets.all(8.0),
              controller: textController,
            ))
      ],
    );
  }

  // TODO We only want to translate Chinese. When the user is typing in English we don't translate.  
  // How often do we want to translate? With every character change? 
  // Can we hook into the autocomplete selection?
  void onTextChanged() async {    
    var translatedText = await widget.translationService.translate(textController.text);  
    print('Translated to $translatedText...');

    setState(() {
      translation = translatedText;
    });
  }
}

// TODO We probably want to create a platform interface in the future
// TODO How do we handle platform errors well?
class TranslationService {

  static MethodChannel channel = MethodChannel('zhongboard/translation');

  Future<void> downloadModel() async {
    print('Downloading translation model...');
    await channel.invokeMethod('downloadModel');
    print("Downloaded model successfully. Okay to start translating...");
  }

  Future<String> translate(String text) async { 
    var translatedText = await channel.invokeMethod<String>('translate', text);

    return translatedText;
  }
}
