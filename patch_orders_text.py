import re

with open('lib/screens/orders_page.dart', 'r') as f:
    content = f.read()

old = r"""                            Text\(
                              '\$\{item\.product\.emoji\} \$\{item\.product\.name\} × \$\{item\.quantity\}',
                              style: const TextStyle\(
                                  fontSize: 13, fontWeight: FontWeight\.w500\),
                            \),"""

new = """                            Expanded(
                              child: Text(
                                '${item.product.emoji} ${item.product.name} × ${item.quantity}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),"""

content = re.sub(old, new, content)

with open('lib/screens/orders_page.dart', 'w') as f:
    f.write(content)
