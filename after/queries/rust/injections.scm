;extends

(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @_macro_name)
    (identifier) @_macro_name
  ]
  (token_tree) @injection.content
  (#any-of? @_macro_name "v")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "html")
  (#set! injection.include-children))
