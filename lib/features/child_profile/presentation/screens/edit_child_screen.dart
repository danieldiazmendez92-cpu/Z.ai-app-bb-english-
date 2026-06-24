import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/se_button.dart';
import '../../../../core/widgets/se_text_field.dart';
import '../../domain/entities/child_profile.dart';
import '../controllers/child_profile_controller.dart';

/// Pantalla para crear o editar un perfil de niño.
///
/// Si recibe `childId` por path parameter, está en modo edición.
/// Si no, está en modo creación (desde ChildPicker o Onboarding).
class EditChildScreen extends ConsumerStatefulWidget {
  const EditChildScreen({
    super.key,
    this.childId,
  });

  final String? childId;

  @override
  ConsumerState<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends ConsumerState<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedAvatar;
  int? _selectedAge;
  final Set<String> _selectedInterests = {};

  bool get _isEditMode => widget.childId != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Si es edición, cargar datos existentes
    if (_isEditMode) {
      final children =
          ref.watch(childProfileControllerProvider).valueOrNull ?? [];
      final existing =
          children.where((c) => c.childId == widget.childId).firstOrNull;
      if (existing != null) {
        // Solo inicializar una vez
        if (_nameController.text.isEmpty) {
          _nameController.text = existing.name;
          _selectedAvatar = existing.avatarUrl;
          _selectedAge = existing.age;
          _selectedInterests.addAll(existing.interests);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar perfil' : 'Nuevo perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SETextField(
                  controller: _nameController,
                  label: 'Nombre del niño',
                  helperText: 'Solo primer nombre o apodo (máx 20 caracteres)',
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresá un nombre';
                    }
                    if (value.trim().length > 20) {
                      return 'Máximo 20 caracteres';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                _buildAvatarSelector(),
                const SizedBox(height: 24),
                _buildAgeSelector(),
                const SizedBox(height: 24),
                _buildInterestsSelector(),

                const SizedBox(height: 32),

                SEButton(
                  onPressed: _save,
                  label: _isEditMode ? 'Guardar cambios' : 'Crear perfil',
                  size: SEButtonSize.large,
                ),

                if (_isEditMode) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _confirmDelete,
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Eliminar perfil'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelector() {
    const avatars = ['🐻', '🦊', '🐰', '🦁', '🐯', '🐱', '🐶', '🦉', '🐼', '🦄'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avatar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: avatars.map((emoji) {
            final isSelected = _selectedAvatar == emoji;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = emoji;
                });
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAgeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edad',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: List.generate(6, (i) {
            final age = i + 2; // 2-7
            final isSelected = _selectedAge == age;
            return ChoiceChip(
              label: Text('$age años'),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedAge = age;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInterestsSelector() {
    const interests = [
      {'id': 'animals', 'label': 'Animales'},
      {'id': 'adventure', 'label': 'Aventuras'},
      {'id': 'bedtime', 'label': 'Hora de dormir'},
      {'id': 'fairy', 'label': 'Cuentos de hadas'},
      {'id': 'learning', 'label': 'Aprender'},
      {'id': 'music', 'label': 'Música'},
      {'id': 'nature', 'label': 'Naturaleza'},
      {'id': 'friends', 'label': 'Amigos'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intereses (opcional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interests.map((interest) {
            final id = interest['id']!;
            final isSelected = _selectedInterests.contains(id);
            return FilterChip(
              label: Text(interest['label']!),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(id);
                  } else {
                    _selectedInterests.add(id);
                  }
                });
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAvatar == null) {
      _showError('Elegí un avatar');
      return;
    }
    if (_selectedAge == null) {
      _showError('Elegí una edad');
      return;
    }

    final controller = ref.read(childProfileControllerProvider.notifier);

    try {
      if (_isEditMode) {
        await controller.updateChild(
          childId: widget.childId!,
          name: _nameController.text,
          age: _selectedAge,
          avatarUrl: _selectedAvatar,
          interests: _selectedInterests.toList(),
        );
      } else {
        await controller.createChild(
          name: _nameController.text,
          age: _selectedAge!,
          avatarUrl: _selectedAvatar!,
          interests: _selectedInterests.toList(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Perfil actualizado'
                : 'Perfil creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar perfil?'),
        content: const Text(
          'El perfil será eliminado en 30 días. Durante ese tiempo, '
          'podés recuperarlo contactándonos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(childProfileControllerProvider.notifier)
          .deleteChild(widget.childId!);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
