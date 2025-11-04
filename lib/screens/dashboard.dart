import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/phoneservices.dart';
import '../widgets/custom_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'add_phone_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  
  const DashboardScreen({super.key, required this.onThemeChanged});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> phones = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPhones();
  }

  Future<void> loadPhones() async {
    setState(() => isLoading = true);
    phones = await PhoneServices.getPhones();
    setState(() => isLoading = false);
  }

  Future<void> refreshPhones() async => loadPhones();

  void addPhone() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPhoneScreen(onAdd: loadPhones),
      ),
    );
  }

  void editPhone(Map<String, dynamic> phone) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPhoneScreen(
          onAdd: loadPhones,
          phoneToEdit: phone,
        ),
      ),
    );
  }

  void confirmDelete(Map<String, dynamic> phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Phone', style: AppTextStyles.heading.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkText
              : AppColors.textDark,
        )),
        content: Text(
          'Are you sure you want to delete this phone?', 
          style: AppTextStyles.body.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              await PhoneServices.deletePhone(phone);
              await loadPhones();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Phone deleted successfully', style: AppTextStyles.body.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text('Delete', style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    String search = searchController.text.toLowerCase();

    List<Map<String, dynamic>> filtered = phones.where((p) {
      return p['name'].toLowerCase().contains(search) ||
          p['brand'].toLowerCase().contains(search);
    }).toList();

    return isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 12),
                Text('Loading', style: AppTextStyles.subtitle.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText
                      : AppColors.textLight,
                )),
              ],
            ),
          )
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        style: AppTextStyles.body.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.darkText 
                              : AppColors.textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkHint
                                : AppColors.textLight,
                          ),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        ),
                        onChanged: (v) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshPhones,
                  color: AppColors.primary,
                  child: filtered.isEmpty
                      ? Center(child: Text(
                      'No phones found', 
                      style: AppTextStyles.subtitle.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkHint
                            : AppColors.textLight,
                      ),
                    ))
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final phone = filtered[i];
                            final imagePath = phone['imagePath'];
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 3,
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.border,
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: kIsWeb
                                              ? Image.network(
                                                  imagePath,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.phone_android,
                                                      color: AppColors.primary,
                                                      size: 32,
                                                    );
                                                  },
                                                )
                                              : Image.file(
                                                  File(imagePath),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.phone_android,
                                                      color: AppColors.primary,
                                                      size: 32,
                                                    );
                                                  },
                                                ),
                                        ),
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.phone_android,
                                          color: AppColors.primary,
                                          size: 32,
                                        ),
                                      ),
                                title: Text(
                                  phone['name'], 
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.darkText
                                        : AppColors.textDark,
                                  ),
                                ),
                                subtitle: Text(
                                '${phone['brand']} - \$${phone['price']}',
                                style: AppTextStyles.subtitle.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.darkHint
                                      : AppColors.textLight,
                                ),
                              ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomButton(
                                      label: 'Edit',
                                      color: AppColors.secondary,
                                      icon: Icons.edit,
                                      onPressed: () => editPhone(phone),
                                    ),
                                    const SizedBox(width: 8),
                                    CustomButton(
                                      label: 'Delete',
                                      color: AppColors.error,
                                      icon: Icons.delete,
                                      onPressed: () => confirmDelete(phone),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Phone Dashboard' : 'Settings'),
      ),
      body: _selectedIndex == 0 
          ? _buildMainScreen() 
          : SettingsScreen(onThemeChanged: widget.onThemeChanged),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: addPhone,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 14),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}