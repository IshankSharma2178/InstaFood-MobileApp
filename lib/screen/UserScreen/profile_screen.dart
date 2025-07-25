import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? profileImageUrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['mobile'] ?? '';
      _addressController.text = data['address'] ?? '';
      setState(() {
        profileImageUrl = data['profileImage'];
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedImage = File(file.path));
      // Upload logic here if needed
    }
  }

  Future<void> updateProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).update({
      'name': _nameController.text.trim(),
      'mobile': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    });

    // ✅ This will update the displayed name immediately
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE91E63),
      body: SafeArea(
        child: Column(
          children: [
            // Top Profile Header
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back button aligned left
                  Align(
                    alignment: Alignment.centerLeft,

                  ),

                  // Centered title with icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.person, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            // Avatar & name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : const AssetImage('assets/user.jpg')) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.camera_alt, size: 18, color: Color(0xFFE91E63)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _nameController.text,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    _auth.currentUser?.email ?? '',
                    style: const TextStyle(color: Color(0xFFDDDDDD), fontSize: 18),
                  ),
                ],
              ),
            ),

            // White Content Card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    buildEditableField('Name', _nameController),
                    buildEditableField('Phone', _phoneController),
                    buildEditableField('Address', _addressController),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: updateProfile,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16)),
                        ],
                      )
                    ),
                    const SizedBox(height: 16),
                    buildOptionTile(Icons.help_outline, 'Help', () {}),
                    buildOptionTile(Icons.logout, 'Logout', () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }),

                    const SizedBox(height: 20),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFCE4EC),
        child: Icon(icon, color: Color(0xFFE91E63)),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
