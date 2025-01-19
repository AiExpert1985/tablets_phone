import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tablets/src/common/forms/edit_box.dart';
import 'package:tablets/src/common/values/constants.dart';
import 'package:tablets/src/common/values/gaps.dart';
import 'package:tablets/src/common/widgets/custom_icons.dart';
import 'package:tablets/src/common/widgets/main_frame.dart';
import 'package:tablets/src/features/transactions/common/common_widgets.dart';
import 'package:tablets/src/features/transactions/controllers/cart_provider.dart';
import 'package:tablets/src/features/transactions/controllers/form_data_container.dart';
import 'package:tablets/src/features/transactions/model/product.dart';
import 'package:transparent_image/transparent_image.dart';

class AddItem extends ConsumerStatefulWidget {
  const AddItem(this.product, {super.key});
  final Product product;

  @override
  // ignore: library_private_types_in_public_api
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends ConsumerState<AddItem> {
  late Map<String, dynamic> itemData;

  @override
  void initState() {
    super.initState();
    // Initialize the product data map with the product's properties
    itemData = {
      'code': widget.product.code,
      'name': widget.product.name,
      'dbRef': widget.product.dbRef,
      'weight': widget.product.packageWeight,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MainFrame(
      includeBottomNavigation: true,
      child: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTitle(),
            VerticalGap.xl,
            _buildImage(),
            VerticalGap.xl,
            _buildPrice(),
            VerticalGap.l,
            _buildQuantity(),
            VerticalGap.l,
            _buildGift(),
            const Spacer(),
            _buildButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      height: 150,
      width: 200,
      imageUrl: widget.product.coverImageUrl,
      progressIndicatorBuilder: (context, url, downloadProgress) => Image.memory(kTransparentImage),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  Widget _buildTitle() {
    return Text(
      itemData['name'],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPrice() {
    final formDataNotifier = ref.read(formDataContainerProvider.notifier);
    final sellingPriceType = formDataNotifier.data['sellingPriceType'];
    final price = sellingPriceType == 'retail'
        ? widget.product.sellRetailPrice
        : widget.product.sellWholePrice;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FormFieldLabel('السعر'),
        HorizontalGap.xl,
        Expanded(
          child: FormInputField(
            onChangedFn: (value) {
              setState(() {
                itemData['sellingPrice'] = value; // Update price in the map
              });
            },
            initialValue: price,
            dataType: FieldDataType.num,
            name: 'price',
          ),
        ),
      ],
    );
  }

  Widget _buildQuantity() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FormFieldLabel('العدد'),
        HorizontalGap.xl,
        Expanded(
          child: FormInputField(
            onChangedFn: (value) {
              setState(() {
                itemData['soldQuantity'] = value; // Update quantity in the map
              });
            },
            dataType: FieldDataType.num,
            name: 'Quantity',
          ),
        ),
      ],
    );
  }

  Widget _buildGift() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const FormFieldLabel('الهدية'),
        HorizontalGap.xl,
        Expanded(
          child: FormInputField(
            onChangedFn: (value) {
              setState(() {
                itemData['giftQuantity'] = value; // Update gift in the map
              });
            },
            dataType: FieldDataType.num,
            name: 'gift',
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const ApproveIcon(),
            onPressed: () {
              cartNotifier.addItem(itemData);
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const CancelIcon(),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
