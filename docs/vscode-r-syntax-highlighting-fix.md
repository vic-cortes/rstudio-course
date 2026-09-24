# Arreglo del resaltado de sintaxis de R en VS Code

Diagnóstico y pasos para replicar, en otro equipo, el arreglo del resaltado de sintaxis (syntax highlighting) de archivos `.R` en VS Code — funciones, variables y constantes en MAYÚSCULAS coloreadas de forma consistente con Python, más el pipe `|>` y las llamadas a `library()`/`setwd()` igualadas al color de `list`.

Hecho sobre: VS Code 1.130.0 · `REditorSupport.r` 2.8.8 · `REditorSupport.r-syntax` 0.1.4 · tema `One Dark Darker`.

## Qué se veía roto

Los archivos `.R` se veían casi monocromáticos: solo los parámetros de las funciones tenían color. Keywords, strings, comentarios, llamadas a función y variables se mostraban todos con el mismo color de texto por defecto.

## Las tres causas reales

1. **Un override de color apuntaba a un scope que ya no existe.** El workspace ya traía un `.vscode/settings.json` con una regla de color para el scope `variable.function.r`. La versión instalada del grammar (`r-syntax` 0.1.4) ya no usa ese nombre para llamadas a función — ahora usa `meta.function-call.r` (y `support.function.r` para funciones "builtin" como `library`). La regla nunca coincidía con nada.

2. **Las variables planas nunca tuvieron scope propio.** El grammar de R no incluye ningún patrón para "identificador genérico" — solo cubre keywords, strings, comentarios, llamadas a función, constantes y operadores. Esto es normal en la mayoría de los grammars (Python tampoco lo hace vía TextMate). Lo que sí coloreaba los parámetros era el *semantic highlighting* del R language server (`languageserver`), que solo soporta ese tipo de token — de ahí la impresión de que "solo los parámetros" tenían color.

3. **R no reconoce MAYÚSCULAS como constantes.** A diferencia de Python (`constant.other.caps.python`), el grammar de R no tiene ninguna regla para tratar identificadores como `MAX_RETRIES` como constantes. Hubo que agregar esa regla a mano con una extensión local.

4. **`library`/`setwd` comparten scope con todas las demás funciones builtin.** Ambos caen en el mismo scope (`support.function.r`) que `print`, `paste`, `sum`, etc. — no hay forma de darles un color distinto *solo a ellos* vía tema, porque cualquier regla de color para ese scope pinta a todas las funciones builtin por igual. Para que se vean como `list` (que sí tiene su propio scope, `storage.type.r`) hubo que inyectarles ese mismo scope con la extensión local.

## Cómo quedó coloreado

| Elemento | Scope de TextMate | Color | Origen |
|---|---|---|---|
| Llamada a función | `meta.function-call.r` | `#52ADF2` | Override agregado |
| Función builtin (`print`, `paste`, etc.) | `support.function.r` | `#52ADF2` | Override agregado |
| Variable | `source.r` (sin scope propio) | `#EF596F` | Override agregado |
| Constante en `MAYUSCULA` | `constant.other.caps.r` | `#F5C876` | Extensión local nueva |
| `list` / `library` / `setwd` | `storage.type.r` | `#D55FDE` | `list` ya funcionaba; `library`/`setwd` — extensión local nueva |
| Pipe `\|>` | `keyword.operator.pipe.r` | `#D55FDE` | Override agregado |
| String | `string.quoted.double.r` | `#98C379` | Ya funcionaba |
| Comentario | `comment.line.number-sign.r` | `#7F848E` | Ya funcionaba |
| `TRUE` / `FALSE` / `NA` | `constant.language.r` | (sin cambio) | Ya funcionaba |

Los colores de función, variable y constante se eligieron para igualar los que usa Pylance en archivos `.py` con el mismo tema. `library`/`setwd`/`|>` se igualaron al morado que ya traía `list` de fábrica (vía la regla genérica `storage` del tema).

## Cómo replicarlo en otro equipo

Requisitos: VS Code con el comando `code` disponible en la terminal (Command Palette → *Shell Command: Install 'code' command in PATH* si falta), y Node.js/`npx` instalado.

### 1. Colorear llamadas a función y variables

Edita (o crea) `.vscode/settings.json` en el proyecto. Si tu tema no se llama exactamente `One Dark Darker`, cambia esa clave por el valor exacto de tu `workbench.colorTheme` — o quita el nivel `"[Nombre del tema]"` para que aplique a cualquier tema.

```json
{
  "editor.tokenColorCustomizations": {
    "[One Dark Darker]": {
      "textMateRules": [
        {
          "scope": [
            "variable.function.r",
            "meta.function-call.r",
            "support.function.r"
          ],
          "settings": { "foreground": "#52ADF2" }
        },
        {
          "scope": ["source.r"],
          "settings": { "foreground": "#EF596F" }
        },
        {
          "scope": ["constant.other.caps.r"],
          "settings": { "foreground": "#F5C876" }
        },
        {
          "scope": ["storage.type.r", "keyword.operator.pipe.r"],
          "settings": { "foreground": "#D55FDE" }
        }
      ]
    }
  }
}
```

Aplica con `Cmd+Shift+P` → *Developer: Reload Window* (basta con esto, es solo configuración).

### 2. La extensión local (constantes en MAYÚSCULAS + `library`/`setwd`)

