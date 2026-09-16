import re

with open('lib/screens/premium_home_screen.dart', 'r') as f:
    content = f.read()

old_net = r"background: Image\.network\(imageUrl, fit: BoxFit\.cover\),"
new_net = """background: Image.network(
                imageUrl, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))),
              ),"""
content = re.sub(old_net, new_net, content)

with open('lib/screens/premium_home_screen.dart', 'w') as f:
    f.write(content)
