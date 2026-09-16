import re

with open('lib/widgets/product_card.dart', 'r') as f:
    content = f.read()

old_net = r"Image\.network\(product\.imagePath!, fit: BoxFit\.cover\)"
new_net = """Image.network(
                              product.imagePath!, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 32),
                                    const SizedBox(height: 4),
                                    Text(product.emoji, style: const TextStyle(fontSize: 24)),
                                  ],
                                ),
                              ),
                            )"""
content = re.sub(old_net, new_net, content)

with open('lib/widgets/product_card.dart', 'w') as f:
    f.write(content)
