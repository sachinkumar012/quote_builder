# Product Quote Builder

A comprehensive Flutter application for creating professional business quotations with ease. This app streamlines the quoting process by providing an intuitive interface to add client information, line items, apply discounts and taxes, and generate polished quotes instantly.

## Features

### Core Functionality
- **Client Information Management**: Capture client name, address, and reference details
- **Dynamic Line Items**: Add multiple products/services with quantity, rate, discount, and tax calculations
- **Flexible Tax Modes**: Support for both tax-inclusive and tax-exclusive pricing
- **Real-time Calculations**: Automatic subtotal, tax amount, and grand total computation
- **Quote Status Tracking**: Track quotes through draft, sent, and accepted statuses
- **Responsive Design**: Optimized layouts for both desktop and mobile devices

### User Experience
- **Live Preview**: Side-by-side form and quote preview for desktop; stacked layout for mobile
- **Currency Formatting**: Indian Rupee (₹) formatting with proper locale support
- **Data Persistence**: Save quotes locally using shared preferences
- **Professional Output**: Clean, printable quote format with table-based item listing

## Installation

### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 2.19 or higher)
- Android Studio or VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Setup Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd quote_builder
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

4. **For Android deployment:**
   ```bash
   flutter build apk --release
   ```

5. **For iOS deployment:**
   ```bash
   flutter build ios --release
   ```

## Usage

### Creating a Quote

1. **Enter Client Information:**
   - Fill in client name, address, and reference number

2. **Add Line Items:**
   - Click "Add Item" to include products/services
   - Enter item name, quantity, rate, discount, and tax percentage
   - Remove items using the delete button (except the first item)

3. **Configure Tax Mode:**
   - Choose between "Tax Inclusive" or "Tax Exclusive" pricing

4. **Review and Save:**
   - Preview the quote in real-time
   - Save quotes locally for future reference
   - Send quotes when ready

### Key Controls
- **Save Button**: Store quote data locally
- **Send Button**: Mark quote as sent
- **Status Dropdown**: Update quote status (Draft/Sent/Accepted)
- **Add Item**: Include additional line items

## Project Structure

```
quote_builder/
├── lib/
│   └── main.dart          # Main application code
├── test/
│   └── widget_test.dart   # Basic widget tests
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
├── pubspec.yaml           # Flutter dependencies and configuration
└── README.md              # This file
```

## Dependencies

- **flutter**: UI framework
- **intl**: Internationalization and number formatting
- **shared_preferences**: Local data storage

## Contributing

We welcome contributions to improve the Product Quote Builder! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter best practices and Material Design guidelines
- Write clear, concise commit messages
- Test changes on both Android and iOS platforms
- Ensure responsive design works across different screen sizes

## Contact & Support

### Sales & Support
- **Phone**: +91 93184 96221
- **Email**: sachin123@gmail.com

### Follow Us
Stay updated with product announcements, best practices, and feature updates:
- [Facebook](https://facebook.com)
- [LinkedIn](https://linkedin.com)
- [X (Twitter)](https://twitter.com)
- [Instagram](https://instagram.com)

## License

© 2025 Product Quote Builder — All Rights Reserved.

Built to simplify and speed up your quoting process with accuracy and professionalism.

## Acknowledgments

- Built with Flutter framework
- Uses Material Design components
- Inspired by modern business quoting workflows

 <img width="1080" height="2400" alt="Screenshot_20251109-155907" src="https://github.com/user-attachments/assets/91c55f0b-cb98-4e37-a488-2fdda4999e8d" />

