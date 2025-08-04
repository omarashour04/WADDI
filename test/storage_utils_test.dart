import 'package:flutter_test/flutter_test.dart';
import 'package:waddi_platform/shared/utils/storage_utils.dart';

void main() {
  group('StorageUtils', () {
    group('sanitizePath', () {
      test('should handle empty string', () {
        expect(StorageUtils.sanitizePath(''), 'unnamed');
      });

      test('should handle simple venue names', () {
        expect(StorageUtils.sanitizePath('My Venue'), 'my_venue');
        expect(StorageUtils.sanitizePath('Conference Center'), 'conference_center');
      });

      test('should handle special characters', () {
        expect(StorageUtils.sanitizePath('Venue & Center!'), 'venue_center');
        expect(StorageUtils.sanitizePath('Café & Bar'), 'caf_bar');
        expect(StorageUtils.sanitizePath('Room #1'), 'room_1');
      });

      test('should handle multiple spaces and hyphens', () {
        expect(StorageUtils.sanitizePath('My  Venue'), 'my_venue');
        expect(StorageUtils.sanitizePath('My--Venue'), 'my_venue');
        expect(StorageUtils.sanitizePath('My  --  Venue'), 'my_venue');
      });

      test('should handle leading and trailing characters', () {
        expect(StorageUtils.sanitizePath('  My Venue  '), 'my_venue');
        expect(StorageUtils.sanitizePath('_My_Venue_'), 'my_venue');
      });

      test('should handle numbers', () {
        expect(StorageUtils.sanitizePath('Venue 123'), 'venue_123');
        expect(StorageUtils.sanitizePath('123 Venue'), '123_venue');
      });
    });

    group('getVenueImagePath', () {
      test('should generate correct venue path', () {
        expect(StorageUtils.getVenueImagePath('My Venue'), 'venues/my_venue/');
        expect(StorageUtils.getVenueImagePath('Conference Center'), 'venues/conference_center/');
      });
    });

    group('getRoomImagePath', () {
      test('should generate correct room path', () {
        expect(
          StorageUtils.getRoomImagePath('My Venue', 'Conference Room'),
          'venues/my_venue/conference_room/'
        );
        expect(
          StorageUtils.getRoomImagePath('Café & Bar', 'Private Room'),
          'venues/caf_bar/private_room/'
        );
      });
    });

    group('generateImageFilename', () {
      test('should generate unique filename', () {
        final filename1 = StorageUtils.generateImageFilename('image.jpg');
        final filename2 = StorageUtils.generateImageFilename('image.jpg');
        
        expect(filename1, isNot(equals(filename2))); // Should be different due to timestamp
        expect(filename1, matches(r'^\d+_image\.jpg$'));
        expect(filename2, matches(r'^\d+_image\.jpg$'));
      });

      test('should handle different file extensions', () {
        final filename = StorageUtils.generateImageFilename('photo.png');
        expect(filename, matches(r'^\d+_photo\.png$'));
      });

      test('should handle filenames with spaces', () {
        final filename = StorageUtils.generateImageFilename('my photo.jpg');
        expect(filename, matches(r'^\d+_my_photo\.jpg$'));
      });
    });
  });
} 