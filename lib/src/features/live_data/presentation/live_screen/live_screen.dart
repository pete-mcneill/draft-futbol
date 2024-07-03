import 'package:draft_futbol/src/features/live_data/data/draft_repository.dart';
import 'package:draft_futbol/src/common_widgets/draft_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the product page for a given product ID.
class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DraftAppBar(),
      body: Consumer(
        builder: (context, ref, _) {
          final DraftRepository = ref.watch(draftRepositoryProvider);
          return Text("Live Screen");
          // return AsyncValueWidget<Product?>(
          //   value: productValue,
          //   data: (product) => product == null
          //       ? EmptyPlaceholderWidget(
          //           message: 'Product not found'.hardcoded,
          //         )
          //       : CustomScrollView(
          //           slivers: [
          //             ResponsiveSliverCenter(
          //               padding: const EdgeInsets.all(Sizes.p16),
          //               child: ProductDetails(product: product),
          //             ),
          //             ProductReviewsList(productId: productId),
          //           ],
          //         ),
          // );
        },
      ),
    );
  }
}

/// Shows all the product details along with actions to:
/// - leave a review
/// - add to cart
// class ProductDetails extends ConsumerWidget {
//   const ProductDetails({super.key, required this.product});
//   final Product product;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final priceFormatted =
//         ref.watch(currencyFormatterProvider).format(product.price);
//     return ResponsiveTwoColumnLayout(
//       startContent: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(Sizes.p16),
//           child: CustomImage(imageUrl: product.imageUrl),
//         ),
//       ),
//       spacing: Sizes.p16,
//       endContent: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(Sizes.p16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(product.title,
//                   style: Theme.of(context).textTheme.titleLarge),
//               gapH8,
//               Text(product.description),
//               // Only show average if there is at least one rating
//               if (product.numRatings >= 1) ...[
//                 gapH8,
//                 ProductAverageRating(product: product),
//               ],
//               gapH8,
//               const Divider(),
//               gapH8,
//               Text(priceFormatted,
//                   style: Theme.of(context).textTheme.headlineSmall),
//               gapH8,
//               LeaveReviewAction(productId: product.id),
//               const Divider(),
//               gapH8,
//               AddToCartWidget(product: product),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }