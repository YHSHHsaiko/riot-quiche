# 情報保存するディレクトリ
```dart
appDirectory
|
-- jsonDirectory
   |
   -- preset1
      |
      -- layers.json
   -- preset2
      |
      -- layers.json
   ...
```

# layers.json
```dart
{
  "layer1": {
    ${各CustomizableWidgetにて定義されたJsonオブジェクト}
  },
  "layer2": {
    ${各CustomizableWidgetにて定義されたJsonオブジェクト}
  }
  ...
}
```