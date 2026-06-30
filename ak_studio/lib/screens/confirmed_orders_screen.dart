import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_history_screen.dart';

class ConfirmedOrdersScreen extends StatefulWidget {
  const ConfirmedOrdersScreen({super.key});

  @override
  State<ConfirmedOrdersScreen> createState() => _ConfirmedOrdersScreenState();
}

class _ConfirmedOrdersScreenState extends State<ConfirmedOrdersScreen> {
  void _showCreateOrderDialog(BuildContext context, {String? docId, Map<String, dynamic>? initialData}) {
    final TextEditingController nameController = TextEditingController(text: initialData?['clientName'] ?? '');
    final TextEditingController phoneController = TextEditingController(text: initialData?['phone'] ?? '');
    final TextEditingController locationController = TextEditingController(text: initialData?['location'] ?? '');
    final TextEditingController dateController = TextEditingController(text: initialData?['eventDate'] ?? '');
    final TextEditingController totalController = TextEditingController(text: initialData != null ? (initialData['totalAmount'] ?? 0).toStringAsFixed(0) : '');
    final TextEditingController advanceController = TextEditingController(
        text: initialData != null ? ((initialData['totalAmount'] ?? 0) - (initialData['pendingAmount'] ?? 0)).toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF202020),
          title: Text(docId == null ? 'Add Manual Order' : 'Edit Order', style: const TextStyle(color: Color(0xFFD4AF37))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Client Name', filled: true, fillColor: Color(0xFF171717)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', filled: true, fillColor: Color(0xFF171717)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location / Venue', filled: true, fillColor: Color(0xFF171717)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Event Date (e.g. Oct 2025)', filled: true, fillColor: Color(0xFF171717)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Amount (₹)', filled: true, fillColor: Color(0xFF171717)),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: advanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Advance Paid (₹)', filled: true, fillColor: Color(0xFF171717)),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: () async {
                if (nameController.text.isEmpty || totalController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name and Total Amount are required!')),
                  );
                  return;
                }

                final double total = double.tryParse(totalController.text) ?? 0;
                final double advance = double.tryParse(advanceController.text) ?? 0;
                final double pending = total - advance;

                final data = {
                  'clientName': nameController.text,
                  'phone': phoneController.text,
                  'location': locationController.text,
                  'eventDate': dateController.text,
                  'totalAmount': total,
                  'pendingAmount': pending,
                  'status': 'Confirmed',
                };

                if (docId == null) {
                  data['date'] = DateTime.now().toIso8601String();
                  await FirebaseFirestore.instance.collection('orders').add(data);
                } else {
                  await FirebaseFirestore.instance.collection('orders').doc(docId).update(data);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(docId == null ? 'Order Created!' : 'Order Updated!')));
              },
              child: const Text('Save Order', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteOrder(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        title: const Text('Delete Order', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to delete this order? This action cannot be undone.', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('orders').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order Deleted.')));
    }
  }

  Future<void> _markPaymentDone(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        title: const Text('Payment Completed', style: TextStyle(color: Color(0xFFD4AF37))),
        content: const Text('Are you sure payment is fully completed? This order will be moved to history.', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({
        'pendingAmount': 0,
        'status': 'Completed',
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order moved to History.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmed Orders', style: TextStyle(color: Color(0xFFD4AF37))),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Order History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'Confirmed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }
          final orders = snapshot.data?.docs ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('No active confirmed orders.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final doc = orders[index];
              final order = doc.data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFF202020),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['clientName'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Location: ${order['location'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                      if (order['phone'] != null && order['phone'].toString().isNotEmpty)
                        Text('Phone: ${order['phone']}', style: const TextStyle(color: Colors.white54)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pending: ₹${order['pendingAmount'] ?? 0}',
                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'Total: ₹${order['totalAmount'] ?? 0}',
                            style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.payment, color: Colors.green, size: 18),
                            label: const Text('Payment Done', style: TextStyle(color: Colors.green)),
                            onPressed: () => _markPaymentDone(doc.id),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                            tooltip: 'Edit',
                            onPressed: () => _showCreateOrderDialog(context, docId: doc.id, initialData: order),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            tooltip: 'Delete',
                            onPressed: () => _deleteOrder(doc.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: () => _showCreateOrderDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
