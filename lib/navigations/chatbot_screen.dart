import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  File? _selectedFile; // For storing the selected file

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': 'Welcome!',
      'isUserMessage': false,
    });
  }

  // void _sendMessage() async {
  //   if (_controller.text.isNotEmpty || _selectedFile != null) {
  //     // Add user's text message if it exists
  //     if (_controller.text.isNotEmpty) {
  //       setState(() {
  //         _messages.add({
  //           'text': _controller.text,
  //           'isUserMessage': true,
  //         });
  //       });
  //     }
  //
  //     // Add selected image as a message if it exists
  //     if (_selectedFile != null) {
  //       setState(() {
  //         _messages.add({
  //           'file': _selectedFile,
  //           'isUserMessage': true,
  //         });
  //       });
  //     }
  //
  //     // Prepare request
  //     var request = http.MultipartRequest('POST', Uri.parse(ENVConfig.serverUrl + '/chatbot-response'));
  //
  //     // Attach the message text
  //     request.fields['phrase'] = _controller.text;
  //
  //     // Attach the file if selected
  //     if (_selectedFile != null) {
  //       request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));
  //     }
  //
  //     // Send request
  //     var response = await request.send();
  //
  //     // Handle response
  //     if (response.statusCode == 200) {
  //       final respStr = await response.stream.bytesToString();
  //       final Map<String, dynamic> data = jsonDecode(respStr);
  //       print(data);
  //       setState(() {
  //         _messages.add({
  //           'text': data['ai_response'] ?? 'Error: Invalid response',
  //           'isUserMessage': false,
  //         });
  //       });
  //     } else {
  //       setState(() {
  //         _messages.add({
  //           'text': 'No response Received',
  //           'isUserMessage': false,
  //         });
  //       });
  //     }
  //
  //     _controller.clear();
  //     _selectedFile = null; // Clear the file after upload
  //   }
  // }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _controller.text,
          'isUserMessage': true,
        });
      });

          if (_selectedFile != null) {
            setState(() {
              _messages.add({
                'file': _selectedFile,
                'isUserMessage': true,
              });
            });
          }

      // Make HTTP POST request
      final response = await http.post(
        Uri.parse(ENVConfig.serverUrl + '/chatbot-response'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phrase': _controller.text,
        }),
      );

      _selectedFile = null;

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        print(data);
        setState(() {
          _messages.add({
            'text': data['ai_response'] ?? 'Error: Invalid response',
            'isUserMessage': false,
          });
        });
      } else {
        setState(() {
          _messages.add({
            'text': 'No Response Found',
            'isUserMessage': false,
          });
        });
      }

      _controller.clear();

    }
  }

  // Function to handle file selection
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCACACA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Set the preferred height for the AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: const Text("Ask your Question"),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
            ],
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFCACACA), // Set background color here
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment: message['isUserMessage']
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: message['isUserMessage']
                              ? const Color(0xFF243E39)
                              : Styles.fontDark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                            bottomRight: message['isUserMessage']
                                ? Radius.zero
                                : Radius.circular(8),
                            bottomLeft: message['isUserMessage']
                                ? Radius.circular(8)
                                : Radius.zero,
                          ),
                          border: message['isUserMessage']
                              ? null
                              : Border.all(color: Styles.fontHighlight),
                        ),
                        child: message['file'] != null
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16), // Rectangular box with radial corners
                              child: Image.file(
                                message['file'],
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Uploaded image',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            if (message['text'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  message['text'],
                                  style: TextStyle(
                                    color: message['isUserMessage']
                                        ? Styles.fontHighlight2
                                        : Styles.bgColor,
                                  ),
                                ),
                              ),
                          ],
                        )
                            : Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            color: message['isUserMessage']
                                ? Styles.fontHighlight2
                                : Styles.bgColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Make the image circular
                        border: Border.all(
                          color: Styles.secondaryColor, // Change to any color you like
                          width: 6, // Border width
                        ),
                      ),
                      child: ClipOval(
                        child: Image.file(
                          _selectedFile!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Selected File: ${_selectedFile!.path.split('/').last}',
                      style: const TextStyle(color: Colors.black87, fontSize: 8),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF243E39),
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.attach_file, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Put your question Here!",
                        hintStyle: const TextStyle(
                            fontSize: 14, color: Colors.white60),
                        filled: true,
                        prefixStyle: const TextStyle(fontSize: 14),
                        prefixIcon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white60,
                        ),
                        fillColor: Styles.shadowColor,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white, // Set text color to white
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF243E39),
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
