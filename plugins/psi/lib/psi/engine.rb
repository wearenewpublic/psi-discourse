# frozen_string_literal: true

# Rails engine for the PSI plugin, providing namespaced routing and controller isolation.
module Psi
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace Psi
  end
end
