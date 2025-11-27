# Responsive Design System Guide

## Quick Start

### 1. Import Extensions
```dart
import 'package:aqvioo/core/utils/responsive_extensions.dart';
```

### 2. Use Extension Methods

#### Percentage-based Sizing
```dart
// Height as percentage (0-100)
SizedBox(height: 5.h(context))  // 5% of screen height

// Width as percentage (0-100)
Container(width: 80.w(context))  // 80% of screen width

// Safe dimensions (excluding system bars)
Padding(padding: EdgeInsets.all(3.sh(context)))  // 3% of safe height
```

#### Scaled Values
```dart
// Scale font sizes
Text('Hello', style: TextStyle(fontSize: 16.sp(context)))

// Scale dimensions
SizedBox(width: 32.scaleW(context))  // Scales 32 based on screen width
SizedBox(height: 48.scaleH(context))  // Scales 48 based on screen height
```

#### Context Extensions
```dart
// Access screen dimensions
final width = context.screenWidth;
final height = context.screenHeight;

// Device category checks
if (context.isSmallPhone) {
  // Adjust for small phones
}

// Responsive values
final padding = context.responsive<double>(
  smallPhone: 12.0,
  mediumPhone: 16.0,
largePhone: 20.0,
  tablet: 24.0,
);
```

### 3. Use Responsive Widgets

#### ResponsiveScaffold
Automatically handles scrolling to prevent overflow:

```dart
ResponsiveScaffold(
  body: Column(
    children: [
      // Your widgets - Will auto-scroll if needed
    ],
  ),
)
```

#### ResponsivePadding
Automatically scales padding:

```dart
ResponsivePadding(
  horizontal: 24,
  vertical: 16,
  child: Text('Hello'),
)
```

## Migration Guide

### Before (Fixed Values)
```dart
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Hello',
            style: TextStyle(fontSize: 18),
          ),
        ),
const SizedBox(height: 48),
      ],
    ),
  ),
)
```

### After (Responsive)
```dart
ResponsiveScaffold(
  body: Column(
    children: [
      SizedBox(height: 32.scaleH(context)),
      ResponsivePadding(
        all: 24,
        child: Text(
          'Hello',
          style: TextStyle(fontSize: 18.sp(context)),
        ),
      ),
      SizedBox(height: 48.scaleH(context)),
    ],
  ),
)
```

## Best Practices

### 1. When to Use What

| Use Case | Method | Example |
|----------|--------|---------|
| Spacing (gap between widgets) | `.scaleH()` or `.scaleW()` | `SizedBox(height: 24.scaleH(context))` |
| Font sizes | `.sp()` | `TextStyle(fontSize: 16.sp(context))` |
| Percentage layouts | `.h()` or `.w()` | `Container(width: 50.w(context))` |
| Fixed-size icons/buttons | `ResponsiveUtils.responsiveIconSize()` | - |
| Padding/margins | `ResponsivePadding` or `.responsive()` extension | `EdgeInsets.all(16).responsive(context)` |

### 2. Screen Overflow Prevention

**Always wrap scrollable content:**
```dart
ResponsiveScaffold(
  scrollable: true,  // default
  body: Column(/* content */),
)
```

**For fixed layouts:**
```dart
ResponsiveScaffoldFixed(
  body: Stack(/* content */),
)
```

### 3. Device-Specific Adjustments

```dart
// Method 1: Using context extension
final buttonHeight = context.responsive<double>(
  smallPhone: 44.0,
  mediumPhone: 48.0,
  largePhone: 52.0,
  tablet: 56.0,
);

// Method 2: Using ResponsiveUtils
final iconSize = ResponsiveUtils.responsiveIconSize(context, 24.0);

// Method 3: Manual check
if (context.isSmallPhone) {
  return CompactWidget();
} else {
  return NormalWidget();
}
```

### 4. Responsive Border Radius
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16).responsive(context),
  ),
)
```

## Common Patterns

### Pattern 1: Full-Width Card
```dart
Container(
  width: 90.w(context),  // 90% of screen width
  padding: EdgeInsets.all(24).responsive(context),
  // ...
)
```

### Pattern 2: Vertical Spacing
```dart
Column(
  children: [
    Widget1(),
    SizedBox(height: 16.scaleH(context)),
    Widget2(),
    SizedBox(height: 24.scaleH(context)),  
    Widget3(),
  ],
)
```

### Pattern 3: Responsive Text
```dart
Text(
  'Title',
  style: TextStyle(
    fontSize: 24.sp(context),
    height: 1.2,
  ),
)
```

### Pattern 4: Input Fields with Keyboard
```dart
ResponsiveScaffold(
  resizeToAvoidBottomInset: true,  // default
  body: Column(
    children: [
      TextField(/* ... */),
      // Keyboard will push content up, scrollable prevents overflow
    ],
  ),
)
```

## Device Breakpoints

| Category | Width Range | Scale Factor |
|----------|-------------|--------------|
| Small Phone | < 360dp | 0.85 |
| Medium Phone | 360-400dp | 0.9 |
| Large Phone | 400-600dp | 1.0 (baseline) |
| Tablet | >= 600dp | 1.15 |

## Troubleshooting

### Issue: Still Getting Overflow

**Solution:** Ensure you're using `ResponsiveScaffold` or wrapping in `SingleChildScrollView`:
```dart
ResponsiveScaffold(
  scrollable: true,
  body: Column(/* ... */),
)
```

### Issue: Elements Too Small on Tablet

**Solution:** Use responsive values:
```dart
// Before
const SizedBox(height: 16)

// After
SizedBox(height: 16.scaleH(context))
```

### Issue: Need Different Layouts for Different Sizes

**Solution:** Use device checks:
```dart
if (context.isTablet) {
  return TwoColumnLayout();
} else {
  return SingleColumnLayout();
}
```

## Examples

### Example 1: Login Screen
```dart
ResponsiveScaffold(
  body: Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(24).responsive(context),
      child: Column(
        children: [
          Text(
            'Welcome',
            style: TextStyle(fontSize: 32.sp(context)),
          ),
          SizedBox(height: 24.scaleH(context)),
          TextField(/* ... */),
          SizedBox(height: 16.scaleH(context)),
          ElevatedButton(/* ... */),
        ],
      ),
    ),
  ),
)
```

### Example 2: Card List
```dart
ResponsiveScaffold(
  body: ListView.separated(
    padding: ResponsivePadding(horizontal: 16, vertical: 20),
    itemCount: items.length,
    separatorBuilder: (_, __) => SizedBox(height: 12.scaleH(context)),
    itemBuilder: (context, index) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16).responsive(context),
        ),
        child: /* ... */,
      );
    },
  ),
)
```

## Summary

✅ **Always use:**
- `ResponsiveScaffold` for screens with potential overflow
- `.sp(context)` for font sizes
- `.scaleH()` / `.scaleW()` for spacing and dimensions  
- `ResponsivePadding` for automatic padding scaling

✅ **Benefits:**
- Zero overflow errors across all devices
- Consistent spacing and sizing
- Easy maintenance
- Tablet support out of the box

✅ **Migration:**
1. Replace `Scaffold` with `ResponsiveScaffold`
2. Add `.sp(context)` to all font sizes
3. Add `.scaleH(context)` to vertical spacing
4. Use `ResponsivePadding` instead of `Padding` where appropriate
