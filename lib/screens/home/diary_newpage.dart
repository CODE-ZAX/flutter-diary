import 'dart:convert';

import 'package:everyday_chronicles/controllers/diary_controller.dart';
import 'package:everyday_chronicles/models/diary_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class DiaryEditorScreen extends StatefulWidget {
  final DiaryModel? existingPage;
  const DiaryEditorScreen({this.existingPage, super.key});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  late quill.QuillController _controller;
  final titleController = TextEditingController();
  final focusNode = FocusNode();
  final diaryController = Get.find<DiaryController>();

  @override
  void initState() {
    super.initState();

    if (widget.existingPage != null) {
      titleController.text = widget.existingPage!.title;

      try {
        final delta = Delta.fromJson(jsonDecode(widget.existingPage!.content));
        _controller = quill.QuillController(
          document: quill.Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = quill.QuillController.basic();
        _controller.document.insert(0, widget.existingPage!.content);
      }
    } else {
      _controller = quill.QuillController.basic();
    }
  }

  void _saveDiaryPage(BuildContext context) {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar("Validation Error", "Title cannot be empty");
      return;
    }

    final delta = _controller.document.toDelta();
    final contentJson = jsonEncode(delta);
    final markdown = _controller.document.toPlainText();

    final now = DateTime.now();
    final newPage = DiaryModel(
      id: widget.existingPage?.id ?? const Uuid().v4(),
      title: title,
      content: contentJson,
      markdownContent: markdown,
      createdAt: widget.existingPage?.createdAt ?? now,
      lastEdited: now,
    );

    if (widget.existingPage == null) {
      diaryController.addDiaryPage(newPage);
    } else {
      diaryController.updateDiaryPage(newPage);
    }

    Navigator.of(context).pop(); // close editor screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.existingPage == null ? "New Diary Page" : "Edit Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize),
            tooltip: 'Summarize Page',
            onPressed: () async {
              final text = _controller.document.toPlainText().trim();

              if (text.split(RegExp(r'\s+')).length <= 20) {
                Get.snackbar("Too Short",
                    "Please write at least 20 words to summarize.");
                return;
              }

              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              final summary = await diaryController.summarizeDiary(text);
              Navigator.of(context).pop(); // close loading dialog

              if (summary == null) {
                Get.snackbar("Error", "Failed to summarize diary entry.");
                return;
              }

              Get.dialog(
                AlertDialog(
                  title: const Text("Summary"),
                  content: SelectableText(summary),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: summary));
                        Get.snackbar("Copied", "Summary copied to clipboard.");
                        Navigator.of(context).pop();
                      },
                      child: const Text("Copy"),
                    ),
                    TextButton(
                      onPressed: () => () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveDiaryPage(context);
            },
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
              ),
              focusNode: focusNode,
              scrollController: ScrollController(),
            ),
          ),
          quill.QuillToolbar.simple(
            configurations: quill.QuillSimpleToolbarConfigurations(
              controller: _controller,
              showHeaderStyle: true,
              showListNumbers: true,
              showListBullets: true,
              showLink: true,
              showUndo: true,
              showRedo: true,
              showBoldButton: false,
              showItalicButton: false,
              showUnderLineButton: false,
              showStrikeThrough: false,
              showFontFamily: false,
              showFontSize: false,
              showBackgroundColorButton: false,
              showColorButton: false,
              showAlignmentButtons: false,
              showDirection: false,
              showJustifyAlignment: false,
              showCenterAlignment: false,
              showRightAlignment: false,
              showClearFormat: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: false,
              showInlineCode: false,
              embedButtons: [], // remove image support
            ),
          )
        ],
      ),
    );
  }
}
