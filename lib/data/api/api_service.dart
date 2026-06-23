import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ GANTI IP INI SESUAI DENGAN IP LAPTOP KAMU (Cek via cmd -> ipconfig)
  // Jangan gunakan localhost / 127.0.0.1 karena emulator tidak akan mengenalnya.
  static const String baseUrl = "http://192.168.1.9:8000/api"; 

  // LOGIKA UNTUK LOGIN USER (POST)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Mengembalikan data JSON dari AuthController Laravel
      return json.decode(response.body);
    } catch (e) {
      return {
        'message': 'Gagal terhubung ke server. Pastikan IP benar dan Laravel menyala.'
      };
    }
  }

  // 1. LOGIKA UNTUK MENGAMBIL RIWAYAT STOK (GET)
  Future<List<dynamic>> getStockHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stock-history'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['data']; // Mengembalikan List data dari Laravel
      } else {
        throw Exception('Gagal memuat riwayat stok');
      }
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  // 2. LOGIKA UNTUK SIMPAN STOK MASUK (POST)
  Future<Map<String, dynamic>> stockIn({
    required int itemId,
    required int userId,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stock-in'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Wajib karena kita kirim raw JSON
        },
        body: jsonEncode({
          'item_id': itemId,
          'user_id': userId,
          'quantity': quantity,
          'notes': notes,
        }),
      );

      return json.decode(response.body); // Mengembalikan response dari Laravel
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }

  // 3. LOGIKA UNTUK SIMPAN STOK KELUAR (POST)
  Future<Map<String, dynamic>> stockOut({
    required int itemId,
    required int userId,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stock-out'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_id': itemId,
          'user_id': userId,
          'quantity': quantity,
          'notes': notes,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke server: $e'};
    }
  }


// GET CATEGORY
Future<List<dynamic>> getCategories() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return [];
  } catch (e) {
    return [];
  }
}

// ADD CATEGORY
Future<Map<String, dynamic>> addCategory(
  String name,
  String description,
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {
      'success': false,
      'message': e.toString(),
    };
  }
}

// DELETE CATEGORY
Future<void> deleteCategory(int id) async {
  await http.delete(
    Uri.parse('$baseUrl/categories/$id'),
  );
}

Future<void> updateCategory(
  int id,
  String name,
  String description,
) async {
  final response = await http.put(
    Uri.parse('$baseUrl/categories/$id'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'description': description,
    }),
  );

  print(response.statusCode);
  print(response.body);
}





}