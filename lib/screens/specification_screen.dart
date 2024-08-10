import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pdf_viewer_screen.dart';

class SpecificationPage extends StatefulWidget {
  final Map<String, dynamic> typeMotor;

  const SpecificationPage({super.key, required this.typeMotor});

  @override
  _SpecificationPageState createState() => _SpecificationPageState();
}

class _SpecificationPageState extends State<SpecificationPage> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    final videoUrl =
        '${dotenv.env['BASE_URL']!}/uploads/type_motor/${widget.typeMotor['video']}';
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _initializeVideoPlayerFuture = _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.typeMotor['type_motor'], style: const TextStyle(fontSize: 24)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          image: const DecorationImage(
            image: AssetImage('assets/pattern.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(8.0), // Padding for the ListView
          children: [
            _controller != null
                ? FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : const SizedBox.shrink(),
            _buildMenuItem(
              context,
              'Informasi Umum',
              widget.typeMotor['informasi_umum'],
            ),
            _buildMenuItem(
              context,
              'Spesifikasi Teknis',
              widget.typeMotor['spesifikasi_teknis'],
            ),
            _buildMenuItem(
              context,
              'Pemeliharaan',
              widget.typeMotor['pemeliharaan'],
            ),
            _buildMenuItem(
              context,
              'Pemecahan Masalah',
              widget.typeMotor['pemecahan_masalah'],
            ),
            _buildMenuItem(
              context,
              'Sistem Kelistrikan',
              widget.typeMotor['sistem_kelistrikan'],
            ),
          ],
        ),
      ),
      floatingActionButton: _controller != null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, String pdfUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Margin between items
      decoration: BoxDecoration(
        color: Colors.blue, // Background color blue
        borderRadius: BorderRadius.circular(12.0), // Border radius
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 20), // Text color for contrast
        ),
        onTap: () {
          launchPdf(
            context,
            '${dotenv.env['BASE_URL']!}/uploads/type_motor/$pdfUrl',
            title,
          );
        },
      ),
    );
  }

  void launchPdf(BuildContext context, String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerFromUrl(pdfUrl: url, title: title),
      ),
    );
  }
}
