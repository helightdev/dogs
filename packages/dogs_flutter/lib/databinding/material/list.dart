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

class ListBindingStyleContributor implements SchemaStructureMaterializationContributor {
  @override
  DogStructureField transformField(DogStructureField field, SchemaType schema) {
    String? itemLabel;
    String? addButtonLabel;
    bool isModified = false;

    if (schema.properties.containsKey(DogsFlutterSchemaTags.listBindingItemLabel)) {
      var value = schema[DogsFlutterSchemaTags.listBindingItemLabel] as String?;
      itemLabel = value;
      isModified = true;
    }

    if (schema.properties.containsKey(DogsFlutterSchemaTags.listBindingAddButtonLabel)) {
      var value = schema[DogsFlutterSchemaTags.listBindingAddButtonLabel] as String?;
      addButtonLabel = value;
      isModified = true;
    }

    if (schema.type == SchemaCoreType.array && isModified) {
      field = field.copy(
        annotations:
            field.annotations +
            [ListBindingStyle(itemLabel: itemLabel, addButtonLabel: addButtonLabel)],
      );
    }

    return field;
  }

  @override
  DogStructure<Object> transformStructure(DogStructure<Object> structure, SchemaType schema) {
    return structure;
  }
}

extension BindingStyleSchemaBuilderExtension on SchemaType {
  SchemaType itemLabel(String label) {
    this[DogsFlutterSchemaTags.listBindingItemLabel] = label;
    return this;
  }

  SchemaType addButtonLabel(String label) {
    this[DogsFlutterSchemaTags.listBindingAddButtonLabel] = label;
    return this;
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
    var verticalGap = style.spacing ?? 8.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ReorderableListView.builder(
          itemCount: controller.fieldOrder.length,
          proxyDecorator: (Widget child, int index, Animation<double> animation) {
            return Material(color: Colors.transparent, child: child);
          },
          itemBuilder: (context, index) {
            final fieldName = controller.fieldOrder[index];
            final fieldController = controller.field(fieldName);
            return Padding(
              key: Key(fieldName),
              padding: index == 0 ? EdgeInsets.zero : EdgeInsets.only(top: verticalGap),
              child: Row(
                children: [
                  Expanded(
                    child: FieldBinding(
                      field: fieldName,
                      controller: fieldController,
                      style: BindingStyle(label: style.itemLabel),
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
        if (controller.fieldOrder.isNotEmpty) SizedBox(height: verticalGap),
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
