import re
import textwrap
from pathlib import Path

# ============================================================
# Configuration: Set your input and output file names here
# ============================================================
WORKFOLDER = "pyParser/"
INPUT_LUA_FILE = WORKFOLDER + "beliefs.lua"
OUTPUT_LUA_FILE = WORKFOLDER + "output.lua"


def strip_lua_comments(lua_code: str) -> str:
    """
    Remove Lua single-line (--) and multi-line (--[[ ... ]]) comments
    while preserving content inside string literals.
    """
    result = []
    i = 0
    n = len(lua_code)

    in_string = False
    string_delim = None  # Either '"' or "'"
    escape = False
    in_block_comment = False

    while i < n:
        char = lua_code[i]
        next_two = lua_code[i:i+2]
        next_four = lua_code[i:i+4]

        # ---------------------------------------------------------
        # Handle block comments: --[[ ... ]]
        # ---------------------------------------------------------
        if not in_string and not in_block_comment and next_four == "--[[":
            in_block_comment = True
            i += 4
            continue

        if in_block_comment:
            if lua_code[i:i+2] == "]]":
                in_block_comment = False
                i += 2
            else:
                i += 1
            continue

        # ---------------------------------------------------------
        # Handle single-line comments: --
        # ---------------------------------------------------------
        if not in_string and next_two == "--":
            # Skip until the end of the line
            while i < n and lua_code[i] != '\n':
                i += 1
            continue

        # ---------------------------------------------------------
        # Handle string literals
        # ---------------------------------------------------------
        if in_string:
            result.append(char)
            if escape:
                escape = False
            elif char == '\\':
                escape = True
            elif char == string_delim:
                in_string = False
            i += 1
            continue

        # Enter string literal
        if char in ('"', "'"):
            in_string = True
            string_delim = char
            result.append(char)
            i += 1
            continue

        # Normal character
        result.append(char)
        i += 1

    return ''.join(result)


# ------------------------------------------------------------
# Utility: Extract balanced Lua tables
# ------------------------------------------------------------
def extract_traits(lua_code: str):
    """
    Extract all `this.<id> = { ... }` blocks using brace matching.
    Returns a list of tuples: (trait_id, block_content).
    """
    traits = []
    pattern = re.compile(r"this\.([A-Za-z0-9_]+)\s*=\s*{")

    for match in pattern.finditer(lua_code):
        trait_id = match.group(1)
        start = match.end() - 1  # position of '{'
        brace_count = 0
        i = start

        while i < len(lua_code):
            if lua_code[i] == "{":
                brace_count += 1
            elif lua_code[i] == "}":
                brace_count -= 1
                if brace_count == 0:
                    end = i
                    traits.append((trait_id, lua_code[start : end + 1]))
                    break
            i += 1

    return traits


# ------------------------------------------------------------
# Description Formatting
# ------------------------------------------------------------
def format_description(desc: str, width: int = 90) -> str:
    """
    Format the description into Lua concatenated strings while
    preserving newline escape sequences.
    """
    # Replace internal double quotes with single quotes for Lua compatibility
    desc = desc.replace('"', "'")

    # Split text while preserving newline tokens (e.g., \n, \n\n)
    tokens = re.split(r'(\\n+)', desc)

    lines = ['    description = (']
    first_segment = True

    for token in tokens:
        if not token:
            continue

        # Handle newline tokens
        if re.fullmatch(r'\\n+', token):
            if not first_segment:
                lines[-1] += ' ..'
            lines.append(f'        "{token}"')
            first_segment = False
            continue

        # Wrap text segments without altering newline semantics
        wrapped_segments = textwrap.wrap(token.strip(), width=width)

        for segment in wrapped_segments:
            if not first_segment:
                lines[-1] += ' ..'
            lines.append(f'        "{segment} "')
            first_segment = False

    lines.append('    ),')
    return "\n".join(lines)


# ------------------------------------------------------------
# Parse mwscript.addSpell
# ------------------------------------------------------------
def parse_spells(block: str):
    """
    Convert mwscript.addSpell calls to selfSpells:add syntax.
    """
    spells = re.findall(
        r'mwscript\.addSpell\s*{\s*reference\s*=\s*tes3\.player\s*,\s*spell\s*=\s*"([^"]+)"\s*}',
        block,
        re.DOTALL,
    )
    return [f'        selfSpells:add("{spell}")' for spell in spells]


# ------------------------------------------------------------
# Parse tes3.modStatistic
# ------------------------------------------------------------
def parse_mod_statistics(block: str):
    """
    Convert tes3.modStatistic calls to attribute/skill base modifications.
    """
    pattern = re.compile(r"tes3\.modStatistic\s*\(\s*{(.*?)}\s*\)", re.DOTALL)

    results = []

    for match in pattern.finditer(block):
        content = match.group(1)

        attr_match = re.search(
            r"attribute\s*=\s*tes3\.attribute\.([A-Za-z0-9_]+)", content
        )
        skill_match = re.search(r"skill\s*=\s*tes3\.skill\.([A-Za-z0-9_]+)", content)
        value_match = re.search(r"value\s*=\s*(-?\d+)", content)

        if not value_match:
            continue

        value = int(value_match.group(1))
        operator = "+" if value > 0 else "-"
        abs_value = abs(value)

        if attr_match:
            attr = attr_match.group(1)
            results.append(
                f"        attrs.{attr}.base        = attrs.{attr}.base {operator} {abs_value}"
            )
        elif skill_match:
            skill = skill_match.group(1)
            results.append(
                f"        skills.{skill}.base         = skills.{skill}.base {operator} {abs_value}"
            )

    return results


