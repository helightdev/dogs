#!/bin/bash

(
cd "packages/dogs_flutter/demo"
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build web --release --base-href /assets/dogs_flutter/demo/
)

rm -rf docs/assets/dogs_flutter/demo
mv -f packages/dogs_flutter/demo/build/web/ docs/assets/dogs_flutter/demo/