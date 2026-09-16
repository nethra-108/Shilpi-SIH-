import re

with open('lib/screens/cart_page.dart', 'r') as f:
    content = f.read()

if "import 'dart:io';" not in content:
    content = "import 'dart:io';\n" + content

with open('lib/screens/cart_page.dart', 'w') as f:
    f.write(content)
