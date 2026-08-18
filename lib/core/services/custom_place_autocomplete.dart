import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/core/services/places_service.dart';

class CustomPlaceAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function(Map<String, dynamic> place)? onSelected;

  const CustomPlaceAutocomplete({
    Key? key,
    required this.controller,
    this.focusNode,
    this.onSelected,
  }) : super(key: key);

  @override
  State<CustomPlaceAutocomplete> createState() =>
      _CustomPlaceAutocompleteState();
}

class _CustomPlaceAutocompleteState extends State<CustomPlaceAutocomplete> {
  final _placesService = PlacesService();
  final _overlayEntry = GlobalKey<NavigatorState>();
  Timer? _debounce;
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = false;
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _debounce?.cancel();
    _hideOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.length < 2) {
        _hideOverlay();
        return;
      }

      setState(() => _isLoading = true);

      try {
        final predictions = await _placesService.searchPlaces(query);
        setState(() {
          _predictions = predictions;
          _isLoading = false;
        });
        _showOverlay();
      } catch (e) {
        print('Error: $e');
        setState(() => _isLoading = false);
      }
    });
  }

  void _showOverlay() {
    _hideOverlay();

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height,
        left: offset.dx,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _predictions.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final prediction = _predictions[index];
                      final structuredFormatting =
                          prediction['structured_formatting']
                              as Map<String, dynamic>?;

                      return ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          structuredFormatting?['main_text'] ??
                              prediction['description'] ??
                              '',
                          style: AppTextStyles.regular,
                        ),
                        subtitle: Text(
                          structuredFormatting?['secondary_text'] ?? '',
                          style: AppTextStyles.regular.copyWith(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          widget.controller.text =
                              prediction['description'] ?? '';
                          widget.onSelected?.call(prediction);
                          _hideOverlay();
                          widget.focusNode?.unfocus();
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _hideOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'ค้นหาสถานที่...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        hintStyle: AppTextStyles.regular.copyWith(color: AppColors.textLighter),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.textLighter, width: 1),
        ),
        suffixIcon: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Icon(Icons.search, color: AppColors.primary),
      ),
    );
  }
}
