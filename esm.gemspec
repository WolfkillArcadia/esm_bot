lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "esm/version"

Gem::Specification.new do |spec|
  spec.name          = "esm_bot"
  spec.version       = ESM::VERSION
  spec.authors       = ["Bryan Dingman"]
  spec.email         = ["bsdingman@gmail.com"]

  spec.summary       = %q{ Exile Server Manager }
  spec.homepage      = "https://github.com/bsdingman/esm_bot"

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bsdingman/esm_bot"
  spec.metadata["changelog_uri"] = "https://github.com/bsdingman/esm_bot"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Release
  spec.add_dependency "actionview"
  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"
  spec.add_dependency "discordrb"
  spec.add_dependency "dotiw"
  spec.add_dependency "httparty"
  spec.add_dependency "i18n"
  spec.add_dependency "otr-activerecord"
  spec.add_dependency "pg"
  spec.add_dependency "puma"
  spec.add_dependency "steam-condenser"
  spec.add_dependency "symmetric-encryption"
  spec.add_dependency "zeitwerk"

  # Development Only
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "dotenv"
  # spec.add_development_dependency "debase"
  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "faye-websocket"
  spec.add_development_dependency "memory_profiler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rerun"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-wait"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "ruby-prof"
  # spec.add_development_dependency "ruby-debug-ide"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "steam_web_api"
  spec.add_development_dependency "yard"
end
