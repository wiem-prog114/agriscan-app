import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'disease_result_screen.dart';

class DiseaseScanScreen extends StatefulWidget {
  const DiseaseScanScreen({Key? key}) : super(key: key);

  @override
  State<DiseaseScanScreen> createState() => _DiseaseScanScreenState();
}

class _DiseaseScanScreenState extends State<DiseaseScanScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter;

  // Color Palette
  static const Color lightBackground = Color(0xFFE5E0D8);
  static const Color sageGreen = Color(0xFFACB087);
  static const Color darkGreen = Color(0xFF4C6444);
  static const Color fieldBackground = Color(0xFFEADED0);

  // Disease labels - must match your model's training classes exactly
  final List<String> _labels = [
    'Healthy Potato',
    'Unhealthy Corn Common Rust',
    'Unhealthy Potato Early Blight',
    'Unhealthy Tomato Early Blight',
    'Unhealthy Tomato Yellow Leaf Curl Virus',
    'Unhealthy_Apple_Rust',
    'Unhealthy_Apple_Scab',
    'healthy tomato',
  ];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/plant_disease_classifier.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
      _showError('Failed to load AI model');
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      _showError('Please select an image first');
      return;
    }

    if (_interpreter == null) {
      _showError('Model not loaded. Please restart the app.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Load and preprocess the image
      final imageBytes = await _selectedImage!.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image to model input size (typically 224x224 or 256x256)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // Convert to input tensor format
      var input = _imageToByteListFloat32(resizedImage, 224);

      // Prepare output tensor
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference
      _interpreter!.run(input, output);

      // Get results
      List<double> probabilities = output[0];
      
      // Find the class with highest probability
      int maxIndex = 0;
      double maxProb = probabilities[0];
      
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }

      String disease = maxIndex < _labels.length ? _labels[maxIndex] : 'Unknown';
      double confidence = maxProb;

      setState(() {
        _isAnalyzing = false;
      });

      // Navigate to results
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiseaseResultScreen(
            disease: disease,
            confidence: confidence,
            imagePath: _selectedImage!.path,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showError('Analysis failed: $e');
    }
  }

  // Convert image to Float32 list for model input
  List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image, int inputSize) {
    var convertedBytes = List.generate(
      1,
      (index) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              (pixel.r / 255.0),  // Red normalized
              (pixel.g / 255.0),  // Green normalized
              (pixel.b / 255.0),  // Blue normalized
            ];
          },
        ),
      ),
    );
    return convertedBytes;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Disease Detection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Scan Your Plant',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a photo to detect diseases',
                style: TextStyle(
                  fontSize: 16,
                  color: darkGreen.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Image Preview Container
              Container(
                height: 350,
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sageGreen.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 80,
                              color: sageGreen.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 16,
                                color: darkGreen.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Select Image Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _pickImage,
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sageGreen,
                    disabledBackgroundColor: sageGreen.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: sageGreen.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Analyze Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: (_isAnalyzing || _selectedImage == null)
                      ? null
                      : _analyzeImage,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_fix_high, color: Colors.white),
                  label: Text(
                    _isAnalyzing ? 'Analyzing...' : 'Analyze Plant',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    disabledBackgroundColor: darkGreen.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: darkGreen.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Instructions Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sageGreen.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: darkGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tips for Better Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTip('Take clear, well-lit photos'),
                    _buildTip('Focus on affected plant parts'),
                    _buildTip('Avoid blurry or dark images'),
                    _buildTip('Include the whole leaf if possible'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: sageGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: darkGreen.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
