import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class AiService {
  final String _cerebrasKey = "YOUR_CEREBRAS_API_KEY";
  final String _serperKey = "YOUR_SERPER_API_KEY";

  // --- 1. Weather API ---
  Future<String?> getLocalWeather() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      final url = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current_weather=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final temp = jsonDecode(response.body)['current_weather']['temperature'];
        return "The current local temperature for the user is $temp°C.";
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  // --- 2. Google Shopping API ---
  Future<List<Map<String, String>>> searchShoppingWeb(String query) async {
    final response = await http.post(
      Uri.parse('https://google.serper.dev/shopping'),
      headers: {'X-API-KEY': _serperKey, 'Content-Type': 'application/json'},
      body: jsonEncode({"q": query, "gl": "us"}),
    );

    if (response.statusCode == 200) {
      final shoppingResults = jsonDecode(response.body)['shopping'] as List<dynamic>? ?? [];
      List<Map<String, String>> formattedResults = [];

      for (var i = 0; i < 3 && i < shoppingResults.length; i++) {
        formattedResults.add({
          "title": shoppingResults[i]['title']?.toString() ?? "Unknown Item",
          "price": shoppingResults[i]['price']?.toString() ?? "Price varies",
          "imageUrl": shoppingResults[i]['imageUrl']?.toString() ?? "",
          "link": shoppingResults[i]['link']?.toString() ?? "",
        });
      }
      return formattedResults;
    }
    throw Exception("Shopping Search Failed");
  }

  // --- 3. Cerebras LLM API ---
  Future<String> getAiResponse({
    required String query,
    required String closetItems,
    required String weatherContext,
    required List<Map<String, String>> memory,
  }) async {
    String systemPrompt = """You are an exclusive, professional AI personal stylist in 2026. 
The user's digital closet contains: [$closetItems]. 

STRICT RULES:
1. BE CONCISE: Keep answers short and punchy.
2. HIGHLIGHT CLOTHES: Wrap every clothing item in double asterisks (e.g., **Red Hoodie**).
3. WEATHER RULE: Use weather data to recommend outfits from the closet.
4. FASHION ONLY: Strictly limit answers to fashion.
5. STRICT CLOSET RESTRAINT: ONLY suggest items explicitly listed in the closet above.
6. EMPTY CLOSET: If "No clothes added yet", say exactly: "You don't have enough clothes in your digital closet for that! First Upload Outfits to the Closet."
7. THE CREATOR: If asked about your creator, reply: "I was created by Sadeesa Damruwan! Also known as Kakashi_EvoX. He's a Software Engineering undergrad at NSBM and founder of TechnovaSolutions."
8. PERSONAL SHOPPER: If the user asks to buy/shop online, output EXACTLY this format: SEARCH_WEB: [Query].""";

    if (memory.isEmpty) {
      memory.add({"role": "system", "content": systemPrompt});
    } else {
      memory[0] = {"role": "system", "content": systemPrompt};
    }
    memory.add({"role": "user", "content": query + weatherContext});

    final response = await http.post(
      Uri.parse('https://api.cerebras.ai/v1/chat/completions'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_cerebrasKey'},
      body: jsonEncode({"model": "llama3.1-8b", "messages": memory, "temperature": 0.2}),
    );

    if (response.statusCode == 200) {
      final text = jsonDecode(response.body)['choices'][0]['message']['content'].toString().trim();
      memory.add({"role": "assistant", "content": text});
      return text;
    }
    throw Exception("AI Request Failed");
  }
}