# frozen_string_literal: true

Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.paths << Rails.root.join('node_modules/bootstrap/dist/js')
Rails.application.config.assets.precompile << 'bootstrap.bundle.min.js'

Rails.application.config.assets.paths << Rails.root.join("app", "assets", "fonts")
Rails.application.config.assets.precompile += %w( bootstrap-icons.woff bootstrap-icons.woff2 )
Rails.application.config.assets.precompile += %w( *.woff *.woff2 )

