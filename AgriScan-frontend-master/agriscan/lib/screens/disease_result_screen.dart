import 'dart:io';
import 'package:flutter/material.dart';

class DiseaseResultScreen extends StatelessWidget {
  final String disease;
  final double confidence;
  final String imagePath;

  const DiseaseResultScreen({
    Key? key,
    required this.disease,
    required this.confidence,
    required this.imagePath,
  }) : super(key: key);

  // Color Palette
  static const Color lightBackground = Color(0xFFE5E0D8);
  static const Color sageGreen = Color(0xFFACB087);
  static const Color darkGreen = Color(0xFF4C6444);
  static const Color accentBrown = Color(0xFF95714F);
  static const Color fieldBackground = Color(0xFFEADED0);

  // Disease information database - matches model classes
  Map<String, Map<String, String>> _getDiseaseInfo() {
    return {
      'Healthy Potato': {
        'description': 'Your potato plant appears to be healthy! No signs of disease detected.',
        'treatment': 'Continue regular watering, ensure proper drainage, and monitor for any changes.',
      },
      'healthy tomato': {
        'description': 'Your tomato plant appears to be healthy! No signs of disease detected.',
        'treatment': 'Maintain consistent watering, provide adequate sunlight, and continue regular care.',
      },
      'Unhealthy Corn Common Rust': {
        'description': 'Common rust appears as small, circular to elongate brown pustules on corn leaves. It can reduce yield if severe.',
        'treatment': 'Plant resistant varieties, remove infected debris, apply fungicides if severe, and ensure good air circulation.',
      },
      'Unhealthy Potato Early Blight': {
        'description': 'Early blight causes dark spots with concentric rings on potato leaves. It typically affects older, lower leaves first.',
        'treatment': 'Remove affected leaves, avoid overhead watering, apply copper-based fungicide, and practice crop rotation.',
      },
      'Unhealthy Tomato Early Blight': {
        'description': 'Early blight causes dark spots with concentric rings on older tomato leaves. Can lead to defoliation and reduced yields.',
        'treatment': 'Remove affected leaves, avoid overhead watering, apply copper-based fungicide, and mulch to prevent soil splash.',
      },
      'Unhealthy Tomato Yellow Leaf Curl Virus': {
        'description': 'Yellow leaf curl virus causes upward curling of leaves, yellowing, and stunted growth in tomato plants. Spread by whiteflies.',
        'treatment': 'Remove infected plants immediately, control whitefly populations with insecticides or neem oil, use resistant varieties, and practice good sanitation.',
      },
      'Unhealthy_Apple_Rust': {
        'description': 'Apple rust (cedar apple rust) causes yellow-orange spots on leaves and fruit. It requires both apple and cedar trees to complete its lifecycle.',
        'treatment': 'Remove nearby cedar trees if possible, apply fungicide in early spring, remove infected leaves, and plant resistant varieties.',
      },
      'Unhealthy_Apple_Scab': {
        'description': 'Apple scab is a fungal disease that causes dark, scabby lesions on leaves and fruit, leading to reduced quality and yield.',
        'treatment': 'Remove infected leaves, apply fungicide preventatively, ensure good air circulation, and choose resistant varieties.',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final isHealthy = disease.toLowerCase().contains('healthy');
    final diseaseInfo = _getDiseaseInfo()[disease];
    final description = diseaseInfo?['description'] ?? 
        (isHealthy 
            ? 'Your plant appears to be healthy! No signs of disease detected.' 
            : 'Disease detected. Please consult with an agricultural expert for specific treatment advice.');
    final treatment = diseaseInfo?['treatment'] ?? 
        (isHealthy 
            ? 'Continue regular care and monitoring of your plant.' 
            : 'Consult with a local agricultural extension office for treatment recommendations.');

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
          'Detection Results',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isHealthy
                        ? [sageGreen, sageGreen.withOpacity(0.7)]
                        : [accentBrown, accentBrown.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isHealthy ? sageGreen : accentBrown).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle : Icons.warning,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      disease,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Description Card
              _buildInfoCard(
                'Description',
                description,
                Icons.info_outline,
              ),
              const SizedBox(height: 16),

              // Treatment Card
              if (!isHealthy)
                _buildInfoCard(
                  'Treatment',
                  treatment,
                  Icons.healing,
                ),
              if (!isHealthy) const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.refresh, color: darkGreen),
                      label: Text(
                        'Scan Again',
                        style: TextStyle(
                          color: darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: darkGreen, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home, color: Colors.white),
                      label: const Text(
                        'Home',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: darkGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
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
                icon,
                color: darkGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: darkGreen.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
