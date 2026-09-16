import re

with open('lib/screens/seller_page.dart', 'r') as f:
    content = f.read()

imports = """
import '../services/shilpi_ai_service.dart';
import '../widgets/empty_state.dart';
"""
# insert at top
content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';" + imports)

with open('lib/screens/seller_page.dart', 'w') as f:
    f.write(content)
