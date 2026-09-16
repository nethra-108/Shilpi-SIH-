import re

with open('lib/screens/premium_home_screen.dart', 'r') as f:
    content = f.read()

# Artisan row
old1 = r"Text\(artisan\['name'\]!, style: const TextStyle\(fontWeight: FontWeight\.bold, fontSize: 15, color: Color\(0xFF1B4332\)\), maxLines: 1\)"
new1 = "Text(artisan['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B4332)), maxLines: 1, overflow: TextOverflow.ellipsis)"
content = re.sub(old1, new1, content)

old2 = r"Text\(LanguageService\.instance\.tr\(artisan\['craft_key'\]!\), style: const TextStyle\(color: Colors\.grey, fontSize: 13\), maxLines: 1\)"
new2 = "Text(LanguageService.instance.tr(artisan['craft_key']!), style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)"
content = re.sub(old2, new2, content)

# AllArtisansScreen
old3 = r"Text\(artisan\['name'\]!, style: const TextStyle\(fontWeight: FontWeight\.bold, fontSize: 15, color: Color\(0xFF1B4332\)\)\)"
new3 = "Text(artisan['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B4332)), maxLines: 1, overflow: TextOverflow.ellipsis)"
content = re.sub(old3, new3, content)

old4 = r"Text\(artisan\['craft'\]!, style: const TextStyle\(color: Colors\.grey, fontSize: 13\)\)"
new4 = "Text(artisan['craft']!, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)"
content = re.sub(old4, new4, content)

with open('lib/screens/premium_home_screen.dart', 'w') as f:
    f.write(content)
