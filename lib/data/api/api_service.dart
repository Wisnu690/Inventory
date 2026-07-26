import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ GANTI IP INI SESUAI DENGAN IP LAPTOP KAMU (Cek via cmd -> ipconfig)
  // Jangan gunakan localhost / 127.0.0.1 karena emulator tidak akan mengenalnya.
  static const String baseUrl = "http://192.168.1.7:8000/api"; 

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
// GET STOCK HISTORY (BERDASARKAN USER ID JIKA ADA)
  Future<List<dynamic>> getStockHistory({int? userId}) async {
    try {
      final String url = userId != null
          ? '$baseUrl/stock-history?user_id=$userId'
          : '$baseUrl/stock-history';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          return jsonResponse['data'];
        } else if (jsonResponse is List) {
          return jsonResponse;
        }
        return [];
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

// SEARCH ITEM BY BARCODE OR SKU
  Future<Map<String, dynamic>?> getItemByCode(String code) async {
    try {
      final items = await getItems();
      for (var item in items) {
        if (item['barcode']?.toString() == code || item['sku']?.toString() == code) {
          return item; // Barang ditemukan
        }
      }
      return null; // Barang tidak ditemukan
    } catch (e) {
      return null;
    }
  }

  
// GET CATEGORY
// GET CATEGORY (Sudah Diperbaiki)
Future<List<dynamic>> getCategories() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      
      // Cek apakah response berupa Map yang memiliki key 'data'
      if (body is Map && body.containsKey('data')) {
        return body['data'];
      } 
      // Cek apakah response langsung berupa List
      else if (body is List) {
        return body;
      }
    }

    return [];
  } catch (e) {
    print("Error getCategories: $e");
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

// ==========================
// ITEM
// ==========================

// GET ITEM
Future<List<dynamic>> getItems() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/items'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }

    return [];
  } catch (e) {
    return [];
  }
}

// ADD ITEM
Future<Map<String, dynamic>> addItem({
  required int categoryId,
  required String name,
  required String brand,
  required String barcode,
  required String sku,
  required int stock,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/items'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category_id': categoryId,
        'name': name,
        'brand': brand,
        'barcode': barcode,
        'sku': sku,
        'stock': stock,
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

// UPDATE ITEM
Future<void> updateItem({
  required int id,
  required int categoryId,
  required String name,
  required String brand,
  required String barcode,
  required String sku,
  required int stock,
}) async {
  await http.put(
    Uri.parse('$baseUrl/items/$id'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'category_id': categoryId,
      'name': name,
      'brand': brand,
      'barcode': barcode,
      'sku': sku,
      'stock': stock,
    }),
  );
}

// DELETE ITEM
Future<void> deleteItem(int id) async {
  await http.delete(
    Uri.parse('$baseUrl/items/$id'),
  );
}



// GET ALL USERS
Future<List<dynamic>> getUsers() async {
  final response = await http.get(Uri.parse('$baseUrl/users'));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Gagal mengambil data user');
  }
}

// ADD USER
Future<bool> addUser(String name, String email, String role, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': name,
      'email': email,
      'role': role,
      'password': password,
    }),
  );
  return response.statusCode == 201 || response.statusCode == 200;
}

// UPDATE USER
Future<bool> updateUser(int id, String name, String email, String role, String? password) async {
  Map<String, dynamic> bodyData = {
    'name': name,
    'email': email,
    'role': role,
  };
  
  // Jika password diisi, sertakan dalam body request
  if (password != null && password.isNotEmpty) {
    bodyData['password'] = password;
  }

  final response = await http.put(
    Uri.parse('$baseUrl/users/$id'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(bodyData),
  );
  return response.statusCode == 200;
}

// DELETE USER
Future<bool> deleteUser(int id) async {
  final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
  return response.statusCode == 200;
}

}