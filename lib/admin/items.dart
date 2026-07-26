import 'package:flutter/material.dart';
import '../data/api/api_service.dart';

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  final ApiService apiService = ApiService();

  List items = [];
  List categories = [];
  bool isLoading = true;

  // 📱 DAFTAR MERK / BRAND
  final List<String> brandList = [
    'Samsung',
    'Xiaomi',
    'POCO',
    'Redmi',
    'OPPO',
    'vivo',
    'realme',
    'Apple (iPhone)',
    'Infinix',
    'TECNO',
    'itel',
    'HONOR',
    'Huawei',
    'ASUS (Zenfone dan ROG Phone)',
    'Nubia',
    'ZTE',
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // 🔄 LOAD DATA ITEMS & CATEGORIES DARI API
  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final itemsData = await apiService.getItems();
      final categoriesData = await apiService.getCategories();

      if (mounted) {
        setState(() {
          items = itemsData;
          categories = categoriesData;
        });
      }
    } catch (e) {
      print("Error saat load data: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ➕ TAMBAH ITEM
  void showAddDialog() async {
    if (categories.isEmpty) {
      final fetchedCategories = await apiService.getCategories();
      setState(() {
        categories = fetchedCategories;
      });
    }

    TextEditingController nameController = TextEditingController();
    TextEditingController barcodeController = TextEditingController();
    TextEditingController skuController = TextEditingController();
    TextEditingController stockController = TextEditingController();

    int? selectedCategoryId;
    String? selectedBrand;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Tambah Item"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama Item"),
                  ),
                  const SizedBox(height: 10),

                  // 🔽 DROPDOWN KATEGORI
                  categories.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Kategori tidak ditemukan! Tambahkan kategori dulu.",
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        )
                      : DropdownButtonFormField<int>(
                          isExpanded: true, // 👈 CEGAH OVERFLOW HORISONAL
                          value: selectedCategoryId,
                          decoration: const InputDecoration(labelText: "Kategori"),
                          items: categories.map<DropdownMenuItem<int>>((cat) {
                            return DropdownMenuItem<int>(
                              value: cat['id'],
                              child: Text(
                                cat['name'] ?? 'Kategori ${cat['id']}',
                                overflow: TextOverflow.ellipsis, // 👈 POTONG TEKS
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedCategoryId = value;
                            });
                          },
                          hint: const Text("Pilih Kategori"),
                        ),

                  const SizedBox(height: 10),

                  // 🔽 DROPDOWN MERK / BRAND
                  DropdownButtonFormField<String>(
                    isExpanded: true, // 👈 CEGAH OVERFLOW HORISONAL
                    value: selectedBrand,
                    decoration: const InputDecoration(labelText: "Brand / Merk"),
                    items: brandList.map<DropdownMenuItem<String>>((brand) {
                      return DropdownMenuItem<String>(
                        value: brand,
                        child: Text(
                          brand,
                          overflow: TextOverflow.ellipsis, // 👈 POTONG TEKS JIKA TERLALU PANJANG
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedBrand = value;
                      });
                    },
                    hint: const Text("Pilih Brand / Merk"),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: barcodeController,
                    decoration: const InputDecoration(labelText: "Barcode"),
                  ),
                  TextField(
                    controller: skuController,
                    decoration: const InputDecoration(labelText: "SKU"),
                  ),
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Jumlah Stok"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () async {
                  if (selectedCategoryId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Silakan pilih kategori terlebih dahulu")),
                    );
                    return;
                  }

                  if (selectedBrand == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Silakan pilih brand / merk terlebih dahulu")),
                    );
                    return;
                  }

                  final res = await apiService.addItem(
                    categoryId: selectedCategoryId!,
                    name: nameController.text,
                    brand: selectedBrand!,
                    barcode: barcodeController.text,
                    sku: skuController.text,
                    stock: int.tryParse(stockController.text) ?? 0,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    
                    String msg = res['message'] ?? "Item berhasil ditambahkan";
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg)),
                    );

                    loadData();
                  }
                },
                child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✏️ EDIT ITEM
  void showEditDialog(Map item) {
    TextEditingController nameController =
        TextEditingController(text: item['name']);
    TextEditingController barcodeController =
        TextEditingController(text: item['barcode'] ?? '');
    TextEditingController skuController =
        TextEditingController(text: item['sku'] ?? '');
    TextEditingController stockController =
        TextEditingController(text: item['stock']?.toString() ?? '0');

    int? selectedCategoryId = item['category_id'];
    bool categoryExists = categories.any((cat) => cat['id'] == selectedCategoryId);
    if (!categoryExists) {
      selectedCategoryId = null;
    }

    String? selectedBrand = item['brand'];
    if (!brandList.contains(selectedBrand)) {
      selectedBrand = null;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Edit Item"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Nama Item"),
                  ),
                  
                  const SizedBox(height: 10),

                  // 🔽 DROPDOWN KATEGORI
                  categories.isEmpty
                      ? const Text("Kategori tidak tersedia", style: TextStyle(color: Colors.red))
                      : DropdownButtonFormField<int>(
                          isExpanded: true, // 👈 CEGAH OVERFLOW
                          value: selectedCategoryId,
                          decoration: const InputDecoration(labelText: "Kategori"),
                          items: categories.map<DropdownMenuItem<int>>((cat) {
                            return DropdownMenuItem<int>(
                              value: cat['id'],
                              child: Text(
                                cat['name'] ?? 'Kategori ${cat['id']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedCategoryId = value;
                            });
                          },
                          hint: const Text("Pilih Kategori"),
                        ),

                  const SizedBox(height: 10),

                  // 🔽 DROPDOWN MERK / BRAND
                  DropdownButtonFormField<String>(
                    isExpanded: true, // 👈 CEGAH OVERFLOW
                    value: selectedBrand,
                    decoration: const InputDecoration(labelText: "Brand / Merk"),
                    items: brandList.map<DropdownMenuItem<String>>((brand) {
                      return DropdownMenuItem<String>(
                        value: brand,
                        child: Text(
                          brand,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedBrand = value;
                      });
                    },
                    hint: const Text("Pilih Brand / Merk"),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: barcodeController,
                    decoration: const InputDecoration(labelText: "Barcode"),
                  ),
                  TextField(
                    controller: skuController,
                    decoration: const InputDecoration(labelText: "SKU"),
                  ),
                  TextField(
                    controller: stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Jumlah Stok"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () async {
                  if (selectedCategoryId == null || selectedBrand == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pastikan Kategori dan Brand sudah dipilih")),
                    );
                    return;
                  }

                  await apiService.updateItem(
                    id: item['id'],
                    categoryId: selectedCategoryId!,
                    name: nameController.text,
                    brand: selectedBrand!,
                    barcode: barcodeController.text,
                    sku: skuController.text,
                    stock: int.tryParse(stockController.text) ?? 0,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    await loadData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Item berhasil diperbarui")),
                    );
                  }
                },
                child: const Text("Update", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // 🗑️ HAPUS ITEM
  void deleteItem(int id) async {
    await apiService.deleteItem(id);
    loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item berhasil dihapus")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Items"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "ITEMS",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // BUTTON TAMBAH ITEM
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: showAddDialog,
                  child: const Text(
                    "+ ADD NEW ITEM",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // SEARCH BAR
              TextField(
                decoration: InputDecoration(
                  hintText: "SEARCH ITEMS",
                  filled: true,
                  fillColor: Colors.grey[300],
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // LIST ITEMS
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? const Center(
                            child: Text("Belum ada item"),
                          )
                        : ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "SKU: ${item['sku'] ?? '-'} | Brand: ${item['brand'] ?? '-'}",
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            "Stok: ${item['stock'] ?? 0} | Barcode: ${item['barcode'] ?? '-'}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // EDIT
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => showEditDialog(item),
                                    ),

                                    // DELETE
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => deleteItem(item['id']),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}