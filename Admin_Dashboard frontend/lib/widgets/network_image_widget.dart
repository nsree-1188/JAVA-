import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkImageWidget extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<NetworkImageWidget> createState() => _NetworkImageWidgetState();
}

class _NetworkImageWidgetState extends State<NetworkImageWidget> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _testImageUrl();
  }

  Future<void> _testImageUrl() async {
    try {
      print('🧪 Testing image URL: ${widget.imageUrl}');

      final response = await http.head(
        Uri.parse(widget.imageUrl),
        headers: {
          'User-Agent': 'Flutter App',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 Image URL test response: ${response.statusCode}');
      print('📡 Content-Type: ${response.headers['content-type']}');
      print('📡 Content-Length: ${response.headers['content-length']}');

      if (response.statusCode != 200) {
        setState(() {
          _hasError = true;
          _errorMessage = 'HTTP ${response.statusCode}';
        });
      }
    } catch (e) {
      print('❌ Image URL test failed: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, color: Colors.red[600], size: 32),
            const SizedBox(height: 8),
            Text(
              'Image Failed',
              style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[600], fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      headers: {
        'User-Agent': 'Flutter App',
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
        'Cache-Control': 'no-cache',
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Image.network error: $error');
        print('❌ Stack trace: $stackTrace');

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = error.toString();
            });
          }
        });

        return widget.errorWidget ?? Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.red[600]),
              Text('Load Error', style: TextStyle(color: Colors.red[600])),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('✅ Image loaded successfully: ${widget.imageUrl}');
          return child;
        }

        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null;

        print('📥 Loading progress: ${progress != null ? (progress * 100).toInt() : '?'}%');

        return widget.placeholder ?? Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 2,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  progress != null ? '${(progress * 100).toInt()}%' : 'Loading...',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
