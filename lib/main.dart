
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/ormawa.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gcsruajolxmipvijpqbg.supabase.co',
    publishableKey: 'sb_publishable__Wz4SRD0RxtowYf4CQJS8A_bwYogagZ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Explore Ormawa Undiksha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Ormawa>> _ormawaFuture;

  final TextEditingController _searchController =
      TextEditingController();

  String selectedCategory = 'Semua';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ormawaFuture = fetchOrmawa();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Ormawa>> fetchOrmawa() async {
    final response = await Supabase.instance.client
        .from('ormawa')
        .select()
        .order('name', ascending: true);

    return (response as List)
        .map((item) => Ormawa.fromJson(item))
        .toList();
  }

  void refreshData() {
    setState(() {
      _ormawaFuture = fetchOrmawa();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore Ormawa Undiksha',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang data',
          ),
        ],
      ),
      body: FutureBuilder<List<Ormawa>>(
        future: _ormawaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal mengambil data organisasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final ormawaList = snapshot.data ?? [];

          if (ormawaList.isEmpty) {
            return const Center(
              child: Text('Belum ada data organisasi.'),
            );
          }

          final categories = [
            'Semua',
            ...{
              ...ormawaList.map((item) => item.category),
            }.toList()..sort(),
          ];

          final filteredList = ormawaList.where((item) {
            final matchesCategory =
                selectedCategory == 'Semua' ||
                item.category == selectedCategory;

            final query = searchQuery.toLowerCase();

            final matchesSearch =
                item.name.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query) ||
                item.level.toLowerCase().contains(query) ||
                item.description.toLowerCase().contains(query);

            return matchesCategory && matchesSearch;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Organisasi Mahasiswa',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Jelajahi organisasi mahasiswa Universitas '
                      'Pendidikan Ganesha.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total organisasi: ${ormawaList.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kolom pencarian
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama organisasi...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.deepPurple,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                                icon: const Icon(Icons.clear),
                                tooltip: 'Hapus pencarian',
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter kategori
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Hasil pencarian
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Organisasi tidak ditemukan.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Coba gunakan kata kunci lainnya.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final ormawa = filteredList[index];

                          return Card(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 26,
                                backgroundColor:
                                    Colors.deepPurple.shade50,
                                child: ormawa.logoUrl != null &&
                                        ormawa.logoUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          ormawa.logoUrl!,
                                          width: 52,
                                          height: 52,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) =>
                                                  const Icon(
                                            Icons.groups,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.groups,
                                        color: Colors.deepPurple,
                                      ),
                              ),
                              title: Text(
                                ormawa.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ormawa.category,
                                      style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(ormawa.level),
                                  ],
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.all(24),
                                      child: SafeArea(
                                        child: Wrap(
                                          children: [
                                            Center(
                                              child: Icon(
                                                Icons.groups,
                                                size: 55,
                                                color: Colors
                                                    .deepPurple.shade400,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            Text(
                                              ormawa.name,
                                              style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Kategori: ${ormawa.category}',
                                            ),
                                            Text(
                                              'Tingkat: ${ormawa.level}',
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Deskripsi',
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(ormawa.description),
                                            const SizedBox(height: 20),
                                            if (ormawa.instagram != null)
                                              Text(
                                                'Instagram: ${ormawa.instagram}',
                                              ),
                                            if (ormawa.contact != null)
                                              Text(
                                                'Kontak: ${ormawa.contact}',
                                              ),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Tutup'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
