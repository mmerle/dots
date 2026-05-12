;; extends

; template literal language comments:
([
  (variable_declarator
    (comment) @injection.language
    value: (template_string) @injection.content)

  (assignment_expression
    (comment) @injection.language
    right: (template_string) @injection.content)

  (arguments
    (comment) @injection.language
    (template_string) @injection.content)

  (return_statement
    (comment) @injection.language
    (template_string) @injection.content)
]
  (#lua-match? @injection.language "^/%*%s*[%w_-]+%s*%*/$")
  (#gsub! @injection.language "^/%*%s*([%w_-]+)%s*%*/$" "%1")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children))
