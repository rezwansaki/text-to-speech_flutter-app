import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MaterialApp(
    title: "Text To Speech",
    home: TextToSpeech(),
    debugShowCheckedModeBanner: false,
  ));
}

class TextToSpeech extends StatefulWidget {
  @override
  _TextToSpeechState createState() => _TextToSpeechState();
}

enum TtsState { playing, stopped }

class _TextToSpeechState extends State<TextToSpeech> {
  //decleration
  FlutterTts flutterTts = FlutterTts();
  TtsState ttsState = TtsState
      .stopped; //to check the state of the tts, such as tts is playig or not.
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  var inputTextCtrl = TextEditingController();
  var inputText;
  var lang = 'en-US';
  var volume = 0.5;
  var pitch = 1.0;
  var speechRate = 0.5;
  var voice = "en-us-x-sfg#female_1-local";

  //methods
  sayNow() async {
    try {
      print(this.inputText);
      await flutterTts.setLanguage(lang);
      await flutterTts.setVolume(volume);
      await flutterTts.setPitch(pitch);
      await flutterTts.setSpeechRate(speechRate);
      await flutterTts.setVoice(voice);
      var result = await flutterTts.speak(this.inputText);
      if (result == 1) setState(() => ttsState = TtsState.playing);

      flutterTts.setCompletionHandler(() {
        //When the whole thing (speaking) is finished it is called
        setState(() {
          print("Complete");
          ttsState = TtsState.stopped;
        });
      });

      flutterTts.setErrorHandler((msg) {
        setState(() {
          print("error: $msg");
          ttsState = TtsState.stopped;
        });
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  } //sayNow

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  void _onChange(String text) {
    setState(() {
      this.inputText = text;
    });
  }

  initState() {
    super.initState();
    setState(() {
      this.inputText = "Please, type something!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text To Speech"),
        leading: Icon(Icons.language),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
          child: Container(
            child: Column(
              children: <Widget>[
                _inputSection(),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _btnSay(),
                    SizedBox(width: 12.0),
                    _btnStop(),
                  ],
                ),
                SizedBox(height: 12.0),
                _languageSelect(),
                SizedBox(height: 32.0),
                _volume(),
                _pitch(),
                _speechRate(),
                _btnReset(),
                SizedBox(height: 42.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Developed by: Md. Rezwan Saki Alin',
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 15.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  } // Widget build

  //widgets
  Widget _btnSay() => Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 25.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text("Say"),
        onPressed: sayNow,
        textColor: Colors.black,
        color: Colors.cyan,
      ));

  Widget _btnStop() => Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 25.0),
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text("Stop"),
          textColor: Colors.black,
          color: Colors.cyan,
          onPressed: _stop));

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 20.0, left: 25.0, right: 25.0),
      child: TextField(
        controller: inputTextCtrl,
        decoration: InputDecoration(labelText: 'Type any text and click the button.'),
        onChanged: (String value) {
          if (value.length > 0) {
            _onChange(value);
          } else {
            setState(() {
              this.inputText = "Please, type something!";
            });
          }
        },
        //to select all
        onTap: () => inputTextCtrl.selection = TextSelection(
            baseOffset: 0, extentOffset: inputTextCtrl.text.length),
      ));

  Widget _volume() {
    return Row(
      children: <Widget>[
        Text(
          'Volume',
          style: TextStyle(color: Colors.teal),
        ),
        Expanded(
          child: Slider(
            value: volume,
            onChanged: (newVolume) {
              setState(() => volume = newVolume);
            },
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: "Volume: $volume",
          ),
        )
      ],
    );
  } //_volume

  Widget _pitch() {
    return Row(
      children: <Widget>[
        Text(
          'Pitch',
          style: TextStyle(color: Colors.teal),
        ),
        Expanded(
          child: Slider(
            value: pitch,
            onChanged: (newPitch) {
              setState(() => pitch = newPitch);
            },
            min: 0.0,
            max: 2.0,
            divisions: 10,
            label: "Pitch: $pitch",
          ),
        )
      ],
    );
  }

  Widget _speechRate() {
    return Row(
      children: <Widget>[
        Text(
          'Speed Rate',
          style: TextStyle(color: Colors.teal),
        ),
        Expanded(
          child: Slider(
            value: speechRate,
            onChanged: (newspeechRate) {
              setState(() => speechRate = newspeechRate);
            },
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: "Speech Rate: $speechRate",
          ),
        )
      ],
    );
  }

  Widget _languageSelect() {
    try {
      return DropdownButton(
        icon: Icon(Icons.arrow_drop_down),
        iconEnabledColor: Colors.teal,
        hint: Text(
          "Select language",
          style: TextStyle(color: Colors.teal),
        ),
        onChanged: (val) {
          setState(() {
            this.lang = val;
            if (val == "en-US") {
              this.voice = "en-us-x-sfg#female_1-local";
            } else if (val == "bn-BD") {
              this.voice = "bn-BD-language";
            }
          });
        },
        value: this.lang,
        elevation: 16,
        style: TextStyle(color: Colors.teal, fontSize: 15),
        underline: Container(height: 2, color: Colors.teal),
        items: [
          DropdownMenuItem(
            value: 'en-US',
            child: Text('English'),
          ),
          DropdownMenuItem(
            value: 'bn-BD',
            child: Text('Bangla'),
          )
        ],
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  } //_dropDownMenu

  Widget _btnReset() {
    return RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text('Reset'),
        textColor: Colors.black,
        color: Colors.cyan,
        onPressed: () {
          setState(() {
            lang = 'en-US';
            volume = 0.5;
            pitch = 1.0;
            speechRate = 0.5;
            voice = "en-us-x-sfg#female_1-local";
            inputText = "Please, type something!";
            inputTextCtrl.text = '';
          });
        });
  }
} //_TextToSpeechState class
