import 'dart:io';

import 'package:delivery_boy_app/src/configs/injector/injector.dart';
import 'package:delivery_boy_app/src/core/session/session_manager.dart';
import 'package:delivery_boy_app/src/core/theme/app_color.dart';
import 'package:delivery_boy_app/src/features/widgets/snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

/// A self-contained widget that shows the profile avatar circle with an edit
/// icon. Tapping the edit icon opens a bottom sheet (Camera / Gallery), then
/// launches the cropper, and finally calls the ProfileImageUpdateBloc API.
class ProfileImageWidget extends StatefulWidget {
  /// The network image URL coming from the session / API response.
  final String? imageUrl;

  const ProfileImageWidget({super.key, this.imageUrl});

  @override
  State<ProfileImageWidget> createState() => _ProfileImageWidgetState();
}

class _ProfileImageWidgetState extends State<ProfileImageWidget> {
  /// Holds the locally-selected & cropped image path while uploading.
  File? _localImage;

  /// Tracks the network URL returned from a successful upload.
  String? _uploadedImageUrl;

  // ──────────────────────────────────────────────
  // Image picking helpers
  // ──────────────────────────────────────────────

  /// Shows the bottom sheet so the user can choose Camera or Gallery.
  void _showImageSourceSheet(BuildContext blocContext) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // useRootNavigator: true pushes the sheet on the ROOT navigator,
      // so it renders OVER the bottom navigation bar.
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _ImageSourceSheet(
        onGallery: () {
          Navigator.of(context, rootNavigator: true).pop();
          _pickAndCrop(blocContext, ImageSource.gallery);
        },
        onCamera: () {
          Navigator.of(context, rootNavigator: true).pop();
          _pickAndCrop(blocContext, ImageSource.camera);
        },
      ),
    );
  }

  /// Picks an image from [source], launches the cropper, and – on success –
  /// dispatches the upload event to [ProfileImageUpdateBloc].
  Future<void> _pickAndCrop(BuildContext blocContext, ImageSource source) async {
    // Capture the bloc reference BEFORE any await to avoid BuildContext async gaps.
    final imageBloc = blocContext.read<ProfileImageUpdateBloc>();

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    // Crop the image with app-matching colours.
    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: AppColor.darkOrange,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColor.darkOrange,
          backgroundColor: const Color(0xFFFFF7F0),
          dimmedLayerColor: Colors.black87,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );

    if (cropped == null) return;

    // Show the chosen image immediately (optimistic UI).
    setState(() => _localImage = File(cropped.path));

    // Fire the BLoC event using the pre-captured reference.
    imageBloc.add(PhotoUpdateGetEvent(cropped.path));
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileImageUpdateBloc, ProfileImageUpdateState>(
      listener: (context, state) {
        if (state is ProfileImageUpdateSuccessState) {
          // Save the URL returned by the API.
          final url = state.data.data?.profileImageUrl;
          if (url != null && url.isNotEmpty) {
            setState(() {
              _uploadedImageUrl = url;
              _localImage = null; // clear local file; use network URL now
            });
            _updateSessionImage(url);
          }
          appSnackBar(context, AppColor.green, state.data.message);
        } else if (state is ProfileImageUpdateFailureState) {
          // Revert optimistic image on failure.
          setState(() => _localImage = null);
          appSnackBar(context, AppColor.bright_red, state.message);
        }
      },
      builder: (blocContext, state) {
        final isLoading = state is ProfileImageUpdateLoadingState;

        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            // ── Avatar circle ──────────────────────────────────────────────
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFEAD9),
                border: Border.all(color: AppColor.darkOrange, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.darkOrange.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(child: _buildAvatarContent(isLoading)),
            ),

            // ── Edit icon (shown only when not uploading) ──────────────────
            if (!isLoading)
              GestureDetector(
                onTap: () => _showImageSourceSheet(blocContext),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColor.darkOrange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _updateSessionImage(String url) async {
    final session = await SessionManager.getUserSession();
    if (session != null && session.data?.deliveryBoy != null) {
      session.data!.deliveryBoy!.profileImage = url;
      await SessionManager.saveUserSession(session);
    }
  }

  /// Returns the correct child for the avatar circle depending on state.
  Widget _buildAvatarContent(bool isLoading) {
    // While uploading – show a loader overlay.
    if (isLoading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _avatarImage(), // dim the image behind the loader
          Container(color: Colors.black.withValues(alpha: 0.35)),
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ),
        ],
      );
    }

    return _avatarImage();
  }

  /// Picks the right image source: local file → uploaded URL → placeholder.
  Widget _avatarImage() {
    if (_localImage != null) {
      return Image.file(_localImage!, fit: BoxFit.cover);
    }

    final networkUrl = _uploadedImageUrl ?? widget.imageUrl;
    if (networkUrl != null && networkUrl.isNotEmpty) {
      return Image.network(
        networkUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmer();
        },
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFFFEAD9),
      highlightColor: Colors.white,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Icon(
      Icons.person_pin_rounded,
      size: 60,
      color: AppColor.darkOrange,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Bottom sheet UI
// ──────────────────────────────────────────────────────────────────────────────

/// The modal bottom sheet that lets the user pick Camera or Gallery.
class _ImageSourceSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ImageSourceSheet({
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Update Profile Photo',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColor.charcoal,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SourceButton(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: onCamera,
              ),
              _SourceButton(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: onGallery,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Individual icon+label button inside the bottom sheet.
class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAD9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColor.border, width: 1.5),
            ),
            child: Icon(icon, size: 32, color: AppColor.darkOrange),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColor.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