# ------------------------------------------------------------
# Parse checkDisabled
# ------------------------------------------------------------
def parse_check_disabled(block: str):
    """
    Convert race-based checkDisabled function to new API syntax.
    """
    match = re.search(
        r'local\s+race\s*=\s*tes3\.player\.object\.race\.id.*?return\s+race\s*~=\s*"([^"]+)"',
        block,
        re.DOTALL,
    )
    if match:
        race = match.group(1).lower()
        return (
            "    checkDisabled = function()\n"
            f"        return getRaceId(self) ~= races['{race}']\n"
            "    end"
        )
    return "    checkDisabled = function()\n" "        return false\n" "    end"


def extract_balanced(text: str, start_index: int, open_char='(', close_char=')'):
    """
    Extract text enclosed by balanced parentheses, respecting quoted strings.
    """
    depth = 0
    i = start_index
    in_string = False
    escape = False

    while i < len(text):
        char = text[i]

        if in_string:
            if escape:
                escape = False
            elif char == '\\':
                escape = True
            elif char == '"':
                in_string = False
        else:
            if char == '"':
                in_string = True
            elif char == open_char:
                depth += 1
            elif char == close_char:
                depth -= 1
                if depth == 0:
                    return text[start_index + 1:i], i
        i += 1

    raise ValueError("Unbalanced parentheses in Lua code in line:\n" + text)


def extract_description(block: str) -> str | None:
    """
    Extract the description from a Lua trait block while preserving
    escaped newline sequences (\\n).
    """
    # Locate the description assignment
    match = re.search(r'description\s*=\s*\(', block)
    if not match:
        return None

    # Extract the balanced parentheses content
    content, _ = extract_balanced(block, match.end() - 1)

    # Remove Lua comments (but not inside strings)
    content = re.sub(r'--.*', '', content)

    # Capture all Lua double-quoted strings, preserving escape sequences
    string_pattern = re.compile(r'"((?:\\.|[^"\\])*)"', re.DOTALL)
    parts = string_pattern.findall(content)

    if not parts:
        return None

    # Join parts while preserving escape sequences like \n
    description = ''.join(parts)

    # Unescape only escaped quotes, leaving \n intact
    description = description.replace('\\"', '"')

    # IMPORTANT: Do NOT normalize whitespace or replace \\n
    return description.strip()


# ------------------------------------------------------------
# Convert a Single Trait
# ------------------------------------------------------------
def convert_trait(trait_id: str, block: str) -> str:
    # Extract name
    name_match = re.search(r'name\s*=\s*"([^"]+)"', block)
    name = name_match.group(1) if name_match else trait_id

    # Extract and format description
    desc_raw = extract_description(block)
    if desc_raw:
        description = format_description(desc_raw)
    else:
        print(f"Warning: No description found for trait '{trait_id}'.")
        description = '    description = (""),'

    # Extract doOnce block
    do_once_match = re.search(
        r'doOnce\s*=\s*function\(\)\s*(.*?)\s*end',
        block,
        re.DOTALL
    )
    do_once_content = do_once_match.group(1) if do_once_match else ""

    spells = parse_spells(do_once_content)
    stats = parse_mod_statistics(do_once_content)

    do_once_lines = ["    doOnce = function()"]
    do_once_lines.extend(spells)

    if spells and stats:
        do_once_lines.append("")

    do_once_lines.extend(stats)
    do_once_lines.append("    end,")

    # Extract checkDisabled
    check_disabled = parse_check_disabled(block)

    # Assemble final trait
    trait_lines = [
        "I.CharacterTraits.addTrait {",
        f'    id = "{trait_id}",',
        "    type = traitType,",
        f'    name = "{name}",',
        description,
        *do_once_lines,
        check_disabled,
        "}"
    ]

    return "\n".join(trait_lines)


# ------------------------------------------------------------
# Convert Entire Lua File
# ------------------------------------------------------------
def convert_lua_file(input_path: str, output_path: str):
    # Read the original Lua file
    lua_code = Path(input_path).read_text(encoding="utf-8")

    # Remove all comments while preserving strings
    lua_code = strip_lua_comments(lua_code)

    # Continue with the rest of your parsing logic
    traits = extract_traits(lua_code)

    if not traits:
        raise ValueError("No traits found in the Lua file.")

    converted_traits = [
        convert_trait(trait_id, block) for trait_id, block in traits
    ]

    output_code = "\n\n".join(converted_traits)
    Path(output_path).write_text(output_code, encoding="utf-8")

    print(f"Conversion complete: {len(traits)} trait(s) written to '{output_path}'.")


# ------------------------------------------------------------
# Script Entry Point
# ------------------------------------------------------------
if __name__ == "__main__":
    convert_lua_file(INPUT_LUA_FILE, OUTPUT_LUA_FILE)
