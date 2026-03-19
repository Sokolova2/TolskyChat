# frozen_string_literal: true

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'bootstrap', to: 'bootstrap.bundle.min.js'
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@picmo/popup-picker", to: "@picmo--popup-picker.js" # @5.8.5
pin "picmo" # @5.8.5
pin_all_from "app/javascript/classes", under: "classes"
pin "classes/RichText", to: "classes/RichText.js"