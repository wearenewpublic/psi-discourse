# frozen_string_literal: true

module Psi
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace Psi
  end
end
