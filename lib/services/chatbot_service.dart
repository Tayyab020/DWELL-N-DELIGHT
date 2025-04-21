import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> postToAitoHuman() async {
  final url = Uri.parse('https://chatgpt-42.p.rapidapi.com/aitohuman');

  final headers = {
    'Content-Type': 'application/json',
    'X-Rapidapi-Key': '056b9a11a8msh6bd2e4429b25ba1p1b548djsne1c78ed5fa6b',
    'X-Rapidapi-Host': 'chatgpt-42.p.rapidapi.com',
  };

  final body = jsonEncode({
    "text":
        "Global warming is the long-term rise in Earth's average temperature due to human activities, primarily the burning of fossil fuels, deforestation, and industrial emissions. These activities release greenhouse gases like carbon dioxide and methane, which trap heat in the atmosphere and lead to climate change. As a result, glaciers are melting, sea levels are rising, and extreme weather events such as hurricanes, heatwaves, and droughts are becoming more frequent. Global warming also threatens biodiversity, disrupts ecosystems, and impacts agriculture, leading to food and water shortages. Urgent action, including reducing carbon emissions, adopting renewable energy, and promoting sustainable practices, is essential to mitigate its effects."
  });

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Response: $responseData');
    } else {
      print('Failed with status: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
