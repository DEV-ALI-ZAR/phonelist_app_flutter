import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_button.dart';
import '../services/phoneservices.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AddPhoneScreen extends StatefulWidget {
  final Function onAdd;
  final Map<String, dynamic>? phoneToEdit;

  const AddPhoneScreen({super.key, required this.onAdd, this.phoneToEdit});

  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String selectedBrand = 'Apple';
  bool isSaving = false;
  String? imagePath;
  XFile? imageFile;
  final ImagePicker _picker = ImagePicker();

  final List<String> brands = ['Apple', 'Samsung', 'Google', 'OnePlus', 'Xiaomi'];

  bool get isEditing => widget.phoneToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      nameController.text = widget.phoneToEdit!['name'];
      priceController.text = widget.phoneToEdit!['price'];
      selectedBrand = widget.phoneToEdit!['brand'];
      imagePath = widget.phoneToEdit!['imagePath'];
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          imageFile = image;
          imagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to pick image',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void deleteImage() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Delete Image',
        style: AppTextStyles.heading.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkText
              : AppColors.textDark,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this image?',
        style: AppTextStyles.body.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkText
              : AppColors.textDark,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.body.copyWith(color: AppColors.primary),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              imagePath = null;
              imageFile = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image removed',
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          },
          child: Text(
            'Delete',
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}

  Future<void> save() async {
    if (nameController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final phone = {
      'name': nameController.text,
      'brand': selectedBrand,
      'price': priceController.text,
      'imagePath': imagePath,
    };

    if (isEditing) {
      await PhoneServices.updatePhone(widget.phoneToEdit!, phone);
    } else {
      await PhoneServices.addPhone(phone);
    }

    if (mounted) {
      setState(() => isSaving = false);
      Navigator.pop(context);
      widget.onAdd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Phone' : 'Add Phone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isSaving
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text('Saving', style: AppTextStyles.subtitle),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Picker Section
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kIsWeb
                                      ? Image.network(
                                          imagePath!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.broken_image,
                                              size: 48,
                                              color: AppColors.error,
                                            );
                                          },
                                        )
                                      : Image.file(
                                          File(imagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : Icon(
                                  Icons.phone_android,
                                  size: 48,
                                  color: AppColors.darkHint,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: isEditing && imagePath != null
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        label: 'Change',
                                        color: AppColors.secondary,
                                        icon: Icons.edit,
                                        onPressed: pickImage,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: CustomButton(
                                        label: 'Delete',
                                        color: AppColors.error,
                                        icon: Icons.delete,
                                        onPressed: deleteImage,
                                      ),
                                    ),
                                  ],
                                )
                              : CustomButton(
                                  label: 'Select Image',
                                  color: AppColors.secondary,
                                  icon: Icons.image,
                                  onPressed: pickImage,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Name Field
                    TextField(
                      controller: nameController,
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.darkText 
                            : AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: AppTextStyles.body.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkHint
                              : AppColors.textLight,
                        ),
                        prefixIcon: Icon(Icons.phone_android, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Brand Selection
                    Text('Brand', style: AppTextStyles.heading.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkText
                          : AppColors.darkHint,
                    )),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: brands.map((brand) {
                        final isSelected = selectedBrand == brand;
                        return ChoiceChip(
                          label: Text(
                            brand,
                            style: AppTextStyles.body.copyWith(
                              color: isSelected ? Colors.white : AppColors.darkHint,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Theme.of(context).cardColor,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                          onSelected: (v) => setState(() => selectedBrand = brand),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Price Field
                    TextField(
                      controller: priceController,
                      style: AppTextStyles.body.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? AppColors.darkText 
                            : AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Price',
                        labelStyle: AppTextStyles.body.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkHint
                              : AppColors.textLight,
                        ),
                        prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Update Phone' : 'Save Phone',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}