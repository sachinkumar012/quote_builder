import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const QuoteBuilderApp());
}

class QuoteBuilderApp extends StatelessWidget {
  const QuoteBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Quote Builder',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const QuoteBuilderHomePage(),
    );
  }
}

enum TaxMode { inclusive, exclusive }

enum QuoteStatus { draft, sent, accepted }

class QuoteBuilderHomePage extends StatefulWidget {
  const QuoteBuilderHomePage({super.key});

  @override
  State<QuoteBuilderHomePage> createState() => _QuoteBuilderHomePageState();
}

class _QuoteBuilderHomePageState extends State<QuoteBuilderHomePage> {
  // Client info
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientAddressController =
      TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  // Line items
  final List<LineItem> _lineItems = [LineItem()];

  // Tax mode
  TaxMode _taxMode = TaxMode.exclusive;

  // Quote status
  QuoteStatus _quoteStatus = QuoteStatus.draft;

  // Currency formatter for rupees
  final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  void _addLineItem() {
    setState(() {
      _lineItems.add(LineItem());
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems.removeAt(index);
    });
  }

  double get _subtotal {
    return _lineItems.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get _taxAmount {
    if (_taxMode == TaxMode.inclusive) {
      return _lineItems.fold(0.0, (sum, item) => sum + item.taxAmount);
    } else {
      return _lineItems.fold(0.0, (sum, item) => sum + item.taxAmount);
    }
  }

  double get _grandTotal {
    if (_taxMode == TaxMode.inclusive) {
      return _subtotal;
    } else {
      return _subtotal + _taxAmount;
    }
  }

  void _saveQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final quoteData = {
      'clientName': _clientNameController.text,
      'clientAddress': _clientAddressController.text,
      'reference': _referenceController.text,
      'taxMode': _taxMode.toString(),
      'quoteStatus': _quoteStatus.toString(),
      'lineItems': _lineItems
          .map(
            (item) => {
              'name': item.name,
              'quantity': item.quantity,
              'rate': item.rate,
              'discount': item.discount,
              'taxPercent': item.taxPercent,
            },
          )
          .toList(),
      'subtotal': _subtotal,
      'taxAmount': _taxAmount,
      'grandTotal': _grandTotal,
      'savedAt': DateTime.now().toIso8601String(),
    };

    final quotes = prefs.getStringList('quotes') ?? [];
    quotes.add(jsonEncode(quoteData));
    await prefs.setStringList('quotes', quotes);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Quote saved successfully!')));
  }

