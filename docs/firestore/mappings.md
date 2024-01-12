## Firestore Conversions
The firestore support package adds following conversions to make your life a bit easier:

| Dart Type | Firestore Type |
|-----------|----------------|
| DateTime  | Timestamp      |
| Uint8List | Blob           |

Those conversions override the default behaviour of the converter and are only applied when the
converter is used in the firestore operation mode. This happens automatically when you use the
the public api provided by the firestore support package and you don't have to worry about it.

!!! info "Normally, dogs already supports those types"
    By default, dogs already has converters for `DateTime` and `Uint8List` that are used in the
    graph and native operation modes. Even though those could be used in the firestore operation
    mode as well, they are not used there, since the types they represent are supported by firestore
    natively.

## Interop for Firestore Types
Of course, all firestore native types are also supported, though they only work in the firestore
operation mode. To make them work outside of the firestore operation mode, you can use the
`installFirebaseInterop` in your `main` method. This will install interop converts for all firestore
native types, so that they can be used in the graph and native operation modes.

Those interop converters perform following conversions:

| Firestore Type | Dart Native Type | Format       |
|----------------|------------------|--------------|
| Timestamp      | String           | ISO8601      |
| Blob           | String           | Base64       |
| GeoPoint       | String           | "$lat, $lon" |

!!! tip "Using those interop module allows you to perform json serialization on firestore native types"
    This means, that you can send the data easily via http requests or store them in preferences.