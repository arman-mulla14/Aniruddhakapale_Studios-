import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ContentManagerScreen extends StatefulWidget {
  const ContentManagerScreen({super.key});

  @override
  State<ContentManagerScreen> createState() => _ContentManagerScreenState();
}

class _ContentManagerScreenState extends State<ContentManagerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  List<XFile> _selectedImages = [];

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
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

  Future<void> _uploadNewStory() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick at least one image!')));
      return;
    }

    setState(() => _isUploading = true);
    
    try {
      List<String> imageUrls = [];
      for (var image in _selectedImages) {
        String url = await _uploadFile(image, 'stories');
        imageUrls.add(url);
      }
      
      await FirebaseFirestore.instance.collection('stories').add({
        'title': _titleController.text.isNotEmpty ? _titleController.text : 'New Chapter',
        'subtitle': _subtitleController.text,
        'description': _descriptionController.text,
        'images': imageUrls,
        'order': DateTime.now().millisecondsSinceEpoch,
      });
      
      setState(() {
        _titleController.clear();
        _subtitleController.clear();
        _descriptionController.clear();
        _selectedImages = [];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showEditStoryDialog(String docId, Map<String, dynamic> data) {
    final TextEditingController editTitleController = TextEditingController(text: data['title']);
    final TextEditingController editSubtitleController = TextEditingController(text: data['subtitle']);
    final TextEditingController editDescriptionController = TextEditingController(text: data['description']);
    List<dynamic> existingImages = List.from(data['images'] ?? []);
    List<XFile> newImagesToUpload = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF202020),
              title: const Text('Edit Story Chapter', style: TextStyle(color: Color(0xFFD4AF37))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editTitleController,
                      decoration: const InputDecoration(labelText: 'Title', filled: true, fillColor: Color(0xFF171717)),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: editSubtitleController,
                      decoration: const InputDecoration(labelText: 'Subtitle', filled: true, fillColor: Color(0xFF171717)),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: editDescriptionController,
                      decoration: const InputDecoration(labelText: 'Description', filled: true, fillColor: Color(0xFF171717)),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Current Images', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: existingImages.map((url) {
                        return Stack(
                          children: [
                            Image.network(url, width: 60, height: 60, fit: BoxFit.cover),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    existingImages.remove(url);
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
                      onPressed: () async {
                        final List<XFile> images = await _picker.pickMultiImage();
                        if (images.isNotEmpty) {
                          setDialogState(() {
                            newImagesToUpload.addAll(images);
                          });
                        }
                      },
                      icon: const Icon(Icons.add_a_photo, color: Colors.black),
                      label: Text('Add New Images (${newImagesToUpload.length})', style: const TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
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
                    // Upload new files
                    List<String> finalImages = List<String>.from(existingImages);
                    for (var file in newImagesToUpload) {
                      String url = await _uploadFile(file, 'stories');
                      finalImages.add(url);
                    }

                    await FirebaseFirestore.instance.collection('stories').doc(docId).update({
                      'title': editTitleController.text,
                      'subtitle': editSubtitleController.text,
                      'description': editDescriptionController.text,
                      'images': finalImages,
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story Chapter Updated!')));
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

  Future<void> _deleteStory(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        title: const Text('Delete Chapter', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to delete this story chapter?', style: TextStyle(color: Colors.white)),
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
      await FirebaseFirestore.instance.collection('stories').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Story Chapter Deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Stories', style: TextStyle(color: Color(0xFFD4AF37))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add New Story Chapter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Chapter Title (e.g., Chapter 7)', filled: true, fillColor: Color(0xFF202020)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(labelText: 'Subtitle', filled: true, fillColor: Color(0xFF202020)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description', filled: true, fillColor: Color(0xFF202020)),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate, color: Colors.black),
                  label: const Text('Select Images', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('${_selectedImages.length} image(s) selected', style: const TextStyle(color: Colors.white54)),
                )
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadNewStory,
              icon: _isUploading ? const CircularProgressIndicator(color: Colors.black) : const Icon(Icons.upload, color: Colors.black),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Story', style: const TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Existing Story Chapters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const Divider(color: Colors.white24, height: 20),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('stories').orderBy('order', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('No stories in database yet.', style: TextStyle(color: Colors.white54));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final List<dynamic> images = data['images'] ?? [];
                    return Card(
                      color: const Color(0xFF202020),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: images.isNotEmpty 
                            ? Image.network(images.first, width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.book, color: Color(0xFFD4AF37)),
                        title: Text(data['title'] ?? 'Chapter', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(data['subtitle'] ?? '', style: const TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditStoryDialog(doc.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStory(doc.id),
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
