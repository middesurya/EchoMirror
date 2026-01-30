import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class CameraCaptureWidget extends StatefulWidget {
  final Function(String path) onImageCaptured;

  const CameraCaptureWidget({
    super.key,
    required this.onImageCaptured,
  });

  @override
  State<CameraCaptureWidget> createState() => _CameraCaptureWidgetState();
}

class _CameraCaptureWidgetState extends State<CameraCaptureWidget> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _isCapturing = false;
  String? _capturedImagePath;
  String? _errorMessage;
  bool _showCamera = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Prefer front camera for selfies
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If image is captured, show the captured image
    if (_capturedImagePath != null) {
      return _buildCapturedImage();
    }

    // If camera is showing
    if (_showCamera) {
      return _buildCameraView();
    }

    // Initial state - show capture button
    return _buildCapturePrompt();
  }

  Widget _buildCapturePrompt() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: () async {
          setState(() {
            _showCamera = true;
          });
          await _initializeCamera();
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.face_retouching_natural,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Capture Expression',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to open camera',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_isCameraReady && _controller != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CameraPreview(_controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Overlay controls
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel button
                IconButton(
                  onPressed: () {
                    _controller?.dispose();
                    _controller = null;
                    setState(() {
                      _showCamera = false;
                      _isCameraReady = false;
                    });
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: _isCameraReady && !_isCapturing ? _captureImage : null,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isCapturing ? Colors.red : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Placeholder for symmetry
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Captured image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_capturedImagePath!),
              fit: BoxFit.cover,
            ),
          ),

          // Success overlay
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Captured',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().scale(),

          // Retake button
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _capturedImagePath = null;
                  _showCamera = true;
                });
                _initializeCamera();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retake'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _showCamera = false;
                  _errorMessage = null;
                });
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _controller!.takePicture();
      
      widget.onImageCaptured(image.path);
      
      _controller?.dispose();
      _controller = null;
      
      setState(() {
        _capturedImagePath = image.path;
        _isCapturing = false;
        _showCamera = false;
        _isCameraReady = false;
      });
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _errorMessage = 'Failed to capture image: $e';
      });
    }
  }
}
