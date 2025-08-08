import 'dart:async';
import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();

  PerformanceMonitor._();

  final Map<String, List<Duration>> _operationTimes = {};
  final Map<String, int> _cacheHits = {};
  final Map<String, int> _cacheMisses = {};
  final Map<String, int> _apiCalls = {};

  /// Start timing an operation
  Timer? startOperation(String operationName) {
    final startTime = DateTime.now();
    
    return Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // This is just a placeholder timer to track the operation
      // In a real implementation, you might want to track more details
    });
  }

  /// End timing an operation
  void endOperation(String operationName, Timer? timer) {
    timer?.cancel();
    final endTime = DateTime.now();
    final duration = endTime.difference(DateTime.now());
    
    _operationTimes.putIfAbsent(operationName, () => []).add(duration);
    
    if (kDebugMode) {
      print('Operation $operationName took ${duration.inMilliseconds}ms');
    }
  }

  /// Record a cache hit
  void recordCacheHit(String cacheType) {
    _cacheHits[cacheType] = (_cacheHits[cacheType] ?? 0) + 1;
  }

  /// Record a cache miss
  void recordCacheMiss(String cacheType) {
    _cacheMisses[cacheType] = (_cacheMisses[cacheType] ?? 0) + 1;
  }

  /// Record an API call
  void recordApiCall(String apiName) {
    _apiCalls[apiName] = (_apiCalls[apiName] ?? 0) + 1;
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    // Operation times
    for (final entry in _operationTimes.entries) {
      final times = entry.value;
      if (times.isNotEmpty) {
        final avgTime = times.map((d) => d.inMilliseconds).reduce((a, b) => a + b) / times.length;
        final minTime = times.map((d) => d.inMilliseconds).reduce((a, b) => a < b ? a : b);
        final maxTime = times.map((d) => d.inMilliseconds).reduce((a, b) => a > b ? a : b);
        
        stats['${entry.key}_avg_ms'] = avgTime.round();
        stats['${entry.key}_min_ms'] = minTime;
        stats['${entry.key}_max_ms'] = maxTime;
        stats['${entry.key}_count'] = times.length;
      }
    }
    
    // Cache statistics
    for (final entry in _cacheHits.entries) {
      final hits = entry.value;
      final misses = _cacheMisses[entry.key] ?? 0;
      final total = hits + misses;
      
      if (total > 0) {
        stats['${entry.key}_cache_hit_rate'] = (hits / total * 100).round();
        stats['${entry.key}_cache_hits'] = hits;
        stats['${entry.key}_cache_misses'] = misses;
      }
    }
    
    // API call statistics
    stats['api_calls'] = _apiCalls;
    
    return stats;
  }

  /// Clear performance data
  void clearStats() {
    _operationTimes.clear();
    _cacheHits.clear();
    _cacheMisses.clear();
    _apiCalls.clear();
  }

  /// Get cache hit rate for a specific cache type
  double getCacheHitRate(String cacheType) {
    final hits = _cacheHits[cacheType] ?? 0;
    final misses = _cacheMisses[cacheType] ?? 0;
    final total = hits + misses;
    
    return total > 0 ? hits / total : 0.0;
  }

  /// Get average operation time
  double getAverageOperationTime(String operationName) {
    final times = _operationTimes[operationName];
    if (times == null || times.isEmpty) return 0.0;
    
    final totalMs = times.map((d) => d.inMilliseconds).reduce((a, b) => a + b);
    return totalMs / times.length;
  }

  /// Print performance report
  void printPerformanceReport() {
    if (!kDebugMode) return;
    
    print('=== Performance Report ===');
    
    final stats = getPerformanceStats();
    for (final entry in stats.entries) {
      print('${entry.key}: ${entry.value}');
    }
    
    print('=== End Report ===');
  }
} 