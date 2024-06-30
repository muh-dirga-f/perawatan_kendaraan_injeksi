// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perawatan Kendaraan Injeksi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _brands = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final apiKey = dotenv.env['API_KEY'];
    final apiUrl = dotenv.env['API_URL'];
    final url = "${apiUrl!}/brand/all";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Api-Key': apiKey!,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _brands = data['data']['brand'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load data";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perawatan Kendaraan Injeksi"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _brands.length,
                  itemBuilder: (context, index) {
                    final brand = _brands[index];
                    final logoUrl =
                        '${dotenv.env['BASE_URL']!}/uploads/brand/' +
                            brand['logo'];
                    return ListTile(
                      leading: Image.network(logoUrl),
                      title: Text(brand['brand']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TypeMotorPage(
                              id: brand['id_brand'],
                              brand: brand['brand'],
                              logoUrl: logoUrl,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class TypeMotorPage extends StatefulWidget {
  final String id;
  final String brand;
  final String logoUrl;

  const TypeMotorPage({
    super.key,
    required this.id,
    required this.brand,
    required this.logoUrl,
  });

  @override
  _TypeMotorPageState createState() => _TypeMotorPageState();
}

class _TypeMotorPageState extends State<TypeMotorPage> {
  List<dynamic> _typeMotors = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchTypeMotors();
  }

  Future<void> fetchTypeMotors() async {
    final apiKey = dotenv.env['API_KEY'];
    final apiUrl = dotenv.env['API_URL'];
    final url =
        "${apiUrl!}/type_motor/all?filter=&field=&start=&limit=&filters[0][co][0][fl]=brand_motor&filters[0][co][0][op]=equal&filters[0][co][0][vl]=${widget.id}&filters[0][co][0][lg]=and&sort_field=&sort_order=ASC";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Api-Key': apiKey!,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _typeMotors = data['data']['type_motor'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load data";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Type Motor ${widget.brand}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _typeMotors.length,
                  itemBuilder: (context, index) {
                    final typeMotor = _typeMotors[index];
                    final imageUrl =
                        '${dotenv.env['BASE_URL']!}/uploads/type_motor/${typeMotor['image_motor']}';
                    return ListTile(
                      leading: Image.network(imageUrl),
                      title: Text(typeMotor['type_motor']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpecificationPage(
                              typeMotor: typeMotor,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class SpecificationPage extends StatelessWidget {
  final Map<String, dynamic> typeMotor;

  const SpecificationPage({super.key, required this.typeMotor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(typeMotor['type_motor']),
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            context,
            'Informasi Umum',
            typeMotor['informasi_umum'],
          ),
          _buildMenuItem(
            context,
            'Spesifikasi Teknis',
            typeMotor['spesifikasi_teknis'],
          ),
          _buildMenuItem(
            context,
            'Pemeliharaan',
            typeMotor['pemeliharaan'],
          ),
          _buildMenuItem(
            context,
            'Pemecahan Masalah',
            typeMotor['pemecahan_masalah'],
          ),
          _buildMenuItem(
            context,
            'Sistem Kelistrikan',
            typeMotor['sistem_kelistrikan'],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String pdfUrl) {
    return ListTile(
      title: Text(title),
      onTap: () {
        launchPdf(
          context,
          '${dotenv.env['BASE_URL']!}/uploads/type_motor/$pdfUrl',
          title,
        );
      },
    );
  }

  void launchPdf(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PDFViewerFromUrl(pdfUrl: url, title: title)),
    );
  }
}

class PDFViewerFromUrl extends StatelessWidget {
  const PDFViewerFromUrl(
      {super.key, required this.pdfUrl, required this.title});

  final String pdfUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const PDF().fromUrl(
        pdfUrl,
        placeholder: (double progress) => Center(child: Text('$progress %')),
        errorWidget: (dynamic error) => Center(child: Text(error.toString())),
      ),
    );
  }
}
