import re

with open('lib/screens/checkout_screen.dart', 'r') as f:
    content = f.read()

content = re.sub(r"const OrdersPage\(\)", "OrdersPage()", content)

with open('lib/screens/checkout_screen.dart', 'w') as f:
    f.write(content)
