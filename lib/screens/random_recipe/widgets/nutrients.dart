import 'package:flutter/material.dart';
import '../../../models/nutrients.dart';
import 'package:google_fonts/google_fonts.dart';

class CompactNutritionWidget extends StatefulWidget {
  final Nutrient nutrient;

  const CompactNutritionWidget({super.key, required this.nutrient});

  @override
  _CompactNutritionWidgetState createState() => _CompactNutritionWidgetState();
}

class _CompactNutritionWidgetState extends State<CompactNutritionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainNutrients(),
        const SizedBox(height: 10),
        _buildExpandableSection(),
      ],
    );
  }

  Widget _buildMainNutrients() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNutrientCard(Icons.local_fire_department, "Calories",
            widget.nutrient.calories, "kcal"),
        _buildNutrientCard(Icons.grain, "Carbs", widget.nutrient.carbs, "g"),
        _buildNutrientCard(
            Icons.accessibility_new, "Protein", widget.nutrient.protein, "g"),
        _buildNutrientCard(Icons.opacity, "Fat", widget.nutrient.fat, "g"),
      ],
    );
  }

  Widget _buildNutrientCard(
      IconData icon, String label, String value, String unit) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: Colors.orange[800], size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style:
                  GoogleFonts.chivo(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              "$value$unit",
              style: GoogleFonts.chivo(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection() {
    return ExpansionTile(
      title: Text(
        "Detailed Nutrition Information",
        style: GoogleFonts.chivo(
          textStyle: TextStyle(
            fontSize: 16,
            color: Colors.orange[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      children: [
        _buildNutrientSection("Nutrients to Monitor", widget.nutrient.bad),
        const SizedBox(height: 10),
        _buildNutrientSection("Beneficial Nutrients", widget.nutrient.good),
      ],
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
    );
  }

  Widget _buildNutrientSection(String title, List<Needs> nutrients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: GoogleFonts.chivo(
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ...nutrients.map((nutri) => _buildNutrientTile(nutri)).toList(),
      ],
    );
  }

  Widget _buildNutrientTile(Needs nutrient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              nutrient.name,
              style:
                  GoogleFonts.chivo(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              nutrient.amount,
              style: GoogleFonts.chivo(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: LinearProgressIndicator(
              value: double.parse(nutrient.percentOfDailyNeeds) / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[800]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${nutrient.percentOfDailyNeeds}%",
            style: GoogleFonts.chivo(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
