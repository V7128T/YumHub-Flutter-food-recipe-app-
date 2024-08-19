import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  final List<bool> _isExpanded = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange[50]!, Colors.orange[100]!],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            "YumHub",
            style: GoogleFonts.chivo(
              textStyle: TextStyle(
                fontSize: 28.0,
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildExpansionPanel(
                    0,
                    "Terms of Use",
                    Icons.description,
                    [
                      _buildListTile("Acceptance of Terms",
                          "By subscribing to any of the spoonacular API plans offered on our website or on rapidapi.com (previously mashape.com) or to a custom plan to which you are invited, you the API subscriber (“you”) confirm that you have read and agree to the Terms of Use outlined below. Failure to honor these terms will result in your use of the spoonacular API being suspended and/or permanently blocked."),
                      _buildListTile("License",
                          "A spoonacular API subscription grants you a nonexclusive, non-transferable license to use the spoonacular API on a month-by-month basis dependent on your payment of the monthly fee associated with your subscription (and any additional charges due to exceeding the number of calls per day covered by your subscription) and on your agreement to respect these terms. You will be charged every month until you cancel your subscription under My Console > Plan/Billing or on RapidAPI's website, depending on where you subscribed."),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpansionPanel(
                    1,
                    "Features",
                    Icons.star,
                    [
                      _buildListTile("5,000+ recipes", null),
                      _buildListTile("Cost breakdown per servings", null),
                      _buildListTile("Related recipes", null),
                      _buildListTile("Advanced Search", null),
                      _buildListTile("Save Recipes & Ingredients", null),
                      _buildListTile("Categorized Recipes", null),
                      _buildListTile(
                          "Simulation of linking with third-party online grocery app.",
                          null),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildExpansionPanel(
                    2,
                    "App Information",
                    Icons.info,
                    [
                      _buildListTile(
                          "App created with Flutter bloc library", null),
                      _buildListTile("Open-source Spoonacular API", null,
                          isLink: true),
                    ],
                  ),
                  // Add some extra space at the bottom to ensure scrolling reveals the full gradient
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionPanel(
      int index, String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withOpacity(0.9), // Make cards slightly transparent
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.orange[800]),
          title: Text(
            title,
            style: GoogleFonts.chivo(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Theme.of(context).primaryColor, // Changed title color
            ),
          ),
          children: children,
          onExpansionChanged: (isExpanded) {
            setState(() {
              _isExpanded[index] = isExpanded;
            });
          },
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String? subtitle, {bool isLink = false}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isLink ? Colors.blue[700] : Colors.black87,
          fontWeight: isLink ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.black54),
            )
          : null,
      onTap: isLink
          ? () async {
              const url = "https://spoonacular.com/food-api";
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch $url')),
                );
              }
            }
          : null,
    );
  }
}
