import os
import re

def extract_class(content, class_name):
    # Find start of class
    pattern = rf"(class {class_name}\b.*?(?:extends|implements).*?\{{)"
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        return None, content
    
    start_idx = match.start()
    
    # We need to find the matching closing brace
    brace_count = 0
    in_string = False
    string_char = ''
    escape = False
    
    end_idx = -1
    for i in range(start_idx, len(content)):
        char = content[i]
        
        if escape:
            escape = False
            continue
            
        if char == '\\':
            escape = True
            continue
            
        if char in ["'", '"'] and not escape:
            if not in_string:
                in_string = True
                string_char = char
            elif string_char == char:
                in_string = False
            continue
            
        if not in_string:
            if char == '{':
                brace_count += 1
            elif char == '}':
                brace_count -= 1
                if brace_count == 0:
                    end_idx = i + 1
                    break
                    
    if end_idx == -1:
        return None, content
        
    class_content = content[start_idx:end_idx]
    new_content = content[:start_idx] + content[end_idx:]
    return class_content, new_content

with open('lib/main.dart', 'r') as f:
    main_content = f.read()

classes_to_extract = {
    'ExplorePage': 'explore_page.dart',
    'WishlistPage': 'wishlist_page.dart',
    'CartPage': 'cart_page.dart',
    'OrdersPage': 'orders_page.dart',
    'SearchPage': 'search_page.dart',
    'SellerPage': 'seller_page.dart'
}

extracted = {}
for class_name, filename in classes_to_extract.items():
    # Also extract any private state classes associated
    state_class_name = f"_{class_name}State"
    
    cls_content, main_content = extract_class(main_content, class_name)
    if cls_content:
        state_content, main_content = extract_class(main_content, state_class_name)
        if state_content:
            cls_content += "\n\n" + state_content
        extracted[filename] = cls_content

# Now write them to lib/screens/ and add imports to main.dart
imports = []
for filename, content in extracted.items():
    imports.append(f"import 'screens/{filename}';")
    
    # Generate the file with necessary imports
    file_content = """import 'package:flutter/material.dart';
import '../constants.dart';
import '../theme/colors.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../widgets/product_card.dart';
import '../repositories/product_repository.dart';
import '../repositories/cart_repository.dart';
import '../repositories/wishlist_repository.dart';
import '../repositories/order_repository.dart';
import '../services/language_service.dart';
import 'checkout_screen.dart';
import 'add_product_screen.dart';
import 'seller_orders_page.dart';

""" + content
    with open(f"lib/screens/{filename}", 'w') as f:
        f.write(file_content)

# Add imports to main.dart
import_string = "\n".join(imports)
main_content = main_content.replace("import 'package:flutter/material.dart';", f"import 'package:flutter/material.dart';\n{import_string}")

with open('lib/main.dart', 'w') as f:
    f.write(main_content)

print(f"Extracted: {list(extracted.keys())}")
