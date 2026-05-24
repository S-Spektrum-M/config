generate-clang-format() {
    cat << 'EOF' > .clang-format
BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 120
AccessModifierOffset: -4
AllowShortFunctionsOnASingleLine: None
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: false
BinPackArguments: false
BinPackParameters: false
FixNamespaceComments: true
IncludeBlocks: Regroup
IndentCaseLabels: true
SortIncludes: true
IncludeCategories:
  - Regex:           '^<[a-z0-9_]+\.h>$'
    Priority:        1
  - Regex:           '^<sys/.*'
    Priority:        1
  - Regex:           '^<[a-z0-9_]+>$'
    Priority:        2
  - Regex:           '^<.*'
    Priority:        3
  - Regex:           '^("catalyst/.*"|<catalyst/.*>)'
    Priority:        4
EOF
    echo "Generated .clang-format in the current directory."
}

generate-clang-tidy() {
    cat << 'EOF' > .clang-tidy
---
# Enable checks based on styleguide.md requirements
# We keep the base set from the previous configuration but refine it to match the new rules.
Checks: >
  -*,
  bugprone-*,
  cppcoreguidelines-*,
  modernize-*,
  performance-*,
  readability-*,
  google-explicit-constructor,
  google-build-using-namespace,
  misc-definitions-in-headers,
  misc-unused-parameters,
  misc-unused-alias-decls,
  clang-analyzer-*,
  -cppcoreguidelines-pro-bounds-array-to-pointer-decay,
  -cppcoreguidelines-pro-bounds-pointer-arithmetic,
  -cppcoreguidelines-pro-type-vararg,
  -modernize-use-trailing-return-type,
  -readability-braces-around-statements,
  -readability-implicit-bool-conversion,
  -readability-identifier-length,
  -llvm-header-guard

# Terminate if errors are found
WarningsAsErrors: "*"

CheckOptions:
  # Check that 'override' is added to overridden virtual functions
  - key:             modernize-use-override.IgnoreDestructors
    value:           'false'

  # Suggest using 'using' instead of 'typedef'
  - key:             modernize-use-using.IgnoreMacros
    value:           'false'

  # --- Naming Conventions (from styleguide.md) ---
  - key: readability-function-cognitive-complexity.Threshold
    value: 50

  # Types (Classes, Structs, Enums): PascalCase (CamelCase)
  # "Suffix _t is disallowed" - Implicitly enforced by CamelCase (usually)
  - key:             readability-identifier-naming.ClassCase
    value:           CamelCase
  - key:             readability-identifier-naming.StructCase
    value:           CamelCase
  - key:             readability-identifier-naming.EnumCase
    value:           CamelCase
  - key:             readability-identifier-naming.TypedefCase
    value:           CamelCase
  - key:             readability-identifier-naming.TypeAliasCase
    value:           CamelCase

  # Functions & Methods: camelCase (camelBack)
  - key:             readability-identifier-naming.FunctionCase
    value:           camelBack
  - key:             readability-identifier-naming.MethodCase
    value:           camelBack

  # Variables: snake_case (lower_case)
  - key:             readability-identifier-naming.VariableCase
    value:           lower_case
  - key:             readability-identifier-naming.ParameterCase
    value:           lower_case
  - key:             readability-identifier-naming.MemberCase
    value:           lower_case

  # Constants & constexpr: SCREAMING_CASE (UPPER_CASE)
  - key:             readability-identifier-naming.GlobalConstantCase
    value:           UPPER_CASE
  - key:             readability-identifier-naming.ConstexprVariableCase
    value:           UPPER_CASE
  - key:             readability-identifier-naming.MacroDefinitionCase
    value:           UPPER_CASE

  # Template Parameters: PascalCase_T
  - key:             readability-identifier-naming.TemplateParameterCase
    value:           CamelCase
  - key:             readability-identifier-naming.TemplateParameterSuffix
    value:           _T

  # Namespaces: lower case
  - key:             readability-identifier-naming.NamespaceCase
    value:           lower_case

# Don't lint third-party headers found in system includes
HeaderFilterRegex: 'src/.*|include/.*'
---
EOF
    echo "Generated .clang-tidy in the current directory."
}
