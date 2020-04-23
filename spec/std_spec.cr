require "spec"
{% if flag?(:win32) %}
  # This list gives an overview over which specs are currently working on win32.
  #
  # See spec/generate_windows_spec.sh for details.
  require "./win32_std_spec.cr"
{% elsif flag?(:wasm32) %}
  # This list gives an overview over which specs are currently working on wasm32.
  #
  # See spec/generate_wasm_spec.sh for details.
  require "./wasm32_std_spec.cr"
{% else %}
  require "./std/**"
{% end %}
