import re

with open('lib/screens/cart_page.dart', 'r') as f:
    content = f.read()

old_net = r"Image\.network\(product\.imagePath!, fit: BoxFit\.contain\)"
new_net = """Image.network(
                                                product.imagePath!, 
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) => Center(child: Text(product.emoji, style: const TextStyle(fontSize: 26))),
                                              )"""
content = re.sub(old_net, new_net, content)

with open('lib/screens/cart_page.dart', 'w') as f:
    f.write(content)
