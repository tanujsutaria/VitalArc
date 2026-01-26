# Multi-Source Food Database Integration

This guide explains how to set up and use VitalArc's multi-source food database integration, which dramatically improves food search quality and variety.

## Overview

VitalArc now searches across **three major food databases**:

1. **Nutritionix** - Best for branded foods, restaurant chains, and US foods
2. **OpenFoodFacts** - Best for international products, barcodes, and product images
3. **USDA FoodData Central** - Best for basic whole foods and nutrition data

The system intelligently combines results from all sources, deduplicates them, and caches them for better performance.

## Features

- **Multi-source search**: Search across all three databases simultaneously
- **Barcode scanning**: Scan product barcodes to instantly find nutrition info
- **Product images**: See actual product photos from OpenFoodFacts
- **Smart caching**: Reduces API calls and improves performance
- **Source badges**: See which database each food came from
- **Favorites & recents**: Track your most-used foods
- **Custom foods**: Create your own food entries

## Setup

### 1. Nutritionix API Key (Optional but Recommended)

Nutritionix provides the best data for branded foods and restaurant items.

**Free tier**: 10,000 requests/month

1. Go to [https://developer.nutritionix.com](https://developer.nutritionix.com)
2. Sign up for a free account
3. Create a new application
4. Copy your App ID and App Key

**Update the API credentials in `NutritionixAPI.swift`:**

```swift
init(
    networkService: NetworkServiceProtocol = NetworkService(),
    appId: String = "YOUR_APP_ID_HERE",     // Replace with your App ID
    appKey: String = "YOUR_APP_KEY_HERE",   // Replace with your App Key
    baseURL: String = "https://trackapi.nutritionix.com/v2"
)
```

### 2. OpenFoodFacts (No Setup Required)

OpenFoodFacts is completely free and open-source. No API key required!

### 3. USDA FoodData Central (Already Configured)

The app uses a demo API key that works with limited rate limits. For production, you may want to get your own key:

1. Go to [https://fdc.nal.usda.gov/api-key-signup.html](https://fdc.nal.usda.gov/api-key-signup.html)
2. Sign up for a free API key
3. Update `USDAFoodAPI.swift` with your key

### 4. Camera Permissions (For Barcode Scanning)

The app needs camera access to scan barcodes. This is automatically requested when the user first tries to scan.

**Already configured** in `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>VitalArc needs camera access to scan food barcodes</string>
```

## Architecture

### Files Created

**API Models:**
- `NutritionixModels.swift` - Nutritionix response models
- `OpenFoodFactsModels.swift` - OpenFoodFacts response models

**API Clients:**
- `NutritionixAPI.swift` - Nutritionix API integration
- `OpenFoodFactsAPI.swift` - OpenFoodFacts API integration
- `FoodAPICoordinator.swift` - Multi-source search coordinator

**Use Cases:**
- `SearchMultiSourceFoodUseCase.swift` - Multi-source search use case

**Infrastructure:**
- `FoodCache.swift` - In-memory caching layer

**UI:**
- `BarcodeScannerView.swift` - Barcode scanner using AVFoundation

**Enhanced Files:**
- `Food.swift` - Added barcode, imageURL, isFavorite, etc.
- `FoodModel.swift` - Added corresponding SwiftData fields
- `FoodSearchView.swift` - Added barcode scanner button
- `FoodSearchViewModel.swift` - Added barcode search support
- `FoodResultRowView.swift` - Added source badges and images

## Usage

### Text Search

1. Open the nutrition log
2. Tap "Add Food"
3. Enter a search query (e.g., "chicken breast", "coke", "doritos")
4. Results from all three databases will appear
5. Each result shows a source badge (USDA, Nutritionix, or OpenFoodFacts)

### Barcode Scanning

1. Open the nutrition log
2. Tap "Add Food"
3. Tap the barcode icon in the top-right
4. Point your camera at a product barcode
5. The app will automatically look up the product and show nutrition info

### Source Badges

Each food result shows a small badge indicating its source:

- 🌿 **USDA** (green) - Basic whole foods, reliable nutrition data
- 🍴 **Nutritionix** (orange) - Branded foods, restaurant items
- 🌍 **Open Food Facts** (blue) - International products, often with images

## How It Works

### Search Flow

1. **User enters query** → debounced for 500ms
2. **Check cache** → return cached results if available
3. **Parallel API calls** → search all configured sources simultaneously
4. **Deduplication** → remove duplicate items based on name + brand
5. **Store in cache** → save for 24 hours
6. **Display results** → show with source badges and images

### Barcode Scanning Flow

1. **User scans barcode** → capture UPC/EAN code
2. **Check cache** → return cached product if available
3. **Try Nutritionix** → if configured and available
4. **Fallback to OpenFoodFacts** → always available
5. **Display result** → show product with full nutrition info

### Caching Strategy

- **Search cache**: Stores query results for 24 hours
- **Barcode cache**: Stores scanned products for 24 hours
- **Max size**: 1,000 entries (auto-cleans oldest 20% when full)
- **Performance**: Dramatically reduces API calls

## Data Quality

### Nutritionix
- ✅ Excellent for US branded foods
- ✅ Restaurant nutrition data
- ✅ Comprehensive macro/micro nutrients
- ⚠️ Requires API key (free tier: 10k/month)

### OpenFoodFacts
- ✅ Huge international database (2M+ products)
- ✅ Product images and photos
- ✅ Barcode lookup
- ✅ Completely free and unlimited
- ⚠️ Variable data quality (crowdsourced)

### USDA
- ✅ Very reliable nutrition data
- ✅ Comprehensive database
- ✅ Government-backed accuracy
- ⚠️ Basic foods only (no branded items)
- ⚠️ No images

## Future Enhancements

### Already Implemented
- ✅ Multi-source search
- ✅ Barcode scanning
- ✅ Smart caching
- ✅ Product images
- ✅ Source badges

### Future Ideas
- ⏳ Favorites and recent foods tracking
- ⏳ Custom food creation UI
- ⏳ Meal templates
- ⏳ Offline mode
- ⏳ User contributions to OpenFoodFacts
- ⏳ Recipe parsing
- ⏳ Restaurant menu search

## Troubleshooting

### "No results found"
- Try different search terms
- Check your internet connection
- Verify API keys are configured (for Nutritionix)

### Barcode scanning not working
- Grant camera permissions
- Ensure good lighting
- Try cleaning the camera lens
- Some barcodes may not be in the databases

### Slow search results
- First search may be slow (hitting APIs)
- Subsequent searches are cached (faster)
- Consider getting Nutritionix API key for better performance

### Images not loading
- Some foods don't have images
- Check internet connection
- OpenFoodFacts images may be slow to load

## API Rate Limits

### Nutritionix (Free Tier)
- 10,000 requests/month
- ~333 requests/day
- Should be plenty for personal use

### OpenFoodFacts
- Unlimited
- Be respectful (max 1 request/second recommended)

### USDA
- Demo key: 1,000 requests/hour
- Personal key: 10,000 requests/hour

## Support

For issues or questions:
1. Check this documentation
2. Review the code comments
3. Test with different search queries
4. Verify API key configuration

## Credits

- **Nutritionix** - [https://nutritionix.com](https://nutritionix.com)
- **OpenFoodFacts** - [https://openfoodfacts.org](https://openfoodfacts.org)
- **USDA FoodData Central** - [https://fdc.nal.usda.gov](https://fdc.nal.usda.gov)