  void _sendQuote() {
    setState(() {
      _quoteStatus = QuoteStatus.sent;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Quote sent successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product Quote Builder'),
            SizedBox(height: 4),
            Text(
              'Easily create and preview detailed business quotations. Add products, apply discounts, calculate totals instantly, and download a polished quote — all in one place.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        toolbarHeight: 80,
        actions: [
          PopupMenuButton<QuoteStatus>(
            onSelected: (QuoteStatus status) {
              setState(() {
                _quoteStatus = status;
              });
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<QuoteStatus>>[
                  const PopupMenuItem<QuoteStatus>(
                    value: QuoteStatus.draft,
                    child: Text('Draft'),
                  ),
                  const PopupMenuItem<QuoteStatus>(
                    value: QuoteStatus.sent,
                    child: Text('Sent'),
                  ),
                  const PopupMenuItem<QuoteStatus>(
                    value: QuoteStatus.accepted,
                    child: Text('Accepted'),
                  ),
                ],
            child: Chip(
              label: Text(
                'Status: ${_quoteStatus.toString().split('.').last.toUpperCase()}',
              ),
              backgroundColor: _getStatusColor(),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop layout: form and preview side by side
            return Row(
              children: [
                Expanded(flex: 1, child: _buildForm()),
                const VerticalDivider(),
                Expanded(flex: 1, child: _buildPreview()),
              ],
            );
          } else {
            // Mobile layout: form and preview stacked
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildFormMobile(),
                  const Divider(),
                  _buildPreviewMobile(),
                  const Divider(),
                  _buildFooter(),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _saveQuote,
            tooltip: 'Save Quote',
            child: const Icon(Icons.save),
            heroTag: 'save',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _sendQuote,
            tooltip: 'Send Quote',
            child: const Icon(Icons.send),
            heroTag: 'send',
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_quoteStatus) {
      case QuoteStatus.draft:
        return Colors.grey;
      case QuoteStatus.sent:
        return Colors.blue;
      case QuoteStatus.accepted:
        return Colors.green;
    }
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clientNameController,
            decoration: const InputDecoration(
              labelText: 'Client Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clientAddressController,
            decoration: const InputDecoration(
              labelText: 'Client Address',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Reference',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Line Items',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addLineItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Tax Mode:'),
              const SizedBox(width: 16),
              DropdownButton<TaxMode>(
                value: _taxMode,
                onChanged: (TaxMode? newValue) {
                  setState(() {
                    _taxMode = newValue!;
                  });
                },
                items: TaxMode.values.map<DropdownMenuItem<TaxMode>>((
                  TaxMode value,
                ) {
                  return DropdownMenuItem<TaxMode>(
                    value: value,
                    child: Text(
                      value == TaxMode.inclusive
                          ? 'Tax Inclusive'
                          : 'Tax Exclusive',
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _lineItems.length,
              itemBuilder: (context, index) {
                return LineItemWidget(
                  item: _lineItems[index],
                  onRemove: index > 0 ? () => _removeLineItem(index) : null,
                  onChanged: () => setState(() {}),
                  currencyFormat: _currencyFormat,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text(_currencyFormat.format(_subtotal)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tax (${_taxMode == TaxMode.inclusive ? 'Included' : 'Excluded'}):',
                    ),
                    Text(_currencyFormat.format(_taxAmount)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _currencyFormat.format(_grandTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        children: [
          Text(
            '© 2025 Product Quote Builder — All Rights Reserved.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Built to simplify and speed up your quoting process with accuracy and professionalism.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Contact Sales & Support',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Phone: +91 93184 96221',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          Text(
            'Email: sachin123@gmail.com',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Follow us for product updates, best practices, and feature announcements:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            '[Facebook] | [LinkedIn] | [X (Twitter)] | [Instagram]',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormMobile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clientNameController,
            decoration: const InputDecoration(
              labelText: 'Client Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clientAddressController,
            decoration: const InputDecoration(
              labelText: 'Client Address',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Reference',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Line Items',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addLineItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Tax Mode:'),
              const SizedBox(width: 16),
              DropdownButton<TaxMode>(
                value: _taxMode,
                onChanged: (TaxMode? newValue) {
                  setState(() {
                    _taxMode = newValue!;
                  });
                },
                items: TaxMode.values.map<DropdownMenuItem<TaxMode>>((
                  TaxMode value,
                ) {
                  return DropdownMenuItem<TaxMode>(
                    value: value,
                    child: Text(
                      value == TaxMode.inclusive
                          ? 'Tax Inclusive'
                          : 'Tax Exclusive',
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _lineItems.length,
            itemBuilder: (context, index) {
              return LineItemWidget(
                item: _lineItems[index],
                onRemove: index > 0 ? () => _removeLineItem(index) : null,
                onChanged: () => setState(() {}),
                currencyFormat: _currencyFormat,
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text(_currencyFormat.format(_subtotal)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tax (${_taxMode == TaxMode.inclusive ? 'Included' : 'Excluded'}):',
                    ),
                    Text(_currencyFormat.format(_taxAmount)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _currencyFormat.format(_grandTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quote Preview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUOTE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Client: ${_clientNameController.text}'),
                    Text('Address: ${_clientAddressController.text}'),
                    Text('Reference: ${_referenceController.text}'),
                    const SizedBox(height: 16),
                    Text(
                      'Status: ${_quoteStatus.toString().split('.').last.toUpperCase()}',
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Items:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Table(
                      border: TableBorder.all(),
                      children: [
                        const TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Item',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Qty',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Rate',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Discount',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Tax %',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        ..._lineItems.map(
                          (item) => TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(item.name),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(item.quantity.toString()),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    _currencyFormat.format(item.rate),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    _currencyFormat.format(item.discount),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text('${item.taxPercent}%'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    _currencyFormat.format(item.total),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Subtotal: ${_currencyFormat.format(_subtotal)}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tax (${_taxMode == TaxMode.inclusive ? 'Included' : 'Excluded'}): ${_currencyFormat.format(_taxAmount)}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Grand Total: ${_currencyFormat.format(_grandTotal)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewMobile() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quote Preview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'QUOTE',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Client: ${_clientNameController.text}'),
                  Text('Address: ${_clientAddressController.text}'),
                  Text('Reference: ${_referenceController.text}'),
                  const SizedBox(height: 16),
                  Text(
                    'Status: ${_quoteStatus.toString().split('.').last.toUpperCase()}',
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Use ListView for mobile instead of table
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _lineItems.length,
                    itemBuilder: (context, index) {
                      final item = _lineItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name.isEmpty ? 'Unnamed Item' : item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Qty: ${item.quantity}'),
                                  Text(
                                    'Rate: ${_currencyFormat.format(item.rate)}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Discount: ${_currencyFormat.format(item.discount)}',
                                  ),
                                  Text('Tax: ${item.taxPercent}%'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Total: ${_currencyFormat.format(item.total)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Subtotal: ${_currencyFormat.format(_subtotal)}'),
                        const SizedBox(height: 8),
                        Text(
                          'Tax (${_taxMode == TaxMode.inclusive ? 'Included' : 'Excluded'}): ${_currencyFormat.format(_taxAmount)}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Grand Total: ${_currencyFormat.format(_grandTotal)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LineItem {
  String name = '';
  int quantity = 1;
  double rate = 0.0;
  double discount = 0.0;
  double taxPercent = 0.0;

  double get subtotal => (rate - discount) * quantity;
  double get taxAmount => subtotal * (taxPercent / 100);
  double get total => subtotal + taxAmount;
}

class LineItemWidget extends StatefulWidget {
  final LineItem item;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;
  final NumberFormat currencyFormat;

  const LineItemWidget({
    super.key,
    required this.item,
    this.onRemove,
    required this.onChanged,
    required this.currencyFormat,
  });

  @override
  State<LineItemWidget> createState() => _LineItemWidgetState();
}

class _LineItemWidgetState extends State<LineItemWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _quantityController.text = widget.item.quantity.toString();
    _rateController.text = widget.item.rate.toStringAsFixed(2);
    _discountController.text = widget.item.discount.toStringAsFixed(2);
    _taxController.text = widget.item.taxPercent.toStringAsFixed(2);

    _nameController.addListener(_updateItem);
    _quantityController.addListener(_updateItem);
    _rateController.addListener(_updateItem);
    _discountController.addListener(_updateItem);
    _taxController.addListener(_updateItem);
  }

  void _updateItem() {
    widget.item.name = _nameController.text;
    widget.item.quantity = int.tryParse(_quantityController.text) ?? 1;
    widget.item.rate = double.tryParse(_rateController.text) ?? 0.0;
    widget.item.discount = double.tryParse(_discountController.text) ?? 0.0;
    widget.item.taxPercent = double.tryParse(_taxController.text) ?? 0.0;
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product/Service Name - Full width
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product/Service Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Quantity and Rate in a row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    decoration: const InputDecoration(
                      labelText: 'Rate (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Discount and Tax in a row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _taxController,
                    decoration: const InputDecoration(
                      labelText: 'Tax %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total and Delete button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${widget.currencyFormat.format(widget.item.total)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Remove Item',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }
}
