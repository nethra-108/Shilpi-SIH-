import re

with open('lib/screens/checkout_screen.dart', 'r') as f:
    content = f.read()

content = content.replace("import '../main.dart';", "import 'orders_page.dart';")

with open('lib/screens/checkout_screen.dart', 'w') as f:
    f.write(content)
