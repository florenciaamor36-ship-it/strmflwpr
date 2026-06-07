import os

with open('index.html', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Cambiar el título de la página como prueba definitiva
for i, line in enumerate(lines):
    if '<title>' in line:
        lines[i] = '    <title>StreamFlow Pro | SaaS Edition</title>\n'
        break

with open('index.html', 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Patch test done")
