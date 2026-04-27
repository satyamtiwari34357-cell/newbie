import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../providers/auth_provider.dart";
import "../../providers/vendor_provider.dart";
import "../../providers/mode_provider.dart";

import "../../models/user_model.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _chargesController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null) return;
    
    try {
      final response = await context.read<AuthProvider>().getMe();
      if (response != null && mounted) {
        final userData = response["user"];
        final profileData = response["profile"];
        
        setState(() {
          _nameController.text = userData?["name"] ?? "";
          _chargesController.text = (profileData?["baseCharges"] ?? 0).toString();
          _bioController.text = profileData?["bio"] ?? "";
        });
      }
    } catch (e) {
      debugPrint("Fetch profile error: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _chargesController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final vendorProvider = context.read<VendorProvider>();
    final token = auth.token;
    
    if (token == null) return;

    final response = await vendorProvider.updateProfile(
      token: token,
      name: _nameController.text,
      baseCharges: double.tryParse(_chargesController.text) ?? 0,
      bio: _bioController.text,
    );

    if (response != null) {
      // Update local AuthProvider state
      if (response["user"] != null) {
        auth.updateUser(UserModel.fromJson(response["user"]));
      }
      setState(() => _isEditing = false);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response != null ? "Profile updated!" : "Failed to update profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isVendor = context.watch<ModeProvider>().isVendorMode;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                label: Text(_isEditing ? "Cancel" : "Edit Profile"),
              ),
            ],
          ),
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(user?.phone ?? "", style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
          const SizedBox(height: 32),
          
          TextField(
            controller: _nameController,
            enabled: _isEditing,
            decoration: InputDecoration(
              labelText: "Display Name",
              prefixIcon: const Icon(Icons.person_outline),
              border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
              filled: _isEditing,
            ),
          ),
          
          if (isVendor) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _chargesController,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Base Charges (₹)",
                prefixIcon: const Icon(Icons.currency_rupee),
                border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
                helperText: _isEditing ? "Your starting service fee" : null,
                filled: _isEditing,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Bio / Description",
                prefixIcon: const Icon(Icons.description_outlined),
                border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
                helperText: _isEditing ? "Tell customers about your expertise" : null,
                filled: _isEditing,
              ),
            ),
          ],
          
          if (_isEditing) ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: context.watch<VendorProvider>().loading ? null : _saveProfile,
                child: context.watch<VendorProvider>().loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Profile Changes"),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
