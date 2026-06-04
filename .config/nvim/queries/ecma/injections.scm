;; extends

; template literal language comments:
([
  (variable_declarator
    (comment) @injection.language
    value: (template_string
      (string_fragment) @injection.content))

  (assignment_expression
    (comment) @injection.language
    right: (template_string
      (string_fragment) @injection.content))

  (arguments
    (comment) @injection.language
    (template_string
      (string_fragment) @injection.content))

  (return_statement
    (comment) @injection.language
    (template_string
      (string_fragment) @injection.content))
]
  (#lua-match? @injection.language "^/%*%s*[%w_-]+%s*%*/$")
  (#gsub! @injection.language "^/%*%s*([%w_-]+)%s*%*/$" "%1")
  (#set! injection.combined)
  (#set! injection.include-children))

; tagged template literals:
(call_expression
  function: (identifier) @injection.language
  arguments: (template_string
    (string_fragment) @injection.content)
  (#set! injection.combined)
  (#set! injection.include-children))
