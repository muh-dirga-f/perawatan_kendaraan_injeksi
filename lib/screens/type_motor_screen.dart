import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'specification_screen.dart';

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
        title: Text('Type Motor ${widget.brand}', style: const TextStyle(fontSize: 24)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: const DecorationImage(
                      image: AssetImage('assets/pattern.png'),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 10.0, // Horizontal space between items
                      mainAxisSpacing: 10.0, // Vertical space between items
                      childAspectRatio: 0.8, // Aspect ratio for the card layout
                    ),
                    itemCount: _typeMotors.length,
                    itemBuilder: (context, index) {
                      final typeMotor = _typeMotors[index];
                      final imageUrl =
                          '${dotenv.env['BASE_URL']!}/uploads/type_motor/${typeMotor['image_motor']}';

                      return GestureDetector(
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
                        child: Card(
                          color: Colors.white, // Background color of the card
                          elevation: 4.0, // Elevation for shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10.0)),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  typeMotor['type_motor'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
