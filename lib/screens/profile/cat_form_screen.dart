import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/cat.dart';
import '../../services/auth_service.dart';
import '../../services/cat_service.dart';
import '../../utils/app_spacing.dart';
import '../../utils/validators.dart';
import '../../widgets/date_field.dart';
import '../../widgets/primary_button.dart';

/// Add or edit a cat profile. Pass [existing] to edit; omit it to create.
class CatFormScreen extends StatefulWidget {
  final Cat? existing;

  const CatFormScreen({super.key, this.existing});

  @override
  State<CatFormScreen> createState() => _CatFormScreenState();
}

class _CatFormScreenState extends State<CatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catService = CatService();

  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _color;
  late final TextEditingController _microchip;
  late final TextEditingController _ownerName;
  final _imagePicker = ImagePicker();
  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;
  String? _photoUrl;
  String? _sex;
  DateTime? _dob;

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _breed = TextEditingController(text: c?.breed ?? '');
    _color = TextEditingController(text: c?.color ?? '');
    _microchip = TextEditingController(text: c?.microchipNumber ?? '');
    _ownerName = TextEditingController(text: c?.ownerName ?? '');
    _photoUrl = c?.photo;
    _sex = c?.sex;
    _dob = c?.dob;
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _color.dispose();
    _microchip.dispose();
    _ownerName.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedPhoto = picked;
      _selectedPhotoBytes = bytes;
    });
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 1, now.month, now.day),
      firstDate: DateTime(now.year - 30),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final userId = AuthService().currentUser!.id;
      var photo = _photoUrl;
      if (_selectedPhoto != null && _selectedPhotoBytes != null) {
        photo = await _catService.uploadCatPhoto(
          _selectedPhotoBytes!,
          _selectedPhoto!.name.split('.').last,
        );
      }
      final cat = Cat(
        id: widget.existing?.id ?? '',
        userId: userId,
        name: _name.text.trim(),
        photo: photo,
        breed: _breed.text.trim().isEmpty ? null : _breed.text.trim(),
        sex: _sex,
        dob: _dob,
        color: _color.text.trim().isEmpty ? null : _color.text.trim(),
        microchipNumber:
            _microchip.text.trim().isEmpty ? null : _microchip.text.trim(),
        ownerName:
            _ownerName.text.trim().isEmpty ? null : _ownerName.text.trim(),
      );

      if (_isEditing) {
        await _catService.updateCat(cat);
      } else {
        await _catService.addCat(cat);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Cat' : 'Add Cat')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PhotoPicker(
                      imageBytes: _selectedPhotoBytes,
                      imageUrl: _photoUrl,
                      onPressed: _saving ? null : _pickPhoto,
                    ),
                    const FormSectionTitle('About'),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => Validators.required(v, field: 'Name'),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    TextFormField(
                      controller: _breed,
                      decoration: const InputDecoration(labelText: 'Breed'),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    DropdownButtonFormField<String>(
                      initialValue: _sex,
                      decoration: const InputDecoration(labelText: 'Sex'),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                            value: 'Female', child: Text('Female')),
                      ],
                      onChanged: (v) => setState(() => _sex = v),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    DateField(
                      label: 'Date of birth',
                      valueText: _dob == null
                          ? 'Select a date'
                          : DateFormat.yMMMd().format(_dob!),
                      onTap: _pickDob,
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    TextFormField(
                      controller: _color,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    const FormSectionTitle('Identification'),
                    TextFormField(
                      controller: _microchip,
                      decoration: const InputDecoration(
                          labelText: 'Microchip number'),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    TextFormField(
                      controller: _ownerName,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                          const InputDecoration(labelText: 'Owner name'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      FormErrorBox(_error!),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: _saving
                          ? 'Saving…'
                          : (_isEditing ? 'Save changes' : 'Add cat'),
                      onPressed: _submit,
                      loading: _saving,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Round-cornered photo preview with a camera badge; the whole thing is the
/// tap target, with a text button underneath for clarity.
class _PhotoPicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final VoidCallback? onPressed;

  const _PhotoPicker({
    required this.imageBytes,
    required this.imageUrl,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasImage = imageBytes != null || imageUrl != null;
    const size = 128.0;
    final radius = BorderRadius.circular(size * 0.32);

    final Widget preview;
    if (imageBytes != null) {
      preview = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (imageUrl != null) {
      preview = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(scheme, text),
      );
    } else {
      preview = _placeholder(scheme, text);
    }

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          button: true,
          label: hasImage ? 'Change cat photo' : 'Choose cat photo',
          child: GestureDetector(
            onTap: onPressed,
            child: SizedBox(
              width: size + 12,
              height: size + 12,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: ClipRRect(
                      borderRadius: radius,
                      child: SizedBox(
                          width: size, height: size, child: preview),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: scheme.surfaceContainerLowest, width: 3),
                      ),
                      child: Icon(Icons.photo_camera_outlined,
                          size: 18, color: scheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.photo_library_outlined, size: 20),
          label: Text(hasImage ? 'Change cat photo' : 'Choose cat photo'),
        ),
      ],
    );
  }

  Widget _placeholder(ColorScheme scheme, TextTheme text) {
    return Container(
      color: scheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.pets, size: 48, color: scheme.onPrimaryContainer),
    );
  }
}
