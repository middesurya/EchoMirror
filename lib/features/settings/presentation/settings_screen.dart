import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/services/image_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final imageService = ImageService.instance;
    await imageService.initialize();
    setState(() {
      _hasApiKey = imageService.hasApiKey;
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ttsEnabled = ref.watch(ttsEnabledProvider);
    final autoGenerateImage = ref.watch(autoGenerateImageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Voice & Narration Section
          _buildSectionHeader(context, 'Voice & Narration'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable TTS Narration'),
                  subtitle: const Text('Read echo stories aloud'),
                  value: ttsEnabled,
                  onChanged: (value) {
                    ref.read(ttsEnabledProvider.notifier).state = value;
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('TTS Voice Settings'),
                  subtitle: const Text('Adjust speed and pitch'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTtsSettings(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Image Generation Section
          _buildSectionHeader(context, 'Image Generation'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Replicate API Key'),
                  subtitle: Text(
                    _hasApiKey ? 'Key configured' : 'Required for image generation',
                  ),
                  trailing: Icon(
                    _hasApiKey ? Icons.check_circle : Icons.warning,
                    color: _hasApiKey
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  onTap: () => _showApiKeyDialog(context),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-generate Images'),
                  subtitle: const Text('Automatically create artwork for each echo'),
                  value: autoGenerateImage,
                  onChanged: _hasApiKey
                      ? (value) {
                          ref.read(autoGenerateImageProvider.notifier).state = value;
                        }
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy & Data Section
          _buildSectionHeader(context, 'Privacy & Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Export All Data'),
                  subtitle: const Text('Download your reflections and echoes'),
                  trailing: const Icon(Icons.download),
                  onTap: _exportData,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Delete All Data'),
                  subtitle: const Text('Permanently remove all app data'),
                  trailing: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onTap: () => _showDeleteConfirmation(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () {
                    // Open privacy policy
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Open Source Licenses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showLicensePage(context: context);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy Note
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.shield,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy First',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All core ML processing happens on-device. Your reflections never leave your phone without explicit consent.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replicate API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Replicate API key to enable AI image generation. Get one free at replicate.com',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'r8_...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscureApiKey = !_obscureApiKey);
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (_apiKeyController.text.trim().isNotEmpty) {
                final imageService = ImageService.instance;
                await imageService.setApiKey(_apiKeyController.text.trim());
                setState(() => _hasApiKey = true);
                _apiKeyController.clear();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTtsSettings(BuildContext context) {
    final ttsService = TtsService.instance;
    double speechRate = 0.5;
    double pitch = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voice Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              Text(
                'Speech Rate: ${speechRate.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: speechRate,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                onChanged: (value) {
                  setModalState(() => speechRate = value);
                  ttsService.setSpeechRate(value);
                },
              ),

              const SizedBox(height: 16),

              Text(
                'Pitch: ${pitch.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Slider(
                value: pitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                onChanged: (value) {
                  setModalState(() => pitch = value);
                  ttsService.setPitch(value);
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ttsService.speak(
                      'This is how your echo stories will sound.',
                    );
                  },
                  child: const Text('Test Voice'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    try {
      final data = await StorageService.instance.exportAllData();
      // In a real app, you'd save this to a file or share it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Exported ${(data['reflections'] as List).length} reflections',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your reflections, echo stories, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await StorageService.instance.deleteAllData();
              ref.read(reflectionsProvider.notifier).refresh();
              ref.read(echoResponsesProvider.notifier).refresh();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data deleted')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
