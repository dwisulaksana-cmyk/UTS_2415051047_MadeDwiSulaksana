
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/ormawa.dart';

const Color primaryColor = Color(0xFF673AB7);
const Color backgroundColor = Color(0xFFF7F5FC);

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
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

  void clearSearch() {
    _searchController.clear();
    setState(() {
      searchQuery = '';
    });
  }

  void showOrmawaDetail(Ormawa ormawa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: primaryColor.withValues(
                        alpha: 0.10,
                      ),
                      child: _buildLogo(ormawa, 76),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      ormawa.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _detailTag(
                        Icons.category_outlined,
                        ormawa.category,
                      ),
                      _detailTag(
                        Icons.account_balance_outlined,
                        ormawa.level,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Tentang Organisasi',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    ormawa.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  if ((ormawa.instagram ?? '').isNotEmpty ||
                      (ormawa.contact ?? '').isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),

                    const Text(
                      'Informasi Kontak',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if ((ormawa.instagram ?? '').isNotEmpty)
                      _contactItem(
                        Icons.camera_alt_outlined,
                        'Instagram',
                        ormawa.instagram!,
                      ),

                    if ((ormawa.contact ?? '').isNotEmpty)
                      _contactItem(
                        Icons.phone_outlined,
                        'Kontak',
                        ormawa.contact!,
                      ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(Ormawa ormawa, double size) {
    if (ormawa.logoUrl != null &&
        ormawa.logoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          ormawa.logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Icon(
              Icons.groups_rounded,
              size: size * 0.55,
              color: primaryColor,
            );
          },
        ),
      );
    }

    return Icon(
      Icons.groups_rounded,
      size: size * 0.55,
      color: primaryColor,
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 65,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 18),
            const Text(
              'Gagal mengambil data organisasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 14),
          const Text(
            'Organisasi tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba gunakan kata kunci lainnya.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: clearSearch,
            child: const Text('Hapus pencarian'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard(Ormawa ormawa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => showOrmawaDetail(ormawa),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: primaryColor.withValues(
                  alpha: 0.09,
                ),
                child: _buildLogo(ormawa, 58),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ormawa.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      ormawa.category,
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            ormawa.level,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        title: const Row(
          children: [
            Icon(Icons.explore_rounded, size: 25),
            SizedBox(width: 10),
            Text(
              'Explore Ormawa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: refreshData,
            tooltip: 'Muat ulang data',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: FutureBuilder<List<Ormawa>>(
        future: _ormawaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
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
              // Header halaman
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF673AB7),
                      Color(0xFF9575CD),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temukan Organisasi Favoritmu!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jelajahi organisasi mahasiswa Universitas '
                      'Pendidikan Ganesha dan temukan ruang untuk '
                      'mengembangkan potensimu.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.groups_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${ormawaList.length} Organisasi Terdaftar',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Pencarian
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama organisasi...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: primaryColor,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: clearSearch,
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Hapus pencarian',
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Judul filter
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Kategori Organisasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${filteredList.length} hasil',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Filter kategori
              SizedBox(
                height: 42,
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
                      showCheckmark: false,
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: selectedCategory == category
                            ? primaryColor
                            : Colors.grey.shade300,
                      ),
                      labelStyle: TextStyle(
                        color: selectedCategory == category
                            ? Colors.white
                            : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // Daftar organisasi
              Expanded(
                child: filteredList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          20,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildOrganizationCard(
                            filteredList[index],
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
