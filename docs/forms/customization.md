# Customization

Most of the customization of the form is done through the annotations of the serializable classes.
The layout of the form is determined by the `@Form` annotation, specifically the `FomrDecorator`
parameter, both of the `@AutoForm` annotation as well as the `DogsForm` widget.

## Example
``` { .dart .annotate }
@serializable
@AutoForm(decorator: AddressDecorator())/*(4)!*/
class Address {
  @AutoFormField(flex: 6)
  final String street;
  
  @AutoFormField(flex: 3/*(2)!*/)
  final String city;
  
  // No @AutoFormField required (1)
  @LengthRange(min: 5, max: 5)/*(3)!*/
  final String zip;

  Address(this.street, this.city, this.zip);
}

class AddressDecorator extends FormColumnDecorator<Address> {
  const/*(7)!*/ AddressDecorator();

  @override
  void decorate(BuildContext context, FormStackConfigurator configurator) {
    configurator.row(["street", "city", "zip"]);/*(5)!*/
    return super.decorate(context, configurator);/*(6)!*/
  }
}
```

1. You don't have to use the `@AutoFormField` annotation if you don't want to apply any additional 
    visual customization to the field.
2. This field will be rendered with a flex of 3 inside the row specified by the `AddressDecorator`.
3. Specifying the length range of the zip field will automatically add a validator to the field.
4. Here, we tell to dogs_forms to use the `AddressDecorator` as a default to render the form.
    Otherwise, the default decorator would be used.
5. We now tell the decorator to render all the fields in a row, respecting their flex values specified
    in the `@AutoFormField` annotation.
6. You normally call the `super.decorate` method at the end of your decorator to automatically add
    fields you forgot to customize manually.
7. The decorator should be const, so that you can use it as an argument to the `@AutoForm` annotation.

!!! tip "My customization annotations are getting to long!"
    If your annotations are getting to long, you can extract the form logic into a separate 
    serializable class and use the projection capabilities of dogs to convert between the two.
    This helps keeping your original serializable class clean and readable.

    Otherwise, you can also use custom factories to create your form fields. There, you can isolate
    the logic without having to create really long annotations. Since this is relatively easy to 
    refactor aftwards, you can always start with the annotations and refactor later.

To find out all the customization options, head to the [API Reference] for the `@AutoForm` and
`@AutoFormField` annotations. A few of the most important ones are listed below:

## Important Options
### AutoFormField.title
The title of the field, that will be used as the labelText for most form fields.
If you want to localize this later, you can also specify 'titleTranslationKey'.

### AutoFormField.subtitle
The title of the field, that will be used as the labelText for most form fields.
If you want to localize this later, you can also specify 'subtitleTranslationKey'.

### AutoFormField.factory
Specify a custom factory used to create the form field. If you generally want to use a custom factory
for all fields of a specific datatype, consider customizing the mode factory registration in your
main method by using a composed mode factory with your custom type bound factory.

### AutoFormField.initializer
Specify a custom initializer used to create the initial value of the form field.
If you want to specify a custom initializer for items of iterable fields, use the `itemInitialzer`
parameter instead.

### AutoFormField.decoration
Specify a custom decoration used to decorate the form field.

## Decorators
Decorators are used to specify the layout of the form. The default decorator is the `FormColumnDecorator`,
which uses an imperative builder approach to specify the layout of the form. The builders pushes
the fields into a list in the order you call the builder methods. Possible builder methods are:

### Row
Rows are specified by calling the `row` method of the `FormStackConfigurator` class. The row method
takes a list of field names as an argument. The order of the fields in the list determines the order
of the fields in the row. The flex values of the fields and constraints are respected, so that the
fields are rendered with the correct width.

### Wrap
Wraps are specified by calling the `wrap` method of the `FormStackConfigurator` class. The wrap method
takes a list of field names as an argument. The order of the fields in the list determines the order
of the fields in the wrap. The constraints of the fields are respected, so that the fields are rendered
with the correct width and height.

### Single Field
You can also push a single field by calling the `field` method of the `FormStackConfigurator` class.
This will add the field to the form column, respecting the constraints of the field.

### Push Widget
You can also push any arbitrary widget by calling the `push` method of the `FormStackConfigurator` class.

#### Field Builders
In case you want to use your own container widgets, you can build individual fields using the
`buildField` and the `buildFlexibleField` methods of the `FormStackConfigurator` class. These
methods take a dog field and a BuildContext as an argument and return the built widget.
You can retrieve the dog field for a specific field name by calling the `popNamed` method of the
`FormStackConfigurator` class. This also automatically removes the field from the remaining fields.

#### Access BuildContext
You can retrieve the current BuildContext by using the `context` field of the `FormStackConfigurator`.