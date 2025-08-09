import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty or invalid URLs
    if (imageUrl.isEmpty) {
      print('DEBUG: Empty image URL provided');
      return _buildPlaceholder();
    }

    print('DEBUG: Loading image: $imageUrl');

    // Check if it's a Firebase Storage URL
    final isFirebaseStorageUrl = imageUrl.contains('firebasestorage.googleapis.com');
    
    if (kIsWeb) {
      // Web-specific implementation
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          // Remove headers for Firebase Storage URLs as they might cause issues
          headers: isFirebaseStorageUrl ? null : const {
            'Access-Control-Allow-Origin': '*',
            'Cache-Control': 'no-cache',
          },
          errorBuilder: (context, error, stackTrace) {
            print('DEBUG: Image failed to load: $imageUrl');
            print('DEBUG: Error: $error');
            print('DEBUG: Stack trace: $stackTrace');
            return _buildPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('DEBUG: Image loaded successfully: $imageUrl');
              return child;
            }
            print('DEBUG: Loading progress: ${loadingProgress.expectedTotalBytes != null ? '${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}' : 'Unknown'}');
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      );
    } else {
      // Mobile implementation
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            print('DEBUG: Image failed to load: $imageUrl');
            print('DEBUG: Error: $error');
            print('DEBUG: Stack trace: $stackTrace');
            return _buildPlaceholder();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('DEBUG: Image loaded successfully: $imageUrl');
              return child;
            }
            print('DEBUG: Loading progress: ${loadingProgress.expectedTotalBytes != null ? '${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}' : 'Unknown'}');
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 