# Data Binding

We provide a way to create a **notifier-based controller** for dog structures that can be used to simplify the process
of
**building forms and data views** using a dogs flavored workflow. Simple variants of the **entire form or individual
fields**
can be **automatically generated** using the structures and can be configured using metadata annotations. The
controller **fully supports the dogs_core validation** system, allowing you to easily create form validations.

## State

The entire state of a structure binding is stored in the `StructureBindingController` and can be initialized using
a structure type with `StructureBindingController.create<T>()` or using a schema with
`StructureBindingController.materialize(Schema)`.


## Flutter Widget Binders

The `FlutterWidgetBinder` opmode is creates a `Widget` and `FieldBindingController` for a given field definition. The binder is
usually inferred from the field type but can be manually overridden by specifying a supplying metadata annotation or
by manually setting it using the `binder` property of the `FieldBinding` widget in flutter.


## Field Binding

A field binding widget automatically creates a `Widget` from the field definition and binds it to the `FieldBindingController`
contained in the `StructureBindingController`. If the customizability of the field is not enough, you can always
create a custom binder or just consume the state of the `FieldBindingController` directly in your widget tree.