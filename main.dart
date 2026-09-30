import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Data Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DaftarMahasiswaPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------
class Mahasiswa {
  final String nim;
  final String nama;
  final String prodi;
  final String kelas;

  Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.kelas,
  });
}

// Hasil dari halaman detail (edit / hapus)
class DetailResult {
  final bool hapus;
  final Mahasiswa? dataBaru;
  DetailResult.hapus()
      : hapus = true,
        dataBaru = null;
  DetailResult.edit(this.dataBaru) : hapus = false;
}

const List<String> daftarProdi = [
  'Informatika',
  'Sistem Informasi',
  'Teknik Komputer',
];

// ---------------------------------------------------------------------------
// Halaman 1: Daftar Mahasiswa (+ pencarian, filter, total, empty state)
// ---------------------------------------------------------------------------
class DaftarMahasiswaPage extends StatefulWidget {
  const DaftarMahasiswaPage({super.key});

  @override
  State<DaftarMahasiswaPage> createState() => _DaftarMahasiswaPageState();
}

class _DaftarMahasiswaPageState extends State<DaftarMahasiswaPage> {
  final List<Mahasiswa> _data = [
    Mahasiswa(nim: '231001', nama: 'Andi Saputra', prodi: 'Informatika', kelas: 'TI-3A'),
    Mahasiswa(nim: '231002', nama: 'Budi Santoso', prodi: 'Informatika', kelas: 'TI-3A'),
    Mahasiswa(nim: '231003', nama: 'Citra Lestari', prodi: 'Sistem Informasi', kelas: 'SI-3B'),
    Mahasiswa(nim: '231004', nama: 'Dewi Anggraini', prodi: 'Sistem Informasi', kelas: 'SI-3B'),
    Mahasiswa(nim: '231005', nama: 'Eko Prasetyo', prodi: 'Teknik Komputer', kelas: 'TK-3A'),
    Mahasiswa(nim: '231006', nama: 'Fajar Nugroho', prodi: 'Teknik Komputer', kelas: 'TK-3A'),
    Mahasiswa(nim: '231007', nama: 'Gita Permata', prodi: 'Informatika', kelas: 'TI-3B'),
    Mahasiswa(nim: '231008', nama: 'Hendra Wijaya', prodi: 'Informatika', kelas: 'TI-3B'),
    Mahasiswa(nim: '231009', nama: 'Intan Maharani', prodi: 'Sistem Informasi', kelas: 'SI-3A'),
    Mahasiswa(nim: '231010', nama: 'Joko Susilo', prodi: 'Teknik Komputer', kelas: 'TK-3B'),
  ];

  final TextEditingController _cariController = TextEditingController();
  String _keyword = '';
  String _filterProdi = 'Semua';

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  // Data yang tampil setelah pencarian + filter
  List<Mahasiswa> get _hasil {
    return _data.where((m) {
      final cocokProdi = _filterProdi == 'Semua' || m.prodi == _filterProdi;
      final k = _keyword.toLowerCase();
      final cocokCari =
          k.isEmpty || m.nama.toLowerCase().contains(k) || m.nim.contains(k);
      return cocokProdi && cocokCari;
    }).toList();
  }

