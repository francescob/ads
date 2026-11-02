# frozen_string_literal: true

# Development-only gem (see Gemfile)
return unless defined?(RailsAiContext)

RailsAiContext.configure do |config|
  # Introspector preset:
  #   :standard — 8 core introspectors (schema, models, routes, jobs, gems, conventions, controllers, tests)
  #   :full     — all 21 introspectors (adds views, turbo, auth, API, config, assets, devops, etc.)
  # config.preset = :standard

  # Or cherry-pick individual introspectors:
  # config.introspectors += %i[views turbo auth api]

  # Models to exclude from introspection
  # config.excluded_models += %w[AdminUser InternalThing]

  # Paths to exclude from code search
  # config.excluded_paths += %w[vendor/bundle]

  # Context mode for generated files (CLAUDE.md, .cursorrules, etc.)
  # :compact — smart, ≤150 lines, references MCP tools for details (default)
  # :full    — dumps everything into context files (good for small apps <30 models)
  # config.context_mode = :compact

  # Max lines for CLAUDE.md in compact mode
  # config.claude_max_lines = 150

  # Max response size for MCP tool results (chars). Safety net for large apps.
  # config.max_tool_response_chars = 120_000

  # Live reload: auto-invalidate MCP tool caches on file changes
  # :auto (default) — enable if `listen` gem is available
  # true  — enable, raise if `listen` is missing
  # false — disable entirely
  # config.live_reload = :auto
  # config.live_reload_debounce = 1.5  # seconds

  # Auto-mount HTTP MCP endpoint at /mcp
  # config.auto_mount = false
  # config.http_path  = "/mcp"
  # config.http_port  = 6029
end
