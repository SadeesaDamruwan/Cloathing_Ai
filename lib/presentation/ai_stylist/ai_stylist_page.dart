import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';

// Import our Professional Layers
import 'package:assignment/data/services/database_service.dart';
import 'package:assignment/data/services/ai_service.dart';
import 'package:assignment/presentation/widgets/neumorphic_container.dart';

// Global memory persists across tabs
List<Map<String, dynamic>> _globalChatMessages = [];
List<Map<String, String>> _globalAiMemory = [];

class AiStylistPage extends StatefulWidget {
  const AiStylistPage({super.key});
  @override
  State<AiStylistPage> createState() => _AiStylistPageState();
}

class _AiStylistPageState extends State<AiStylistPage> {
  final _dbService = DatabaseService();
  final _aiService = AiService();
  final _ctrl = TextEditingController();
  final _scrollController = ScrollController();
  final _speech = SpeechToText();
  final _picker = ImagePicker();
  final _flutterTts = FlutterTts();

  bool _loading = false;
  bool _isListening = false;
  bool _isTtsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    if (_globalChatMessages.isEmpty) {
      _globalChatMessages.add({
        "role": "ai",
        "text": "Hey! I'm your Ai-powered Stylist. Ask me for an outfit! (Try asking: 'What should I wear for the weather outside?' or 'Find me a red striped polo shirt')"
      });
    }
    _scrollToBottom();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) { if (status == 'done' || status == 'notListening') setState(() => _isListening = false); },
      onError: (_) => setState(() => _isListening = false),
    );
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  void _toggleListening() async {
    await _flutterTts.stop();
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() => _ctrl.text = val.recognizedWords), pauseFor: const Duration(seconds: 3));
      }
    }
  }

  Future<void> _launchURL(String urlString) async {
    if (!await launchUrl(Uri.parse(urlString), mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 50, maxWidth: 600, maxHeight: 600);
    if (image != null) _showSaveDialog(File(image.path));
  }

  void _showSaveDialog(File imageFile) {
    String itemName = "";
    String selectedCategory = "Tops";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFE0E5EC),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add to Closet", style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(imageFile, height: 120, width: 120, fit: BoxFit.cover)),
              const SizedBox(height: 20),
              NeumorphicContainer(
                isInner: true,
                child: TextField(onChanged: (val) => itemName = val, decoration: const InputDecoration(border: InputBorder.none, hintText: "Item Name", contentPadding: EdgeInsets.symmetric(horizontal: 15))),
              ),
              const SizedBox(height: 20),
              NeumorphicContainer(
                isInner: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory, isExpanded: true,
                      items: ["Tops", "Bottoms", "Accessories"].map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                      onChanged: (val) => setDialogState(() => selectedCategory = val!),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (itemName.trim().isEmpty) return;
                Navigator.pop(context);
                _saveImage(imageFile, itemName.trim(), selectedCategory);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("Save Item", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage(File imageFile, String name, String category) async {
    setState(() => _loading = true);
    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());
      final user = FirebaseAuth.instance.currentUser;

      // Clean Professional Call
      await _dbService.saveCustomClosetItem(user!.uid, name, category, base64Image);

      setState(() {
        _globalChatMessages.add({"role": "user", "text": "Uploaded a photo of my $name.", "image": imageFile});
        _globalChatMessages.add({"role": "ai", "text": "✅ Saved your **$name**! What should we pair it with?"});
      });
    } catch (e) {
      setState(() => _globalChatMessages.add({"role": "ai", "text": "Failed to save: $e"}));
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  Future<void> _askAi() async {
    await _flutterTts.stop();
    if (_isListening) { await _speech.stop(); setState(() => _isListening = false); }

    final query = _ctrl.text.trim();
    if (query.isEmpty) return;

    setState(() { _globalChatMessages.add({"role": "user", "text": query}); _loading = true; });
    _ctrl.clear();
    _scrollToBottom();

    try {
      final user = FirebaseAuth.instance.currentUser;
      final doc = await _dbService.getUserProfile(user!.uid); // Using our Database Service!

      String closetItems = "No clothes added yet";
      if (doc.exists && doc.data() != null) {
        final custom = doc.data()!['custom_images'] as List<dynamic>? ?? [];
        if (custom.isNotEmpty) closetItems = custom.map((i) => "${i['name']} (${i['category']})").join(", ");
      }

      String weatherCtx = "";
      if (query.toLowerCase().contains(RegExp(r'weather|cold|hot|outside|temperature'))) {
        final tempInfo = await _aiService.getLocalWeather();
        if (tempInfo != null) weatherCtx = "\n\nCRITICAL CONTEXT: $tempInfo Suggest an outfit for this temperature.";
      }

      // Clean Professional Call
      final aiResponse = await _aiService.getAiResponse(
          query: query, closetItems: closetItems, weatherContext: weatherCtx, memory: _globalAiMemory
      );

      if (aiResponse.startsWith("SEARCH_WEB:")) {
        String searchQuery = aiResponse.replaceAll("SEARCH_WEB:", "").trim();
        await _performSearch(searchQuery);
      } else {
        setState(() { _globalChatMessages.add({"role": "ai", "text": aiResponse}); });
        if (_isTtsEnabled) await _flutterTts.speak(aiResponse.replaceAll('**', ''));
      }
    } catch (e) {
      setState(() => _globalChatMessages.add({"role": "ai", "text": "Styling error: $e"}));
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _globalChatMessages.add({"role": "ai", "text": "🔍 Searching for: **$query**..."}));
    try {
      final results = await _aiService.searchShoppingWeb(query);
      setState(() {
        _globalChatMessages.add({
          "role": "ai",
          "text": results.isEmpty ? "I couldn't find matches right now!" : "Here are the top options:",
          "shopping_results": results
        });
      });
    } catch (e) {
      setState(() => _globalChatMessages.add({"role": "ai", "text": "Search failed. Check your connection."}));
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Widget _buildText(String text, bool isAI) {
    final parts = text.split('**');
    return RichText(
      text: TextSpan(
        style: TextStyle(color: isAI ? Colors.black : Colors.white, fontSize: 15),
        children: List.generate(parts.length, (i) => TextSpan(text: parts[i], style: TextStyle(fontWeight: i % 2 == 1 ? FontWeight.w900 : FontWeight.normal))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E5EC),
      appBar: AppBar(
        title: const Text("Clothing Ai", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isTtsEnabled ? Icons.volume_up : Icons.volume_off, color: _isTtsEnabled ? Colors.black : Colors.black45),
            onPressed: () { setState(() => _isTtsEnabled = !_isTtsEnabled); if (!_isTtsEnabled) _flutterTts.stop(); },
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildChatList()),
            if (_loading) const LinearProgressIndicator(color: Colors.black),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController, padding: const EdgeInsets.all(20),
      itemCount: _globalChatMessages.length,
      itemBuilder: (ctx, i) {
        final msg = _globalChatMessages[i];
        bool isAI = msg["role"] == "ai";

        return Align(
          alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            padding: const EdgeInsets.all(16),
            decoration: isAI ? BoxDecoration(color: const Color(0xFFE0E5EC), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.grey.shade400, offset: const Offset(5, 5), blurRadius: 10), const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10)])
                : BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg["image"] != null) ...[ ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(msg["image"], height: 150, width: double.infinity, fit: BoxFit.cover)), const SizedBox(height: 10) ],
                _buildText(msg["text"]!, isAI),
                if (msg["shopping_results"] != null) _buildShoppingCarousel(msg["shopping_results"]),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShoppingCarousel(List<dynamic> results) {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 15),
      child: ListView.builder(
          scrollDirection: Axis.horizontal, itemCount: results.length,
          itemBuilder: (ctx, index) {
            final item = results[index];
            return GestureDetector(
              onTap: () { if (item["link"] != null) _launchURL(item["link"]); },
              child: Container(
                width: 130, margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: item["imageUrl"] != null && item["imageUrl"]!.isNotEmpty ? Image.network(item["imageUrl"]!.startsWith("//") ? "https:${item["imageUrl"]}" : item["imageUrl"], fit: BoxFit.cover, width: double.infinity) : Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.shopping_bag)))),
                    Padding(padding: const EdgeInsets.all(8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(item["price"]!, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)), Text(item["title"]!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, height: 1.2)) ]))
                  ],
                ),
              ),
            );
          }
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          GestureDetector(onTap: _toggleListening, child: NeumorphicContainer(isInner: _isListening, child: Padding(padding: const EdgeInsets.all(12), child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.black)))),
          const SizedBox(width: 10),
          PopupMenuButton<ImageSource>(
            color: const Color(0xFFE0E5EC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), offset: const Offset(0, -120),
            onSelected: _pickImage,
            itemBuilder: (ctx) => [const PopupMenuItem(value: ImageSource.camera, child: Text('Take a Photo')), const PopupMenuItem(value: ImageSource.gallery, child: Text('Gallery'))],
            child: const NeumorphicContainer(child: Padding(padding: EdgeInsets.all(12), child: Icon(Icons.add, size: 26))),
          ),
          const SizedBox(width: 10),
          Expanded(child: NeumorphicContainer(isInner: true, child: TextField(controller: _ctrl, onSubmitted: (_) => _askAi(), decoration: const InputDecoration(border: InputBorder.none, hintText: "Ask Cerebras...", contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14))))),
          IconButton(icon: const Icon(Icons.send), onPressed: _askAi),
        ],
      ),
    );
  }
}