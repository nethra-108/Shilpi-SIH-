import sys
import glob
import os

def check_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    in_string = False
    string_char = ''
    escape = False
    
    braces = 0
    parens = 0
    brackets = 0
    
    for i, char in enumerate(content):
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
            if char == '{': braces += 1
            elif char == '}': braces -= 1
            elif char == '(': parens += 1
            elif char == ')': parens -= 1
            elif char == '[': brackets += 1
            elif char == ']': brackets -= 1
            
            if braces < 0 or parens < 0 or brackets < 0:
                print(f"{filepath} syntax unbalanced! braces:{braces} parens:{parens} brackets:{brackets} near char {i}")
                return False
                
    if braces != 0 or parens != 0 or brackets != 0:
        print(f"{filepath} syntax unbalanced! end braces:{braces} parens:{parens} brackets:{brackets}")
        return False
        
    return True

all_good = True
for f in glob.glob('lib/**/*.dart', recursive=True):
    if not check_file(f):
        all_good = False

if all_good:
    print("All syntax is perfectly balanced!")
    sys.exit(0)
else:
    sys.exit(1)