R no tiene ninguna regla nativa para esto, así que se agrega vía una **extensión local mínima** que inyecta patrones nuevos al grammar de R sin tocar el archivo original de `r-syntax` (así sobrevive a sus actualizaciones). Esta misma extensión cubre dos cosas: las constantes en MAYÚSCULAS y el reetiquetado de `library`/`setwd` al scope `storage.type.r` (el de `list`).

El código fuente vive en este mismo repo, en [`.vscode/r-caps-constant/`](../.vscode/r-caps-constant/) — al clonar el repo en otro equipo ya lo tienes, solo falta empaquetarlo e instalarlo (paso 3).

`package.json`:

```json
{
  "name": "r-caps-constant",
  "displayName": "R ALL_CAPS Constant Highlight (local)",
  "description": "Adds a constant.other.caps.r scope to ALL_CAPS identifiers in R files, and a storage.type.r scope to library()/setwd() calls, mirroring conventions the base r-syntax grammar doesn't cover.",
  "version": "0.0.5",
  "publisher": "local",
  "engines": { "vscode": "^1.75.0" },
  "contributes": {
    "grammars": [
      {
        "scopeName": "constant.caps.r.injection",
        "path": "./syntaxes/r-caps-injection.json",
        "injectTo": ["source.r"]
      }
    ]
  }
}
```

`syntaxes/r-caps-injection.json`:

```json
{
  "scopeName": "constant.caps.r.injection",
  "injectionSelector": "L:source.r - (string, comment, support.constant)",
  "patterns": [
    {
      "name": "constant.other.caps.r",
      "match": "\\b(?!(?:TRUE|FALSE|NULL|NA|NA_integer_|NA_real_|NA_complex_|NA_character_|Inf|NaN)\\b)[A-Z][A-Z0-9_]+\\b"
    },
    {
      "name": "storage.type.r",
      "match": "\\b(?:library|setwd)\\b(?=\\s*\\()"
    }
  ]
}
```

**Por qué así y no de otra forma:**

- Se probó excluir `TRUE`/`FALSE`/`NA` por scope (`-constant`) en vez de por regex, pero no funciona — en el momento en que el tokenizer decide qué regla gana, esas palabras todavía no tienen ningún scope asignado, así que excluir "donde ya hay scope constant" no excluye nada. Por eso la exclusión va directo en el regex con un lookahead negativo, y la prioridad de inyección es `L:` (alta) para que aplique de forma consistente en cualquier posición del archivo, incluyendo asignaciones a nivel raíz.
- Para `library`/`setwd` se reutiliza literalmente el scope `storage.type.r` (el mismo que ya usa `list`) en vez de inventar un scope nuevo y ponerle un color a mano — así quedan automáticamente del mismo color que `list` sin duplicar la definición del color en dos lugares, y si el tema cambia algún día ese color, los tres se actualizan juntos. El lookahead `(?=\s*\()` evita que matchee la palabra si no es una llamada a función (por ejemplo, si alguna vez se usara `library` como nombre de variable).

### 3. Empaquetar e instalar

Desde la raíz del repo, ya clonado en el equipo nuevo. **No empaquetes/instales estando dentro de `~/.vscode/extensions`** — VS Code se pisa a sí mismo si lo haces desde ahí (por eso el `.vsix` se genera en `/tmp`, no junto al código fuente):

```sh
cd .vscode/r-caps-constant

npx --yes @vscode/vsce package --allow-missing-repository --no-dependencies \
  -o /tmp/r-caps-constant-0.0.5.vsix

code --install-extension /tmp/r-caps-constant-0.0.5.vsix
```

Cierra VS Code por completo (`Cmd+Q`, no solo la ventana) y vuelve a abrirlo — una extensión nueva solo se detecta al iniciar, "Reload Window" no basta.

### 4. Verificar

`Cmd+Shift+P` → *Developer: Inspect Editor Tokens and Scopes*, y haz clic sobre distintos elementos de un archivo `.R` para confirmar el scope y el color aplicado (campo `foreground` en el popup).

```r
library(dplyr)
setwd("./code/finance/")

greet <- function(name) {
  message <- paste("Hola,", name) |>
    toupper()
  # saluda
  print(message)
}
MAX_RETRIES <- 3
is_ready <- TRUE
```

Esperado: `library`/`setwd` en morado (igual que `list`), el pipe `|>` también en ese morado, `greet`/`paste`/`toupper`/`print` en azul, `message` en rojo, `MAX_RETRIES` en amarillo, `TRUE` sin cambio, el comentario en gris itálica, el string en verde.

## Notas para el futuro

- Si más adelante cambias el regex o los colores de `.vscode/r-caps-constant/syntaxes/r-caps-injection.json`, sube el número de `version` en `.vscode/r-caps-constant/package.json` antes de reempaquetar — si no, VS Code puede asumir que ya la tiene instalada y no aplicar el cambio.
- Si una futura actualización de `REditorSupport.r-syntax` vuelve a cambiar los nombres de scope (como pasó con `variable.function.r` → `meta.function-call.r`), usa *Inspect Editor Tokens and Scopes* para encontrar el nuevo nombre y actualiza el paso 1.
- `.vscode/settings.json` y el código fuente de la extensión (`.vscode/r-caps-constant/`) ya viven en el repo, así que clonarlo los trae automáticamente. Lo único que no viaja con el repo es el **paquete instalado en VS Code**: hay que repetir el paso 3 (empaquetar + `code --install-extension`) en cada equipo nuevo, y de nuevo después de `git pull` si `r-caps-constant/` cambió.
