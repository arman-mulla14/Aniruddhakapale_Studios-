import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MomentsManagerScreen extends StatefulWidget {
  const MomentsManagerScreen({super.key});

  @override
  State<MomentsManagerScreen> createState() => _MomentsManagerScreenState();
}

class _MomentsManagerScreenState extends State<MomentsManagerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  XFile? _coverImage;
  List<XFile> _galleryImages = [];

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _coverImage = image);
    }
  }

  Future<void> _pickGalleryImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _galleryImages.addAll(images));
    }
  }
  
  Future<String> _uploadFile(XFile file, String folder) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + file.name;
    Reference ref = FirebaseStorage.instance.ref().child(folder).child(fileName);
    
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await ref.putData(bytes);
    } else {
      await ref.putFile(File(file.path));
    }
    
    return await ref.getDownloadURL();
  }

  Future<void> _uploadMoment() async {
    if (_titleController.text.isEmpty || _coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Cover Image are required!')));
      return;
    }

    setState(() => _isUploading = true);
    
    try {
      String coverUrl = await _uploadFile(_coverImage!, 'moments_covers');
      
      List<String> galleryUrls = [];
      for (var image in _galleryImages) {
        String url = await _uploadFile(image, 'moments_gallery');
        galleryUrls.add(url);
      }
      
      await FirebaseFirestore.instance.collection('moments').add({
        'title': _titleController.text,
        'location': _locationController.text,
        'date': _dateController.text,
        'description': _descriptionController.text,
        'coverImage': coverUrl,
        'galleryImages': galleryUrls,
        'order': DateTime.now().millisecondsSinceEpoch,
      });
      
      setState(() {
        _titleController.clear();
        _locationController.clear();
        _dateController.clear();
        _descriptionController.clear();
        _coverImage = null;
        _galleryImages = [];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moment uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showEditMomentDialog(String docId, Map<String, dynamic> data) {
    final TextEditingController editTitleController = TextEditingController(text: data['title']);
    final TextEditingController editLocationController = TextEditingController(text: data['location']);
    final TextEditingController editDateController = TextEditingController(text: data['date']);
    final TextEditingController editDescriptionController = TextEditingController(text: data['description']);
    String coverUrl = data['coverImage'] ?? '';
    List<dynamic> galleryUrls = List.from(data['galleryImages'] ?? []);
    
    XFile? newCover;
    List<XFile> newGallery = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF202020),
              title: const Text('Edit Moment', style: TextStyle(color: Color(0xFFD4AF37))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editTitleController,
                      decoration: const InputDecoration(labelText: 'Event Title', filled: true, fillColor: Color(0xFF171717)),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: editLocationController,
                            decoration: const InputDecoration(labelText: 'Location', filled: true, fillColor: Color(0xFF171717)),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: editDateController,
                            decoration: const InputDecoration(labelText: 'Date', filled: true, fillColor: Color(0xFF171717)),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: editDescriptionController,
                      decoration: const InputDecoration(labelText: 'Description', filled: true, fillColor: Color(0xFF171717)),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Cover Image', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    newCover != null
                        ? const Text('New Cover Selected', style: TextStyle(color: Colors.green))
                        : (coverUrl.isNotEmpty 
                            ? Image.network(coverUrl, height: 80, width: double.infinity, fit: BoxFit.cover)
                            : const Text('No Cover Image')),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () async {
                        final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
                        if (img != null) {
                          setDialogState(() => newCover = img);
                        }
                      },
                      child: const Text('Change Cover', style: TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Gallery Images', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: galleryUrls.map((url) {
                        return Stack(
                          children: [
                            Image.network(url, width: 60, height: 60, fit: BoxFit.cover),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    galleryUrls.remove(url);
                                  });
                                },
                                child: Container(
                                  color: Colors.black54,
                                  child: const Icon(Icons.close, color: Colors.red, size: 18),
                                ),
                              ),
                            )
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () async {
                        final List<XFile> imgs = await _picker.pickMultiImage();
                        if (imgs.isNotEmpty) {
                          setDialogState(() {
                            newGallery.addAll(imgs);
                          });
                        }
                      },
                      icon: const Icon(Icons.add_a_photo, color: Colors.black),
                      label: Text('Add New Photos (${newGallery.length})', style: const TextStyle(color: Colors.black)),
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
                    String finalCover = coverUrl;
                    if (newCover != null) {
                      finalCover = await _uploadFile(newCover!, 'moments_covers');
                    }

                    List<String> finalGallery = List<String>.from(galleryUrls);
                    for (var file in newGallery) {
                      String url = await _uploadFile(file, 'moments_gallery');
                      finalGallery.add(url);
                    }

                    await FirebaseFirestore.instance.collection('moments').doc(docId).update({
                      'title': editTitleController.text,
                      'location': editLocationController.text,
                      'date': editDateController.text,
                      'description': editDescriptionController.text,
                      'coverImage': finalCover,
                      'galleryImages': finalGallery,
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moment Updated!')));
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteMoment(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        title: const Text('Delete Moment', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to delete this event/moment from the website?', style: TextStyle(color: Colors.white)),
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
      await FirebaseFirestore.instance.collection('moments').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Moment Deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Moments', style: TextStyle(color: Color(0xFFD4AF37))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add New Moment / Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Event Title (e.g., The First Dance)', filled: true, fillColor: Color(0xFF202020)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location (e.g., Mumbai)', filled: true, fillColor: Color(0xFF202020)),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date (e.g., Oct 2025)', filled: true, fillColor: Color(0xFF202020)),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (Optional)', filled: true, fillColor: Color(0xFF202020)),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickCoverImage,
                  icon: const Icon(Icons.image, color: Colors.black),
                  label: const Text('Pick Cover Image', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text(_coverImage != null ? 'Cover Selected' : 'No Cover Selected', style: const TextStyle(color: Colors.white54))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickGalleryImages,
                  icon: const Icon(Icons.photo_library, color: Colors.black),
                  label: const Text('Pick Gallery Images', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(child: Text('${_galleryImages.length} Gallery Images Selected', style: const TextStyle(color: Colors.white54))),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadMoment,
              icon: _isUploading ? const CircularProgressIndicator(color: Colors.black) : const Icon(Icons.cloud_upload, color: Colors.black),
              label: Text(_isUploading ? 'Uploading Moment...' : 'Publish Moment to Website', style: const TextStyle(color: Colors.black, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Existing Moments / Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const Divider(color: Colors.white24, height: 20),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('moments').orderBy('order', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('No moments in database yet.', style: TextStyle(color: Colors.white54));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String? coverImage = data['coverImage'];
                    return Card(
                      color: const Color(0xFF202020),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: (coverImage != null && coverImage.isNotEmpty)
                            ? Image.network(coverImage, width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.image, color: Color(0xFFD4AF37)),
                        title: Text(data['title'] ?? 'Moment', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${data['location'] ?? ''} • ${data['date'] ?? ''}', style: const TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditMomentDialog(doc.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMoment(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
