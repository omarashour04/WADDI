import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const FirebaseImageWidget({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('DEBUG: FirebaseImageWidget - Original URL: $imageUrl');
    
    if (imageUrl.isEmpty) {
      print('DEBUG: Image URL is empty, showing placeholder');
      return _buildPlaceholder();
    }

    // For Firebase Storage URLs, always try to get a fresh download URL
    if (imageUrl.contains('firebasestorage.googleapis.com')) {
      print('DEBUG: Detected Firebase Storage URL, getting fresh download URL');
      return _buildFirebaseStorageImage();
    } else if (imageUrl.startsWith('gs://')) {
      print('DEBUG: Detected gs:// URL, converting to Firebase Storage reference');
      return _buildGsUrlImage();
    } else {
      print('DEBUG: Treating as regular network image');
      return _buildNetworkImage();
    }
  }

  Widget _buildFirebaseStorageImage() {
    try {
      // Extract the path from the Firebase Storage URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length < 3) {
        print('DEBUG: Invalid Firebase Storage URL format: $imageUrl');
        return _buildPlaceholder();
      }

      // Get the object path (everything after /o/)
      final objectPath = pathSegments.sublist(2).join('/');
      final decodedPath = Uri.decodeComponent(objectPath);
      
      print('DEBUG: Firebase Storage path: $decodedPath');

      // Get fresh download URL from Firebase Storage
      return FutureBuilder<String>(
        future: FirebaseStorage.instance.ref(decodedPath).getDownloadURL(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            print('DEBUG: Error getting download URL: ${snapshot.error}');
            // Try the original URL as fallback
            return _buildNetworkImageWithFallback();
          }

          if (!snapshot.hasData) {
            return _buildPlaceholder();
          }

          final downloadUrl = snapshot.data!;
          print('DEBUG: Fresh download URL: $downloadUrl');

          return ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: Image.network(
              downloadUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                print('DEBUG: Image failed to load with fresh URL: $downloadUrl');
                print('DEBUG: Error: $error');
                // Try the original URL as fallback
                return _buildNetworkImageWithFallback();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  print('DEBUG: Image loaded successfully with fresh URL: $downloadUrl');
                  return child;
                }
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
        },
      );
    } catch (e) {
      print('DEBUG: Error parsing Firebase Storage URL: $e');
      return _buildNetworkImageWithFallback();
    }
  }

  Widget _buildNetworkImageWithFallback() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        headers: kIsWeb ? {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Requested-With',
          'Cache-Control': 'no-cache',
        } : null,
        errorBuilder: (context, error, stackTrace) {
          print('DEBUG: Image failed to load with fallback: $imageUrl');
          print('DEBUG: Error: $error');
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('DEBUG: Image loaded successfully with fallback: $imageUrl');
            return child;
          }
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

  Widget _buildGsUrlImage() {
    try {
      // Convert gs:// URL to Firebase Storage reference
      final gsUrl = imageUrl;
      final ref = FirebaseStorage.instance.refFromURL(gsUrl);
      
      print('DEBUG: Converting gs:// URL to reference: $gsUrl');

      return FutureBuilder<String>(
        future: ref.getDownloadURL(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            print('DEBUG: Error getting download URL from gs://: ${snapshot.error}');
            return _buildPlaceholder();
          }

          if (!snapshot.hasData) {
            return _buildPlaceholder();
          }

          final downloadUrl = snapshot.data!;
          print('DEBUG: Download URL from gs://: $downloadUrl');

          return ClipRRect(
            borderRadius: borderRadius ?? BorderRadius.zero,
            child: Image.network(
              downloadUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                print('DEBUG: Image failed to load from gs://: $downloadUrl');
                print('DEBUG: Error: $error');
                return _buildPlaceholder();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  print('DEBUG: Image loaded successfully from gs://: $downloadUrl');
                  return child;
                }
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
        },
      );
    } catch (e) {
      print('DEBUG: Error handling gs:// URL: $e');
      return _buildPlaceholder();
    }
  }

  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        headers: kIsWeb ? {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization, X-Requested-With',
        } : null,
        errorBuilder: (context, error, stackTrace) {
          print('DEBUG: Image failed to load: $imageUrl');
          print('DEBUG: Error: $error');
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('DEBUG: Image loaded successfully: $imageUrl');
            return child;
          }
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