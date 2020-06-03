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
  [
      {
       ${各CustomizableWidgetにて定義されたJsonオブジェクト}
      },
      {
       ${各CustomizableWidgetにて定義されたJsonオブジェクト}
      }
  ]
  ...
}
```
