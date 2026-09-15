import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/catalog_service.dart';
import '../services/image_analysis_service.dart';
import '../services/image_enhancement_service.dart';

import '../services/tts_service.dart';
import 'image_comparison_dialog.dart';
import 'voice_capture_dialog.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController materialController = TextEditingController();
  final TextEditingController makingTimeController = TextEditingController();
  final TextEditingController expectedPriceController = TextEditingController();
  final TextEditingController stockController = TextEditingController(text: '3');
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController storyController = TextEditingController();

  String? rawPhotoPath;
  String? displayPhotoPath;
  bool isUsingEnhanced = false;

  String category = 'Other';
  String detectedLanguageName = 'Not detected';
  String detectedLanguageCode = 'en-IN';
  String craftType = '';
  String colour = 'Natural';
  String pattern = '';
  String shape = '';
  String visibleFeatures = '';

  bool isAnalyzingImage = false;
  bool isEnhancingImage = false;
  int marketPrice = 800;
  int marketLow = 700;
  int marketHigh = 900;

  @override
  void dispose() {
    nameController.dispose();
    materialController.dispose();
    makingTimeController.dispose();
    expectedPriceController.dispose();
    stockController.dispose();
    lengthController.dispose();
    widthController.dispose();
    heightController.dispose();
    descriptionController.dispose();
    storyController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> startVoiceCatalog() async {
    final VoiceResult? result = await showDialog<VoiceResult>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const VoiceCaptureDialog(
        title: '🎙️ AI Voice Cataloging',
        instruction:
            'Speak naturally in your own language. Tell us what you made, materials used, and your expected price.',
      ),
    );

    if (!mounted || result == null || result.text.trim().isEmpty) return;

    detectedLanguageName = languageName(result.language);
    detectedLanguageCode = result.language;

    applyVoiceUnderstanding(result.text);

    // AI speaks back in detected language asking for photo
    final String prompt = TtsService.getPromptForPhoto(detectedLanguageCode);
    await TtsService.instance.speak(prompt, languageCode: detectedLanguageCode);

    if (!mounted) return;
    await promptPhotoSelection();
  }

  Future<void> promptPhotoSelection() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  '📸 AI needs the product photo',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: kDarkGreen,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Take a clear photo or choose an existing photo from gallery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Take Photo (Camera)'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(sheetContext, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Choose from Gallery'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source != null) {
      await pickAndProcessImage(source);
    }
  }

  Future<void> pickAndProcessImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 92,
      );

      if (file == null || !mounted) return;

      setState(() {
        rawPhotoPath = file.path;
        displayPhotoPath = file.path;
        isUsingEnhanced = false;
        isAnalyzingImage = true;
        isEnhancingImage = true;
      });

      // 1. Run craft analysis on actual image file
      final analysis = await ImageAnalysisService.instance.analyzeImage(file.path);

      if (!analysis.success) {
        if (!mounted) return;
        setState(() {
          isAnalyzingImage = false;
          isEnhancingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[800],
            content: Text(analysis.error ?? 'Unable to analyze this image. Please take a clearer photo or enter details manually.'),
          ),
        );
        return;
      }

      // 2. Run AI enhancement via backend
      final enhancement =
          await ImageEnhancementService.instance.enhanceProductImage(file.path);

      if (!mounted) return;

      setState(() {
        isAnalyzingImage = false;
        isEnhancingImage = false;
        category = analysis.category;
        nameController.text = analysis.productName;
        materialController.text = analysis.material;
        craftType = analysis.craftType;
        shape = analysis.shape;
        visibleFeatures = analysis.visibleFeatures;
      });

      regenerateCatalog(detectedTitle: analysis.productName);
      

      // Show Before / After Comparison Dialog
      final ImageComparisonResult? compResult =
          await showDialog<ImageComparisonResult>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) => ImageComparisonDialog(
          originalPath: file.path,
          enhancedPath: enhancement.enhancedImagePath,
          isAiEnhanced: enhancement.isAiEnhanced,
          enhancements: enhancement.enhancements,
        ),
      );

      if (!mounted) return;

      if (compResult != null) {
        setState(() {
          displayPhotoPath = compResult.selectedPath;
          isUsingEnhanced = compResult.isEnhanced;
        });

        final dimPrompt = TtsService.getPromptForDimensions(detectedLanguageCode);
        await TtsService.instance.speak(dimPrompt, languageCode: detectedLanguageCode);
      } else {
        await promptPhotoSelection();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isAnalyzingImage = false;
        isEnhancingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo processing note: $e')),
      );
    }
  }

  void applyVoiceUnderstanding(String transcript) {
    final String lower = transcript.toLowerCase();

    String detectedCategory = category;
    String detectedMaterial = materialController.text;
    String detectedName = nameController.text;

    if (containsAny(lower, <String>[
      'bamboo', 'bamboo basket', 'veduru', 'వెదురు', 'బుట్ట', 'basket', 'cane', 'tokri', 'टोकरी'
    ])) {
      detectedCategory = 'Bamboo';
      detectedMaterial = 'Natural bamboo';
      detectedName = 'Handmade Bamboo Basket';
      craftType = 'Artisanal Splint Weaving';
    } else if (containsAny(lower, <String>[
      'wood', 'wooden', 'chekka', 'చెక్క', 'woodwork', 'bowl', 'lakdi', 'लकड़ी'
    ])) {
      detectedCategory = 'Woodwork';
      detectedMaterial = 'Seasoned hardwood';
      detectedName = 'Handcrafted Wooden Vessel';
      craftType = 'Hand-carved Woodwork';
    } else if (containsAny(lower, <String>[
      'pot', 'pottery', 'clay', 'మట్టి', 'కుండ', 'mitti', 'घड़ा', 'terracotta'
    ])) {
      detectedCategory = 'Pottery';
      detectedMaterial = 'Natural clay / terracotta';
      detectedName = 'Handmade Terracotta Pot';
      craftType = 'Wheel-thrown Pottery';
    } else if (containsAny(lower, <String>[
      'saree', 'cotton', 'cloth', 'textile', 'చీర', 'బట్ట', 'khadi', 'handloom', 'साड़ी'
    ])) {
      detectedCategory = 'Textiles';
      detectedMaterial = 'Handloom cotton / silk';
      detectedName = 'Handwoven Cotton Textile';
      craftType = 'Traditional Handloom';
    } else if (containsAny(lower, <String>[
      'silver', 'jewellery', 'jewelry', 'earring', 'ఆభరణం', 'gehna', 'कंगन'
    ])) {
      detectedCategory = 'Jewellery';
      detectedMaterial = 'Silver alloy / metal craft';
      detectedName = 'Tribal Hand-Cast Jewellery';
      craftType = 'Lost-wax Metal Casting';
    } else if (containsAny(lower, <String>[
      'decor', 'decoration', 'wall', 'hanging', 'అలంకరణ'
    ])) {
      detectedCategory = 'Home Decor';
      detectedMaterial = 'Natural fibers';
      detectedName = 'Handmade Home Decor';
      craftType = 'Eco-friendly Weave';
    }

    final RegExp moneyPattern = RegExp(
      r'(?:₹|rs\.?|rupees?|రూపాయలు?|రూ\.|रूपये?)\s*([0-9]{2,6})',
      caseSensitive: false,
    );
    final Match? moneyMatch = moneyPattern.firstMatch(lower);

    final RegExp daysPattern = RegExp(
      r'(\d+)\s*(day|days|రోజు|రోజులు|दिन)',
      caseSensitive: false,
    );
    final Match? daysMatch = daysPattern.firstMatch(lower);

    setState(() {
      category = detectedCategory;
      if (detectedMaterial.isNotEmpty) {
        materialController.text = detectedMaterial;
      }
      if (detectedName.isNotEmpty) {
        nameController.text = detectedName;
      }
      if (moneyMatch != null) {
        expectedPriceController.text = moneyMatch.group(1)!;
      }
      if (daysMatch != null) {
        makingTimeController.text = '${daysMatch.group(1)} days';
      }
    });

    regenerateCatalog();
    
  }

  void regenerateCatalog({String? detectedTitle}) {
    final double? l = double.tryParse(lengthController.text.trim());
    final double? w = double.tryParse(widthController.text.trim());
    final double? h = double.tryParse(heightController.text.trim());

    final String activeTitle = (detectedTitle != null && detectedTitle.trim().isNotEmpty)
        ? detectedTitle.trim()
        : nameController.text.trim();

    // If nothing has been analyzed or entered, do not invent dummy catalog data
    if (activeTitle.isEmpty &&
        materialController.text.trim().isEmpty &&
        visibleFeatures.isEmpty &&
        category == 'Other') {
      return;
    }

    final catalog = CatalogService.instance.generateCatalog(
      voiceTranscript: '',
      category: category,
      detectedTitle: activeTitle.isNotEmpty ? activeTitle : null,
      visibleFeatures: visibleFeatures.isNotEmpty ? visibleFeatures : null,
      material: materialController.text.trim().isEmpty
          ? 'Natural craft material'
          : materialController.text.trim(),
      craftType: craftType.isNotEmpty ? craftType : 'Handcrafted',
      shape: shape.isNotEmpty ? shape : 'Observed form',
      colour: colour,
      pattern: pattern,
      length: l,
      width: w,
      height: h,
      makingTime: makingTimeController.text.trim(),
    );

    setState(() {
      if (nameController.text.trim().isEmpty && catalog.title.isNotEmpty) {
        nameController.text = catalog.title;
      }
      descriptionController.text = catalog.detailedDescription;
      storyController.text = catalog.artisanStory;
    });
  }



  Future<void> confirmAndPublish() async {
    if (displayPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add or take a product photo first.')),
      );
      return;
    }

    final int finalPrice = int.tryParse(expectedPriceController.text.trim()) ?? marketPrice;

    final String finalName = nameController.text.trim().isEmpty
        ? 'Handmade $category Craft'
        : nameController.text.trim();

    final String voiceConfirm = TtsService.getPromptForPublishConfirmation(
      detectedLanguageCode,
      finalName,
      finalPrice,
    );
    await TtsService.instance.speak(voiceConfirm, languageCode: detectedLanguageCode);

    if (!mounted) return;

    final bool? shouldPublish = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Row(
            children: <Widget>[
              Icon(Icons.record_voice_over, color: kGreen),
              SizedBox(width: 10),
              Text('Voice Confirmation'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '“Your $finalName is ready for the marketplace at ₹$finalPrice.”',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Product: $finalName', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Category: $category • $craftType'),
                    Text('Selling Price: ₹$finalPrice'),
                    if (isUsingEnhanced)
                      const Text(
                        '✨ Studio AI Enhanced Photo Active',
                        style: TextStyle(color: kGreen, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Edit / Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.check),
              label: const Text('Publish to Marketplace'),
            ),
          ],
        );
      },
    );

    if (shouldPublish != true || !mounted) return;

    final double? l = double.tryParse(lengthController.text.trim());
    final double? w = double.tryParse(widthController.text.trim());
    final double? h = double.tryParse(heightController.text.trim());
    final int available = int.tryParse(stockController.text.trim()) ?? 3;

    final newProduct = Product(
      id: 'shilpi_artisan_${DateTime.now().millisecondsSinceEpoch}',
      name: finalName,
      category: category,
      artisan: 'You — Shilpi Verified Artisan',
      location: 'Telangana Heritage Craft Cluster, India',
      material: materialController.text.trim().isEmpty
          ? 'Natural Craft Material'
          : materialController.text.trim(),
      craftType: craftType,
      emoji: category == 'Pottery'
          ? '🏺'
          : category == 'Textiles'
              ? '🧣'
              : category == 'Jewellery'
                  ? '💎'
                  : category == 'Woodwork'
                      ? '🥣'
                      : category == 'Home Decor'
                          ? '🌿'
                          : category == 'Bamboo'
                              ? '🧺'
                              : finalName.toLowerCase().contains('laptop')
                                  ? '💻'
                                  : '✨',
      price: finalPrice,
      marketLow: marketLow,
      marketHigh: marketHigh,
      stock: available,
      rating: 5.0,
      story: storyController.text.trim().isNotEmpty
          ? storyController.text.trim()
          : descriptionController.text.trim(),
      imagePath: displayPhotoPath,
      originalImagePath: rawPhotoPath,
      length: l,
      width: w,
      height: h,
      isSellerProduct: true,
      createdAt: DateTime.now(),
    );

    await ProductRepository.instance.addProduct(newProduct);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kGreen,
        content: Text('🎉 $finalName successfully published to Shilpi Marketplace!'),
      ),
    );

    Navigator.pop(context, newProduct);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sell Craft on Shilpi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EFE9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: <Widget>[
                const CircleAvatar(
                  backgroundColor: kGreen,
                  radius: 22,
                  child: Icon(Icons.auto_awesome, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Voice-First Smart Cataloging',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: kDarkGreen,
                        ),
                      ),
                      Text(
                        'Speak in your language → AI Photo Enhancement → Fair Price → Sell',
                        style: TextStyle(color: Colors.grey[700], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const SectionTitle('1. Voice Input (No Typing Required)'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: <Widget>[
                const Text(
                  '🗣️ Speak Naturally in Telugu, Hindi, or English',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Shilpi automatically detects your spoken language and extracts product details.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: startVoiceCatalog,
                    icon: const Icon(Icons.mic),
                    label: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Tap Microphone & Speak',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                if (detectedLanguageName != 'Not detected') ...<Widget>[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EFE9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Detected Language: $detectedLanguageName',
                        style: const TextStyle(
                          color: kGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          const SectionTitle('2. Product Photo & AI Transformation'),
          GestureDetector(
            onTap: promptPhotoSelection,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black12),
              ),
              child: displayPhotoPath == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.add_a_photo_outlined, size: 48, color: kGreen),
                        SizedBox(height: 8),
                        Text(
                          'Tap to Add Product Photo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Camera or Gallery',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    )
                  : Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(displayPhotoPath!),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        if (isUsingEnhanced)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: kGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    'Marketplace Ready',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          if (isAnalyzingImage || isEnhancingImage) ...<Widget>[
            const SizedBox(height: 10),
            const LinearProgressIndicator(color: kGreen),
            const SizedBox(height: 6),
            const Text(
              '✨ AI is segmenting background & balancing studio lighting...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: kGreen),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => pickAndProcessImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => pickAndProcessImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          const SectionTitle('3. AI Catalog Generation'),
          textField('Product Name', nameController),
          textField('Material', materialController),
          textField('Making Time', makingTimeController),
          DropdownButtonFormField<String>(
            key: ValueKey<String>(category),
            initialValue: category,
            decoration: InputDecoration(
              labelText: 'Craft Category',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: const <String>[
              'Bamboo',
              'Pottery',
              'Textiles',
              'Jewellery',
              'Woodwork',
              'Home Decor',
              'Other',
            ].map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: (String? val) {
              if (val != null) {
                setState(() {
                  category = val;
                  regenerateCatalog();
                  
                });
              }
            },
          ),
          const SizedBox(height: 10),
          infoBox('Craft Technique', craftType),
          infoBox('Visual Shape', shape),
          infoBox('Detected Features', visibleFeatures),
          const SizedBox(height: 10),
          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Marketplace Product Description',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: storyController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Artisan Heritage Story',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: regenerateCatalog,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Regenerate Catalog'),
            ),
          ),
          const SizedBox(height: 14),

          const SectionTitle('4. Product Dimensions (Optional)'),
          const Text(
            'Exact dimensions are not guessed from photos. Enter length, width, and height or skip.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(child: textField('Length (cm)', lengthController, number: true)),
              const SizedBox(width: 8),
              Expanded(child: textField('Width (cm)', widthController, number: true)),
              const SizedBox(width: 8),
              Expanded(child: textField('Height (cm)', heightController, number: true)),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              lengthController.clear();
              widthController.clear();
              heightController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dimensions skipped. You can still publish.')),
              );
            },
            icon: const Icon(Icons.skip_next),
            label: const Text('Skip Dimensions'),
          ),
          const SizedBox(height: 14),

          const SectionTitle('5. Pricing'),
          TextField(
            controller: expectedPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Expected Selling Price (₹)',
              hintText: 'e.g. 1200',
              prefixIcon: const Icon(Icons.currency_rupee),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),

          const SectionTitle('6. Stock & Protection'),
          textField('Available Units / Stock', stockController, number: true),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: confirmAndPublish,
              icon: const Icon(Icons.publish),
              label: const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Confirm & Publish Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoBox(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F4),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget textField(
    String label,
    TextEditingController controller, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
          color: kDarkGreen,
        ),
      ),
    );
  }
}
