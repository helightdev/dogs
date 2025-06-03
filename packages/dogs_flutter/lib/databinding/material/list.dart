import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/material.dart';

class ListBindingStyle extends BindingStyleExtension<ListBindingStyle>
    implements StructureMetadata, BindingStyleModifier {
  final String? addButtonLabel;
  final double? spacing;
  final ListBindingViewFactory? viewFactory;
  final String? itemLabel;

  const ListBindingStyle({this.addButtonLabel, this.spacing, this.viewFactory, this.itemLabel});

  @override
  BindingStyle createStyleOverrides() {
    return BindingStyle(extensions: [this]);
  }

  @override
  ListBindingStyle merge(ListBindingStyle? other) {
    if (other == null) return this;
    return ListBindingStyle(
      addButtonLabel: addButtonLabel ?? other.addButtonLabel,
      spacing: spacing ?? other.spacing,
      viewFactory: viewFactory ?? other.viewFactory,
      itemLabel: itemLabel ?? other.itemLabel,
    );
  }
}

abstract class ListBindingViewFactory {
  const ListBindingViewFactory();

  Widget buildListView(
    BuildContext context,
    ListBindingStyle style,
    ListBindingFieldController controller,
  );
}

class DefaultListBindingViewFactory implements ListBindingViewFactory {

  const DefaultListBindingViewFactory();

  @override
  Widget buildListView(
    BuildContext context,
    ListBindingStyle style,
    ListBindingFieldController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: style.spacing ?? 8.0,
      children: [
        ReorderableListView.builder(
          itemCount: controller.fieldOrder.length,
          proxyDecorator: (
            Widget child,
            int index,
            Animation<double> animation,
          ) {
            return Material(color: Colors.transparent, child: child);
          },
          itemBuilder: (context, index) {
            final fieldName = controller.fieldOrder[index];
            final fieldController = controller.field(fieldName);
            return Padding(
              key: Key(fieldName),
              padding:
                  index == 0
                      ? EdgeInsets.zero
                      : EdgeInsets.only(top: style.spacing ?? 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: FieldBinding(
                      field: fieldName,
                      controller: fieldController,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      controller.removeFieldAt(index);
                    },
                  ),
                  SizedBox(width: 32.0),
                ],
              ),
            );
          },
          onReorder: (int oldIndex, int newIndex) {
            controller.reorderFields(oldIndex, newIndex);
          },
          shrinkWrap: true,
        ),
        FilledButton(
          onPressed: () {
            controller.addField();
          },
          child: Text(style.addButtonLabel ?? "Add"),
        ),
      ],
    );
  }
}
