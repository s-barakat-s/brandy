import 'package:brandy/core/services/core_providers.dart';
import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/features/brands/domain/entities/brand.dart';
import 'package:brandy/features/brands/presentation/providers/brand_providers.dart';
import 'package:brandy/shared/presentation/widgets/app_card.dart';
import 'package:brandy/shared/presentation/widgets/app_page_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/primary_button.dart';
import 'package:brandy/shared/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BrandFormScreen extends ConsumerStatefulWidget {
  const BrandFormScreen({
    super.key,
    this.brandId,
  });

  final String? brandId;

  @override
  ConsumerState<BrandFormScreen> createState() => _BrandFormScreenState();
}

class _BrandFormScreenState extends ConsumerState<BrandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _typeController;
  late final TextEditingController _logoPathController;
  late final TextEditingController _descriptionController;
  bool _didHydrate = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _typeController = TextEditingController();
    _logoPathController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _logoPathController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _hydrate(Brand? brand) {
    if (_didHydrate || brand == null) {
      return;
    }

    _nameController.text = brand.name;
    _typeController.text = brand.type;
    _logoPathController.text = brand.logoPath ?? '';
    _descriptionController.text = brand.description;
    _didHydrate = true;
  }

  Future<void> _pickLogo() async {
    final pickedPath = await ref.read(imagePickerProvider).pickImagePath();
    if (pickedPath == null || !mounted) {
      return;
    }

    _logoPathController.text = pickedPath;
    setState(() {});
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final draft = BrandDraft(
      brandId: widget.brandId,
      name: _nameController.text.trim(),
      type: _typeController.text.trim(),
      logoPath: _logoPathController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    try {
      if (widget.brandId == null) {
        await ref.read(createBrandProvider)(draft);
      } else {
        await ref.read(updateBrandProvider)(draft);
      }

      if (!mounted) {
        return;
      }
      context.pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandAsync = widget.brandId == null
        ? const AsyncData<Brand?>(null)
        : ref.watch(brandByIdProvider(widget.brandId!));

    return AppPageScaffold(
      title: widget.brandId == null ? 'Add Brand' : 'Edit Brand',
      body: brandAsync.when(
        data: (brand) {
          if (widget.brandId != null && brand == null) {
            return const Center(child: Text('Brand not found.'));
          }

          _hydrate(brand);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                const SectionHeader(
                  title: 'Brand Identity',
                  subtitle: 'Set up the name and type that will anchor this workspace.',
                ),
                AppCard(
                  tone: AppCardTone.highlight,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Brand name'),
                        validator: _requiredValidator,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(labelText: 'Brand type'),
                        validator: _requiredValidator,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Logo',
                  subtitle: 'Optional, but useful when you want the brand to feel easier to recognize.',
                ),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.large),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.medium),
                            Expanded(
                              child: Text(
                                _logoPathController.text.trim().isEmpty
                                    ? 'No logo selected yet.'
                                    : _logoPathController.text.trim(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _logoPathController,
                        decoration: const InputDecoration(labelText: 'Logo path'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      OutlinedButton.icon(
                        onPressed: _pickLogo,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Choose Logo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Description',
                  subtitle: 'Add a short note so the brand has context across the app.',
                ),
                AppCard(
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                PrimaryButton(
                  label: widget.brandId == null ? 'Save Brand' : 'Update Brand',
                  leading: const Icon(Icons.check_circle_outline),
                  isBusy: _isSaving,
                  onPressed: _save,
                ),
                const SizedBox(height: AppSpacing.xlarge),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load brand: $error')),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
