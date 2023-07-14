import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

class ChipOptions {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  ChipOptions({
    required this.label,
    required this.selected,
    required this.onSelected,
  });
}

class FilterH2HMatches extends ConsumerWidget {
  FilterH2HMatches({
    required this.options,
    Key? key,
  }) : super(
          key: key,
        );

  /// The foreground color of the bar.
  final List<ChipOptions> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool bps = ref.read(utilsProvider).liveBps!;
    return Column(
      children: <Widget>[
        Wrap(spacing: 5.0, runAlignment: WrapAlignment.end, children: <Widget>[
          for (var option in options)
            ChoiceChip(
              label: Text(option.label),
              selected: option.selected,
              onSelected: (selected) {
                option.onSelected(!option.selected);
              },
            )
        ]),
      ],
    );
  }
}
