import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:everyday_chronicles/controllers/diary_controller.dart';
import 'package:everyday_chronicles/models/diary_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class DiaryEditorScreen extends StatefulWidget {
  final DiaryModel? existingPage;
  const DiaryEditorScreen({this.existingPage, super.key});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  final _controller = quill.QuillController.basic();
  final titleController = TextEditingController();
  // final picker = ImagePicker();
  final focusNode = FocusNode();
  final storage = FirebaseStorage.instance;
  final diaryController = Get.find<DiaryController>();

  @override
  void initState() {
    super.initState();

    if (widget.existingPage != null) {
      titleController.text = widget.existingPage!.title;
      _controller.document = quill.Document.fromJson(
        quill.Document.fromDelta(
          Delta()..insert(widget.existingPage!.content),
        ).toDelta().toJson(),
      );
    }
  }

  Future<String> _uploadImage(String imageFile) async {
    final File myFile = File(imageFile);
    final ref = storage.ref().child('diary_images/${const Uuid().v4()}');
    await ref.putFile(myFile);
    return await ref.getDownloadURL();
  }

  Future<void> _insertImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final imageUrl = await _uploadImage(pickedFile.path);
    final index = _controller.selection.baseOffset;
    final length = _controller.selection.extentOffset - index;

    _controller.replaceText(
      index,
      length,
      quill.BlockEmbed.image(imageUrl),
      TextSelection.collapsed(offset: index + 1),
    );
  }

  void _saveDiaryPage() {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar("Validation Error", "Title cannot be empty");
      return;
    }

    final content = _controller.document.toPlainText();
    final now = DateTime.now();
    final newPage = DiaryModel(
      id: widget.existingPage?.id ?? const Uuid().v4(),
      title: title,
      content: content,
      createdAt: widget.existingPage?.createdAt ?? now,
      lastEdited: now,
    );

    if (widget.existingPage == null) {
      diaryController.addDiaryPage(newPage);
    } else {
      diaryController.updateDiaryPage(newPage);
    }

    Get.back(); // Go back to diary list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.existingPage == null ? "New Diary Page" : "Edit Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _insertImage,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDiaryPage,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Enter title...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: quill.QuillEditor(
              configurations: quill.QuillEditorConfigurations(
                controller: _controller,
                scrollable: true,
                autoFocus: true,
                expands: true,
                padding: const EdgeInsets.all(12),
                placeholder: "Start writing your page...",
                embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                customStyles: const quill.DefaultStyles(
                  h1: quill.DefaultTextBlockStyle(
                    TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    quill.VerticalSpacing(16, 8),
                    quill.VerticalSpacing(16, 8),
                    null,
                  ),
                ),
              ),
              focusNode: focusNode,
              scrollController: ScrollController(),
            ),
          ),
          quill.QuillToolbar.simple(
            configurations: quill.QuillSimpleToolbarConfigurations(
              controller: _controller,
              embedButtons: FlutterQuillEmbeds.toolbarButtons(
                imageButtonOptions: QuillToolbarImageButtonOptions(
                    imageButtonConfigurations: QuillToolbarImageConfigurations(
                        onImageInsertCallback: (str, opt) =>
                            _uploadImage(str))),
              ),
            ),
          )
        ],
      ),
    );
  }
}
