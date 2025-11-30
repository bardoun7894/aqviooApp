# Tabby Payment Configuration

## Credentials

### API Keys
- **Secret Key (API Key)**: `<YOUR_SECRET_KEY>`
- **Public Key**: `<YOUR_PUBLIC_KEY>`
- **Merchant Code**: `sa` (Saudi Arabia)

## Environment Variables

Add these to your `.env` file:

```env
TABBY_API_KEY=<YOUR_SECRET_KEY>
TABBY_MERCHANT_CODE=sa
```

## Enable All Payment Methods

> [!NOTE]
> The `source` parameter mentioned (`{"id": "src_all"}`) is for **backend API integration** when creating sessions via Tabby's REST API, not the Flutter SDK.

If you're implementing server-side session creation, include:
```json
{
  "payment": {
    ...
  },
  "source": {
    "id": "src_all"
  }
}
```

The Flutter SDK handles payment methods automatically when the session is created. The in-app WebView will show all available payment methods based on your merchant configuration.

## Current Integration

The app uses the **Flutter SDK** which:
- Creates sessions directly from the mobile app
- Opens Tabby's WebView for payment
- Automatically shows all enabled payment methods for your merchant account

No additional configuration is needed in the Flutter code to enable payment methods - this is controlled by your Tabby merchant dashboard settings.
