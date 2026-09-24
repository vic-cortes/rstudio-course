# r-caps-constant (local VS Code extension)

Extensión local (no publicada en el Marketplace) que agrega dos scopes de TextMate que el grammar `REditorSupport.r-syntax` no cubre:

- `constant.other.caps.r` en identificadores `EN_MAYUSCULAS` (constantes), igual que hace el grammar de Python.
- `storage.type.r` en llamadas a `library()`/`setwd()`, para que se vean del mismo color que `list` en vez del color genérico de función.

Ver el diagnóstico completo y el porqué de cada decisión en [`docs/vscode-r-syntax-highlighting-fix.md`](../../docs/vscode-r-syntax-highlighting-fix.md).

## Empaquetar e instalar

Desde **fuera** de `~/.vscode/extensions` (empaquetar/instalar directo desde ahí hace que VS Code se pise a sí mismo):

```sh
cd .vscode/r-caps-constant
npx --yes @vscode/vsce package --allow-missing-repository --no-dependencies \
  -o /tmp/r-caps-constant-$(node -p "require('./package.json').version").vsix

code --install-extension /tmp/r-caps-constant-$(node -p "require('./package.json').version").vsix
```

Cierra VS Code por completo (`Cmd+Q`) y vuelve a abrirlo — una extensión nueva o actualizada solo se detecta al iniciar.

## Al modificar el regex o agregar reglas

Sube el campo `version` en `package.json` antes de reempaquetar, o VS Code puede asumir que ya la tiene instalada y no aplicar el cambio.
