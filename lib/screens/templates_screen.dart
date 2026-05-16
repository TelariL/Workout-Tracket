import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../database/app_database.dart';
import '../repository/training_repository.dart';
import 'template_detail_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final db = AppDatabase.instance;

  late TrainingRepository repo;

  List<Template> templates = [];

  @override
  void initState() {
    super.initState();

    repo = TrainingRepository(db);

    _load();
  }

  Future<void> _load() async {
    templates = await repo.getTemplates();

    setState(() {});
  }

  Future<void> _createTemplate() async {
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Новый шаблон",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Название шаблона",
                  filled: true,
                  fillColor: const Color(0xFFF0F0F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();

                    if (name.isEmpty) return;

                    final id = await repo.createTemplate(
                      name: name,
                    );

                    if (!mounted) return;

                    Navigator.pop(context);

                    _load();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TemplateDetailScreen(
                          templateId: id,
                          templateName: name,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF363636),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Создать",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      child: SafeArea(
        top: false,

        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 8,
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),


            const SizedBox(height: 20),

            Text(
              "Шаблоны",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: templates.isEmpty
                  ? Center(
                child: Text(
                  "Нет шаблонов",
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 6,
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),

                      child: Dismissible(
                        key: ValueKey("template_${template.id}"),
                        direction: DismissDirection.endToStart,

                        background: Container(),

                        secondaryBackground: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),

                        confirmDismiss: (_) async {
                          await repo.deleteTemplate(template.id);

                          _load();

                          return true;
                        },

                        child: InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialWithModalsPageRoute(
                                builder: (_) => TemplateDetailScreen(
                                  templateId: template.id,
                                  templateName: template.name,
                                ),
                              ),
                            );

                            _load();
                          },

                          child: Container(
                            height: 60,
                            color: const Color(0xFFF0F0F0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        template.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF363636),
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 317,
                height: 60,
                child: ElevatedButton(
                  onPressed: _createTemplate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(
                      color: Color(0xFF363636),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Создать шаблон",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF363636),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}