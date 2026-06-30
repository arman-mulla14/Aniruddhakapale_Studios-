import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  bool _isConfirming = false;

  void _showAcceptDialog(BuildContext context, String queryId, Map<String, dynamic> queryData) {
    final TextEditingController totalController = TextEditingController();
    final TextEditingController advanceController = TextEditingController();
    final TextEditingController phoneController = TextEditingController(text: queryData['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF202020),
              title: const Text('Accept Booking', style: TextStyle(color: Color(0xFFD4AF37))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Client: ${queryData['names']}', style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Verify Phone Number', filled: true, fillColor: Color(0xFF171717)),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Package Amount (₹)', filled: true, fillColor: Color(0xFF171717)),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: advanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Advance Paid (₹)', filled: true, fillColor: Color(0xFF171717)),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isConfirming ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                  onPressed: _isConfirming
                      ? null
                      : () async {
                          setDialogState(() => _isConfirming = true);

                          final double total = double.tryParse(totalController.text) ?? 0;
                          final double advance = double.tryParse(advanceController.text) ?? 0;
                          final double pending = total - advance;

                          try {
                            // 1. Create order
                            await FirebaseFirestore.instance.collection('orders').add({
                              'clientName': queryData['names'],
                              'email': queryData['email'],
                              'phone': phoneController.text,
                              'location': queryData['eventDetails'],
                              'totalAmount': total,
                              'pendingAmount': pending,
                              'date': DateTime.now().toIso8601String(),
                              'status': 'Confirmed',
                            });

                            // 2. Delete query
                            await FirebaseFirestore.instance.collection('queries').doc(queryId).delete();

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Booking Confirmed! Moved to Orders.')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error accepting booking: $e')),
                            );
                          } finally {
                            setDialogState(() => _isConfirming = false);
                          }
                        },
                  child: _isConfirming
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('Confirm Order', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests', style: TextStyle(color: Color(0xFFD4AF37))),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('queries').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }
          final queries = snapshot.data?.docs ?? [];

          if (queries.isEmpty) {
            return const Center(child: Text('No pending booking requests.'));
          }

          return ListView.builder(
            itemCount: queries.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final queryDoc = queries[index];
              final query = queryDoc.data() as Map<String, dynamic>;
              return Card(
                color: const Color(0xFF202020),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(query['names'] ?? 'Unknown', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)))),
                          const Chip(label: Text('Pending', style: TextStyle(color: Colors.black, fontSize: 10)), backgroundColor: Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${query['email'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                      if (query['phone'] != null) Text('Phone: ${query['phone']}', style: const TextStyle(color: Colors.white70)),
                      Text('Event Details: ${query['eventDetails'] ?? 'N/A'}', style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      const Text('Story:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(query['story'] ?? 'N/A', style: const TextStyle(color: Colors.white54)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                          onPressed: () => _showAcceptDialog(context, queryDoc.id, query),
                          child: const Text('Accept & Confirm Booking', style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