  Future<void> _tambah() async {
    final baru = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(builder: (_) => const FormMahasiswaPage()),
    );
    if (baru != null) {
      setState(() => _data.add(baru));
    }
  }

  Future<void> _lihatDetail(Mahasiswa m) async {
    final hasil = await Navigator.push<DetailResult>(
      context,
      MaterialPageRoute(builder: (_) => DetailMahasiswaPage(mahasiswa: m)),
    );
    if (hasil == null) return;
    final index = _data.indexOf(m);
    if (index == -1) return;
    setState(() {
      if (hasil.hapus) {
        _data.removeAt(index);
      } else if (hasil.dataBaru != null) {
        _data[index] = hasil.dataBaru!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tampil = _hasil;

    return Scaffold(
      appBar: AppBar(title: const Text('Data Mahasiswa')),
      body: Column(
        children: [
          // Jumlah mahasiswa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Mahasiswa: ${_data.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _cariController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari nama atau NIM...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _keyword = v),
            ),
          ),
          // Filter program studi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _filterProdi,
              decoration: const InputDecoration(
                labelText: 'Filter Program Studi',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ['Semua', ...daftarProdi]
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) => setState(() => _filterProdi = v ?? 'Semua'),
            ),
          ),
          const SizedBox(height: 8),
          // Daftar / empty state
          Expanded(
            child: tampil.isEmpty
                ? Center(
                    child: Text(
                      _data.isEmpty
                          ? 'Belum ada data mahasiswa'
                          : 'Data tidak ditemukan',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: tampil.length,
                    itemBuilder: (context, i) {
                      final m = tampil[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          onTap: () => _lihatDetail(m),
                          leading: CircleAvatar(child: Text(m.nama[0])),
                          title: Text(m.nama),
                          subtitle: Text('${m.nim}\n${m.prodi} - ${m.kelas}'),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambah,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Mahasiswa'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Halaman 2: Form Tambah / Edit (dengan validasi)
// ---------------------------------------------------------------------------
class FormMahasiswaPage extends StatefulWidget {
  final Mahasiswa? mahasiswa; // null = tambah, ada isi = edit
  const FormMahasiswaPage({super.key, this.mahasiswa});

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nimC;
  late final TextEditingController _namaC;
  late final TextEditingController _prodiC;
  late final TextEditingController _kelasC;

  bool get _modeEdit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();
    // Data lama otomatis muncul saat mode edit
    _nimC = TextEditingController(text: widget.mahasiswa?.nim ?? '');
    _namaC = TextEditingController(text: widget.mahasiswa?.nama ?? '');
    _prodiC = TextEditingController(text: widget.mahasiswa?.prodi ?? '');
    _kelasC = TextEditingController(text: widget.mahasiswa?.kelas ?? '');
  }

  @override
  void dispose() {
    _nimC.dispose();
    _namaC.dispose();
    _prodiC.dispose();
    _kelasC.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        Mahasiswa(
          nim: _nimC.text.trim(),
          nama: _namaC.text.trim(),
          prodi: _prodiC.text.trim(),
          kelas: _kelasC.text.trim(),
        ),
      );
    }
  }

  String? _wajib(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Edit Mahasiswa' : 'Form Tambah Mahasiswa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nimC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'NIM', border: OutlineInputBorder()),
                validator: (v) => _wajib(v, 'NIM'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaC,
                decoration: const InputDecoration(
                    labelText: 'Nama', border: OutlineInputBorder()),
                validator: (v) => _wajib(v, 'Nama'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prodiC,
                decoration: const InputDecoration(
                    labelText: 'Program Studi', border: OutlineInputBorder()),
                validator: (v) => _wajib(v, 'Program Studi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kelasC,
                decoration: const InputDecoration(
                    labelText: 'Kelas', border: OutlineInputBorder()),
                validator: (v) => _wajib(v, 'Kelas'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simpan,
                child: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Halaman 3: Detail Mahasiswa (Edit + Hapus dengan AlertDialog)
// ---------------------------------------------------------------------------
class DetailMahasiswaPage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  const DetailMahasiswaPage({super.key, required this.mahasiswa});

  @override
  State<DetailMahasiswaPage> createState() => _DetailMahasiswaPageState();
}

class _DetailMahasiswaPageState extends State<DetailMahasiswaPage> {
  Future<void> _edit() async {
    final baru = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswaPage(mahasiswa: widget.mahasiswa),
      ),
    );
    if (baru != null && mounted) {
      Navigator.pop(context, DetailResult.edit(baru));
    }
  }

  Future<void> _hapus() async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (yakin == true && mounted) {
      Navigator.pop(context, DetailResult.hapus());
    }
  }

  Widget _baris(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(nilai,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mahasiswa;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _baris('NIM', m.nim),
            _baris('Nama', m.nama),
            _baris('Program Studi', m.prodi),
            _baris('Kelas', m.kelas),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _edit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _hapus,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
