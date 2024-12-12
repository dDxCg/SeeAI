import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


class AzureService {
  final String _backendUrl = "http://your-backend-url.com/upload";

  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var decodedData = jsonDecode(responseData.body);
        return decodedData['description']; 
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}