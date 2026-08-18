import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rodzendai_form/core/constants/app_colors.dart';
import 'package:rodzendai_form/core/constants/app_text_styles.dart';
import 'package:rodzendai_form/presentation/register/blocs/places_autocomplete_bloc/places_autocomplete_bloc.dart';
import 'package:rodzendai_form/widgets/dialog/loading_dialog.dart';
import 'package:rodzendai_form/widgets/loading_widget.dart';

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
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<PlacesAutocompleteBloc>().add(SearchPlacesEvent(query));
  }

  void _showOverlay(
    List<Map<String, dynamic>> predictions,
    bool isLoading, {
    String? emptyMessage,
  }) {
    _hideOverlay();

    if (predictions.isEmpty && !isLoading && emptyMessage == null) return;

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
            child: isLoading
                ? LoaderWidget()
                : predictions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_off,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            emptyMessage ?? 'ไม่พบสถานที่',
                            style: AppTextStyles.regular.copyWith(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: predictions.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final prediction = predictions[index];
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
                          // Update text field
                          widget.controller.text =
                              prediction['description'] ?? '';

                          // Hide overlay immediately
                          _hideOverlay();

                          // Unfocus keyboard
                          widget.focusNode?.unfocus();

                          // Call callback
                          widget.onSelected?.call(prediction);

                          // Update bloc state and clear predictions
                          final bloc = context.read<PlacesAutocompleteBloc>();
                          bloc.add(SelectPlaceEvent(prediction));
                          bloc.add(const ClearPlacesEvent());
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
    return BlocListener<PlacesAutocompleteBloc, PlacesAutocompleteState>(
      listener: (context, state) {
        if (state is PlacesAutocompleteLoaded) {
          if (state.predictions.isEmpty &&
              widget.controller.text.trim().isNotEmpty) {
            _showOverlay([], false, emptyMessage: 'ไม่พบสถานที่');
          } else {
            _showOverlay(state.predictions, false);
          }
        } else if (state is PlacesAutocompleteLoading) {
          _showOverlay([], true);
        } else if (state is PlacesAutocompleteInitial) {
          _hideOverlay();
        } else if (state is PlacesAutocompleteError) {
          if (widget.controller.text.trim().isNotEmpty) {
            _showOverlay([], false, emptyMessage: 'เกิดข้อผิดพลาดในการค้นหา');
          } else {
            _hideOverlay();
          }
        } else if (state is PlacesAutocompleteSelected) {
          _hideOverlay();
        }
      },
      child: BlocBuilder<PlacesAutocompleteBloc, PlacesAutocompleteState>(
        builder: (context, state) {
          final isLoading = state is PlacesAutocompleteLoading;

          return TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              if (state is PlacesAutocompleteLoaded &&
                  state.predictions.isNotEmpty) {
                final first = state.predictions.first;
                widget.controller.text = first['description'] ?? '';
                _hideOverlay();
                widget.focusNode?.unfocus();
                widget.onSelected?.call(first);
                final bloc = context.read<PlacesAutocompleteBloc>();
                bloc.add(SelectPlaceEvent(first));
                bloc.add(const ClearPlacesEvent());
              } else {
                widget.focusNode?.unfocus();
              }
            },
            decoration: InputDecoration(
              hintText: 'ค้นหาสถานที่...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              hintStyle: AppTextStyles.regular.copyWith(
                color: AppColors.textLighter,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.textLighter, width: 1),
              ),
              suffixIcon: isLoading
                  ? SizedBox(width: 20, height: 20, child: LoadingWidget())
                  : Icon(Icons.search, color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}
